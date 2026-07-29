import 'dart:io';
import 'dart:typed_data';

import 'package:billey/features/speech/application/speech_assistant_controller.dart';
import 'package:billey/features/speech/application/speech_assistant_state.dart';
import 'package:billey/features/speech/domain/generate_speech_use_case.dart';
import 'package:billey/features/speech/domain/result.dart';
import 'package:billey/features/speech/domain/speech_entities.dart';
import 'package:billey/features/speech/domain/speech_repository.dart';
import 'package:billey/features/speech/domain/transcribe_audio_use_case.dart';
import 'package:billey/features/speech/services/audio_playback_service.dart';
import 'package:billey/features/speech/services/audio_recorder_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late File recording;
  late _FakeRecorder recorder;
  late _FakePlayback playback;
  late _FakeRepository repository;
  late SpeechAssistantController controller;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('speech-controller');
    recording = File('${directory.path}/recording.m4a');
    await recording.writeAsBytes([1, 2, 3]);
    recorder = _FakeRecorder(recording.path);
    playback = _FakePlayback();
    repository = _FakeRepository();
    controller = SpeechAssistantController(
      recorder: recorder,
      playback: playback,
      transcribeAudio: TranscribeAudioUseCase(repository),
      generateSpeech: GenerateSpeechUseCase(repository),
    );
  });

  tearDown(() async {
    controller.dispose();
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('emits recording states in order', () async {
    final states = <SpeechAssistantStatus>[];
    controller.addListener(() => states.add(controller.state.status));

    await controller.startRecording();

    expect(states, [
      SpeechAssistantStatus.requestingPermission,
      SpeechAssistantStatus.recording,
    ]);
  });

  test('transcribes, emits success and removes temporary recording', () async {
    final states = <SpeechAssistantStatus>[];
    controller.addListener(() => states.add(controller.state.status));
    await controller.startRecording();

    await controller.stopRecordingAndTranscribe();

    expect(
      states,
      containsAllInOrder([
        SpeechAssistantStatus.stoppingRecording,
        SpeechAssistantStatus.transcribing,
        SpeechAssistantStatus.transcriptionSuccess,
      ]),
    );
    expect(controller.state.transcript?.text, 'texto transcrito');
    expect(await recording.exists(), isFalse);
  });

  test('prevents simultaneous recording starts', () async {
    await Future.wait([
      controller.startRecording(),
      controller.startRecording(),
    ]);

    expect(recorder.startCalls, 1);
  });

  test('emits failure while preserving previous transcript', () async {
    await controller.startRecording();
    await controller.stopRecordingAndTranscribe();
    repository.synthesisFailure = const ValidationFailure('falló');

    await controller.generateAndPlaySpeech('confirmación');

    expect(controller.state.status, SpeechAssistantStatus.failure);
    expect(controller.state.transcript?.text, 'texto transcrito');
    expect(controller.state.errorMessage, 'falló');
  });

  test('resetSession clears transcript and returns to initial state', () async {
    await controller.startRecording();
    await controller.stopRecordingAndTranscribe();
    expect(controller.state.transcript?.text, 'texto transcrito');

    controller.resetSession();

    expect(controller.state.status, SpeechAssistantStatus.initial);
    expect(controller.state.transcript, isNull);
    expect(controller.state.errorMessage, isNull);
  });
}

class _FakeRecorder implements AudioRecorderService {
  _FakeRecorder(this.path);

  final String path;
  int startCalls = 0;
  bool recording = false;

  @override
  Future<double> get currentAmplitudeDb async => -160;

  @override
  Future<void> cancel() async => recording = false;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<bool> get isRecording async => recording;

  @override
  Future<void> start() async {
    startCalls++;
    recording = true;
  }

  @override
  Future<RecordedAudio> stop() async {
    recording = false;
    return RecordedAudio(path: path, mimeType: 'audio/mp4');
  }
}

class _FakePlayback implements AudioPlaybackService {
  @override
  Future<void> dispose() async {}

  @override
  Future<void> play(GeneratedAudio audio) async {}

  @override
  Future<void> stop() async {}
}

class _FakeRepository implements SpeechRepository {
  SpeechFailure? synthesisFailure;

  @override
  Future<Result<GeneratedAudio>> synthesize({required String text}) async {
    final failure = synthesisFailure;
    if (failure != null) return ErrorResult(failure);
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
    return const Success(Transcript(text: 'texto transcrito'));
  }
}
