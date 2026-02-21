import 'package:flutter/material.dart';

// error color : #c94a4a
// primaryColor : #1a8917

/// Medium Mobile Design Tokens (iOS/Android WebView equivalent)
class AppTheme {
  static ColorScheme get lightColorScheme => ColorScheme.light(
    background: lightBackground,
    surface: lightSurface,
    primary: lightPrimaryText,
    secondary: lightSecondaryText,
    tertiary: lightCodeBg,
    tertiaryContainer: lightCodeBorder,
    error: errorColor,
  );
  static ColorScheme get darkColorScheme => ColorScheme.dark(
    background: darkBackground,
    surface: darkSurface,
    primary: darkPrimaryText,
    secondary: darkSecondaryText,
    tertiary: darkCodeBg,
    tertiaryContainer: darkCodeBorder,
    error: errorColor,
  );

  /// Error and Primary Colors
  static const Color errorColor = Color(0xFFC94A4A); // #c94a4a
  static const Color primaryColor = Color(0xFF1A8917); // #1a8917

  /// Light Mode Colors (Mobile)
  static const Color lightBackground = Color(0xFFFFFFFF); // #fff
  static const Color lightSurface = Color.fromARGB(
    255,
    255,
    255,
    255,
  ); // #fafafa
  static const Color lightPrimaryText = Color(0xFF242424); // #242424 (headings)
  static const Color lightSecondaryText = Color(
    0xFF6B6B6B,
  ); // #6b6b6b (subtitle/meta)
  static const Color lightCodeBg = Color(0xFFF2F2F2); // #f7f7f7
  static const Color lightCodeBorder = Color(0xFFE1E1E1); // #e1e1e1
  static const Color lightAccent = Color(0xFF00AB6B); // Medium green

  /// Dark Mode Colors (Mobile)
  static const Color darkBackground = Color(0xFF121212); // #121212
  static const Color darkSurface = Color(0xFF1C1C1E); // #1c1c1e
  static const Color darkPrimaryText = Color(0xFFE8E8E8); // #e8e8e8
  static const Color darkSecondaryText = Color(0xFF8E8E93); // #8e8e93
  static const Color darkCodeBg = Color(0xFF2D2D2D); // #2d2d2d
  static const Color darkCodeBorder = Color(0xFF404040); // #404040
  static const Color darkAccent = Color(0xFF00D084); // Dark green

  /// Typography (Mobile-first: 375px viewport)
  static const double screenPadding = 20.0; // Mobile content padding
  static const double lineHeightMultiplier = 1.5;
  static const double letterSpacingBody = -0.01;

  /// Font Families (Medium's custom stack)
  static final TextStyle sohne = TextStyle(
    fontFamily: 'sohne',
    fontWeight: FontWeight.w400,
  );
  static final TextStyle sourceSerifPro = TextStyle(
    fontFamily: 'source-serif-pro',
    fontFamilyFallback: const [
      'Georgia',
      'Cambria',
      'Times New Roman',
      'Times',
      'serif',
    ],
  );
  static final TextStyle sourceCodePro = TextStyle(
    fontFamily: 'source-code-pro',
    fontFamilyFallback: [
      "Menlo",
      "Monaco",
      "Courier New",
      "Courier",
      "monospace",
    ],
  );

  /// Light Theme Typography Styles (Mobile)
  static TextStyle lightTitle(BuildContext context) => sohne.copyWith(
    fontSize: 32, // h1 mobile
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: lightPrimaryText,
  );

  static TextStyle lightScreenTitle(BuildContext context) => sohne.copyWith(
    fontSize: 26, // h1 mobile
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
    color: lightPrimaryText,
  );

  static TextStyle lightSubtitle(BuildContext context) => sohne.copyWith(
    fontSize: 20, // h2 mobile
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
    color: lightSecondaryText,
  );

  static TextStyle lightHeading(BuildContext context) => sohne.copyWith(
    fontSize: 22, // h3 mobile
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
    color: lightPrimaryText,
  );

  static TextStyle lightSubheading(BuildContext context) => sohne.copyWith(
    fontSize: 20, // h4 mobile
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: 0,
    color: lightPrimaryText,
  );

