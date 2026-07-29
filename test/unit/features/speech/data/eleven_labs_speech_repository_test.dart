import 'dart:typed_data';

import 'package:billey/features/speech/data/eleven_labs_exception.dart';
import 'package:billey/features/speech/data/eleven_labs_remote_data_source.dart';
import 'package:billey/features/speech/data/eleven_labs_speech_repository.dart';
import 'package:billey/features/speech/data/speech_dtos.dart';
import 'package:billey/features/speech/domain/result.dart';
import 'package:billey/features/speech/domain/speech_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps transcription DTO to domain', () async {
    final repository = ElevenLabsSpeechRepository(
      _FakeRemoteDataSource(
        transcript: const SpeechToTextResponseDto(
          text: 'texto',
          languageCode: 'es',
        ),
      ),
    );

    final result = await repository.transcribe(
      audio: const RecordedAudio(path: 'ignored', mimeType: 'audio/mp4'),
    );

    expect(result, isA<Success<Transcript>>());
    expect((result as Success<Transcript>).value.text, 'texto');
  });

  test('maps technical exception to failure', () async {
    final repository = ElevenLabsSpeechRepository(
      _FakeRemoteDataSource(
        error: const ElevenLabsException(
          ElevenLabsErrorKind.quotaExceeded,
          'cuota',
          statusCode: 429,
        ),
      ),
    );

    final result = await repository.synthesize(text: 'hola');

    expect(result, isA<ErrorResult<GeneratedAudio>>());
    expect(
      (result as ErrorResult<GeneratedAudio>).failure,
      isA<QuotaExceededFailure>(),
    );
  });

  test('does not leak unknown technical exceptions', () async {
    final repository = ElevenLabsSpeechRepository(
      _FakeRemoteDataSource(error: StateError('secret body')),
    );

    final result = await repository.synthesize(text: 'hola');
    final failure = (result as ErrorResult<GeneratedAudio>).failure;

    expect(failure, isA<UnknownFailure>());
    expect(failure.message, isNot(contains('secret body')));
  });
}

class _FakeRemoteDataSource implements ElevenLabsRemoteDataSource {
  _FakeRemoteDataSource({this.transcript, this.error});

  final SpeechToTextResponseDto? transcript;
  final Object? error;

  @override
  Future<GeneratedAudioDto> synthesize(String text) async {
    if (error != null) throw error!;
    return GeneratedAudioDto(
      bytes: Uint8List.fromList([1]),
      mimeType: 'audio/mpeg',
      format: 'mp3',
    );
  }

  @override
  Future<SpeechToTextResponseDto> transcribe(RecordedAudio audio) async {
    if (error != null) throw error!;
    return transcript ?? const SpeechToTextResponseDto(text: 'texto');
  }
}
