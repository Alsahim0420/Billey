/// Default decryption key for `assets/config/environment.enc`.
///
/// This is intentionally committed to source so every build — Xcode,
/// Android Studio, plain `flutter build`, CI — decrypts the bundled
/// ElevenLabs configuration without needing a `--dart-define` flag passed
/// at exactly the right time. It only obscures the API key from casual
/// inspection of the asset bundle; it is not a real secret boundary (the
/// key itself ships inside the compiled app either way, and is
/// extractable by anyone with the binary). `--dart-define=ENV_ENCRYPTION_KEY=...`
/// still overrides this when explicitly provided.
const String defaultEnvEncryptionKey =
    'aHdYE2zWrLI1Nu3tHtVsiwFFvXj6g1JQ5W2Jr4gLzPc=';
