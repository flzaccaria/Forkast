import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const supportedLocales = [
  Locale('it'),
  Locale('en'),
  Locale('da'),
];

class LocaleNotifier extends ChangeNotifier {
  LocaleNotifier(this._prefs) {
    final saved = _prefs.getString(_key);
    if (saved != null) _locale = Locale(saved);
  }

  static const _key = 'app_locale';
  final SharedPreferences _prefs;
  Locale? _locale;

  Locale? get locale => _locale;

  Locale get effectiveLocale => _locale ?? supportedLocales.first;

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    if (locale == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, locale.languageCode);
    }
    notifyListeners();
  }
}

class LocaleScope extends InheritedWidget {
  const LocaleScope({
    super.key,
    required this.notifier,
    required super.child,
  });

  final LocaleNotifier notifier;

  static LocaleNotifier of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleScope>()!.notifier;
  }

  @override
  bool updateShouldNotify(LocaleScope old) => notifier != old.notifier;
}
