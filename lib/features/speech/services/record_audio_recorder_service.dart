import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../domain/speech_entities.dart';
import 'audio_recorder_service.dart';

class RecordAudioRecorderService implements AudioRecorderService {
  RecordAudioRecorderService({AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _activePath;
  DateTime? _startedAt;

  @override
  Future<bool> hasPermission() => _recorder.hasPermission();

  @override
  Future<bool> get isRecording => _recorder.isRecording();

  @override
  Future<void> start() async {
    if (await isRecording) {
      throw StateError('Ya existe una grabación activa.');
    }
    final directory = await getTemporaryDirectory();
    final path =
        '${directory.path}/billey_voice_${DateTime.now().microsecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
    _activePath = path;
    _startedAt = DateTime.now();
  }

  @override
  Future<RecordedAudio> stop() async {
    final path = await _recorder.stop() ?? _activePath;
    final startedAt = _startedAt;
    _activePath = null;
    _startedAt = null;
    if (path == null) {
      throw StateError('No se pudo recuperar la grabación.');
    }
    return RecordedAudio(
      path: path,
      mimeType: 'audio/mp4',
      duration: startedAt == null ? null : DateTime.now().difference(startedAt),
    );
  }

  @override
  Future<void> cancel() async {
    final path = await _recorder.stop() ?? _activePath;
    _activePath = null;
    _startedAt = null;
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
