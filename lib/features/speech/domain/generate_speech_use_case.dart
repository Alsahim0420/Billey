import 'result.dart';
import 'speech_entities.dart';
import 'speech_repository.dart';

class GenerateSpeechUseCase {
  const GenerateSpeechUseCase(this._repository);

  final SpeechRepository _repository;

  Future<Result<GeneratedAudio>> call(String text) {
    final normalized = text.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const ErrorResult(
          ValidationFailure('El texto para reproducir no puede estar vacío.'),
        ),
      );
    }
    return _repository.synthesize(text: normalized);
  }
}
