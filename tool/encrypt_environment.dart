import 'dart:io';

import 'package:billey/features/speech/config/encrypted_environment_codec.dart';

Future<void> main() async {
  const sourcePath = '.env.local';
  const outputPath = 'assets/config/environment.enc';

  try {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError(
        'No existe $sourcePath. Crea el archivo desde .env.example.',
      );
    }

    final encodedKey = Platform.environment['ENV_ENCRYPTION_KEY'] ?? '';
    final key = EncryptedEnvironmentCodec.decodeKey(encodedKey);
    final clearText = await source.readAsString();
    final encrypted = await EncryptedEnvironmentCodec().encrypt(
      plainText: clearText,
      key: key,
    );

    final output = File(outputPath);
    await output.parent.create(recursive: true);
    await output.writeAsString(encrypted, flush: true);
    stdout.writeln('Configuración cifrada creada en $outputPath.');
  } catch (error) {
    stderr.writeln('No se pudo cifrar la configuración: $error');
    exitCode = 1;
  }
}
