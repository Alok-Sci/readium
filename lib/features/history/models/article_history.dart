class ArticleHistory {
  final int? id;
  final String originalUrl;
  final String title;
  final String subtitle;
  final String? coverImageUrl;
  final String authorName;
  final String authorImageUrl;
  final String readTime;
  final String publishDate;
  final bool isMemberOnly;
  final DateTime readAt;

  ArticleHistory({
    this.id,
    required this.originalUrl,
    required this.title,
    required this.subtitle,
    this.coverImageUrl,
    required this.authorName,
    required this.authorImageUrl,
    required this.readTime,
    required this.publishDate,
    required this.isMemberOnly,
    required this.readAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalUrl': originalUrl,
      'title': title,
      'subtitle': subtitle,
      'coverImageUrl': coverImageUrl,
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'readTime': readTime,
      'publishDate': publishDate,
      'isMemberOnly': isMemberOnly ? 1 : 0,
      'readAt': readAt.millisecondsSinceEpoch,
    };
  }

  factory ArticleHistory.fromMap(Map<String, dynamic> map) {
    return ArticleHistory(
      id: map['id']?.toInt(),
      originalUrl: map['originalUrl'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      coverImageUrl: map['coverImageUrl'],
      authorName: map['authorName'] ?? '',
      authorImageUrl: map['authorImageUrl'] ?? '',
      readTime: map['readTime'] ?? '',
      publishDate: map['publishDate'] ?? '',
      isMemberOnly: map['isMemberOnly'] == 1,
      readAt: DateTime.fromMillisecondsSinceEpoch(map['readAt']),
    );
  }
}
