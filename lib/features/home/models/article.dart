class Article {
  final String endpoint;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final String? topic;
  final String? authorName;
  final String? authorImageUrl;
  final String readTime;
  final String publishDate;

  Article({
    required this.endpoint,
    this.imageUrl,
    required this.title,
    this.topic,
    required this.subtitle,
    this.authorName,
    this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
  });

  String get fullUrl => 'https://freedium-mirror.cfd$endpoint';
}
