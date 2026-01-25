import 'package:flutter/material.dart';
import 'package:readium/core/context_extension.dart';
import 'package:readium/core/theme/app_theme.dart';

class DisplaySettingsBottomSheet extends StatefulWidget {
  final String currentFontFamily;
  final double currentFontSize;
  final Function(String fontFamily, double fontSize, ThemeMode themeMode)
      onSettingsChanged;
  final ThemeMode currentThemeMode;

  const DisplaySettingsBottomSheet({
    super.key,
    required this.currentFontFamily,
    required this.currentFontSize,
    required this.onSettingsChanged,
    required this.currentThemeMode,
  });

  @override
  State<DisplaySettingsBottomSheet> createState() =>
      _DisplaySettingsBottomSheetState();
}

class _DisplaySettingsBottomSheetState
    extends State<DisplaySettingsBottomSheet> {
  late double _selectedFontSize;
  late ThemeMode _selectedThemeMode;

  // Font size percentages - base size is 100% (18pt)
  final double _baseFontSize = 18.0;
  final List<int> _fontSizePercentages = [
    25,
    50,
    75,
    100,
    125,
    150,
    175,
  ];

  @override
  void initState() {
    super.initState();
    _selectedFontSize = widget.currentFontSize;
    _selectedThemeMode = widget.currentThemeMode;
  }

  int _getFontSizePercentage() {
    return ((_selectedFontSize / _baseFontSize) * 100).round();
  }

  double _percentageToFontSize(int percentage) {
    return (_baseFontSize * percentage) / 100;
  }

  void _increaseFontSize() {
    final currentPercentage = _getFontSizePercentage();
    final currentIndex = _fontSizePercentages.indexOf(currentPercentage);

    if (currentIndex < _fontSizePercentages.length - 1) {
      final newPercentage = _fontSizePercentages[currentIndex + 1];
      setState(() {
        _selectedFontSize = _percentageToFontSize(newPercentage);
      });
      widget.onSettingsChanged(
        widget.currentFontFamily,
        _selectedFontSize,
        _selectedThemeMode,
      );
    }
  }

  void _decreaseFontSize() {
    final currentPercentage = _getFontSizePercentage();
    final currentIndex = _fontSizePercentages.indexOf(currentPercentage);

    if (currentIndex > 0) {
      final newPercentage = _fontSizePercentages[currentIndex - 1];
      setState(() {
        _selectedFontSize = _percentageToFontSize(newPercentage);
      });
      widget.onSettingsChanged(
        widget.currentFontFamily,
        _selectedFontSize,
        _selectedThemeMode,
      );
    }
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  IconData _getThemeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  void _showThemeModePopup(BuildContext context, Offset position) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy - 150, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: ThemeMode.values.map((mode) {
        final isSelected = _selectedThemeMode == mode;
        return PopupMenuItem<ThemeMode>(
          value: mode,
          child: Row(
            children: [
              Icon(
                _getThemeModeIcon(mode),
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _getThemeModeLabel(mode),
                style: TextStyle(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(Icons.check, color: context.colorScheme.primary, size: 20),
            ],
          ),
        );
      }).toList(),
      elevation: 8,
    ).then((selectedMode) {
      if (selectedMode != null) {
        setState(() {
          _selectedThemeMode = selectedMode;
        });
        widget.onSettingsChanged(
          widget.currentFontFamily,
          _selectedFontSize,
          _selectedThemeMode,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: context.colorScheme.secondary),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Font Size Controls
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Decrease button
                    _SizeControlButton(
                      label: 'A',
                      fontSize: 18,
                      onTap: _decreaseFontSize,
                      borderSide: BorderSide.none,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            vertical:
                                BorderSide(color: context.colorScheme.tertiary),
                          ),
                        ),
                        // Percentage display
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              '${_getFontSizePercentage()}%',
                              style: context.textTheme.labelLarge?.copyWith(
                                color: context.colorScheme.secondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Increase button
                    _SizeControlButton(
                      label: 'A',
                      fontSize: 22,
                      onTap: _increaseFontSize,
                      borderSide: BorderSide.none,
                    ),
                  ],
                ),

                // Divider
                Divider(
                  height: 1,
                  thickness: 1,
                  color: context.colorScheme.tertiaryContainer,
                ),

                const SizedBox(height: 8),

                // Appearance Tile
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appearance',
                        style: context.textTheme.labelLarge,
                      ),
                      PopupMenuButton<ThemeMode>(
                        onSelected: (selectedMode) {
                          setState(() {
                            _selectedThemeMode = selectedMode;
                          });
                          widget.onSettingsChanged(
                            widget.currentFontFamily,
                            _selectedFontSize,
                            _selectedThemeMode,
                          );
                        },
                        itemBuilder: (context) => ThemeMode.values.map((mode) {
                          final isSelected = _selectedThemeMode == mode;
                          return PopupMenuItem<ThemeMode>(
                            value: mode,
                            child: Row(
                              children: [
                                Icon(
                                  _getThemeModeIcon(mode),
                                  color: isSelected
                                      ? context.colorScheme.primary
                                      : context.colorScheme.secondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _getThemeModeLabel(mode),
                                  style: TextStyle(
                                    color: isSelected
                                        ? context.colorScheme.primary
                                        : context.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                if (isSelected)
                                  Icon(Icons.check,
                                      color: context.colorScheme.primary,
                                      size: 20),
                              ],
                            ),
                          );
                        }).toList(),
                        elevation: 8,
                        child: Text(
                          _getThemeModeLabel(_selectedThemeMode),
                          style: context.textTheme.labelLarge?.copyWith(
                            color: context.colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: context.colorScheme.primary,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Reusable Size Control Button Widget
class _SizeControlButton extends StatelessWidget {
  final String label;
  final double fontSize;
  final VoidCallback onTap;
  final BorderSide borderSide;

  const _SizeControlButton({
    required this.label,
    required this.fontSize,
    required this.onTap,
    required this.borderSide,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppTheme.sourceSerifPro.fontFamily,
                  color: context.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
