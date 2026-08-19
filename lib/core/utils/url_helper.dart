import 'dart:developer';

/// Utility class for URL manipulation and normalization
class UrlHelper {
  /// Base URL for Freedium mirror service
  static const String freediumBaseUrl = 'https://freedium-mirror.cfd';

  // Medium's URL for images
  static String get mediumImageUrl => 'https://miro.medium.com/v2/';

  // Medium's URL for images
  static String? absoluteMediumImageUrl(String? imageUrl, {int size = 100}) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // If the imageUrl is the placeholder image web url then do not proceed further.
    if (imageUrl.contains("https://ui-avatars.com/")) return imageUrl;

    final imageName = imageUrl.split('/').last;
    if (imageName.isNotEmpty) {
      final url = '$mediumImageUrl/resize:fit:$size/$imageName';
      log('Image URL: $url');
      return url;
    }
    return '$freediumBaseUrl$imageUrl';
  }

  /// Convert relative URL to absolute URL using base URL
  ///
  /// Returns empty string if [relativeUrl] is empty
  /// Returns [relativeUrl] as-is if already absolute
  /// Otherwise prepends [baseUrl] to create absolute URL
  static String makeAbsolute(String relativeUrl, {String? baseUrl}) {
    if (relativeUrl.isEmpty) return '';

    if (relativeUrl.startsWith('http://') ||
        relativeUrl.startsWith('https://')) {
      return relativeUrl;
    }

    final base = Uri.parse(baseUrl ?? freediumBaseUrl);
    return base.resolve(relativeUrl).toString();
  }

  /// Build Freedium mirror URL from Medium article URL
  static String buildFreediumUrl(String mediumUrl) {
    return '$freediumBaseUrl$mediumUrl';
  }
}
