import 'package:flutter/material.dart';
import 'package:readium/core/utils/app_assets.dart';
import 'package:readium/features/article/views/article_screen.dart';
import 'package:readium/features/history/widgets/article_history_tile.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/features/history/models/article_history.dart';
import 'package:readium/core/services/history_service.dart';
import 'package:readium/core/sizedbox_extension.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  List<ArticleHistory> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final history = await _historyService.getHistory();
      setState(() {
        _historyItems = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all read history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory();
      _loadHistory();
    }
  }

  Future<void> _handleRemoveArticle(ArticleHistory item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from History'),
        content: Text('Remove "${item.title}" from read history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      await _historyService.removeFromHistory(item.id!);
      _loadHistory();
    }
  }

  void _navigateToArticle(String url) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ArticleScreen(mediumUrl: url),
      ),
    )
        .then((_) {
      // Refresh history when returning from article screen
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        automaticallyImplyLeading: false,
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
                    "Read History",
                    style: context.textTheme.displayMedium,
                  ),
                  if (_historyItems.isNotEmpty)
                    IconButton(
                      icon: Center(
                        child: Image.asset(
                          AppAssets.delete,
                          color: context.colorScheme.error,
                          height: 24,
                          width: 24,
                        ),
                      ),
                      tooltip: 'Clear history',
                      onPressed: _clearHistory,
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
            height: 1,
            color: context.colorScheme.tertiaryContainer,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: context.colorScheme.onSurface.withOpacity(0.5),
                        ),
                        16.height,
                        Text(
                          'No articles read yet',
                          style: context.textTheme.headlineSmall?.copyWith(
                            color:
                                context.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        8.height,
                        Text(
                          'Articles you read will appear here',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color:
                                context.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.separated(
                    itemCount: _historyItems.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 0,
                      color: context.colorScheme.tertiaryContainer,
                    ),
                    itemBuilder: (context, index) {
                      final item = _historyItems[index];
                      return Dismissible(
                        key: Key(item.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: context.colorScheme.error,
                          child: IconButton(
                            icon: Image.asset(
                              AppAssets.delete,
                              color: context.colorScheme.tertiary,
                              height: 24,
                              width: 24,
                            ),
                            onPressed: () => _handleRemoveArticle(item),
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Remove from History'),
                              content: Text(
                                  'Remove "${item.title}" from read history?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: context.colorScheme.error,
                                  ),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) async {
                          if (item.id != null) {
                            await _historyService.removeFromHistory(item.id!);
                            setState(() {
                              _historyItems.removeAt(index);
                            });
                          }
                        },
                        child: ArticleHistoryTile(
                          originalUrl: item.originalUrl,
                          title: item.title,
                          subtitle: item.subtitle,
                          authorName: item.authorName,
                          authorImageUrl: item.authorImageUrl,
                          readTime: item.readTime,
                          publishDate: item.publishDate,
                          coverImageUrl: item.coverImageUrl,
                          isMemberOnly: item.isMemberOnly,
                          onRemove: () => _handleRemoveArticle(item),
                          onTap: () => _navigateToArticle(item.originalUrl),
                          readAt: item.readAt,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
