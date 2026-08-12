/// Utility class for URL manipulation and normalization
class UrlHelper {
  /// Base URL for Freedium mirror service
  static const String freediumBaseUrl = 'https://freedium-mirror.cfd/';

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
