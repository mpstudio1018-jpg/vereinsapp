class FussballDeMatchDto {
  final String homeTeam;
  final String awayTeam;
  final String venue;
  final DateTime? kickoff;
  final String matchId;
  final String score;
  final String referee;
  final String competition;
  final String matchUrl;

  const FussballDeMatchDto({
    required this.homeTeam,
    required this.awayTeam,
    required this.venue,
    required this.kickoff,
    required this.matchId,
    required this.score,
    required this.referee,
    required this.competition,
    required this.matchUrl,
  });

  factory FussballDeMatchDto.fromJson(Map<String, dynamic> json) {
    final home = _readString(
      json,
      keys: const ['home', 'homeTeam', 'home_team', 'teamHome'],
      fallback: '-',
    );
    final away = _readString(
      json,
      keys: const ['away', 'awayTeam', 'away_team', 'teamAway'],
      fallback: '-',
    );
    final venue = _readString(
      json,
      keys: const ['venue', 'location', 'stadium', 'place'],
      fallback: 'Sportanlage',
    );
    final matchId = _readString(
      json,
      keys: const ['matchId', 'match_id', 'spielnummer', 'id'],
      fallback: '',
    );

    final kickoffRaw = _readString(
      json,
      keys: const ['kickoff', 'startTime', 'dateTime', 'date'],
      fallback: '',
    );
    final parsedKickoff = kickoffRaw.isEmpty ? null : DateTime.tryParse(kickoffRaw);

    final score = _readString(
      json,
      keys: const ['score', 'result', 'matchScore', 'finalScore'],
      fallback: '',
    );
    final referee = _readString(
      json,
      keys: const ['referee', 'schiedsrichter', 'official'],
      fallback: '',
    );
    final competition = _readString(
      json,
      keys: const ['competition', 'competitionName', 'league', 'tournament'],
      fallback: '',
    );
    final matchUrl = _readString(
      json,
      keys: const ['matchUrl', 'url', 'link', 'href'],
      fallback: '',
    );

    return FussballDeMatchDto(
      homeTeam: home,
      awayTeam: away,
      venue: venue,
      kickoff: parsedKickoff,
      matchId: matchId,
      score: score,
      referee: referee,
      competition: competition,
      matchUrl: matchUrl,
    );
  }

  static String _readString(
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
}
