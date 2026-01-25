import 'dart:async';
import 'dart:io';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  Function(String)? _onLinkReceived;

  /// Initialize deep link handling
  Future<void> initialize(Function(String) onLinkReceived) async {
    _onLinkReceived = onLinkReceived;
    
    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleIncomingLink(uri);
      },
      onError: (err) {
        debugPrint('Deep link error: $err');
      },
    );

    // Handle links when app is launched from a link
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }
  }

  /// Handle incoming deep link
  void _handleIncomingLink(Uri uri) {
    debugPrint('Received deep link: $uri');
    
    String? mediumUrl;
    
    // Handle different types of links
    if (uri.scheme == 'readium') {
      // Custom scheme: readium://medium.com/article-path
      if (uri.host == 'medium.com' || uri.host.endsWith('.medium.com')) {
        mediumUrl = 'https://${uri.host}${uri.path}';
        if (uri.query.isNotEmpty) {
          mediumUrl += '?${uri.query}';
        }
      }
    } else if (uri.scheme == 'https' || uri.scheme == 'http') {
      // Direct HTTP/HTTPS links
      if (uri.host == 'medium.com' || uri.host.endsWith('.medium.com')) {
        mediumUrl = uri.toString();
      }
    }

    // If we have a valid Medium URL, pass it to the callback
    if (mediumUrl != null && _onLinkReceived != null) {
      _onLinkReceived!(mediumUrl);
    }
  }

  /// Check if a URL is a valid Medium URL
  bool isMediumUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      return uri.host == 'medium.com' || uri.host.endsWith('.medium.com');
    } catch (e) {
      return false;
    }
  }

  /// Generate a universal link for sharing
  String generateUniversalLink(String mediumUrl) {
    final encodedUrl = Uri.encodeComponent(mediumUrl);
    final androidStore = Uri.encodeComponent(AppConfig.androidStoreUrl);
    final iosStore = Uri.encodeComponent(AppConfig.iosStoreUrl);
    
    return '${AppConfig.webFallbackUrl}/universal-link.html?url=$encodedUrl&android_store=$androidStore&ios_store=$iosStore';
  }
  
  /// Generate a shareable link that works across platforms
  String generateShareableLink(String mediumUrl) {
    // For sharing, we use the universal link that handles app detection
    return generateUniversalLink(mediumUrl);
  }
  
  /// Launch store URL based on platform
  Future<void> launchStoreUrl() async {
    String storeUrl;
    
    if (Platform.isAndroid) {
      storeUrl = AppConfig.androidStoreUrl;
    } else if (Platform.isIOS) {
      storeUrl = AppConfig.iosStoreUrl;
    } else {
      storeUrl = AppConfig.webFallbackUrl;
    }
    
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch store URL: $storeUrl');
    }
  }
  
  /// Check if the current platform supports the app
  bool isPlatformSupported() {
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _onLinkReceived = null;
  }
}