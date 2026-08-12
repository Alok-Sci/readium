import 'package:html/dom.dart';
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

  /// Recursively decode HTML entities in all text nodes
  /// 
  /// Note: This may not work well with flutter_html package as it
  /// re-parses the HTML string. Use [decodeHtmlString] instead.
  static void decodeTextNodes(Element element) {
    _processNode(element);
  }

  static void _processNode(Node node) {
    if (node.nodeType == Node.TEXT_NODE) {
      // Decode text node
      final text = node.text;
      if (text != null && text.contains('&')) {
        node.text = _unescape.convert(text);
      }
    } else if (node is Element) {
      // Special handling for code blocks with contenteditable
      if (node.localName == 'code' && 
          node.attributes['contenteditable'] == 'true') {
        _decodeCodeBlock(node);
      } else {
        // Recursively process all child nodes
        for (final child in node.nodes.toList()) {
          _processNode(child);
        }
      }
    }
  }

  /// Decode text in nested span structure within code blocks
  static void _decodeCodeBlock(Element codeElement) {
    // Code blocks have structure: code > span.line > span
    // Extract all text content, decode, then reconstruct
    for (final child in codeElement.nodes.toList()) {
      _processNode(child);
    }
  }
}
