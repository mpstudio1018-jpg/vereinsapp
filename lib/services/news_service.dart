import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as html_dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import '../models/vereins_news.dart';

class NewsService {
  static const String _feedUrl = 'https://tvfriedrichstein.de/feed/';
  static const String _cacheKey = 'tvfriedrichstein_news_cache_v1';

  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<VereinsNews>> loadLatestNews({
    int limit = 8,
    void Function(Object error)? onLiveError,
  }) async {
    try {
      final items = await _fetchLiveNews(limit: limit);
      await _saveCache(items);
      return items;
    } catch (error) {
      if (kDebugMode) {
        debugPrint('NewsService live feed failed: $error');
      }
      onLiveError?.call(error);

      final cachedItems = await _loadCache();
      if (cachedItems.isNotEmpty) {
        return cachedItems;
      }

      return _fallbackNews();
    }
  }

  Future<List<VereinsNews>> _fetchLiveNews({required int limit}) async {
    final response = await _client.get(
      Uri.parse(_feedUrl),
      headers: const {'Accept': 'application/rss+xml, application/xml, text/xml'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('RSS request failed with status ${response.statusCode}');
    }

    final document = XmlDocument.parse(response.body);
    final items = document.findAllElements('item').take(limit);

    return items
        .map(_parseItem)
        .where((item) => item.titel.trim().isNotEmpty && item.link.trim().isNotEmpty)
        .toList();
  }

  VereinsNews _parseItem(XmlElement item) {
    final title = _firstText(item, 'title');
    final link = _firstText(item, 'link');
    final pubDate = _firstText(item, 'pubDate');
    final descriptionHtml = _firstText(item, 'description');
    final contentHtml = _firstText(item, 'content:encoded');
    final htmlSource = contentHtml.isNotEmpty ? contentHtml : descriptionHtml;

    final fragment = html_parser.parseFragment(htmlSource);
    final fragmentText = fragment.nodes.map((node) => node.text).join(' ');
    final teaser = _extractTeaser(fragmentText.isNotEmpty ? fragmentText : descriptionHtml);
    final imageUrl = _extractImageUrl(fragment) ?? _extractEnclosureUrl(item);

    return VereinsNews(
      titel: _cleanText(title),
      link: link,
      datum: _formatRssDate(pubDate),
      vorschaubildUrl: imageUrl ?? '',
      teaserText: teaser,
    );
  }

  String _firstText(XmlElement item, String name) {
    final matches = item.findAllElements(name);
    if (matches.isEmpty) return '';
    return matches.first.innerText.trim();
  }

  String _cleanText(String? input) {
    final value = input ?? '';
    final fragmentText = html_parser.parseFragment(value).nodes.map((node) => node.text).join(' ');
    return fragmentText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _extractTeaser(String? rawText) {
    final cleaned = (rawText ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleaned.isEmpty) return 'Aktuelle Informationen vom Verein.';
    if (cleaned.length <= 180) return cleaned;
    return '${cleaned.substring(0, 177).trimRight()}...';
  }

  String? _extractImageUrl(html_dom.DocumentFragment fragment) {
    final src = fragment.querySelector('img')?.attributes['src']?.trim() ?? '';
    return src.isEmpty ? null : src;
  }

  String? _extractEnclosureUrl(XmlElement item) {
    final enclosure = item.findAllElements('enclosure');
    if (enclosure.isEmpty) return null;
    final url = enclosure.first.getAttribute('url')?.trim() ?? '';
    return url.isEmpty ? null : url;
  }

  String _formatRssDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
  }

  Future<void> _saveCache(List<VereinsNews> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
  }

  Future<List<VereinsNews>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return <VereinsNews>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <VereinsNews>[];
      return decoded
          .whereType<Map>()
          .map((entry) => VereinsNews.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (_) {
      return <VereinsNews>[];
    }
  }

  List<VereinsNews> _fallbackNews() {
    return const [
      VereinsNews(
        titel: 'Vereins-News offline',
        link: 'https://tvfriedrichstein.de/',
        datum: 'aktuell',
        vorschaubildUrl: '',
        teaserText: 'Die Live-Anbindung war nicht erreichbar. Bitte später erneut versuchen.',
      ),
      VereinsNews(
        titel: 'Wichtiger Hinweis',
        link: 'https://tvfriedrichstein.de/feed/',
        datum: 'aktuell',
        vorschaubildUrl: '',
        teaserText: 'Sobald die Verbindung wieder steht, lädt die App automatisch die aktuellen Beiträge aus dem RSS-Feed.',
      ),
    ];
  }
}