/// Configurazione iniettata a compile-time via --dart-define.
///
/// Esempio:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=eyJ... \
///     --dart-define=POWERSYNC_URL=https://xxxx.powersync.journeyapps.com
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const powersyncUrl = String.fromEnvironment('POWERSYNC_URL');
  static const appUrl = String.fromEnvironment('APP_URL');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      powersyncUrl.isNotEmpty;
}
