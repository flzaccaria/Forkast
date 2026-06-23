import 'package:flutter/material.dart';

import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/plan_repository.dart';
import '../app_scope.dart';
import '../theme.dart';
import '../widgets/forkast_app_bar.dart';
import 'day_screen.dart';

/// Weekly plan (FR-7): a navigable week of dinners, with dish names
/// per day. Tapping a day opens "Dinner of the day".
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  late final PlanRepository _repo;
  int _weekStartDay = DateTime.monday;

  /// Any date within the displayed week.
  DateTime _reference = DateTime.now();

  static const _monthNames = [
    'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
    'lug', 'ago', 'set', 'ott', 'nov', 'dic',
  ];
  static const _shortDayNames = [
    'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom',
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
      appBar: forkastAppBar(context),
      body: Column(
        children: [
          _WeekHeader(
            label: 'Settimana $_week · $_year',
            range: _rangeLabel(),
            onPrev: () => _shiftWeek(-1),
            onNext: () => _shiftWeek(1),
            onToday: _goToday,
          ),
          Divider(
            height: 0.5,
            color: Theme.of(context).extension<ForkastTokens>()!.border,
          ),
          Expanded(
            child: StreamBuilder<WeekPlan?>(
              stream: _repo.watchWeekPlan(_year, _week),
              builder: (context, planSnap) {
                final weekPlan = planSnap.data;
                if (weekPlan == null) {
                  return _buildDayList(weekdays, const {}, weekEmpty: true);
                }
                return StreamBuilder<Map<int, DayOverview>>(
                  stream: _repo.watchWeekOverview(weekPlan.id),
                  builder: (context, overviewSnap) {
                    final overview = overviewSnap.data ?? const {};
                    final isEmpty = overview.values
                        .every((ov) => ov.dishCount == 0);
                    return _buildDayList(weekdays, overview,
                        weekEmpty: isEmpty);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayList(
    List<int> weekdays,
    Map<int, DayOverview> overview, {
    required bool weekEmpty,
  }) {
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    final today = DateTime.now();
    return Column(
      children: [
        // "Copy previous week" — prominent only when the week is empty
        if (weekEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _copyPreviousWeek,
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text('Copia settimana precedente'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: tokens.ink,
                  side: BorderSide(color: tokens.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: weekdays.length,
            separatorBuilder: (_, __) => Divider(
              height: 0.5,
              indent: 20,
              endIndent: 20,
              color: tokens.border,
            ),
            itemBuilder: (context, i) {
              final dow = weekdays[i];
              final date = dateOfIsoWeek(_year, _week, dow);
              final ov = overview[dow];
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              return _DayRow(
                dayName: _shortDayNames[dow - 1],
                dayNumber: date.day,
                isToday: isToday,
                dishNames: ov?.dishNames ?? const [],
                guests: ov?.guests,
                onTap: () => _openDay(dow),
              );
            },
          ),
        ),
        // "Copy" in the overflow menu when week is NOT empty
        if (!weekEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _copyPreviousWeek,
                icon: const Icon(Icons.copy_all_outlined, size: 16),
                label: const Text('Copia settimana precedente'),
                style: TextButton.styleFrom(
                  foregroundColor: tokens.inkMuted,
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.dayName,
    required this.dayNumber,
    required this.isToday,
    required this.dishNames,
    this.guests,
    required this.onTap,
  });

  final String dayName;
  final int dayNumber;
  final bool isToday;
  final List<String> dishNames;
  final int? guests;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: isToday
            ? BoxDecoration(
                color: primary.withValues(alpha: 0.06),
              )
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day badge
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isToday ? Colors.white : tokens.inkMuted,
                    ),
                  ),
                  Text(
                    '$dayNumber',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isToday ? Colors.white : tokens.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Dish names
            Expanded(
              child: dishNames.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Nessun piatto',
                        style: TextStyle(
                          fontSize: 14,
                          color: tokens.inkMuted,
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        for (final name in dishNames)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: tokens.ink,
                              ),
                            ),
                          ),
                        if (guests != null)
                          Text(
                            '$guests ${guests == 1 ? "commensale" : "commensali"}',
                            style: TextStyle(
                              fontSize: 13,
                              color: tokens.inkMuted,
                            ),
                          ),
                      ],
                    ),
            ),
            Icon(Icons.chevron_right, color: tokens.inkMuted, size: 20),
          ],
        ),
      ),
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
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
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
                    style: Theme.of(context).textTheme.titleSmall),
                Text(range,
                    style: TextStyle(
                      fontSize: 13,
                      color: tokens.inkMuted,
                    )),
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
