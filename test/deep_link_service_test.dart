import 'package:flutter_test/flutter_test.dart';
import 'package:readium/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService', () {
    late DeepLinkService deepLinkService;

    setUp(() {
      deepLinkService = DeepLinkService();
    });

    test('should identify valid Medium URLs', () {
      expect(deepLinkService.isMediumUrl('https://medium.com/article'), true);
      expect(deepLinkService.isMediumUrl('https://towardsdatascience.medium.com/article'), true);
      expect(deepLinkService.isMediumUrl('http://medium.com/article'), true);
      expect(deepLinkService.isMediumUrl('https://example.com/article'), false);
      expect(deepLinkService.isMediumUrl('invalid-url'), false);
    });

    test('should handle invalid URLs gracefully', () {
      expect(deepLinkService.isMediumUrl(''), false);
      expect(deepLinkService.isMediumUrl('not-a-url'), false);
      expect(deepLinkService.isMediumUrl('://invalid'), false);
    });
  });
}