import 'package:flutter/services.dart';

import 'configuration_exception.dart';
import 'encrypted_environment_codec.dart';
import 'secret_provider.dart';

typedef EncryptedAssetLoader = Future<String> Function(String path);

class EncryptedEnvironmentSecretProvider implements SecretProvider {
  EncryptedEnvironmentSecretProvider({
    EncryptedAssetLoader? assetLoader,
    String? encryptionKey,
    EncryptedEnvironmentCodec? codec,
    this.assetPath = 'assets/config/environment.enc',
  })  : _assetLoader = assetLoader ?? rootBundle.loadString,
        _encryptionKey =
            encryptionKey ?? const String.fromEnvironment('ENV_ENCRYPTION_KEY'),
        _codec = codec ?? EncryptedEnvironmentCodec();

  final EncryptedAssetLoader _assetLoader;
  final String _encryptionKey;
  final EncryptedEnvironmentCodec _codec;
  final String assetPath;

  Map<String, String>? _values;

  @override
  Future<void> initialize() async {
    if (_values != null) return;

    try {
      final payload = await _assetLoader(assetPath);
      final key = EncryptedEnvironmentCodec.decodeKey(_encryptionKey);
      final clearText = await _codec.decrypt(payload: payload, key: key);
      _values = _parseEnvironment(clearText);
    } on ConfigurationException {
      rethrow;
    } catch (_) {
      throw const ConfigurationException(
        'No se pudo cargar la configuración cifrada.',
      );
    }
  }

  @override
  String getRequired(String key) {
    final value = getOptional(key);
    if (value == null || value.trim().isEmpty) {
      throw ConfigurationException('Falta la variable obligatoria $key.');
    }
    return value;
  }

  @override
  String? getOptional(String key) {
    final values = _values;
    if (values == null) {
      throw const ConfigurationException(
        'SecretProvider debe inicializarse antes de usarse.',
      );
    }
    return values[key];
  }

  Map<String, String> _parseEnvironment(String source) {
    final result = <String, String>{};
    for (final rawLine in source.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final separator = line.indexOf('=');
      if (separator <= 0) continue;
      final key = line.substring(0, separator).trim();
      var value = line.substring(separator + 1).trim();
      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }
      result[key] = value;
    }
    return Map.unmodifiable(result);
  }
}
