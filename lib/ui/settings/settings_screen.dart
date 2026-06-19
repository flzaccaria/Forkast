import 'package:flutter/material.dart';

import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/household_repository.dart';
import '../app_scope.dart';
import 'ingredients_screen.dart';
import 'pairing_screen.dart';
import 'tags_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final HouseholdRepository _repo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = HouseholdRepository(scope.database, scope.householdId);
  }

  static const _weekdayNames = {
    1: 'Lunedì',
    2: 'Martedì',
    3: 'Mercoledì',
    4: 'Giovedì',
    5: 'Venerdì',
    6: 'Sabato',
    7: 'Domenica',
  };

  Future<void> _editDefaultGuests(int current) async {
    final value = await showDialog<int>(
      context: context,
      builder: (_) => _GuestsDialog(initial: current),
    );
    if (value != null) await _repo.setDefaultGuests(value);
  }

  Future<void> _editWeekStart(int current) async {
    final value = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Inizio settimana'),
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
                    title: Text(_weekdayNames[wd]!),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: StreamBuilder<Household>(
        stream: _repo.watch(),
        builder: (context, snapshot) {
          final household = snapshot.data;
          return ListView(
            children: [
              const _SectionHeader('Pianificazione'),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Commensali predefiniti'),
                subtitle: const Text('Valore iniziale di ogni nuova serata'),
                trailing: Text(
                  household?.defaultGuests.toString() ?? '—',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: household == null
                    ? null
                    : () => _editDefaultGuests(household.defaultGuests),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_view_week),
                title: const Text('Inizio settimana'),
                trailing: Text(
                  household == null
                      ? '—'
                      : _weekdayNames[household.weekStartDay] ?? '—',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: household == null
                    ? null
                    : () => _editWeekStart(household.weekStartDay),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.autorenew),
                title: const Text('Rigenerazione automatica'),
                subtitle: const Text(
                    'Aggiorna la lista appena il piano cambia, senza chiedere'),
                value: household?.autoRegen ?? false,
                onChanged: household == null
                    ? null
                    : (v) => _repo.setAutoRegen(v),
              ),
              const _SectionHeader('Cataloghi'),
              ListTile(
                leading: const Icon(Icons.kitchen),
                title: const Text('Gestione ingredienti'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const IngredientsScreen()),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.label_outline),
                title: const Text('Tag dei piatti'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TagsScreen()),
                ),
              ),
              const _SectionHeader('Dispositivi'),
              ListTile(
                leading: const Icon(Icons.devices),
                title: const Text('Abbina un dispositivo'),
                subtitle: const Text('Condividi i dati con un secondo telefono'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PairingScreen()),
                ),
              ),
            ],
          );
        },
      ),
    );
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
    return AlertDialog(
      title: const Text('Commensali predefiniti'),
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
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: const Text('Salva'),
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
