import 'package:flutter/material.dart';

import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/plan_repository.dart';
import '../app_scope.dart';
import '../widgets/settings_button.dart';
import 'day_screen.dart';

/// Piano settimanale (FR-7): una settimana di cene navigabile, con conteggio
/// piatti e commensali per giorno. Toccando un giorno si apre "Cena del giorno".
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late final PlanRepository _repo;
  int _weekStartDay = DateTime.monday;

  /// Una data qualsiasi all'interno della settimana mostrata.
  DateTime _reference = DateTime.now();

  static const _monthNames = [
    'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
    'lug', 'ago', 'set', 'ott', 'nov', 'dic',
  ];
  static const _dayNames = [
    'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
    'Venerdì', 'Sabato', 'Domenica',
  ];

  int get _year => isoWeekYear(_reference);
  int get _week => isoWeekNumber(_reference);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = PlanRepository(scope.database, scope.householdId);
    _repo.weekStartDay().then((v) {
      if (mounted) setState(() => _weekStartDay = v);
    });
  }

  void _shiftWeek(int deltaWeeks) {
    setState(() => _reference =
        _reference.add(Duration(days: 7 * deltaWeeks)));
  }

  void _goToday() => setState(() => _reference = DateTime.now());

  Future<void> _copyPreviousWeek() async {
    final prev = _reference.subtract(const Duration(days: 7));
    final fromYear = isoWeekYear(prev);
    final fromWeek = isoWeekNumber(prev);

    if (!await _repo.hasPlannedDishes(fromYear, fromWeek)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La settimana precedente è vuota.')),
        );
      }
      return;
    }

    // Punto aperto §8: se la destinazione non è vuota, chiediamo all'utente.
    var replace = false;
    if (await _repo.hasPlannedDishes(_year, _week)) {
      if (!mounted) return;
      final choice = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Questa settimana non è vuota'),
          content: const Text(
              'Vuoi sostituire i piatti esistenti o aggiungere quelli della '
              'settimana precedente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('merge'),
              child: const Text('Aggiungi'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('replace'),
              child: const Text('Sostituisci'),
            ),
          ],
        ),
      );
      if (choice == null) return;
      replace = choice == 'replace';
    }

    await _repo.copyWeek(
      fromYear: fromYear,
      fromWeek: fromWeek,
      toYear: _year,
      toWeek: _week,
      replace: replace,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settimana copiata.')),
      );
    }
  }

  Future<void> _openDay(int dayOfWeek) async {
    final date = dateOfIsoWeek(_year, _week, dayOfWeek);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DayScreen(
          year: _year,
          week: _week,
          dayOfWeek: dayOfWeek,
          date: date,
        ),
      ),
    );
  }

  String _rangeLabel() {
    final first = dateOfIsoWeek(_year, _week, _weekStartDay);
    final last = first.add(const Duration(days: 6));
    return '${first.day} ${_monthNames[first.month - 1]} – '
        '${last.day} ${_monthNames[last.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = orderedWeekdays(_weekStartDay);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'copy') _copyPreviousWeek();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'copy',
                child: ListTile(
                  leading: Icon(Icons.copy_all),
                  title: Text('Copia settimana precedente'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SettingsButton(),
        ],
      ),
      body: Column(
        children: [
          _WeekHeader(
            label: 'Settimana $_week · $_year',
            range: _rangeLabel(),
            onPrev: () => _shiftWeek(-1),
            onNext: () => _shiftWeek(1),
            onToday: _goToday,
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<WeekPlan?>(
              stream: _repo.watchWeekPlan(_year, _week),
              builder: (context, planSnap) {
                final weekPlan = planSnap.data;
                if (weekPlan == null) {
                  return _buildDayList(weekdays, const {});
                }
                return StreamBuilder<Map<int, DayOverview>>(
                  stream: _repo.watchWeekOverview(weekPlan.id),
                  builder: (context, overviewSnap) {
                    return _buildDayList(
                        weekdays, overviewSnap.data ?? const {});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayList(List<int> weekdays, Map<int, DayOverview> overview) {
    final today = DateTime.now();
    return ListView.separated(
      itemCount: weekdays.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final dow = weekdays[i];
        final date = dateOfIsoWeek(_year, _week, dow);
        final ov = overview[dow];
        final isToday = date.year == today.year &&
            date.month == today.month &&
            date.day == today.day;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isToday
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: Text('${date.day}'),
          ),
          title: Text(_dayNames[dow - 1]),
          subtitle: Text(
            ov == null || ov.dishCount == 0
                ? 'Nessun piatto'
                : '${ov.dishCount} '
                    '${ov.dishCount == 1 ? "piatto" : "piatti"} · '
                    '${ov.guests} ${ov.guests == 1 ? "commensale" : "commensali"}',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openDay(dow),
        );
      },
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader({
    required this.label,
    required this.range,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  final String label;
  final String range;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Expanded(
            child: Column(
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(range,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
          TextButton(onPressed: onToday, child: const Text('Oggi')),
        ],
      ),
    );
  }
}
