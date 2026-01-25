class Article {
  final String endpoint;
  final String? imageUrl;
  final String title;
  final String? authorName;
  final String? authorImageUrl;
  final String readTime;
  final String publishDate;
  final bool isMemberOnly;
  final String subtitle;

  Article({
    required this.endpoint,
    this.imageUrl,
    required this.title,
    this.authorName,
    this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
    required this.isMemberOnly,
    required this.subtitle,
  });

  String get fullUrl => 'https://freedium-mirror.cfd$endpoint';
}
