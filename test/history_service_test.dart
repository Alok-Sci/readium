import 'package:flutter_test/flutter_test.dart';
import 'package:readium/core/services/history_service.dart';
import 'package:readium/database/database_helper.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/features/article/models/article_tag.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('HistoryService Tests', () {
    late HistoryService historyService;

    setUpAll(() {
      // Initialize FFI
      sqfliteFfiInit();
      // Change the default factory for unit testing calls for SQFlite
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      historyService = HistoryService();
      // Clear any existing data before each test
      await historyService.clearHistory();
    });

    test('should add article to history', () async {
      final article = ArticleData(
        originalUrl: 'https://medium.com/test-article',
        title: 'Test Article',
        subtitle: 'Test Subtitle',
        coverImageUrl: 'https://example.com/image.jpg',
        coverImageAlt: 'Test Image',
        authorName: 'Test Author',
        authorUrl: 'https://medium.com/@testauthor',
        authorImageUrl: 'https://example.com/author.jpg',
        readTime: '5 min read',
        publishDate: 'Jan 1, 2024',
        isMemberOnly: false,
        tags: [
          ArticleTag(title: 'Flutter', href: 'https://medium.com/tag/flutter')
        ],
        cleanedBodyHtml: '<p>Test content</p>',
      );

      await historyService.addToHistory(article);
      final history = await historyService.getHistory();

      expect(history.length, 1);
      expect(history.first.title, 'Test Article');
      expect(history.first.originalUrl, 'https://medium.com/test-article');
    });

    test('should retrieve history in descending order', () async {
      final article1 = ArticleData(
        originalUrl: 'https://medium.com/test-article-1',
        title: 'First Article',
        subtitle: 'First Subtitle',
        coverImageUrl: null,
        coverImageAlt: null,
        authorName: 'Test Author',
        authorUrl: 'https://medium.com/@testauthor',
        authorImageUrl: 'https://example.com/author.jpg',
        readTime: '3 min read',
        publishDate: 'Jan 1, 2024',
        isMemberOnly: false,
        tags: [],
        cleanedBodyHtml: '<p>First content</p>',
      );

      final article2 = ArticleData(
        originalUrl: 'https://medium.com/test-article-2',
        title: 'Second Article',
        subtitle: 'Second Subtitle',
        coverImageUrl: null,
        coverImageAlt: null,
        authorName: 'Test Author',
        authorUrl: 'https://medium.com/@testauthor',
        authorImageUrl: 'https://example.com/author.jpg',
        readTime: '4 min read',
        publishDate: 'Jan 2, 2024',
        isMemberOnly: true,
        tags: [],
        cleanedBodyHtml: '<p>Second content</p>',
      );

      await historyService.addToHistory(article1);
      // Add a small delay to ensure different timestamps
      await Future.delayed(const Duration(milliseconds: 10));
      await historyService.addToHistory(article2);

      final history = await historyService.getHistory();

      expect(history.length, 2);
      // Most recent should be first (descending order)
      expect(history.first.title, 'Second Article');
      expect(history.last.title, 'First Article');
    });

    test('should update readAt timestamp for existing article', () async {
      final article = ArticleData(
        originalUrl: 'https://medium.com/test-article',
        title: 'Test Article',
        subtitle: 'Test Subtitle',
        coverImageUrl: null,
        coverImageAlt: null,
        authorName: 'Test Author',
        authorUrl: 'https://medium.com/@testauthor',
        authorImageUrl: 'https://example.com/author.jpg',
        readTime: '5 min read',
        publishDate: 'Jan 1, 2024',
        isMemberOnly: false,
        tags: [],
        cleanedBodyHtml: '<p>Test content</p>',
      );

      // Add article first time
      await historyService.addToHistory(article);
      final firstHistory = await historyService.getHistory();
      final firstReadAt = firstHistory.first.readAt;

      // Add same article again after a delay
      await Future.delayed(const Duration(milliseconds: 10));
      await historyService.addToHistory(article);
      final secondHistory = await historyService.getHistory();

      // Should still have only one entry
      expect(secondHistory.length, 1);
      // But readAt timestamp should be updated
      expect(secondHistory.first.readAt.isAfter(firstReadAt), true);
    });

    test('should clear all history', () async {
      final article = ArticleData(
        originalUrl: 'https://medium.com/test-article',
        title: 'Test Article',
        subtitle: 'Test Subtitle',
        coverImageUrl: null,
        coverImageAlt: null,
        authorName: 'Test Author',
        authorUrl: 'https://medium.com/@testauthor',
        authorImageUrl: 'https://example.com/author.jpg',
        readTime: '5 min read',
        publishDate: 'Jan 1, 2024',
        isMemberOnly: false,
        tags: [],
        cleanedBodyHtml: '<p>Test content</p>',
      );

      await historyService.addToHistory(article);
      expect((await historyService.getHistory()).length, 1);

      await historyService.clearHistory();
      expect((await historyService.getHistory()).length, 0);
    });
  });
}
