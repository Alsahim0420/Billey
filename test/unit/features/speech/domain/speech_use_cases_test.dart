import 'dart:io';
import 'dart:typed_data';

import 'package:billey/features/speech/domain/generate_speech_use_case.dart';
import 'package:billey/features/speech/domain/result.dart';
import 'package:billey/features/speech/domain/speech_entities.dart';
import 'package:billey/features/speech/domain/speech_repository.dart';
import 'package:billey/features/speech/domain/transcribe_audio_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _FakeSpeechRepository repository;

  setUp(() {
    repository = _FakeSpeechRepository();
  });

  test('GenerateSpeechUseCase rejects blank text', () async {
    final result = await GenerateSpeechUseCase(repository)('   ');

    expect(result, isA<ErrorResult<GeneratedAudio>>());
    expect(repository.synthesizeCalls, 0);
  });

  test('GenerateSpeechUseCase delegates normalized text', () async {
    final result = await GenerateSpeechUseCase(repository)(' hola ');

    expect(result, isA<Success<GeneratedAudio>>());
    expect(repository.lastText, 'hola');
  });

  test('TranscribeAudioUseCase rejects a missing file', () async {
    final result = await TranscribeAudioUseCase(repository)(
      const RecordedAudio(path: '/missing/audio.m4a', mimeType: 'audio/mp4'),
    );

    expect(result, isA<ErrorResult<Transcript>>());
    expect(repository.transcribeCalls, 0);
  });

  test('TranscribeAudioUseCase rejects an empty file', () async {
    final directory = await Directory.systemTemp.createTemp('speech-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/empty.m4a');
    await file.create();

    final result = await TranscribeAudioUseCase(repository)(
      RecordedAudio(path: file.path, mimeType: 'audio/mp4'),
    );

    expect(result, isA<ErrorResult<Transcript>>());
    expect(repository.transcribeCalls, 0);
  });

  test('TranscribeAudioUseCase delegates a valid recording', () async {
    final directory = await Directory.systemTemp.createTemp('speech-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/audio.m4a');
    await file.writeAsBytes([1, 2, 3]);

    final result = await TranscribeAudioUseCase(repository)(
      RecordedAudio(path: file.path, mimeType: 'audio/mp4'),
    );

    expect(result, isA<Success<Transcript>>());
    expect(repository.transcribeCalls, 1);
  });
}

class _FakeSpeechRepository implements SpeechRepository {
  int synthesizeCalls = 0;
  int transcribeCalls = 0;
  String? lastText;

  @override
  Future<Result<GeneratedAudio>> synthesize({required String text}) async {
    synthesizeCalls++;
    lastText = text;
    return Success(
      GeneratedAudio(
        bytes: Uint8List.fromList([1]),
        mimeType: 'audio/mpeg',
        format: 'mp3',
      ),
    );
  }

  @override
  Future<Result<Transcript>> transcribe({required RecordedAudio audio}) async {
    transcribeCalls++;
    return const Success(Transcript(text: 'transcripción'));
  }
}
