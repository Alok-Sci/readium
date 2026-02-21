class AppConfig {
  // Store URLs for app redirection when app is not installed
  static const String androidStoreUrl = String.fromEnvironment(
    'ANDROID_STORE_URL',
    defaultValue:
        'https://play.google.com/store/apps/details?id=com.readium.app',
  );

  static const String iosStoreUrl = String.fromEnvironment(
    'IOS_STORE_URL',
    defaultValue: 'https://apps.apple.com/app/readium/id123456789',
  );

  // Web fallback URL for universal links
  static const String webFallbackUrl = String.fromEnvironment(
    'WEB_FALLBACK_URL',
    defaultValue: 'https://alok-sci.github.io/readium',
  );

  // Custom scheme for the app
  static const String customScheme = 'readium';

  // Domain for universal links
  static const String universalLinkDomain = String.fromEnvironment(
    'UNIVERSAL_LINK_DOMAIN',
    defaultValue: 'readium.app',
  );
}
