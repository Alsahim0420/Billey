import '../domain/speech_entities.dart';

enum SpeechAssistantStatus {
  initial,
  requestingPermission,
  recording,
  stoppingRecording,
  transcribing,
  transcriptionSuccess,
  generatingSpeech,
  playingSpeech,
  stopped,
  failure,
  unavailable,
}

class SpeechAssistantState {
  const SpeechAssistantState({
    this.status = SpeechAssistantStatus.initial,
    this.transcript,
    this.errorMessage,
  });

  final SpeechAssistantStatus status;
  final Transcript? transcript;
  final String? errorMessage;

  bool get isBusy => switch (status) {
        SpeechAssistantStatus.requestingPermission ||
        SpeechAssistantStatus.stoppingRecording ||
        SpeechAssistantStatus.transcribing ||
        SpeechAssistantStatus.generatingSpeech ||
        SpeechAssistantStatus.playingSpeech =>
          true,
        _ => false,
      };

  SpeechAssistantState copyWith({
    SpeechAssistantStatus? status,
    Transcript? transcript,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SpeechAssistantState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
