import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'deep_link_service.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  final DeepLinkService _deepLinkService = DeepLinkService();

  /// Share a Medium article with universal link support
  Future<void> shareArticle(String mediumUrl, {String? subject}) async {
    try {
      // Generate universal link that handles app detection
      final shareableLink = _deepLinkService.generateShareableLink(mediumUrl);

      // Extract article title from URL for better sharing experience
      final articleTitle = _extractArticleTitle(mediumUrl);
      final shareText =
          subject ?? 'Check out this article on Readium: $articleTitle';

      await Share.share(
        '$shareText\n\n$shareableLink',
        subject: subject ?? 'Shared from Readium',
      );
    } catch (e) {
      // Fallback to sharing the original URL
      await Share.share(
        'Check out this article: $mediumUrl',
        subject: subject ?? 'Shared from Readium',
      );
    }
  }

  /// Share the app itself
  Future<void> shareApp() async {
    const appDescription = 'Read Medium articles for free with Readium!';
    final storeLink = _deepLinkService.generateUniversalLink(
      'https://medium.com',
    );

    await Share.share(
      '$appDescription\n\nDownload the app: $storeLink',
      subject: 'Check out Readium App',
    );
  }

  /// Copy article link to clipboard
  Future<void> copyArticleLink(String mediumUrl) async {
    final shareableLink = _deepLinkService.generateShareableLink(mediumUrl);
    await Clipboard.setData(ClipboardData(text: shareableLink));
  }

  /// Extract article title from Medium URL for better sharing
  String _extractArticleTitle(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;

      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        // Convert URL slug to readable title
        return lastSegment
            .split('-')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
            )
            .join(' ')
            .replaceAll(RegExp(r'-[a-f0-9]+$'), ''); // Remove hash at end
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return 'Medium Article';
  }
}
