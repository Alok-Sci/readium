import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:readium/core/utils/url_helper.dart';
import 'package:readium/features/article/widgets/article_code_block_builder.dart';
import 'package:readium/features/article/widgets/article_header.dart';
import 'package:readium/features/article/widgets/article_screen_skeleton.dart';
import 'package:readium/features/article/widgets/article_tag_widget.dart';
import 'package:readium/features/article/widgets/article_bottom_bar.dart';
import 'package:readium/features/article/widgets/display_settings_bottom_sheet.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/infrastructure/freedium/sanitizers/markdown_html_sanitizer.dart';
import 'package:readium/shared/widgets/network_error_screen.dart';
import 'package:readium/core/services/history_service.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import '../models/article_repository.dart';
import 'package:readium/main.dart';

class ArticleScreen extends StatefulWidget {
  final String mediumUrl;
  final bool hideOpenInMedium;

  const ArticleScreen({
    super.key,
    required this.mediumUrl,
    this.hideOpenInMedium = false,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  late final ArticleRepository _repo;
  late final HistoryService _historyService;
  late Future<ArticleData> _future;

  // Display settings state
  String _fontFamily = 'source-serif-pro';
  double _fontSize = 18.0;
  double _textScaleFactor = 1.0; // 100% = 1.0

  @override
  void initState() {
    super.initState();
    _repo = ArticleRepository();
    _historyService = HistoryService();
    _future = _repo.loadFromMediumUrl(widget.mediumUrl);
  }

  void _showDisplaySettings() {
    // Get current theme mode from app state
    final appState = MyApp.of(context);
    final currentThemeMode = appState?.themeMode ?? ThemeMode.system;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DisplaySettingsBottomSheet(
        currentFontFamily: _fontFamily,
        currentFontSize: _fontSize,
        currentThemeMode: currentThemeMode,
        onSettingsChanged: (fontFamily, fontSize, themeMode) {
          setState(() {
            _fontFamily = fontFamily;
            _fontSize = fontSize;
            // Calculate text scale factor based on percentage
            // Base is 18pt = 100%, so scale factor = fontSize / 18
            _textScaleFactor = fontSize / 18.0;
          });
          // Update theme mode at app level
          appState?.changeThemeMode(themeMode);
        },
      ),
    );
  }

  TextStyle _getBodyTextStyle(BuildContext context) {
    final baseStyle = context.textTheme.bodyLarge!;

    // Map font family value to actual font family
    String? fontFamily;
    List<String>? fontFamilyFallback;

    switch (_fontFamily) {
      case 'source-serif-pro':
        fontFamily = 'source-serif-pro';
        fontFamilyFallback = const [
          'Georgia',
          'Cambria',
          'Times New Roman',
          'Times',
          'serif',
        ];
        break;
      case 'sohne':
        fontFamily = 'sohne';
        fontFamilyFallback = const [
          'Helvetica Neue',
          'Helvetica',
          'Arial',
          'sans-serif',
        ];
        break;
      case 'source-code-pro':
        fontFamily = 'source-code-pro';
        fontFamilyFallback = const [
          'Menlo',
          'Monaco',
          'Courier New',
          'Courier',
          'monospace',
        ];
        break;
      case 'system':
      default:
        fontFamily = null;
        fontFamilyFallback = null;
    }

    return baseStyle.copyWith(
      fontSize: _fontSize,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
  }

  /// Builds the Markdown style sheet for the article body.
  ///
  /// Two things that don't map 1:1 from the old `flutter_html` `style`
  /// map, worth knowing about:
  ///
  /// - `MarkdownStyleSheet` has one [MarkdownStyleSheet.blockSpacing]
  ///   value applied *between every block-level element* — there's no
  ///   per-tag "top margin" the way `flutter_html`'s `Margins.only(top:
  ///   ...)` gave you. [blockSpacing] below sets the baseline rhythm;
  ///   `h3Padding`/`h4Padding` then add a bit more on top of that
  ///   specifically before headings, to recreate "a new section gets
  ///   more breathing room than a new paragraph."
  /// - The old style map used *negative* bottom margins on `p`/`h3`/`h4`
  ///   as a line-height compensation hack. `EdgeInsets` can't go
  ///   negative here (`Padding` asserts non-negative insets), so that
  ///   trick has no direct equivalent — the numbers below are tuned to
  ///   look right without it rather than reproduce it exactly.
  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final bodyStyle = _getBodyTextStyle(context);
    final bodySmall = context.textTheme.bodySmall!;

    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      blockSpacing: 16,

      // paragraph
      p: bodyStyle.copyWith(height: 1.4),
      pPadding: const EdgeInsets.symmetric(horizontal: 24),

      // links — plain underlined body text, not a themed link color;
      // matches the old version, which never made links tappable either
      a: bodyStyle.copyWith(decoration: TextDecoration.underline),

      // h3 section heading
      h3: TextStyle(
        color: context.textTheme.headlineMedium!.color,
        fontSize: context.textTheme.headlineMedium!.fontSize,
        fontFamily: context.textTheme.headlineMedium!.fontFamily,
        fontWeight: context.textTheme.headlineMedium!.fontWeight,
        height: 1.2,
      ),
      h3Padding: const EdgeInsets.only(top: 12, left: 24, right: 24),

      // h4 subsection heading
      h4: TextStyle(
        color: context.textTheme.headlineSmall!.color,
        fontSize: context.textTheme.headlineSmall!.fontSize,
        fontFamily: context.textTheme.headlineSmall!.fontFamily,
        fontWeight: context.textTheme.headlineSmall!.fontWeight,
        height: 1.2,
      ),
      h4Padding: const EdgeInsets.only(top: 4, left: 24, right: 24),

      // inline code block
      code: TextStyle(
        backgroundColor: bodySmall.backgroundColor,
        color: bodySmall.color,
        fontSize: bodySmall.fontSize,
        letterSpacing: bodySmall.letterSpacing,
        height: bodySmall.height,
        fontFamily: bodySmall.fontFamily,
        fontFamilyFallback: bodySmall.fontFamilyFallback,
      ),

      codeblockDecoration: const BoxDecoration(), // No decoration
      codeblockPadding: EdgeInsets.zero, // No padding

      // blockquote
      blockquote: bodyStyle.copyWith(fontStyle: FontStyle.italic),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: bodyStyle.color!, width: 3),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(
        left: 20,
        right: 24,
        top: 8,
        bottom: 8,
      ),

      // lists
      listBullet: bodyStyle.copyWith(height: 1.1, fontSize: context.textTheme.bodySmall?.fontSize),
      listBulletPadding: const EdgeInsets.only(left: 12, right: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back_rounded,
              color: context.colorScheme.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              AppAssets.more,
              width: 24,
              height: 24,
              color: context.colorScheme.secondary,
            ),
            onPressed: _showDisplaySettings,
            tooltip: 'Display Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<ArticleData>(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.hasError) {
                return NetwokrErrorScreen();
              }
              return ArticleScreenSkeleton();
            }

            final article = snapshot.data!;

            // Save article to history when successfully loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _historyService.addToHistory(article);
            });

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ArticleHeader(
                    article: article,
                    textScaleFactor: _textScaleFactor,
                  ),

                  // Markdown body
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(_textScaleFactor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: MarkdownBody(
                        data: MarkdownHtmlSanitizer.stripPictureTags(article.markdownContent ?? ''),
                        styleSheet: _buildMarkdownStyleSheet(context),
                        softLineBreak: true,
                        selectable: true,
                        builders: {
                          'pre': ArticleCodeBlockBuilder(
                            context: context,
                            isDarkTheme: context.isDarkTheme,
                          ),
                        },
                        imageBuilder: (uri, title, alt) => ShimmerNetworkImage(
                          UrlHelper.absoluteMediumImageUrl(
                            uri.toString(),
                            size: 500,
                          ),
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),

                  // Tags row
                  if (article.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Wrap(
                        children: article.tags.map((tag) {
                          return ArticleTagWidget(tag);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: FutureBuilder<ArticleData>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          return ArticleBottomBar(
            articleUrl: snapshot.data!.originalUrl,
            articleTitle: snapshot.data!.title,
            hideOpenInMedium: widget.hideOpenInMedium,
          );
        },
      ),
    );
  }
}
