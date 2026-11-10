import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:readium/core/theme/app_theme.dart';
import 'package:readium/features/article/services/article_code_syntax_highlighter_service.dart';

/// Renders fenced code blocks from the article's Markdown body via
/// flutter_highlight — syntax-highlighted code sitting directly in the
/// reading flow, matching Medium's code block look.
///
/// Registered against the `pre` tag — not `code` — so it only
/// intercepts fenced/indented code *blocks*. Inline code spans (`` `like
/// this` ``) never produce a `pre` element and fall straight through to
/// the ordinary [MarkdownStyleSheet.code] text style.
class ArticleCodeBlockBuilder extends MarkdownElementBuilder {
  ArticleCodeBlockBuilder({required this.isDarkTheme});

  final bool isDarkTheme;

  static const _codeFontFamily = 'source-code-pro';
  static const _codeFontFamilyFallback = [
    'Menlo',
    'Monaco',
    'Courier New',
    'Courier',
    'monospace',
  ];
  static const _codeTextStyle = TextStyle(
    fontFamily: _codeFontFamily,
    fontFamilyFallback: _codeFontFamilyFallback,
    fontSize: 14,
    height: 1.2,
  );

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final codeElement = _findCodeChild(element);
    final code = (codeElement ?? element).textContent;
    final language = _languageFromClass(codeElement?.attributes['class']);

    // Get syntax-highlighted widget using the service
    final highlightedWidget =
        ArticleCodeSyntaxHighlighterService.instance.highlightWidget(
      code,
      language: language,
      isDark: isDarkTheme,
      baseStyle: _codeTextStyle,
    );

    // Use theme colors directly without storing BuildContext
    final borderColor =
        isDarkTheme ? AppTheme.darkCodeBorder : AppTheme.lightCodeBorder;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.vs2015ThemeBg,
        border: Border.all(color: borderColor),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          constraints: BoxConstraints(
            minWidth: 1.sw - 48 - 24, // Full width minus margins and padding
          ),
          alignment: Alignment.centerLeft,
          child: highlightedWidget ??
              // No grammar for this language — render as plain monospace text
              Text(
                code,
                style: _codeTextStyle,
              ),
        ),
      ),
    );
  }

  md.Element? _findCodeChild(md.Element pre) {
    for (final child in pre.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'code') return child;
    }
    return null;
  }

  static String? _languageFromClass(String? classAttr) {
    if (classAttr == null || !classAttr.startsWith('language-')) return null;
    final raw = classAttr.substring('language-'.length);
    return raw.isEmpty ? null : raw;
  }
}
