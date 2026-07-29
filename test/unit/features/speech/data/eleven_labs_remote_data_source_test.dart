import 'dart:convert';
import 'dart:io';

import 'package:billey/features/speech/config/eleven_labs_config.dart';
import 'package:billey/features/speech/data/eleven_labs_exception.dart';
import 'package:billey/features/speech/data/eleven_labs_remote_data_source.dart';
import 'package:billey/features/speech/domain/speech_entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final config = ElevenLabsConfig(
    baseUrl: Uri.parse('https://api.elevenlabs.io'),
    apiKey: 'test-api-key',
    voiceId: 'voice-123',
    textToSpeechModelId: 'eleven_flash_v2_5',
    speechToTextModelId: 'scribe_v2',
    outputFormat: 'mp3_44100_128',
  );

  test('builds TTS request and interprets binary audio', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response.bytes(
        [1, 2, 3],
        200,
        headers: {
          'content-type': 'audio/mpeg',
          'request-id': 'request-1',
          'character-cost': '4',
        },
      );
    });
    final source = HttpElevenLabsRemoteDataSource(
      config: config,
      client: client,
    );

    final result = await source.synthesize('Hola');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;

    expect(captured.url.path, '/v1/text-to-speech/voice-123');
    expect(captured.url.queryParameters['output_format'], 'mp3_44100_128');
    expect(captured.headers['xi-api-key'], 'test-api-key');
    expect(body['text'], 'Hola');
    expect(body['model_id'], 'eleven_flash_v2_5');
    expect(result.bytes, [1, 2, 3]);
    expect(result.requestId, 'request-1');
    expect(result.characterCost, 4);
  });

  test('uses the currently selected voice for TTS', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response.bytes([1], 200);
    });
    var selectedVoiceId = 'female-voice';
    final source = HttpElevenLabsRemoteDataSource(
      config: config,
      client: client,
      voiceIdProvider: () => selectedVoiceId,
    );

    selectedVoiceId = 'male-voice';
    await source.synthesize('Hola');

    expect(captured.url.path, '/v1/text-to-speech/male-voice');
  });

  test('builds multipart STT request and parses transcript', () async {
    final directory = await Directory.systemTemp.createTemp('stt-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/voice.m4a');
    await file.writeAsBytes([1, 2, 3]);
    final client = _CapturingClient(
      responseBody: jsonEncode({
        'text': 'Hoy me gasté cien mil pesos',
        'language_code': 'es',
        'language_probability': 0.99,
      }),
    );
    final source = HttpElevenLabsRemoteDataSource(
      config: config,
      client: client,
    );

    final result = await source.transcribe(
      RecordedAudio(path: file.path, mimeType: 'audio/mp4'),
    );

    final request = client.request as http.MultipartRequest;
    expect(request.headers['xi-api-key'], 'test-api-key');
    expect(request.fields['model_id'], 'scribe_v2');
    expect(request.files.single.field, 'file');
    expect(request.files.single.contentType.toString(), 'audio/mp4');
    expect(result.text, 'Hoy me gasté cien mil pesos');
    expect(result.languageCode, 'es');
  });

  for (final entry in <int, ElevenLabsErrorKind>{
    401: ElevenLabsErrorKind.unauthorized,
    402: ElevenLabsErrorKind.quotaExceeded,
    403: ElevenLabsErrorKind.forbidden,
    422: ElevenLabsErrorKind.invalidAudio,
    429: ElevenLabsErrorKind.quotaExceeded,
    500: ElevenLabsErrorKind.api,
  }.entries) {
    test('maps HTTP ${entry.key}', () async {
      final source = HttpElevenLabsRemoteDataSource(
        config: config,
        client: MockClient(
          (_) async => http.Response('sensitive body', entry.key),
        ),
      );

      await expectLater(
        source.synthesize('Hola'),
        throwsA(
          isA<ElevenLabsException>().having(
            (error) => error.kind,
            'kind',
            entry.value,
          ),
        ),
      );
    });
  }

  test('maps malformed STT JSON to a sanitized exception', () async {
    final directory = await Directory.systemTemp.createTemp('stt-test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/voice.m4a');
    await file.writeAsBytes([1]);
    final source = HttpElevenLabsRemoteDataSource(
      config: config,
      client: _CapturingClient(responseBody: '{broken'),
    );

    await expectLater(
      source.transcribe(
        RecordedAudio(path: file.path, mimeType: 'audio/mp4'),
      ),
      throwsA(
        isA<ElevenLabsException>().having(
          (error) => error.kind,
          'kind',
          ElevenLabsErrorKind.invalidResponse,
        ),
      ),
    );
  });
}

class _CapturingClient extends http.BaseClient {
  _CapturingClient({required this.responseBody});

  final String responseBody;
  http.BaseRequest? request;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    this.request = request;
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
