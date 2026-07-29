import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/eleven_labs_config.dart';
import '../domain/speech_entities.dart';
import 'eleven_labs_exception.dart';
import 'speech_dtos.dart';

abstract interface class ElevenLabsRemoteDataSource {
  Future<GeneratedAudioDto> synthesize(String text);

  Future<SpeechToTextResponseDto> transcribe(RecordedAudio audio);
}

class HttpElevenLabsRemoteDataSource implements ElevenLabsRemoteDataSource {
  HttpElevenLabsRemoteDataSource({
    required ElevenLabsConfig config,
    required http.Client client,
  })  : _config = config,
        _client = client;

  final ElevenLabsConfig _config;
  final http.Client _client;

  Map<String, String> get _authenticationHeader => {
        'xi-api-key': _config.apiKey,
      };

  @override
  Future<GeneratedAudioDto> synthesize(String text) async {
    final uri = _config.baseUrl.replace(
      path: '/v1/text-to-speech/${_config.voiceId}',
      queryParameters: {'output_format': _config.outputFormat},
    );

    try {
      final response = await _client
          .post(
            uri,
            headers: {
              ..._authenticationHeader,
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.acceptHeader: 'audio/mpeg',
            },
            body: jsonEncode({
              'text': text,
              'model_id': _config.textToSpeechModelId,
              'voice_settings': {
                'stability': 0.5,
                'similarity_boost': 0.75,
                'style': 0.0,
                'use_speaker_boost': true,
                'speed': 1.0,
              },
            }),
          )
          .timeout(_config.receiveTimeout);

      _ensureSuccess(response.statusCode);
      if (response.bodyBytes.isEmpty) {
        throw const ElevenLabsException(
          ElevenLabsErrorKind.invalidResponse,
          'ElevenLabs devolvió audio vacío.',
        );
      }
      return GeneratedAudioDto(
        bytes: Uint8List.fromList(response.bodyBytes),
        mimeType:
            response.headers[HttpHeaders.contentTypeHeader] ?? 'audio/mpeg',
        format: _config.outputFormat,
        requestId: response.headers['request-id'],
        characterCost: int.tryParse(response.headers['character-cost'] ?? ''),
      );
    } on TimeoutException {
      throw const ElevenLabsException(
        ElevenLabsErrorKind.timeout,
        'ElevenLabs tardó demasiado en generar el audio.',
      );
    } on SocketException catch (error) {
      throw ElevenLabsException(
        ElevenLabsErrorKind.noInternet,
        'No hay conexión para contactar a ElevenLabs.',
        debugDetails: error.osError?.message,
      );
    } on http.ClientException catch (error) {
      throw ElevenLabsException(
        ElevenLabsErrorKind.noInternet,
        'No fue posible contactar a ElevenLabs.',
        debugDetails: error.message,
      );
    }
  }

  @override
  Future<SpeechToTextResponseDto> transcribe(RecordedAudio audio) async {
    final request = http.MultipartRequest(
      'POST',
      _config.baseUrl.replace(path: '/v1/speech-to-text'),
    )
      ..headers.addAll(_authenticationHeader)
      ..fields['model_id'] = _config.speechToTextModelId
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          audio.path,
          contentType: MediaType.parse(audio.mimeType),
        ),
      );

    try {
      final streamed = await _client.send(request).timeout(_config.sendTimeout);
      final response = await http.Response.fromStream(streamed)
          .timeout(_config.receiveTimeout);
      _ensureSuccess(response.statusCode);

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respuesta STT inválida.');
      }
      return SpeechToTextResponseDto.fromJson(decoded);
    } on TimeoutException {
      throw const ElevenLabsException(
        ElevenLabsErrorKind.timeout,
        'ElevenLabs tardó demasiado en transcribir el audio.',
      );
    } on SocketException catch (error) {
      throw ElevenLabsException(
        ElevenLabsErrorKind.noInternet,
        'No hay conexión para contactar a ElevenLabs.',
        debugDetails: error.osError?.message,
      );
    } on http.ClientException catch (error) {
      throw ElevenLabsException(
        ElevenLabsErrorKind.noInternet,
        'No fue posible contactar a ElevenLabs.',
        debugDetails: error.message,
      );
    } on FormatException catch (error) {
      throw ElevenLabsException(
        ElevenLabsErrorKind.invalidResponse,
        'ElevenLabs devolvió una transcripción inválida.',
        debugDetails: error.message,
      );
    }
  }

  void _ensureSuccess(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return;
    switch (statusCode) {
      case 400:
      case 422:
        throw ElevenLabsException(
          ElevenLabsErrorKind.invalidAudio,
          'El audio o los parámetros enviados no son válidos.',
          statusCode: statusCode,
        );
      case 401:
        throw ElevenLabsException(
          ElevenLabsErrorKind.unauthorized,
          'La credencial de ElevenLabs no es válida.',
          statusCode: statusCode,
        );
      case 403:
        throw ElevenLabsException(
          ElevenLabsErrorKind.forbidden,
          'La credencial no tiene permisos para esta operación.',
          statusCode: statusCode,
        );
      case 429:
        throw ElevenLabsException(
          ElevenLabsErrorKind.quotaExceeded,
          'Se alcanzó la cuota de ElevenLabs.',
          statusCode: statusCode,
        );
      default:
        throw ElevenLabsException(
          ElevenLabsErrorKind.api,
          'ElevenLabs no pudo completar la solicitud.',
          statusCode: statusCode,
        );
    }
  }
}
