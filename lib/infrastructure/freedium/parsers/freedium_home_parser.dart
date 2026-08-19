import 'package:readium/infrastructure/freedium/models/feed_page_result.dart';
import 'package:readium/infrastructure/freedium/svelte/svelte_data_parser.dart';

/// Parses a `freedium-mirror.cfd/__data.json` response (the home feed)
/// into a [FeedPageResult].
///
/// All SvelteKit/devalue decoding is inherited from [SvelteDataParser] —
/// this class's only job is mapping the generic resolved page data onto
/// the feed model.
///
/// ```dart
/// final response = await http.get(Uri.parse('https://freedium-mirror.cfd/__data.json'));
/// final feed = FreediumHomeParser().parse(response.body);
/// ```
class FreediumHomeParser extends SvelteDataParser<FeedPageResult> {
  @override
  FeedPageResult mapPageData(Map<String, dynamic> pageData) {
    return FeedPageResult.fromResolvedPageData(pageData);
  }
}
