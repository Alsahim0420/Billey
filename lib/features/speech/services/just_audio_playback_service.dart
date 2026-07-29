import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/speech_entities.dart';
import 'audio_playback_service.dart';

class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  File? _temporaryAudio;
  bool _sessionConfigured = false;

  Future<void> _activateAudioSession() async {
    final session = await AudioSession.instance;
    if (!_sessionConfigured) {
      await session.configure(const AudioSessionConfiguration.speech());
      _sessionConfigured = true;
    }
    await session.setActive(true);
  }

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<bool> get playingStream => _player.playingStream;

  @override
  Stream<bool> get completedStream => _player.processingStateStream
      .map((state) => state == ProcessingState.completed)
      .distinct();

  @override
  Future<void> load(GeneratedAudio audio) async {
    await _activateAudioSession();
    await stop();
    final directory = await getTemporaryDirectory();
    final extension =
        audio.format.toLowerCase().contains('mp3') ? 'mp3' : 'bin';
    final file = File(
      '${directory.path}/billey_speech_${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    await file.writeAsBytes(audio.bytes, flush: true);
    _temporaryAudio = file;
    await _player.setFilePath(file.path);
  }

  @override
  Future<void> play(GeneratedAudio audio) async {
    await load(audio);
    await resume();
  }

  @override
  Future<void> resume() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    await _player.stop();
    final file = _temporaryAudio;
    _temporaryAudio = null;
    if (file != null && await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}
