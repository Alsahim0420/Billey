enum ElevenLabsErrorKind {
  noInternet,
  unauthorized,
  forbidden,
  quotaExceeded,
  invalidAudio,
  api,
  timeout,
  invalidResponse,
}

class ElevenLabsException implements Exception {
  const ElevenLabsException(
    this.kind,
    this.message, {
    this.statusCode,
    this.debugDetails,
  });

  final ElevenLabsErrorKind kind;
  final String message;
  final int? statusCode;
  final String? debugDetails;
}
