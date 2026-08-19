import 'dart:convert';

import 'svelte_parse_exception.dart';
import 'svelte_value_resolver.dart';

/// Decodes a raw SvelteKit `__data.json` HTTP response body — newline
/// delimited JSON — into a list of fully-resolved values, one per entry
/// in the route's `nodes` array (`null` for a layout with no data of its
/// own, a resolved [Map]/[List]/primitive otherwise).
///
/// This class only understands SvelteKit's generic wire protocol; it has
/// no idea what a "feed" or an "article" is — that's deliberate. Keeping
/// this envelope-level decoding separate from Freedium-specific field
/// mapping (done in [SvelteDataParser] subclasses) means a change to
/// either one never risks breaking the other.
class SvelteResponseDecoder {
  const SvelteResponseDecoder();

  List<dynamic> decode(String rawBody) {
    final lines = rawBody
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList(growable: false);

    if (lines.isEmpty) {
      throw const SvelteDataParseException('Empty __data.json response.');
    }

    final parsedLines = <Map<String, dynamic>>[];
    for (final line in lines) {
      try {
        parsedLines.add(jsonDecode(line) as Map<String, dynamic>);
      } on FormatException catch (e) {
        throw SvelteDataParseException(
          'Response was not valid NDJSON. Freedium may be returning an '
          'error page instead of __data.json.',
          e,
        );
      }
    }

    final dataLine = parsedLines.firstWhere(
      (l) => l['type'] == 'data',
      orElse: () => throw const SvelteDataParseException(
        'No "data" line found in the __data.json response.',
      ),
    );

    final chunksById = <int, List<dynamic>>{
      for (final line in parsedLines)
        if (line['type'] == 'chunk')
          line['id'] as int: line['data'] as List<dynamic>,
    };
    // Chunk ids not yet claimed by a node-index match, oldest first — a
    // best-effort fallback, see the note in _resolveNode below.
    final unmatchedChunkIds = chunksById.keys.toList();

    final nodes = dataLine['nodes'] as List<dynamic>;
    return [
      for (var nodeIndex = 0; nodeIndex < nodes.length; nodeIndex++)
        nodes[nodeIndex] == null
            ? null
            : _resolveNode(
                nodes[nodeIndex] as Map<String, dynamic>,
                nodeIndex,
                chunksById,
                unmatchedChunkIds,
              ),
    ];
  }

  dynamic _resolveNode(
    Map<String, dynamic> node,
    int nodeIndex,
    Map<int, List<dynamic>> chunksById,
    List<int> unmatchedChunkIds,
  ) {
    final flat = node['data'] as List<dynamic>;

    // Find any pending-promise slots (Freedium uses these for the home
    // feed, which loads behind a skeleton while the real cards stream
    // in) and supply their eventual value from a matching "chunk" line.
    //
    // CAVEAT: SvelteKit's exact rule for correlating a promise
    // placeholder with the chunk that resolves it isn't publicly
    // documented. Empirically, Freedium sends one chunk per node whose
    // `id` equals that *node's* index in the `nodes` array, so that's
    // tried first; if it doesn't match, chunks are consumed in arrival
    // order as a fallback. If a page ever has more than one deferred
    // field per node this fallback could mis-pair them — a
    // [SvelteDataParseException] or an oddly-empty field downstream is
    // the signal to revisit this rather than trust it blindly.
    final promiseOverrides = <int, dynamic>{};
    for (var i = 0; i < flat.length; i++) {
      final entry = flat[i];
      final isPromiseSlot =
          entry is List && entry.length == 2 && entry.first == 'Promise';
      if (!isPromiseSlot) continue;

      List<dynamic>? chunkData;
      if (chunksById.containsKey(nodeIndex)) {
        chunkData = chunksById[nodeIndex];
        unmatchedChunkIds.remove(nodeIndex);
      } else if (unmatchedChunkIds.isNotEmpty) {
        chunkData = chunksById[unmatchedChunkIds.removeAt(0)];
      }

      if (chunkData != null) {
        promiseOverrides[i] = SvelteValueResolver(chunkData).resolve(0);
      }
    }

    return SvelteValueResolver(flat, promiseOverrides: promiseOverrides)
        .resolve(0);
  }
}
