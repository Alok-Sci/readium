import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:readium/features/article/widgets/article_header.dart';
import 'package:readium/features/article/widgets/article_screen_skeleton.dart';
import 'package:readium/features/article/widgets/article_tag_widget.dart';
import 'package:readium/features/article/widgets/article_bottom_bar.dart';
import 'package:readium/features/article/widgets/display_settings_bottom_sheet.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/features/article/models/article_data.dart';
import 'package:readium/shared/widgets/network_error_screen.dart';
import 'package:readium/shared/widgets/primary_text_button.dart';
import 'package:readium/core/services/history_service.dart';
import 'package:readium/shared/widgets/shimmer_network_image.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:universal_code_viewer/universal_code_viewer.dart';
import 'package:url_launcher/url_launcher.dart';
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

                  // HTML body
                  MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(_textScaleFactor),
                    ),
                    child: Html(
                      data: article.cleanedBodyHtml,
                      doNotRenderTheseTags: {
                        'style',
                        'script',
                        'iframe',
                        'button',
                        'nav'
                      },
                      extensions: [
                        TagExtension(
                          tagsToExtend: {'pre'},
                          builder: (tagCtx) {
                            String language = '';
                            // extract the code language name
                            language = tagCtx.element!.children.first.classes
                                .firstWhere((cl) => cl.startsWith('language-'))
                                .split('language-')
                                .last;

                            // display the code viewer
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
                          },
                        ),
                        TagExtension(
                          tagsToExtend: {'a'},
                          builder: (tagCtx) {
                            final href =
                                tagCtx.element?.attributes['href'] ?? '';

                            // Check if this is a story list link
                            if (href.contains('https://medium.com/') &&
                                href.contains('/list/')) {
                              final h2Element =
                                  tagCtx.element?.querySelector('h2');
                              if (h2Element != null) {
                                final title = h2Element.text.trim();

                                // Extract background image URL from descendant div's style attribute
                                String? imageUrl;
                                final divElements =
                                    tagCtx.element?.querySelectorAll('div');
                                if (divElements != null) {
                                  for (final div in divElements) {
                                    final style = div.attributes['style'] ?? '';
                                    final urlMatch = RegExp(
                                            r"background-image:\s*url\('([^']+)'\)")
                                        .firstMatch(style);
                                    if (urlMatch != null) {
                                      imageUrl = urlMatch.group(1);
                                      break;
                                    }
                                  }
                                }
                                final image = ShimmerNetworkImage(
                                  imageUrl!,
                                  width: .8.sw,
                                  height: 100,
                                  fit: BoxFit.cover,
                                );

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.tertiary,
                                    border: Border.all(
                                        color: context
                                            .colorScheme.tertiaryContainer),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      20.height,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: Text(
                                          title,
                                          style:
                                              context.textTheme.headlineSmall,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        child: PrimaryTextButton(
                                          text: 'View List',
                                          onPressed: () {
                                            launchUrl(Uri.parse(href));
                                          },
                                        ),
                                      ),
                                      20.height,
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: image,
                                          ),
                                          5.width,
                                          Expanded(
                                            flex: 2,
                                            child: image,
                                          ),
                                          5.width,
                                          Expanded(
                                            flex: 1,
                                            child: image,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }
                            }

                            // Use default rendering for other links by returning the original element
                            return Text(
                              tagCtx.element!.text,
                              style: context.textTheme.bodyLarge?.copyWith(
                                decoration: TextDecoration.underline,
                              ),
                            );
                          },
                        )
                      ],
                      style: {
                        // paragraph
                        'p': Style(
                          color: _getBodyTextStyle(context).color,
                          fontSize:
                              FontSize(_getBodyTextStyle(context).fontSize!),
                          fontFamily: _getBodyTextStyle(context).fontFamily,
                          fontFamilyFallback:
                              _getBodyTextStyle(context).fontFamilyFallback,
                          lineHeight: LineHeight.number(1.4),
                          margin: Margins.only(
                            top: 12.08,
                            bottom: -8.28, // -
                            left: 24,
                            right: 24,
                          ),
                        ),
                        'li': Style(
                            color: _getBodyTextStyle(context).color,
                            fontSize:
                                FontSize(_getBodyTextStyle(context).fontSize!),
                            fontFamily: _getBodyTextStyle(context).fontFamily,
                            fontFamilyFallback:
                                _getBodyTextStyle(context).fontFamilyFallback,
                            margin: Margins.only(top: 12, bottom: -8.28),
                            listStylePosition: ListStylePosition.outside),
                        // h3 section heading
                        'h3': Style(
                          color: context.textTheme.headlineMedium!.color,
                          fontSize: FontSize(
                              context.textTheme.headlineMedium!.fontSize!),
                          fontFamily:
                              context.textTheme.headlineMedium!.fontFamily,
                          fontWeight:
                              context.textTheme.headlineMedium!.fontWeight,
                          margin: Margins.only(
                            top: 28,
                            bottom: -5.6, // -
                            left: 24,
                            right: 24,
                          ),
                        ),
                        // h4 subsection
                        'h4': Style(
                          color: context.textTheme.headlineSmall!.color,
                          fontSize: FontSize(
                              context.textTheme.headlineSmall!.fontSize!),
                          fontFamily:
                              context.textTheme.headlineSmall!.fontFamily,
                          fontWeight:
                              context.textTheme.headlineSmall!.fontWeight,
                          margin: Margins.only(
                            top: 19.68,
                            bottom: -9.96, // -
                            left: 24,
                            right: 24,
                          ),
                        ),
                        'pre': Style(
                          backgroundColor:
                              context.textTheme.bodySmall!.backgroundColor,
                          fontSize: FontSize(18),
                          margin: Margins.only(right: 24, left: 24, top: 40),
                          padding: HtmlPaddings.all(32),
                          lineHeight: LineHeight.number(
                              context.textTheme.labelSmall!.height!),
                          border: Border.all(
                              width: 1,
                              color: context
                                  .textTheme.bodySmall!.backgroundColor!),
                        ),
                        // inline code (no language-*)
                        'code': Style(
                          backgroundColor:
                              context.textTheme.bodySmall!.backgroundColor,
                          color: context.textTheme.bodySmall!.color,
                          fontSize:
                              FontSize(context.textTheme.bodySmall!.fontSize!),
                          letterSpacing:
                              context.textTheme.bodySmall!.letterSpacing,
                          lineHeight: LineHeight.number(
                              context.textTheme.bodySmall!.height!),
                          fontFamily: context.textTheme.bodySmall!.fontFamily,
                          fontFamilyFallback:
                              context.textTheme.bodySmall!.fontFamilyFallback,
                          padding: HtmlPaddings.symmetric(
                            vertical: 2,
                            horizontal: 4,
                          ),
                        ),
                        // blockquote
                        'blockquote': Style(
                          margin: Margins.only(left: -4), // -
                          fontStyle: FontStyle.italic,
                          border: Border(
                            left: BorderSide(
                              color: context.textTheme.bodyLarge!.color!,
                              width: 3,
                            ),
                          ),
                        ),
                        // anchor
                        'a': Style(
                          color: context.textTheme.bodyLarge!.color!,
                        ),
                        // image
                        'img': Style(
                          margin: Margins.only(
                            top: 40,
                            left: 24,
                            right: 24,
                          ),
                        ),
                        'figcaption': Style(
                          fontFamily: context.textTheme.labelMedium!.fontFamily,
                          fontSize: FontSize(
                              context.textTheme.labelMedium!.fontSize!),
                          color: context.textTheme.labelMedium!.color!,
                          textAlign: TextAlign.center,
                          margin: Margins.only(
                            top: 10,
                            left: 24,
                            right: 24,
                          ),
                        ),
                      },
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
