import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'configuration_exception.dart';

class EncryptedEnvironmentCodec {
  EncryptedEnvironmentCodec({AesGcm? cipher})
      : _cipher = cipher ?? AesGcm.with256bits();

  static const formatVersion = 1;
  static const nonceLength = 12;
  static const keyLength = 32;

  final AesGcm _cipher;

  Future<String> encrypt({
    required String plainText,
    required Uint8List key,
  }) async {
    _validateKey(key);
    final nonce = _cipher.newNonce();
    final secretBox = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: SecretKey(key),
      nonce: nonce,
    );

    return jsonEncode(<String, Object>{
      'version': formatVersion,
      'nonce': base64Encode(secretBox.nonce),
      'ciphertext': base64Encode(secretBox.cipherText),
      'tag': base64Encode(secretBox.mac.bytes),
    });
  }

  Future<String> decrypt({
    required String payload,
    required Uint8List key,
  }) async {
    _validateKey(key);

    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic> ||
          decoded['version'] != formatVersion) {
        throw const ConfigurationException(
          'El archivo de configuración cifrado no es compatible.',
        );
      }

      final nonce = base64Decode(_requiredString(decoded, 'nonce'));
      final cipherText = base64Decode(_requiredString(decoded, 'ciphertext'));
      final tag = base64Decode(_requiredString(decoded, 'tag'));
      if (nonce.length != nonceLength) {
        throw const ConfigurationException(
          'El nonce de configuración no es válido.',
        );
      }

      final clearText = await _cipher.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(tag)),
        secretKey: SecretKey(key),
      );
      return utf8.decode(clearText);
    } on ConfigurationException {
      rethrow;
    } on SecretBoxAuthenticationError {
      throw const ConfigurationException(
        'No se pudo autenticar la configuración cifrada.',
      );
    } on FormatException {
      throw const ConfigurationException(
        'El archivo de configuración cifrado está dañado.',
      );
    } catch (_) {
      throw const ConfigurationException(
        'No se pudo descifrar la configuración.',
      );
    }
  }

  static Uint8List decodeKey(String encodedKey) {
    if (encodedKey.trim().isEmpty) {
      throw const ConfigurationException(
        'Falta ENV_ENCRYPTION_KEY.',
      );
    }
    try {
      final key = base64Decode(encodedKey.trim());
      _validateKey(key);
      return Uint8List.fromList(key);
    } catch (error) {
      if (error is ConfigurationException) rethrow;
      throw const ConfigurationException(
        'ENV_ENCRYPTION_KEY debe ser una clave Base64 de 32 bytes.',
      );
    }
  }

  static void _validateKey(List<int> key) {
    if (key.length != keyLength) {
      throw const ConfigurationException(
        'ENV_ENCRYPTION_KEY debe representar exactamente 32 bytes.',
      );
    }
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.isEmpty) {
      throw const ConfigurationException(
        'El archivo de configuración cifrado está incompleto.',
      );
    }
    return value;
  }
}
