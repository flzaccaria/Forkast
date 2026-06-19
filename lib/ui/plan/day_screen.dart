import 'package:flutter/material.dart';

import '../../data/repositories/plan_repository.dart';
import '../app_scope.dart';
import 'dish_picker_screen.dart';

/// Cena del giorno (FR-8/9): commensali della serata (default sovrascrivibile)
/// e piatti assegnati. La serata viene creata pigramente alla prima modifica.
class DayScreen extends StatefulWidget {
  const DayScreen({
    super.key,
    required this.year,
    required this.week,
    required this.dayOfWeek,
    required this.date,
  });

  final int year;
  final int week;
  final int dayOfWeek;
  final DateTime date;

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  late final PlanRepository _repo;

  /// Id della serata, risolto/creato pigramente.
  String? _planDayId;
  int _guests = 4;
  bool _loading = true;

  static const _dayNames = [
    'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
    'Venerdì', 'Sabato', 'Domenica',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = PlanRepository(scope.database, scope.householdId);
    _ensureDay();
  }

  Future<void> _ensureDay() async {
    final day = await _repo.ensurePlanDay(
      widget.year,
      widget.week,
      widget.dayOfWeek,
    );
    if (mounted) {
      setState(() {
        _planDayId = day.id;
        _guests = day.guests;
        _loading = false;
      });
    }
  }

  Future<void> _editGuests() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => _GuestsDialog(initial: _guests),
    );
    if (result != null && result != _guests && _planDayId != null) {
      setState(() => _guests = result);
      await _repo.setGuests(_planDayId!, result);
    }
  }

  Future<void> _addDishes() async {
    final id = _planDayId;
    if (id == null) return;
    final current = await _repo.watchDayDishes(id).first;
    final alreadyIds = current.map((e) => e.dishId).toList();
    if (!mounted) return;

    final selected = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => DishPickerScreen(alreadySelected: alreadyIds),
      ),
    );
    if (selected != null && selected.isNotEmpty) {
      await _repo.addDishes(id, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = '${_dayNames[widget.dayOfWeek - 1]} ${widget.date.day}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Commensali'),
                  trailing: Text(
                    '$_guests',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: _editGuests,
                ),
                const Divider(height: 1),
                Expanded(child: _buildDishes()),
              ],
            ),
      floatingActionButton: _loading
          ? null
          : FloatingActionButton.extended(
              onPressed: _addDishes,
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi piatto'),
            ),
    );
  }

  Widget _buildDishes() {
    final id = _planDayId;
    if (id == null) return const SizedBox.shrink();
    return StreamBuilder<List<PlanDishEntry>>(
      stream: _repo.watchDayDishes(id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final dishes = snapshot.data!;
        if (dishes.isEmpty) {
          return const Center(
            child: Text('Nessun piatto per questa cena.\n'
                'Tocca "Aggiungi piatto".',
                textAlign: TextAlign.center),
          );
        }
        return ListView.separated(
          itemCount: dishes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final d = dishes[i];
            return ListTile(
              title: Text(d.dishName),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _repo.removeDish(d.planDayDishId),
              ),
            );
          },
        );
      },
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
      title: const Text('Commensali'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filledTonal(
            icon: const Icon(Icons.remove),
            onPressed:
                _value > 1 ? () => setState(() => _value--) : null,
          ),
          Text('$_value',
              style: Theme.of(context).textTheme.headlineMedium),
          IconButton.filledTonal(
            icon: const Icon(Icons.add),
            onPressed: () => setState(() => _value++),
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
          child: const Text('Conferma'),
        ),
      ],
    );
  }
}
