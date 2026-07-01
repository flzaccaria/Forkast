import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/locale_provider.dart';
import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/household_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import 'pairing_screen.dart';
import 'sync_status_screen.dart';
import 'tags_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late HouseholdRepository _repo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = HouseholdRepository(scope.database, scope.householdId);
  }

  String _weekdayName(int dow, String locale) {
    final date = DateTime(2024, 1, dow); // 2024-01-01 is Monday
    return DateFormat.EEEE(locale).format(date);
  }

  Future<void> _editDefaultGuests(int current) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _GuestsDialog(initial: current),
    );
    if (value != null) await _repo.setDefaultGuests(value);
  }

  Future<void> _editWeekStart(int current) async {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settingsWeekStart),
        children: [
          RadioGroup<int>(
            groupValue: current,
            onChanged: (v) => Navigator.of(ctx).pop(v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final wd in orderedWeekdays(1))
                  RadioListTile<int>(
                    value: wd,
                    title: Text(_weekdayName(wd, locale)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    if (value != null) await _repo.setWeekStartDay(value);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final localeNotifier = LocaleScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: StreamBuilder<Household>(
        stream: _repo.watch(),
        builder: (context, snapshot) {
          final household = snapshot.data;
          return ListView(
            children: [
              _SectionHeader(l.settingsPlanning),
              ListTile(
                leading: const Icon(Icons.people_outlined),
                title: Text(l.settingsDefaultGuests),
                subtitle: Text(l.settingsDefaultGuestsSubtitle),
                trailing: Text(
                  household?.defaultGuests.toString() ?? '—',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: household == null
                    ? null
                    : () => _editDefaultGuests(household.defaultGuests),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week_outlined),
                title: Text(l.settingsWeekStart),
                trailing: Text(
                  household == null
                      ? '—'
                      : _weekdayName(household.weekStartDay, locale),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: household == null
                    ? null
                    : () => _editWeekStart(household.weekStartDay),
              ),
              _SectionHeader(l.settingsCatalogs),
              ListTile(
                leading: const Icon(Icons.label_outlined),
                title: Text(l.settingsCoursesVocabulary),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TagsScreen()),
                ),
              ),
              _SectionHeader(l.settingsDevices),
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: Text(l.settingsPairDevice),
                subtitle: Text(l.settingsPairDeviceSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PairingScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sync_outlined),
                title: Text(l.settingsSync),
                subtitle: Text(l.settingsSyncSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SyncStatusScreen()),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(l.settingsLanguage),
                subtitle: Text(l.settingsLanguageSubtitle),
                trailing: Text(
                  _currentLanguageLabel(localeNotifier.locale, l),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => _showLanguagePicker(context),
              ),
            ],
          );
        },
      ),
    );
  }

  String _currentLanguageLabel(Locale? locale, AppLocalizations l) {
    if (locale == null) return l.languageSystem;
    return switch (locale.languageCode) {
      'it' => l.languageIt,
      'en' => l.languageEn,
      'da' => l.languageDa,
      _ => locale.languageCode,
    };
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final localeNotifier = LocaleScope.of(context);
    final l = AppLocalizations.of(context);
    final current = localeNotifier.locale;
    final sentinel = Object();

    final result = await showDialog<Object?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settingsLanguage),
        children: [
          for (final entry in <(Locale?, String)>[
            (null, l.languageSystem),
            (const Locale('it'), l.languageIt),
            (const Locale('en'), l.languageEn),
            (const Locale('da'), l.languageDa),
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(entry.$1 ?? sentinel),
              child: Row(
                children: [
                  if ((entry.$1 == null && current == null) ||
                      entry.$1?.languageCode == current?.languageCode)
                    const Icon(Icons.check, size: 18)
                  else
                    const SizedBox(width: 18),
                  const SizedBox(width: 12),
                  Text(entry.$2),
                ],
              ),
            ),
        ],
      ),
    );
    if (result == null) return; // dismissed
    final Locale? chosen = result == sentinel ? null : result as Locale;
    await localeNotifier.setLocale(chosen);
  }
}

class _GuestsDialog extends StatefulWidget {
  const _GuestsDialog({required this.initial});

  final int initial;

  @override
  State<_GuestsDialog> createState() => _GuestsDialogState();
}

class _GuestsDialogState extends State<_GuestsDialog> {
  late int _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.settingsDefaultGuests),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.remove),
            onPressed: _value > 1 ? () => setState(() => _value--) : null,
          ),
          Text('$_value', style: Theme.of(context).textTheme.headlineMedium),
          IconButton.filledTonal(
            icon: const Icon(Icons.add),
            onPressed: _value < 99 ? () => setState(() => _value++) : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: Text(l.save),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
