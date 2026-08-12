import 'package:html_unescape/html_unescape.dart';

/// Utility class for decoding HTML entities
class HtmlEntityDecoder {
  static final _unescape = HtmlUnescape();

  /// Decode HTML entities in a raw HTML string
  /// 
  /// This is more reliable than decoding DOM nodes because flutter_html
  /// re-parses the HTML string and may re-encode entities
  static String decodeHtmlString(String html) {
    return _unescape.convert(html);
  }
}
