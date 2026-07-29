abstract interface class SecretProvider {
  Future<void> initialize();

  String getRequired(String key);

  String? getOptional(String key);
}
