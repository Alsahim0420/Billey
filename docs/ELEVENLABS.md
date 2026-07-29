# Integración de voz con ElevenLabs

Billey usa ElevenLabs para transcribir grabaciones y generar confirmaciones de
audio. La integración está separada en configuración, dominio, data,
servicios de dispositivo y estado `ChangeNotifier`.

## Configuración requerida

Copia `.env.example` como `.env.local` y completa:

```dotenv
ELEVENLABS_API_KEY=
ELEVENLABS_VOICE_ID=
ELEVENLABS_TTS_MODEL_ID=eleven_flash_v2_5
ELEVENLABS_STT_MODEL_ID=scribe_v2
ELEVENLABS_OUTPUT_FORMAT=mp3_44100_128
```

La API key se obtiene en ElevenLabs. El Voice ID se puede copiar desde la
biblioteca de voces o desde la configuración de una voz de la cuenta.

`.env.local`, `.env` y los archivos `*.key` están ignorados por Git. Nunca
agregues secretos a `.env.example`.

## Cifrar la configuración

`ENV_ENCRYPTION_KEY` debe ser una clave aleatoria de 32 bytes codificada en
Base64:

```bash
export ENV_ENCRYPTION_KEY="$(openssl rand -base64 32)"
dart run tool/encrypt_environment.dart
```

La herramienta lee `.env.local` y genera
`assets/config/environment.enc`. El formato almacena versión, nonce aleatorio,
ciphertext y authentication tag. El algoritmo es AES-256-GCM y la herramienta
no imprime secretos.

Para borrar y regenerar el asset, elimina `assets/config/environment.enc`,
actualiza `.env.local` y vuelve a ejecutar la herramienta con la misma clave
que usarás al compilar.

## Ejecutar

```bash
flutter run \
  --dart-define=ENV_ENCRYPTION_KEY="$ENV_ENCRYPTION_KEY"
```

Si falta el asset, la clave o alguna variable obligatoria, el resto de Billey
inicia normalmente y la función de voz muestra un error de configuración.

## Flujo

En la pantalla de nueva transacción:

1. Pulsa el micrófono para comenzar.
2. Pulsa otra vez para detener y transcribir.
3. Revisa el texto devuelto.
4. Opcionalmente, reproduce la confirmación TTS.

Este módulo no interpreta importes, no crea borradores financieros y no guarda
transacciones automáticamente. La transcripción queda disponible en
`SpeechAssistantState.transcript` para una integración posterior.

## Permisos y archivos temporales

- Android: `RECORD_AUDIO` e `INTERNET`.
- iOS: `NSMicrophoneUsageDescription`.

Las grabaciones y el audio generado se guardan únicamente en el directorio
temporal y se eliminan después de usarse o cancelarse.

## Pruebas

```bash
flutter test test/unit/features/speech
flutter analyze
```

Las pruebas usan fakes y clientes HTTP locales; nunca llaman realmente a
ElevenLabs.

## Rotación y cambios

Para rotar la API key:

1. Revoca la anterior en ElevenLabs.
2. Actualiza `ELEVENLABS_API_KEY` en `.env.local`.
3. Regenera `environment.enc`.
4. Vuelve a compilar con `ENV_ENCRYPTION_KEY`.

Para cambiar de voz o modelos, modifica las variables correspondientes y
regenera el asset.

## Limitación de seguridad

El cifrado protege el repositorio y evita distribuir el secreto en texto
plano. No impide por completo que alguien con control de un APK/IPA y acceso a
la clave de compilación extraiga la API key en tiempo de ejecución. Para una
protección fuerte en producción, las llamadas deben pasar por un backend
propio que mantenga la API key fuera del dispositivo y aplique autenticación,
cuotas y rate limiting.
