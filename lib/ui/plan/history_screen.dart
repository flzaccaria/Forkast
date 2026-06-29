import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/display_name.dart';
import '../../core/week.dart';
import '../../data/database.dart';
import '../../data/repositories/plan_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import '../app_scope.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late PlanRepository _repo;
  late Stream<List<WeekPlan>> _stream;
  int _weekStartDay = DateTime.monday;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _repo = PlanRepository(scope.database, scope.householdId);
    _stream = _repo.watchPastWeekPlans();
    _repo.weekStartDay().then((v) {
      if (mounted) setState(() => _weekStartDay = v);
    });
  }

  String _rangeLabel(int year, int week) {
    final locale = Localizations.localeOf(context).toString();
    final first = dateOfIsoWeek(year, week, _weekStartDay);
    final last = first.add(const Duration(days: 6));
    final fmt = DateFormat.MMMd(locale);
    return '${fmt.format(first)} – ${fmt.format(last)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: StreamBuilder<List<WeekPlan>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final weeks = snapshot.data!;
          if (weeks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_outlined, size: 48,
                        color: tokens.inkMuted),
                    const SizedBox(height: 12),
                    Text(
                      l.historyEmpty,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: tokens.inkMuted, fontSize: 15),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: weeks.length,
            separatorBuilder: (_, __) => Divider(
              height: 0.5,
              indent: 20,
              endIndent: 20,
              color: tokens.border,
            ),
            itemBuilder: (context, i) {
              final wp = weeks[i];
              return _HistoryWeekTile(
                weekPlan: wp,
                label: l.planWeekLabel(wp.week, wp.year),
                range: _rangeLabel(wp.year, wp.week),
                repo: _repo,
              );
            },
          );
        },
      ),
    );
  }
}

class _HistoryWeekTile extends StatefulWidget {
  const _HistoryWeekTile({
    required this.weekPlan,
    required this.label,
    required this.range,
    required this.repo,
  });

  final WeekPlan weekPlan;
  final String label;
  final String range;
  final PlanRepository repo;

  @override
  State<_HistoryWeekTile> createState() => _HistoryWeekTileState();
}

class _HistoryWeekTileState extends State<_HistoryWeekTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return Column(
      children: [
        ListTile(
          title: Text(widget.label),
          subtitle: Text(widget.range),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: tokens.inkMuted,
          ),
          onTap: () => setState(() => _expanded = !_expanded),
        ),
        if (_expanded)
          _HistoryWeekDetail(
            weekPlanId: widget.weekPlan.id,
            repo: widget.repo,
          ),
      ],
    );
  }
}

class _HistoryWeekDetail extends StatelessWidget {
  const _HistoryWeekDetail({
    required this.weekPlanId,
    required this.repo,
  });

  final String weekPlanId;
  final PlanRepository repo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final tokens = Theme.of(context).extension<ForkastTokens>()!;
    return StreamBuilder<Map<int, DayOverview>>(
      stream: repo.watchWeekOverview(weekPlanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final overview = snapshot.data!;
        if (overview.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.planNoDishes,
                style: TextStyle(color: tokens.inkMuted)),
          );
        }
        final days = overview.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in days) ...[
                Text(
                  DateFormat.EEEE(locale)
                      .format(DateTime(2024, 1, entry.key)),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: tokens.inkMuted,
                  ),
                ),
                if (entry.value.dishes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(l.planNoDishes,
                        style: TextStyle(
                            fontSize: 13, color: tokens.inkMuted)),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final dish in entry.value.dishes)
                          Text(
                            localizedSeedName(
                              storedName: dish.name,
                              seedKey: dish.seedKey,
                              nameModified: dish.nameModified,
                              locale: locale,
                            ),
                            style: TextStyle(fontSize: 14, color: tokens.ink),
                          ),
                        Text(
                          l.planGuests(entry.value.guests),
                          style: TextStyle(
                              fontSize: 12, color: tokens.inkMuted),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
