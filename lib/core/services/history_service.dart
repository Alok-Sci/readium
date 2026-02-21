import 'package:readium/database/database_helper.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/features/history/models/article_history.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  HistoryService._internal();

  factory HistoryService() => _instance;

  Future<void> addToHistory(ArticleData article) async {
    final historyItem = ArticleHistory(
      originalUrl: article.originalUrl,
      title: article.title,
      subtitle: article.subtitle,
      coverImageUrl: article.coverImageUrl,
      authorName: article.authorName,
      authorImageUrl: article.authorImageUrl,
      readTime: article.readTime,
      publishDate: article.publishDate,
      isMemberOnly: article.isMemberOnly,
      readAt: DateTime.now(),
    );

    await _databaseHelper.insertArticleHistory(historyItem);
  }

  Future<List<ArticleHistory>> getHistory() async {
    return await _databaseHelper.getArticleHistory();
  }

  Future<void> removeFromHistory(int id) async {
    await _databaseHelper.deleteArticleHistory(id);
  }

  Future<void> clearHistory() async {
    await _databaseHelper.clearAllHistory();
  }
}
