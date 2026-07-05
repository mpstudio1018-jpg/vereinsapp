class VereinsNews {
  final String titel;
  final String link;
  final String datum;
  final String vorschaubildUrl;
  final String teaserText;

  const VereinsNews({
    required this.titel,
    required this.link,
    required this.datum,
    required this.vorschaubildUrl,
    required this.teaserText,
  });

  Map<String, dynamic> toJson() => {
        'titel': titel,
        'link': link,
        'datum': datum,
        'vorschaubildUrl': vorschaubildUrl,
        'teaserText': teaserText,
      };

  factory VereinsNews.fromJson(Map<String, dynamic> json) {
    return VereinsNews(
      titel: json['titel']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
      datum: json['datum']?.toString() ?? '',
      vorschaubildUrl: json['vorschaubildUrl']?.toString() ?? '',
      teaserText: json['teaserText']?.toString() ?? '',
    );
  }
}