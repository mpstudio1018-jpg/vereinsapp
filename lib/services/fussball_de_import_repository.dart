import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/fussball_de_match_dto.dart';

class FussballDeImportRepository {
  static const String _cachePrefix = 'fussball_de_schedule_cache_v2_';

  final http.Client _client;
  final String? _apiBaseUrl;

  FussballDeImportRepository({
    http.Client? client,
    this._apiBaseUrl,
  })  : _client = client ?? http.Client();

  Future<List<FussballDeMatchDto>> fetchTeamSchedule({
    required String teamId,
  }) async {
    try {
      final liveMatches = await _fetchLiveSchedule(teamId: teamId);
      if (liveMatches.isNotEmpty) {
        await _saveCache(teamId, liveMatches);
        return liveMatches;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('DFBnet live schedule fetch failed for $teamId: $error');
      }
    }

    final cachedMatches = await _loadCache(teamId);
    if (cachedMatches.isNotEmpty) {
      return cachedMatches;
    }

    throw Exception('DFBnet schedule request failed for team $teamId');
  }

  Future<List<FussballDeMatchDto>> _fetchLiveSchedule({
    required String teamId,
  }) async {
    final normalizedTeamId = teamId.trim();
    if (normalizedTeamId.isEmpty) {
      throw Exception('teamId is empty');
    }

    final candidateUris = <Uri>{
      if ((_apiBaseUrl?.trim() ?? '').isNotEmpty)
        Uri.parse('${_apiBaseUrl!.trim()}/teams/$normalizedTeamId/schedule'),
      Uri.parse('https://www.fussball.de/rest/spielplan?teamId=$normalizedTeamId'),
      Uri.parse('https://www.fussball.de/api/spielplan?teamId=$normalizedTeamId'),
      Uri.parse('https://www.fussball.de/dfbnet/spielplan?teamId=$normalizedTeamId'),
    };

    Object? lastError;
    for (final uri in candidateUris) {
      try {
        final response = await _client.get(
          uri,
          headers: const {
            'Accept': 'application/json, application/xml, text/xml, */*',
            'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
          },
        );

        if (response.statusCode < 200 || response.statusCode >= 300) {
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }

        final contentType = response.headers['content-type']?.toLowerCase() ?? '';
        final matches = contentType.contains('xml')
            ? _parseXmlSchedule(response.body, sourceUri: uri)
            : _parseJsonSchedule(response.body, sourceUri: uri);

        if (matches.isNotEmpty) {
          return matches;
        }

        lastError = 'No schedule data found at $uri';
      } catch (error) {
        lastError = error;
      }
    }

    throw Exception('DFBnet schedule fetch failed: $lastError');
  }

  List<FussballDeMatchDto> _parseJsonSchedule(String body, {required Uri sourceUri}) {
    final decoded = jsonDecode(body);
    final rawEntries = <dynamic>[];

    void addCandidates(dynamic value) {
      if (value is List) {
        rawEntries.addAll(value);
      } else if (value is Map<String, dynamic>) {
        for (final key in ['matches', 'games', 'schedule', 'data', 'items', 'entries', 'rows']) {
          final nested = value[key];
          if (nested is List) {
            rawEntries.addAll(nested);
          }
        }
      }
    }

    if (decoded is List) {
      rawEntries.addAll(decoded);
    } else if (decoded is Map<String, dynamic>) {
      addCandidates(decoded);
      final nestedObjects = decoded.values.whereType<Map<String, dynamic>>();
      for (final nested in nestedObjects) {
        addCandidates(nested);
      }
    }

    return rawEntries
        .whereType<Map>()
        .map((entry) => _mapDto(Map<String, dynamic>.from(entry), sourceUri: sourceUri))
        .whereType<FussballDeMatchDto>()
        .toList(growable: false);
  }

  List<FussballDeMatchDto> _parseXmlSchedule(String body, {required Uri sourceUri}) {
    final document = XmlDocument.parse(body);
    final matches = <FussballDeMatchDto>[];

    final matchNodes = <XmlElement>[
      ...document.findAllElements('match'),
      ...document.findAllElements('spiel'),
      ...document.findAllElements('game'),
      ...document.findAllElements('fixture'),
      ...document.findAllElements('row'),
    ];

    for (final node in matchNodes) {
      final dto = _mapDto(_xmlNodeToMap(node), sourceUri: sourceUri);
      if (dto != null) {
        matches.add(dto);
      }
    }

    return matches;
  }

