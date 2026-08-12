import 'package:html/dom.dart';

/// Utility class for cleaning and sanitizing HTML content
class HtmlCleaner {
  /// Remove unwanted elements from article DOM
  static void cleanArticle(Element article) {
    // Remove first div under article tag
    final firstDiv = article.querySelector('div');
    firstDiv?.remove();

    // Remove script and iframe tags
    article.querySelectorAll('script').forEach((e) => e.remove());
    article.querySelectorAll('iframe').forEach((e) => e.remove());

    // Remove navigation and progress elements
    article.querySelectorAll('nav#header').forEach((e) => e.remove());
    article.querySelectorAll('div#progress').forEach((e) => e.remove());

    // Remove notification sections
    article
        .querySelectorAll('section[aria-label="Notifications alt+T"]')
        .forEach((e) => e.remove());

    // Remove TOC section
    article
        .querySelectorAll('section[aria-labelledby="toc-heading"]')
        .forEach((e) => e.remove());

    // Remove footer and modals
    article.querySelectorAll('footer').forEach((e) => e.remove());
    article.querySelectorAll('#problemModal').forEach((e) => e.remove());
    article
        .querySelectorAll('.storage-notification-container')
        .forEach((e) => e.remove());

    // Remove dark mode code blocks
    article.querySelectorAll('div.dark\\:block').forEach((div) {
      final classes = div.classes.toList();
      if (classes.contains('hidden')) {
        div.remove();
      }
    });

    // Remove HTML comments
    _removeComments(article);

    // Remove Tailwind CSS classes
    _removeTailwindClasses(article);
  }

  /// Recursively remove all HTML comment nodes
  static void _removeComments(Element element) {
    for (final node in element.nodes.toList()) {
      if (node.nodeType == Node.COMMENT_NODE) {
        node.remove();
      } else if (node is Element) {
        _removeComments(node);
      }
    }
  }

  /// Remove Tailwind CSS utility classes from all elements
  static void _removeTailwindClasses(Element element) {
    final tailwindPatterns = [
      RegExp(r'\b(p|m|pt|pb|pl|pr|px|py|mt|mb|ml|mr|mx|my)-\d+\b'),
      RegExp(r'\b(w|h|min-w|min-h|max-w|max-h)-\w+\b'),
      RegExp(r'\b(text|bg|border|rounded|shadow|flex|grid|gap)-\w+\b'),
      RegExp(r'\b(hover|focus|active|disabled|sm|md|lg|xl|2xl):[\w-]+\b'),
      RegExp(r'\b(space|divide|ring|opacity|z|order|col|row)-\w+\b'),
    ];

    for (final el in element.querySelectorAll('*')) {
      final classAttr = el.attributes['class'];
      if (classAttr != null && classAttr.isNotEmpty) {
        final classes = classAttr.split(RegExp(r'\s+'));
        final filtered = classes.where((cls) {
          return !tailwindPatterns.any((pattern) => pattern.hasMatch(cls));
        }).toList();

        if (filtered.isEmpty) {
          el.attributes.remove('class');
        } else {
          el.attributes['class'] = filtered.join(' ');
        }
      }
    }
  }
}
