// main.dart or app_state.dart
import 'dart:async';

import 'package:receive_sharing_intent_plus/receive_sharing_intent_plus.dart';

class ShareHandler {
  static StreamSubscription? _textSubscription;
  static StreamSubscription? _mediaSubscription;
  static String? _sharedUrl;

  static void initialize(Function(String) onShareReceived) {
    // Listen when app is OPEN (live shares)
    _textSubscription = ReceiveSharingIntentPlus.getTextStream().listen(
      (String? value) {
        if (value != null && value.isNotEmpty) {
          _sharedUrl = _extractMediumUrl(value);
          onShareReceived(_sharedUrl!);
        }
      },
      onError: (err) => print('Share error: $err'),
    );

    // Handle when app was CLOSED (initial share)
    ReceiveSharingIntentPlus.getInitialText().then((String? value) {
      if (value != null && value.isNotEmpty) {
        _sharedUrl = _extractMediumUrl(value);
        onShareReceived(_sharedUrl!);
      }
    });
  }

  static String _extractMediumUrl(String sharedText) {
    // Medium URLs: https://medium.com/@user/article-slug or medium.com links
    final mediumRegex = RegExp(
      r'https?://(?:www\.)?(?:medium\.com/[^/\s]+/[^/\s]+|[^/\s]+\.medium\.com/[^/\s]+)',
      caseSensitive: false,
    );
    final match = mediumRegex.firstMatch(sharedText);
    return match?.group(0) ?? sharedText.trim();
  }

  static void dispose() {
    _textSubscription?.cancel();
    _mediaSubscription?.cancel();
  }
}
