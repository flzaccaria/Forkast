import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/plan_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../theme.dart';
import 'dish_picker_screen.dart';

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

  String? _planDayId;
  int _guests = 4;
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = PlanRepository(scope.database, scope.householdId);
    _ensureDay();
  }

  String _dayTitle() {
    final locale = Localizations.localeOf(context).toString();
    final dayName = DateFormat.EEEE(locale).format(widget.date);
    final capitalized = dayName[0].toUpperCase() + dayName.substring(1);
    return '$capitalized ${widget.date.day}';
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_dayTitle())),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.people_outlined),
                  title: Text(l.dayGuests),
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
              label: Text(l.dayAddDish),
            ),
    );
  }

  Widget _buildDishes() {
    final l = AppLocalizations.of(context);
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
          final tokens = Theme.of(context).extension<ForkastTokens>()!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l.dayEmptyState,
                textAlign: TextAlign.center,
                style: TextStyle(color: tokens.inkMuted, fontSize: 15),
              ),
            ),
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
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.dayGuests),
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
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          child: Text(l.confirm),
        ),
      ],
    );
  }
}
