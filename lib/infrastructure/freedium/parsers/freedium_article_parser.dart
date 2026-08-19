
import 'package:readium/infrastructure/freedium/models/freedium_article.dart';
import 'package:readium/infrastructure/freedium/svelte/svelte_data_parser.dart';

/// Parses a `freedium-mirror.cfd/<mediumArticleUrl>/__data.json`
/// response into a [FreediumArticle].
///
/// ```dart
/// final url = Uri.parse('https://freedium-mirror.cfd/$mediumArticleUrl/__data.json');
/// final response = await http.get(url);
/// final article = FreediumArticleParser().parse(response.body);
/// ```
class FreediumArticleParser extends SvelteDataParser<FreediumArticle> {
  @override
  FreediumArticle mapPageData(Map<String, dynamic> pageData) {
    return FreediumArticle.fromResolvedPageData(pageData);
  }
}