  static TextStyle lightBody(BuildContext context) => sourceSerifPro.copyWith(
    fontSize: 19, // Body mobile (16-18px scale)
    fontWeight: FontWeight.w400,
    height: lineHeightMultiplier,
    letterSpacing: -0.054,
    color: lightPrimaryText,
  );

  static TextStyle lightMeta(BuildContext context) => sohne.copyWith(
    fontSize: 14, // Author name
    fontWeight: FontWeight.w400,
    color: lightPrimaryText,
  );

  static TextStyle lightCaption(BuildContext context) => sohne.copyWith(
    fontSize: 14, // Meta/read time
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: lightSecondaryText,
  );

  static TextStyle lightCodeInline(BuildContext context) =>
      sourceCodePro.copyWith(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: lightPrimaryText,
        backgroundColor: lightCodeBg,
      );

  static TextStyle lightCodeBlock(BuildContext context) =>
      sourceCodePro.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: -5.6,
        letterSpacing: -0.308,
        color: lightPrimaryText,
      );

  /// Dark Theme Typography Styles (Mobile)
  static TextStyle darkTitle(BuildContext context) =>
      lightTitle(context).copyWith(color: darkPrimaryText);

  static TextStyle darkScreenTitle(BuildContext context) =>
      lightScreenTitle(context).copyWith(color: darkPrimaryText.withAlpha(210));

  static TextStyle darkSubtitle(BuildContext context) =>
      lightSubtitle(context).copyWith(color: darkPrimaryText);

  static TextStyle darkHeading(BuildContext context) =>
      lightHeading(context).copyWith(color: darkPrimaryText);

  static TextStyle darkSubheading(BuildContext context) =>
      lightSubheading(context).copyWith(color: darkPrimaryText);

  static TextStyle darkBody(BuildContext context) =>
      lightBody(context).copyWith(color: darkPrimaryText);

  static TextStyle darkMeta(BuildContext context) =>
      lightMeta(context).copyWith(color: darkPrimaryText);
  static TextStyle darkCaption(BuildContext context) =>
      lightCaption(context).copyWith(color: darkSecondaryText);

  static TextStyle darkCodeInline(BuildContext context) => lightCodeInline(
    context,
  ).copyWith(color: darkPrimaryText, backgroundColor: darkCodeBg);

  static TextStyle darkCodeBlock(BuildContext context) => lightCodeBlock(
    context,
  ).copyWith(color: darkPrimaryText, backgroundColor: darkCodeBg);

  /// ThemeData for Flutter (Mobile)
  static ThemeData lightTheme(BuildContext context) => ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: lightColorScheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightPrimaryText,
      surfaceTintColor: lightBackground,
      iconTheme: IconThemeData(color: lightSecondaryText),
      elevation: 4,
    ),
    textTheme: TextTheme(
      displayLarge: lightTitle(context),
      displayMedium: lightScreenTitle(context),
      displaySmall: lightSubtitle(context),
      headlineMedium: lightHeading(context),
      headlineSmall: lightSubheading(context),
      bodyLarge: lightBody(context),
      bodySmall: lightCodeInline(context),
      labelLarge: lightMeta(context), // for author name
      labelMedium: lightCaption(context), // for caption and meta
      labelSmall: lightCodeBlock(context),
    ),
  );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: darkColorScheme,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkPrimaryText,
      surfaceTintColor: darkBackground,
      iconTheme: IconThemeData(color: darkSecondaryText),
      elevation: 0,
    ),
    textTheme: TextTheme(
      displayLarge: darkTitle(context),
      displayMedium: darkScreenTitle(context),
      displaySmall: darkSubtitle(context),
      headlineMedium: darkHeading(context),
      headlineSmall: darkSubheading(context),
      bodyLarge: darkBody(context),
      bodySmall: darkCodeInline(context),
      labelLarge: darkMeta(context), // for author name
      labelMedium: darkCaption(context), // for caption and meta
      labelSmall: darkCodeInline(context),
    ),
  );

  /// Spacing (Mobile)
  static const EdgeInsets screenPaddingEdgeInsets = EdgeInsets.all(
    screenPadding,
  );
  static const double blockSpacing = 24.0; // Between sections
  static const double paraSpacing = 28.0; // Paragraph top margin
}
