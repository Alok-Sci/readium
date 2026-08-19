/// Cleans up raw HTML that Freedium occasionally leaks into its Markdown
/// output. `flutter_markdown_plus` doesn't render inline HTML, so left
/// alone this shows up in the middle of the article.
class MarkdownHtmlSanitizer {
  const MarkdownHtmlSanitizer._();

  static final _pictureBlock = RegExp(
    r'<picture\b[^>]*>(.*?)</picture>',
    caseSensitive: false,
    dotAll: true,
  );
  static final _imgTag = RegExp(
    r'<img\b[^>]*/?>',
    caseSensitive: false,
    dotAll: true,
  );
  static final _imgSrc = RegExp(
    r'\bsrc="([^"]*)"',
    caseSensitive: false,
  );
  static final _altAttr = RegExp(r'\balt="([^"]*)"', caseSensitive: false);

  /// Replaces every `<picture>...</picture>` block with an equivalent
  /// `![alt](src)` Markdown image, extracted from the `<img>` tag inside.
  static String stripPictureTags(String markdown) {
    return markdown.replaceAllMapped(_pictureBlock, (match) {
      final block = match.group(0)!;
      final imgTag = _imgTag.firstMatch(block)?.group(0);
      if (imgTag == null) return '';
      final src = _imgSrc.firstMatch(imgTag)?.group(1);
      if (src == null || src.isEmpty) return '';

      final rawAlt = _altAttr.firstMatch(imgTag)?.group(1) ?? '';
      // Freedium sends `alt="None"` as a placeholder rather than
      // omitting the attribute — treat that the same as no alt text.
      final alt =
          rawAlt.isEmpty || rawAlt.toLowerCase() == 'none' ? '' : rawAlt;

      return '![$alt]($src)';
    });
  }
}