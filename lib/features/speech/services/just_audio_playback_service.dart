import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/speech_entities.dart';
import 'audio_playback_service.dart';

class JustAudioPlaybackService implements AudioPlaybackService {
  JustAudioPlaybackService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  File? _temporaryAudio;

  @override
  Future<void> play(GeneratedAudio audio) async {
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
    await _player.play();
  }

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
