import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:readium/core/context_extension.dart';
import 'package:universal_code_viewer/universal_code_viewer.dart';

class ArticleCodeViewer extends StatelessWidget {
  const ArticleCodeViewer({
    super.key,
    required this.language,
    required this.tagCtx,
  });
  final ExtensionContext tagCtx;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 12.0,
      ),
      child: UniversalCodeViewer(
        showLineNumbers: false,
        code: tagCtx.element!.text,
        style: context.isDarkTheme
            ? SyntaxHighlighterStyles.vscodeDark
            : SyntaxHighlighterStyles.vscodeLight,
        codeLanguage: language,
      ),
    );
  }
}
