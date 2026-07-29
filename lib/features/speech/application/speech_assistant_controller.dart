import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../domain/generate_speech_use_case.dart';
import '../domain/result.dart';
import '../domain/speech_entities.dart';
import '../domain/transcribe_audio_use_case.dart';
import '../services/audio_playback_service.dart';
import '../services/audio_recorder_service.dart';
import 'speech_assistant_state.dart';

class SpeechAssistantController extends ChangeNotifier {
  SpeechAssistantController({
    required AudioRecorderService recorder,
    required AudioPlaybackService playback,
    required TranscribeAudioUseCase transcribeAudio,
    required GenerateSpeechUseCase generateSpeech,
  })  : _recorder = recorder,
        _playback = playback,
        _transcribeAudio = transcribeAudio,
        _generateSpeech = generateSpeech;

  SpeechAssistantController.unavailable(String message)
      : _recorder = null,
        _playback = null,
        _transcribeAudio = null,
        _generateSpeech = null,
        _state = SpeechAssistantState(
          status: SpeechAssistantStatus.unavailable,
          errorMessage: message,
        );

  final AudioRecorderService? _recorder;
  final AudioPlaybackService? _playback;
  final TranscribeAudioUseCase? _transcribeAudio;
  final GenerateSpeechUseCase? _generateSpeech;
  Timer? _silenceTimer;
  DateTime? _recordingStartedAt;
  DateTime? _lastSpeechAt;
  bool _speechDetected = false;
  bool _checkingAmplitude = false;

  SpeechAssistantState _state = const SpeechAssistantState();
  SpeechAssistantState get state => _state;

  Future<void> startRecording() async {
    if (_recorder == null) {
      _emit(_state);
      return;
    }
    if (_state.isBusy || _state.status == SpeechAssistantStatus.recording) {
      return;
    }
    _emit(_state.copyWith(
      status: SpeechAssistantStatus.requestingPermission,
      clearError: true,
    ));
    try {
      if (!await _recorder.hasPermission()) {
        _fail('Activa el permiso del micrófono para grabar.');
        return;
      }
      await _recorder.start();
      _emit(_state.copyWith(status: SpeechAssistantStatus.recording));
      _startSilenceDetection();
    } catch (_) {
      _fail('No se pudo iniciar la grabación.');
    }
  }

  Future<void> stopRecordingAndTranscribe() async {
    if (_state.status != SpeechAssistantStatus.recording ||
        _recorder == null ||
        _transcribeAudio == null) {
      return;
    }
    RecordedAudio? recording;
    try {
      _stopSilenceDetection();
      _emit(_state.copyWith(status: SpeechAssistantStatus.stoppingRecording));
      recording = await _recorder.stop();
      _emit(_state.copyWith(status: SpeechAssistantStatus.transcribing));
      final result = await _transcribeAudio(recording);
      switch (result) {
        case Success<Transcript>():
          _emit(SpeechAssistantState(
            status: SpeechAssistantStatus.transcriptionSuccess,
            transcript: result.value,
          ));
        case ErrorResult<Transcript>():
          _fail(result.failure.message);
      }
    } catch (_) {
      _fail('No se pudo transcribir la grabación.');
    } finally {
      if (recording != null) {
        await _deleteIfExists(recording.path);
      }
    }
  }

  Future<void> cancelRecording() async {
    if (_recorder == null) return;
    try {
      _stopSilenceDetection();
      await _recorder.cancel();
      _emit(_state.copyWith(
        status: SpeechAssistantStatus.stopped,
        clearError: true,
      ));
    } catch (_) {
      _fail('No se pudo cancelar la grabación.');
    }
  }

  void _startSilenceDetection() {
    _stopSilenceDetection();
    _recordingStartedAt = DateTime.now();
    _speechDetected = false;
    _silenceTimer = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => _checkForSilence(),
    );
  }

  Future<void> _checkForSilence() async {
    if (_checkingAmplitude ||
        _state.status != SpeechAssistantStatus.recording ||
        _recorder == null) {
      return;
    }
    _checkingAmplitude = true;
    try {
      final now = DateTime.now();
      final startedAt = _recordingStartedAt ?? now;
      final amplitude = await _recorder.currentAmplitudeDb;
      if (amplitude > -42) {
        _speechDetected = true;
        _lastSpeechAt = now;
      }
      final finishedSpeaking = _speechDetected &&
          _lastSpeechAt != null &&
          now.difference(_lastSpeechAt!) >= const Duration(milliseconds: 1200);
      final reachedMaximum =
          now.difference(startedAt) >= const Duration(seconds: 15);
      if (finishedSpeaking || reachedMaximum) {
        await stopRecordingAndTranscribe();
      }
    } catch (_) {
      // Si el dispositivo no informa amplitud, aún se puede detener a mano.
    } finally {
      _checkingAmplitude = false;
    }
  }

  void _stopSilenceDetection() {
    _silenceTimer?.cancel();
    _silenceTimer = null;
    _recordingStartedAt = null;
    _lastSpeechAt = null;
  }

  Future<void> generateAndPlaySpeech(String text) async {
    if (_state.isBusy || _generateSpeech == null || _playback == null) return;
    _emit(_state.copyWith(
      status: SpeechAssistantStatus.generatingSpeech,
      clearError: true,
    ));
    final result = await _generateSpeech(text);
    switch (result) {
      case Success<GeneratedAudio>():
        try {
          _emit(_state.copyWith(status: SpeechAssistantStatus.playingSpeech));
          await _playback.play(result.value);
          _emit(_state.copyWith(status: SpeechAssistantStatus.stopped));
        } catch (_) {
          _fail('No se pudo reproducir el audio.');
        }
      case ErrorResult<GeneratedAudio>():
        _fail(result.failure.message);
    }
  }

  Future<void> stopPlayback() async {
    if (_playback == null) return;
    await _playback.stop();
    _emit(_state.copyWith(status: SpeechAssistantStatus.stopped));
  }

  void clearError() {
    _emit(_state.copyWith(
      status: SpeechAssistantStatus.initial,
      clearError: true,
    ));
  }

  void _fail(String message) {
    _emit(_state.copyWith(
      status: SpeechAssistantStatus.failure,
      errorMessage: message,
    ));
  }

  void _emit(SpeechAssistantState value) {
    _state = value;
    notifyListeners();
  }

  Future<void> _deleteIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best effort cleanup; no user data is kept intentionally.
    }
  }

  @override
  void dispose() {
    _stopSilenceDetection();
    _recorder?.cancel();
    _playback?.dispose();
    super.dispose();
  }
}
