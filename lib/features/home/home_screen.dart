import 'package:flutter/material.dart';
import 'package:readium/features/article/views/article_screen.dart';
import 'package:readium/features/article/widgets/article_list_tile_skeleton.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/services/share_handler.dart';
import 'package:readium/core/services/deep_link_service.dart';
import 'package:readium/core/sizedbox_extension.dart';
import 'package:readium/shared/widgets/readium_search_bar.dart';
import 'package:readium/features/home/services/article_service.dart';
import 'package:readium/features/home/models/article.dart';
import 'package:readium/features/home/widgets/article_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlController = TextEditingController();
  final _urlFocusNode = FocusNode();
  final DeepLinkService _deepLinkService = DeepLinkService();
  bool _isLoadingExploreArticles = true;
  List<Article> _articles = [];
  String? _errorMessage;

  void _navigateToArticle(String url, {bool fromExplore = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          mediumUrl: url,
          hideOpenInMedium: fromExplore,
        ),
      ),
    );
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoadingExploreArticles = true;
      _errorMessage = null;
    });

    try {
      final articles = await ArticleService.fetchArticles();
      setState(() {
        _articles = articles;
        _isLoadingExploreArticles = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingExploreArticles = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Load articles
    _loadArticles();

    // Listen for shares
    ShareHandler.initialize((sharedUrl) {
      setState(() {
        _urlController.text = sharedUrl;
      });

      // Navigate to article
      _navigateToArticle(sharedUrl);
    });

    // Initialize deep linking
    _deepLinkService.initialize((mediumUrl) {
      setState(() {
        _urlController.text = mediumUrl;
      });

      // Navigate to article
      _navigateToArticle(mediumUrl);
    });
  }

  @override
  void dispose() {
    ShareHandler.dispose();
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 130,
          flexibleSpace: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Home",
                      style: context.textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              30.height
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(
              color: context.colorScheme.tertiaryContainer,
              height: 1.0,
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              toolbarHeight: 80,
              titleSpacing: 0,
              title: ReadiumSearchBar(
                focusNode: _urlFocusNode,
                controller: _urlController,
                onSearch: (value) => _navigateToArticle(_urlController.text),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  20.height,
                  // Section Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Explore Articles",
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  16.height,
                  // Loading State
                  if (_isLoadingExploreArticles) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          ArticleListTileSkeleton(),
                          20.height,
                          ArticleListTileSkeleton(),
                          20.height,
                          ArticleListTileSkeleton(),
                        ],
                      ),
                    ),
                  ]
                  // Error State
                  else if (_errorMessage != null) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: context.colorScheme.error,
                          ),
                          16.height,
                          Text(
                            'Failed to load articles',
                            style: context.textTheme.titleMedium,
                          ),
                          8.height,
                          Text(
                            _errorMessage!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          16.height,
                          ElevatedButton.icon(
                            onPressed: _loadArticles,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ]
                  // Articles List
                  else if (_articles.isEmpty) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 48,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          16.height,
                          Text(
                            'No articles found',
                            style: context.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ArticleCard(
                              article: _articles[index],
                              onTap: () => _navigateToArticle(
                                  _articles[index].fullUrl,
                                  fromExplore: true),
                            ),
                            if (index < _articles.length - 1)
                              Divider(
                                height: 0,
                                color: context.colorScheme.tertiaryContainer,
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                  20.height,
                ],
              ),
            ),
          ],
        ));
  }
}
