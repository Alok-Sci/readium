import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/helpers/article_helpers.dart';
import 'package:readium/core/utils/app_assets.dart';

class ArticleBottomBar extends StatefulWidget {
  final String articleUrl;
  final String articleTitle;
  final bool hideOpenInMedium;

  const ArticleBottomBar({
    super.key,
    required this.articleUrl,
    required this.articleTitle,
    this.hideOpenInMedium = false,
  });

  @override
  State<ArticleBottomBar> createState() => _ArticleBottomBarState();
}

class _ArticleBottomBarState extends State<ArticleBottomBar> {
  int _clapCount = 0;
  int _commentCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(color: context.colorScheme.tertiary, width: 1),
        ),
      ),
      // padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Clap button
          _BottomBarButton(
            assetIcon: AppAssets.clap,
            label: _clapCount == 0 ? '--' : _clapCount.toString(),
            tooltip: 'Claps',
          ),

          // Comment button
          _BottomBarButton(
            assetIcon: AppAssets.comment,
            label: _commentCount == 0 ? '--' : _commentCount.toString(),
            tooltip: 'Comments',
          ),

          // Open in Medium (conditionally shown)
          if (!widget.hideOpenInMedium)
            _BottomBarButton(
              assetIcon: AppAssets.redirect,
              onTap: () => handleOpenInMedium(widget.articleUrl),
              tooltip: 'Open in Medium',
            ),

          // Share button
          _BottomBarButton(
            assetIcon: AppAssets.share,
            onTap: () =>
                handleShareArticle(widget.articleTitle, widget.articleUrl),
            tooltip: 'Share',
          ),
        ],
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final String? assetIcon;
  final String? label;
  final VoidCallback? onTap;
  final bool isActive;
  final String? tooltip;

  const _BottomBarButton({
    this.assetIcon,
    this.label,
    this.onTap,
    this.isActive = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (assetIcon != null)
                    Image.asset(
                      assetIcon!,
                      width: 24,
                      height: 24,
                      color: context.colorScheme.onSurface,
                    ),
                  if (label != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      label!,
                      style: context.textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? context.colorScheme.secondary
                            : context.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
