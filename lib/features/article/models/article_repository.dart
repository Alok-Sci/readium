// article_repository.dart
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/features/article/models/article_tag.dart';

class ArticleRepository {
  Future<ArticleData> loadFromMediumUrl(String mediumUrl) async {
    final freediumUrl = Uri.parse('https://freedium-mirror.cfd/$mediumUrl');
    log(freediumUrl.toString());
    final response = await http.get(freediumUrl);
    if (response.statusCode != 200) {
      throw Exception('Failed to load Freedium page');
    }

    final document = html_parser.parse(response.body);

    // 1. work only with <body>
    final body = document.body;
    if (body == null) {
      throw Exception('Body not found');
    }

    // 2. remove unwanted elements as per spec
    _cleanBody(body);

    // 3. extract metadata
    final originalUrl = _extractOriginalUrl(body);
    final authorInfo = _extractAuthor(body);
    final readInfo = _extractReadTimePublishDateAndMember(body);
    final titleEl = body.querySelector('h1');
    final subtitleEl = body.querySelector('h2');

    final coverImg = body.querySelector(
        'img[alt="Preview image"]'); // alt exactly "Preview image" [file:1]
    final tags = _extractTags(body);

    // 4. cleaned article HTML: use only the main content container if needed
    //   In Freedium sample, main content lives inside `.main-content`. [file:1]
    final mainContent = body.querySelector('.main-content') ?? body;
    final cleanedHtml = mainContent.innerHtml;

    return ArticleData(
      originalUrl: originalUrl,
      title: titleEl?.text.trim() ?? '',
      subtitle: subtitleEl?.text.trim() ?? '',
      coverImageUrl: coverImg?.attributes['src'],
      coverImageAlt: coverImg?.attributes['alt'],
      authorName: authorInfo.$1,
      authorImageUrl: authorInfo.$3,
      authorUrl: authorInfo.$2,
      readTime: readInfo.$1,
      publishDate: readInfo.$2,
      isMemberOnly: readInfo.$3,
      tags: tags,
      cleanedBodyHtml: cleanedHtml,
    );
  }

  void _cleanBody(Element body) {
    // remove nav elements (Freedium header/nav). [file:1]
    // body.querySelectorAll('nav').forEach((e) => e.remove());

    // remove elements with class "storage-notification-container". [file:1]
    body
        .querySelectorAll('.storage-notification-container')
        .forEach((e) => e.remove());

    // remove element with id "problemModal". [file:1]
    body.querySelectorAll('#problemModal').forEach((e) => e.remove());
  }

  String _extractOriginalUrl(Element body) {
    // a element whose text ends with "Go to the original". [file:1]
    final link = body.querySelector('a');
    final anchor = body.querySelectorAll('a').firstWhere(
        (a) => a.text.trim().endsWith('Go to the original'),
        orElse: () => link ?? Element.tag('a'));
    final href = anchor.attributes['href'] ?? '';
    // Freedium sample keeps original Medium url including #bypass. [file:1]
    return href;
  }

  (String, String, bool) _extractReadTimePublishDateAndMember(Element body) {
    // Find span group: 4 span siblings, two with "." content. [file:1]
    for (final span in body.querySelectorAll('span')) {
      final parent = span.parent;
      if (parent == null) continue;
      final spans =
          parent.children.where((e) => e.localName == 'span').toList();
      if (spans.length < 3) continue;
      final dots = spans.where((s) => s.text.trim() == '·').length;
      if (dots == 2 && spans.length >= 5) {
        final readTime = spans[0].text.trim().split('~').last;
        final publishDate = spans[2].text.trim().split('(').first;
        final memberText =
            spans[4].text.trim().toLowerCase(); // "Free: Yes/No" [file:1]
        final isMemberOnly = memberText.contains('free: no');
        return (readTime, publishDate, isMemberOnly);
      }
    }
    return ('', '', false);
  }

  (String, String, String) _extractAuthor(Element body) {
    // a[href*="https://medium.com/@"] with img child; img alt = author name, src = avatar. [file:1]
    final candidates = body.querySelectorAll('a[href*="https://medium.com/@"]');
    for (final a in candidates) {
      final img = a.querySelector('img');
      if (img != null) {
        final name = img.attributes['alt']?.trim() ?? '';
        final imageUrl = img.attributes['src'] ?? '';
        var authorUrl = a.attributes['href'] ?? '';
        // Remove #bypass from author URL to get clean Medium profile URL
        authorUrl = authorUrl.replaceAll('#bypass', '');
        if (name.isNotEmpty && imageUrl.isNotEmpty) {
          return (name, authorUrl, imageUrl);
        }
      }
    }
    return ('', '', '');
  }

  List<ArticleTag> _extractTags(Element body) {
    final tagAnchors =
        body.querySelectorAll('a[href*="https://medium.com/tag/"]');
    return tagAnchors.map((a) {
      var href = a.attributes['href'] ?? '';
      href = href.replaceAll('#bypass', ''); // remove #bypass. [file:1]
      final title = a.attributes['title'] ?? a.text.trim();
      return ArticleTag(title: title, href: href);
    }).toList();
  }
}
