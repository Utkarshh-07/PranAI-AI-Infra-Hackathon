class HealthCheck {
  static Map<String, dynamic> getStatus() {
    return {
      'status': 'ok',
      'service': 'PranAI backend',
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