  FussballDeMatchDto? _mapDto(Map<String, dynamic> json, {required Uri sourceUri}) {
    final home = _readString(
      json,
      keys: const ['homeTeam', 'home', 'teamHome', 'home_team', 'clubHome'],
      fallback: '',
    );
    final away = _readString(
      json,
      keys: const ['awayTeam', 'away', 'teamAway', 'away_team', 'clubAway'],
      fallback: '',
    );
    final venue = _readString(
      json,
      keys: const ['venue', 'location', 'stadium', 'place', 'sportplatz'],
      fallback: 'Sportanlage',
    );
    final matchId = _readString(
      json,
      keys: const ['matchId', 'match_id', 'spielnummer', 'id', 'number'],
      fallback: '',
    );
    final kickoff = _parseKickoff(
      _readString(
        json,
        keys: const ['kickoff', 'dateTime', 'date', 'startTime', 'spielbeginn'],
        fallback: '',
      ),
    );
    final score = _readString(
      json,
      keys: const ['result', 'score', 'matchScore', 'finalScore', 'ergebnis'],
      fallback: '',
    );
    final referee = _readString(
      json,
      keys: const ['referee', 'schiedsrichter', 'official'],
      fallback: '',
    );
    final competition = _readString(
      json,
      keys: const ['competition', 'competitionName', 'league', 'tournament', 'competitionLabel'],
      fallback: '',
    );
    final matchUrl = _readString(
      json,
      keys: const ['matchUrl', 'url', 'link', 'href'],
      fallback: '',
    );

    if (home.isEmpty && away.isEmpty && kickoff == null && matchId.isEmpty) {
      return null;
    }

    return FussballDeMatchDto(
      homeTeam: home.isEmpty ? '-' : home,
      awayTeam: away.isEmpty ? '-' : away,
      venue: venue,
      kickoff: kickoff,
      matchId: matchId,
      score: score,
      referee: referee,
      competition: competition,
      matchUrl: matchUrl.isEmpty ? sourceUri.toString() : matchUrl,
    );
  }

  Map<String, dynamic> _xmlNodeToMap(XmlElement node) {
    final map = <String, dynamic>{};

    for (final attribute in node.attributes) {
      map[attribute.name.local] = attribute.value;
    }

    for (final child in node.childElements) {
      final key = child.name.local;
      final value = child.innerText.trim();
      if (value.isNotEmpty) {
        map[key] = value;
      }
    }

    final text = node.innerText.trim();
    if (text.isNotEmpty) {
      map['text'] = text;
    }

    return map;
  }

  DateTime? _parseKickoff(String raw) {
    if (raw.trim().isEmpty) return null;
    final normalized = raw.replaceAll('\u00A0', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

    final direct = DateTime.tryParse(normalized);
    if (direct != null) return direct;

    final patterns = <RegExp>[
      RegExp(r'(\d{1,2})\.(\d{1,2})\.(\d{2,4}).*?(\d{1,2}):(\d{2})'),
      RegExp(r'(\d{1,2})/(\d{1,2})/(\d{2,4}).*?(\d{1,2}):(\d{2})'),
      RegExp(r'(\d{1,2})\.(\d{1,2})\.\s*(\d{1,2}):(\d{2})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(normalized);
      if (match == null) continue;

      final day = int.tryParse(match.group(1) ?? '');
      final month = int.tryParse(match.group(2) ?? '');
      final year = int.tryParse(match.group(3) ?? '') ?? DateTime.now().year;
      final hour = int.tryParse(match.group(4) ?? '');
      final minute = int.tryParse(match.group(5) ?? '');
      if (day == null || month == null || hour == null || minute == null) continue;
      final resolvedYear = year < 100 ? 2000 + year : year;
      try {
        return DateTime(resolvedYear, month, day, hour, minute);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  String _readString(
    Map<String, dynamic> json, {
    required List<String> keys,
    required String fallback,
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }
    return fallback;
  }

  Future<void> _saveCache(String teamId, List<FussballDeMatchDto> matches) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(matches.map(_encodeDto).toList());
    await prefs.setString('$_cachePrefix$teamId', encoded);
  }

  Future<List<FussballDeMatchDto>> _loadCache(String teamId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cachePrefix$teamId');
    if (raw == null || raw.isEmpty) return <FussballDeMatchDto>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <FussballDeMatchDto>[];
      return decoded
          .whereType<Map>()
          .map((entry) => FussballDeMatchDto.fromJson(Map<String, dynamic>.from(entry)))
          .toList(growable: false);
    } catch (_) {
      return <FussballDeMatchDto>[];
    }
  }

  Map<String, dynamic> _encodeDto(FussballDeMatchDto match) {
    return {
      'homeTeam': match.homeTeam,
      'awayTeam': match.awayTeam,
      'venue': match.venue,
      'kickoff': match.kickoff?.toIso8601String() ?? '',
      'matchId': match.matchId,
      'score': match.score,
      'referee': match.referee,
      'competition': match.competition,
      'matchUrl': match.matchUrl,
    };
  }
}
