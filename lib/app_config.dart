/// Central place for the settings you are most likely to change.
class AppConfig {
  /// false = Demo mode (works instantly, no backend, no real emails).
  /// true  = Firebase mode (real accounts + real verification emails).
  ///
  /// Switch without editing code:
  ///   flutter run --dart-define=USE_FIREBASE=true
  static const bool useFirebase =
      bool.fromEnvironment('USE_FIREBASE', defaultValue: false);

  /// Only emails on these domains (or their subdomains) can register.
  static const List<String> allowedDomains = ['ueuromed.org'];

  /// Accounts allowed to publish announcements (admins / club reps).
  /// In Firebase mode the person must really own the inbox, so this is safe
  /// for a prototype. For production, use custom claims instead.
  static const List<String> publisherEmails = [
    'admin@ueuromed.org',
    'studentaffairs@ueuromed.org',
  ];

  static const String appName = 'Student Hub';
  static const String universityShort = 'UEMF';
  static const String version = '1.0.0';
}
