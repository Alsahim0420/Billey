import '../config/configuration_exception.dart';
import '../domain/result.dart';
import '../domain/speech_entities.dart';
import '../domain/speech_repository.dart';
import 'eleven_labs_exception.dart';
import 'eleven_labs_remote_data_source.dart';

class ElevenLabsSpeechRepository implements SpeechRepository {
  const ElevenLabsSpeechRepository(this._remoteDataSource);

  final ElevenLabsRemoteDataSource _remoteDataSource;

  @override
  Future<Result<GeneratedAudio>> synthesize({required String text}) async {
    try {
      final dto = await _remoteDataSource.synthesize(text);
      return Success(dto.toDomain());
    } catch (error) {
      return ErrorResult(_mapFailure(error));
    }
  }

  @override
  Future<Result<Transcript>> transcribe({required RecordedAudio audio}) async {
    try {
      final dto = await _remoteDataSource.transcribe(audio);
      return Success(dto.toDomain());
    } catch (error) {
      return ErrorResult(_mapFailure(error));
    }
  }

  SpeechFailure _mapFailure(Object error) {
    if (error is ConfigurationException) {
      return ConfigurationFailure(error.message);
    }
    if (error is! ElevenLabsException) {
      return const UnknownFailure('Ocurrió un error inesperado con la voz.');
    }

    final details = [
      if (error.statusCode != null) 'HTTP ${error.statusCode}',
      if (error.debugDetails != null) error.debugDetails,
    ].join(' - ');
    final debugDetails = details.isEmpty ? null : details;

    return switch (error.kind) {
      ElevenLabsErrorKind.noInternet =>
        NoInternetFailure(error.message, debugDetails: debugDetails),
      ElevenLabsErrorKind.unauthorized =>
        UnauthorizedFailure(error.message, debugDetails: debugDetails),
      ElevenLabsErrorKind.forbidden =>
        ForbiddenFailure(error.message, debugDetails: debugDetails),
      ElevenLabsErrorKind.quotaExceeded =>
        QuotaExceededFailure(error.message, debugDetails: debugDetails),
      ElevenLabsErrorKind.invalidAudio =>
        InvalidAudioFailure(error.message, debugDetails: debugDetails),
      ElevenLabsErrorKind.timeout =>
        TimeoutFailure(error.message, debugDetails: debugDetails),
      ElevenLabsErrorKind.api ||
      ElevenLabsErrorKind.invalidResponse =>
        ApiFailure(error.message, debugDetails: debugDetails),
    };
  }
}
