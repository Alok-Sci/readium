/// Thrown when a SvelteKit `__data.json` response can't be decoded.
///
/// In practice this means Freedium has changed its SvelteKit version or
/// route shape, and the decoding logic in this `svelte_data` package
/// needs a look — the [message] is written to make that diagnosis fast.
class SvelteDataParseException implements Exception {
  const SvelteDataParseException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'SvelteDataParseException: $message'
      : 'SvelteDataParseException: $message (cause: $cause)';
}
