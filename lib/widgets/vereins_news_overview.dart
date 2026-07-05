import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/vereins_news.dart';
import '../services/news_service.dart';

const Color kNewsPrimaryColor = Color(0xFF800020);

class VereinsNewsOverview extends StatefulWidget {
  const VereinsNewsOverview({super.key});

  @override
  State<VereinsNewsOverview> createState() => _VereinsNewsOverviewState();
}

class _VereinsNewsOverviewState extends State<VereinsNewsOverview> {
  final NewsService _newsService = NewsService();
  final PageController _pageController = PageController(viewportFraction: 0.93);

  Timer? _slideTimer;
  String? _loadWarning;
  int _currentSlide = 0;
  int _activeTopCount = 0;
  bool _contentVisible = false;

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _syncAutoSlide(int count) {
    if (_activeTopCount == count) return;

    _slideTimer?.cancel();
    _activeTopCount = count;

    if (_currentSlide >= count && count > 0) {
      _currentSlide = 0;
    }

    if (count <= 1) return;

    _slideTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final nextPage = (_currentSlide + 1) % count;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await canLaunchUrl(uri)) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  int _resolveTopNewsCount(int totalCount) {
    if (totalCount >= 4) return 4;
    if (totalCount == 3) return 3;
    return totalCount;
  }

  Widget _buildListImage(VereinsNews news) {
    if (news.vorschaubildUrl.trim().isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.article, color: Colors.white70),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        news.vorschaubildUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.article, color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildTopSlide(VereinsNews news, {required bool isBreaking}) {
    final hasImage = news.vorschaubildUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: () => _openExternal(news.link),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF131926),
          image: hasImage
              ? DecorationImage(
                  image: NetworkImage(news.vorschaubildUrl),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00000000),
                Color(0xB3000000),
                Color(0xE0000000),
              ],
            ),
            border: Border.all(color: Colors.white10),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Stack(
            children: [
              if (isBreaking)
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: kNewsPrimaryColor,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Text(
                      'BREAKING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    news.titel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.datum,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerInitialFadeIn() {
    if (_contentVisible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _contentVisible) return;
      setState(() {
        _contentVisible = true;
      });
    });
  }

  Widget _buildSlideIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final selected = index == _currentSlide;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? kNewsPrimaryColor : Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildNewsListItem(VereinsNews news) {
    return Card(
      color: const Color(0xFF131926),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.white10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openExternal(news.link),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListImage(news),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.datum,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      news.titel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      news.teaserText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsContent(List<VereinsNews> allNews) {
    final topCount = _resolveTopNewsCount(allNews.length);
    final topNews = allNews.take(topCount).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAutoSlide(topNews.length);
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'News & Vereinsinfos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kNewsPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Aktuelle Meldungen live von tvfriedrichstein.de',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          if (_loadWarning != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
              ),
              child: Text(
                _loadWarning!,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
              ),
            ),
          ],
          if (topNews.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 230,
              child: PageView.builder(
                controller: _pageController,
                itemCount: topNews.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
                itemBuilder: (context, index) =>
                    _buildTopSlide(topNews[index], isBreaking: index == 0),
              ),
            ),
            const SizedBox(height: 10),
            _buildSlideIndicators(topNews.length),
          ],
          const SizedBox(height: 20),
          const Text(
            'Alle Beitraege',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: kNewsPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            itemCount: allNews.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _buildNewsListItem(allNews[index]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VereinsNews>>(
      future: _newsService.loadLatestNews(
        onLiveError: (error) {
          if (!mounted) return;
          setState(() {
            _loadWarning =
                'Live-Feed konnte nicht geladen werden. Es werden lokale oder Offline-News angezeigt.';
          });
        },
      ),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <VereinsNews>[];

        if (snapshot.connectionState == ConnectionState.waiting && items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: kNewsPrimaryColor),
            ),
          );
        }

        if (snapshot.hasError && items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'News konnten derzeit nicht geladen werden.',
              style: TextStyle(color: Colors.redAccent),
            ),
          );
        }

        _triggerInitialFadeIn();

        return AnimatedOpacity(
          opacity: _contentVisible ? 1 : 0,
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOut,
          child: _buildNewsContent(items),
        );
      },
    );
  }
}
