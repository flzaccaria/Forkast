import 'package:flutter/material.dart';

import '../../core/l10n_enums.dart';
import '../../core/reparto.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme.dart';

class RepartoDepartmentHeader extends StatelessWidget {
  const RepartoDepartmentHeader({super.key, required this.dbKey});

  final String? dbKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final primary = Theme.of(context).colorScheme.primary;
    final surfacePage = Theme.of(context).extension<ForkastTokens>()!.surfacePage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      color: surfacePage,
      child: Text(
        localizedReparto(dbKey, l).toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: primary,
        ),
      ),
    );
  }
}

sealed class RepartoEntry<T> {
  const RepartoEntry();
}

class RepartoHeaderEntry<T> extends RepartoEntry<T> {
  const RepartoHeaderEntry(this.dbKey);
  final String? dbKey;
}

class RepartoItemEntry<T> extends RepartoEntry<T> {
  const RepartoItemEntry(this.item);
  final T item;
}

List<RepartoEntry<T>> groupByReparto<T>({
  required List<T> items,
  required String? Function(T) categoryOf,
  required String Function(T) nameOf,
}) {
  final sorted = [...items]..sort((a, b) {
      final byReparto =
          repartoSortIndex(categoryOf(a)).compareTo(repartoSortIndex(categoryOf(b)));
      return byReparto != 0 ? byReparto : nameOf(a).compareTo(nameOf(b));
    });
  final entries = <RepartoEntry<T>>[];
  String? currentLabel;
  for (final item in sorted) {
    final label = categoryOf(item) ?? repartoNonAssegnato;
    if (label != currentLabel) {
      entries.add(RepartoHeaderEntry<T>(categoryOf(item)));
      currentLabel = label;
    }
    entries.add(RepartoItemEntry<T>(item));
  }
  return entries;
}
