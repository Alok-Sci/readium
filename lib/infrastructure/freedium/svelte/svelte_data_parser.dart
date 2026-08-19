import 'package:readium/infrastructure/freedium/svelte/svelte_response_decoder.dart';

/// Base class for parsers that turn a Freedium (SvelteKit) `__data.json`
/// response into a typed domain model.
///
/// This class has exactly one job: locate the resolved "page data" map
/// for a route (via [SvelteResponseDecoder]) and hand it to the
/// subclass. Each subclass has exactly one job of its own: map that
/// generic map onto a domain model it understands — a feed page, an
/// article, and so on. Splitting those two responsibilities is what lets
/// a third Freedium route be supported later by writing one small
/// subclass, without ever touching the devalue-decoding logic.
abstract class SvelteDataParser<T> {
  SvelteDataParser({SvelteResponseDecoder? decoder})
      : _decoder = decoder ?? const SvelteResponseDecoder();

  final SvelteResponseDecoder _decoder;

  /// Parses a raw `__data.json` response body into [T].
  ///
  /// Throws [SvelteDataParseException] if the response isn't a
  /// well-formed SvelteKit data payload.
  T parse(String rawBody) {
    final nodes = _decoder.decode(rawBody);
    return mapPageData(selectPageNode(nodes));
  }

  /// Picks which resolved node holds this route's own data.
  ///
  /// Defaults to the last non-null node: SvelteKit nests route data by
  /// layout depth (`nodes[0]` is the root `+layout`, and so on), and the
  /// page's own `+page` data is always last. Both the home feed and the
  /// article route currently only ever populate the final node, so this
  /// default covers everything this app needs; override it if a future
  /// route needs data merged in from an earlier (layout) node too.
  Map<String, dynamic> selectPageNode(List<dynamic> nodes) {
    final pageNode = nodes.lastWhere((n) => n != null, orElse: () => null);
    if (pageNode is! Map<String, dynamic>) {
      throw StateError(
        'Expected the route\'s page node to resolve to an object, got '
        '${pageNode.runtimeType}. Freedium may have changed its route '
        'structure.',
      );
    }
    return pageNode;
  }

  /// Subclasses implement only this: turn the generic, already-decoded
  /// page-data map into a typed domain model.
  T mapPageData(Map<String, dynamic> pageData);
}
