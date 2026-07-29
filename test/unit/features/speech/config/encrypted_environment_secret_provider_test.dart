import 'dart:convert';
import 'dart:typed_data';

import 'package:billey/features/speech/config/configuration_exception.dart';
import 'package:billey/features/speech/config/encrypted_environment_codec.dart';
import 'package:billey/features/speech/config/encrypted_environment_secret_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const encodedKey = 'MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=';
  final key = Uint8List.fromList(base64Decode(encodedKey));
  late EncryptedEnvironmentCodec codec;

  setUp(() {
    codec = EncryptedEnvironmentCodec();
  });

  Future<String> encryptedFixture() {
    return codec.encrypt(
      plainText: '''
ELEVENLABS_API_KEY=secret-value
ELEVENLABS_VOICE_ID=voice-id
OPTIONAL=value
''',
      key: key,
    );
  }

  test('decrypts an encrypted environment fixture', () async {
    final payload = await encryptedFixture();
    final provider = EncryptedEnvironmentSecretProvider(
      encryptionKey: encodedKey,
      assetLoader: (_) async => payload,
    );

    await provider.initialize();

    expect(provider.getRequired('ELEVENLABS_API_KEY'), 'secret-value');
    expect(provider.getOptional('OPTIONAL'), 'value');
  });

  test('fails when the encryption key is missing', () async {
    final provider = EncryptedEnvironmentSecretProvider(
      encryptionKey: '',
      assetLoader: (_) async => encryptedFixture(),
    );

    await expectLater(
      provider.initialize(),
      throwsA(isA<ConfigurationException>()),
    );
  });

  test('fails when the authentication tag is invalid', () async {
    final payload =
        jsonDecode(await encryptedFixture()) as Map<String, dynamic>;
    payload['tag'] = base64Encode(List<int>.filled(16, 0));
    final provider = EncryptedEnvironmentSecretProvider(
      encryptionKey: encodedKey,
      assetLoader: (_) async => jsonEncode(payload),
    );

    await expectLater(
      provider.initialize(),
      throwsA(isA<ConfigurationException>()),
    );
  });

  test('fails for an unknown required variable', () async {
    final provider = EncryptedEnvironmentSecretProvider(
      encryptionKey: encodedKey,
      assetLoader: (_) => encryptedFixture(),
    );
    await provider.initialize();

    expect(
      () => provider.getRequired('MISSING'),
      throwsA(isA<ConfigurationException>()),
    );
  });

  test('never exposes secret values in errors', () async {
    final provider = EncryptedEnvironmentSecretProvider(
      encryptionKey: encodedKey,
      assetLoader: (_) async => 'secret-value-is-not-json',
    );

    try {
      await provider.initialize();
      fail('Expected initialization to fail');
    } catch (error) {
      expect(error.toString(), isNot(contains('secret-value')));
    }
  });
}
