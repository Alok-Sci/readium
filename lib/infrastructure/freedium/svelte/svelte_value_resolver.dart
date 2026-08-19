import 'package:readium/infrastructure/freedium/svelte/svelte_parse_exception.dart';

/// Special-form tags this resolver knows how to handle. SvelteKit's
/// `devalue`-based serializer uses a 2-element array whose first entry
/// is one of these strings to encode values plain JSON can't represent
/// directly (dates, pending promises, ...).
///
/// Only `Promise` (used for Freedium's streamed/deferred feed data) and
/// `Date` are implemented — both are what we've actually observed or can
/// safely predict from `devalue`'s public format. Anything else throws
/// rather than silently guessing at an unverified encoding.
const _knownSpecialTags = {'Promise', 'Date'};

/// Resolves one "flat", devalue-encoded array — as produced by SvelteKit
/// for its `__data.json` endpoints — into a plain Dart object graph of
/// [Map], [List], [String], [num], [bool], [DateTime] and `null`.
///
/// ### The encoding, in a nutshell
///
/// SvelteKit flattens and deduplicates the page's serialized data into
/// one JSON array. Each element of that array is a "descriptor" for the
/// value at that index:
///
/// - A primitive (`String`, `num`, `bool`, `null`) at index `i` IS the
///   final value for `i` — nothing further to resolve.
/// - An object (`Map`) at index `i` describes a plain object; each of
///   its VALUES is itself an index into the flat array, resolved
///   recursively. Keys are left as-is.
/// - An array of ints at index `i` describes a plain array the same
///   way — every element is an index to resolve.
/// - A 2-element array tagged with a known type (e.g. `["Date", 7]`)
///   is a special value — see [_resolveSpecial].
/// - The index `-1` is devalue's sentinel for `undefined` (it can never
///   be a real array position) and always resolves to `null`.
///
/// A resolver instance is single-use per flat array (it caches by index
/// to avoid re-resolving shared/deduplicated values, and to stay
/// well-behaved if a future payload ever contains a genuine reference
/// cycle).
class SvelteValueResolver {
  SvelteValueResolver(this._flat, {Map<int, dynamic>? promiseOverrides})
      : _promiseOverrides = promiseOverrides ?? const {};

  final List<dynamic> _flat;

  /// Pre-resolved values for `["Promise", _]` slots, keyed by the flat
  /// array index that holds the Promise descriptor (NOT by whatever
  /// number sits inside the descriptor itself — see
  /// `SvelteResponseDecoder` for why). Supplied by the caller once it has
  /// matched a deferred slot against a streamed "chunk" line.
  final Map<int, dynamic> _promiseOverrides;

  final Map<int, dynamic> _cache = {};

  /// Resolves the value at [index], recursively resolving any nested
  /// references, starting from the root at index `0`.
  dynamic resolve(int index) {
    if (index == -1) return null; // devalue's `undefined` sentinel

    if (_cache.containsKey(index)) return _cache[index];

    if (index < 0 || index >= _flat.length) {
      throw SvelteDataParseException(
        'Reference index $index is out of range for a flat array of '
        'length ${_flat.length}. Freedium likely changed its payload '
        'shape — this decoder needs updating.',
      );
    }

    final raw = _flat[index];
    dynamic resolved;

    if (raw == null || raw is String || raw is num || raw is bool) {
      resolved = raw;
    } else if (raw is List) {
      if (raw.isNotEmpty &&
          raw.first is String &&
          _knownSpecialTags.contains(raw.first)) {
        resolved = _resolveSpecial(index, raw);
      } else {
        resolved = raw.map((e) => resolve(e as int)).toList(growable: false);
      }
    } else if (raw is Map) {
      resolved = raw.map<String, dynamic>(
        (key, value) => MapEntry(key as String, resolve(value as int)),
      );
    } else {
      throw SvelteDataParseException(
        'Unrecognized descriptor type ${raw.runtimeType} at index $index.',
      );
    }

    _cache[index] = resolved;
    return resolved;
  }

  dynamic _resolveSpecial(int index, List<dynamic> raw) {
    final tag = raw.first as String;
    switch (tag) {
      case 'Promise':
        // The initial payload can never inline a still-pending promise's
        // value — it just marks the slot. If the caller matched this
        // slot to a resolved streamed chunk, use that; otherwise it's
        // genuinely unresolved (e.g. a route we haven't wired chunk
        // correlation for yet).
        return _promiseOverrides[index];
      case 'Date':
        final millis = resolve(raw[1] as int) as num;
        return DateTime.fromMillisecondsSinceEpoch(
          millis.toInt(),
          isUtc: true,
        );
      default:
        throw SvelteDataParseException('Unsupported special tag "$tag".');
    }
  }
}
