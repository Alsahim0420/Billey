sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class ErrorResult<T> extends Result<T> {
  const ErrorResult(this.failure);

  final SpeechFailure failure;
}

sealed class SpeechFailure {
  const SpeechFailure(this.message, {this.debugDetails});

  final String message;
  final String? debugDetails;
}

final class ValidationFailure extends SpeechFailure {
  const ValidationFailure(super.message);
}

final class NoInternetFailure extends SpeechFailure {
  const NoInternetFailure(super.message, {super.debugDetails});
}

final class UnauthorizedFailure extends SpeechFailure {
  const UnauthorizedFailure(super.message, {super.debugDetails});
}

final class ForbiddenFailure extends SpeechFailure {
  const ForbiddenFailure(super.message, {super.debugDetails});
}

final class QuotaExceededFailure extends SpeechFailure {
  const QuotaExceededFailure(super.message, {super.debugDetails});
}

final class InvalidAudioFailure extends SpeechFailure {
  const InvalidAudioFailure(super.message, {super.debugDetails});
}

final class ApiFailure extends SpeechFailure {
  const ApiFailure(super.message, {super.debugDetails});
}

final class TimeoutFailure extends SpeechFailure {
  const TimeoutFailure(super.message, {super.debugDetails});
}

final class ConfigurationFailure extends SpeechFailure {
  const ConfigurationFailure(super.message, {super.debugDetails});
}

final class UnknownFailure extends SpeechFailure {
  const UnknownFailure(super.message, {super.debugDetails});
}
