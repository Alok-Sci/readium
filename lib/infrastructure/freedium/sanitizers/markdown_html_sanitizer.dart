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
  static final _anchorTag = RegExp(
    r'<a\b[^>]*>(.*?)</a>',
    caseSensitive: false,
    dotAll: true,
  );
  
  static final _altAttr = RegExp(r'\balt="([^"]*)"', caseSensitive: false);
  static final _hrefAttr = RegExp(r'\bhref="([^"]*)"', caseSensitive: false);

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

  /// Replaces every `<a href="...">...</a>` tag with an equivalent
  /// `[text](href)` Markdown link, using the inner text as the label.
  static String stripAnchorTags(String markdown) {
    return markdown.replaceAllMapped(_anchorTag, (match) {
      final tag = match.group(0)!;
      final href = _hrefAttr.firstMatch(tag)?.group(1);
      if (href == null || href.isEmpty) return match.group(1) ?? '';

      // Strip any nested HTML tags from the inner content to get plain text.
      final innerText =
          (match.group(1) ?? '').replaceAll(RegExp(r'<[^>]+>'), '').trim();
      if (innerText.isEmpty) return '';

      return '[$innerText]($href)';
    });
  }
}
