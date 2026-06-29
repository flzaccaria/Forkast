import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/l10n_enums.dart';
import '../../core/reparto.dart';
import '../../core/unit.dart';
import '../../data/database.dart';
import '../../data/repositories/ingredient_repository.dart';
import '../../l10n/generated/app_localizations.dart';

Future<Ingredient?> showIngredientForm(
  BuildContext context, {
  required IngredientRepository repo,
  String? initialName,
  Ingredient? existing,
}) {
  return showModalBottomSheet<Ingredient>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _IngredientForm(
      repo: repo,
      initialName: initialName,
      existing: existing,
    ),
  );
}

class _IngredientForm extends StatefulWidget {
  const _IngredientForm({required this.repo, this.initialName, this.existing});

  final IngredientRepository repo;
  final String? initialName;
  final Ingredient? existing;

  @override
  State<_IngredientForm> createState() => _IngredientFormState();
}

class _IngredientFormState extends State<_IngredientForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
      text: widget.existing?.name ?? widget.initialName ?? '');
  late bool _isQb = widget.existing?.isQb ?? false;
  late String? _category = widget.existing?.category;
  late Unit _selectedUnit = _resolveInitialUnit();
  late bool _alwaysInList = widget.existing?.alwaysInList ?? false;
  late final _defaultQtyController = TextEditingController(
    text: widget.existing?.defaultQty != null
        ? widget.existing!.defaultQty.toString()
        : '',
  );
  bool _saving = false;

  bool _unitLocked = false;

  bool get _isEditing => widget.existing != null;

  Unit _resolveInitialUnit() {
    if (widget.existing == null) return Unit.grammi;
    if (widget.existing!.isQb) return Unit.grammi;
    return Unit.tryParse(widget.existing!.unit) ??
        Unit.tryParseLoose(widget.existing!.unit) ??
        Unit.grammi;
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      widget.repo.isUnitLocked(widget.existing!.id).then((locked) {
        if (mounted) setState(() => _unitLocked = locked);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _defaultQtyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final unit = _isQb ? 'q.b.' : _selectedUnit.dbValue;
      final roundingKind = _isQb ? null : _selectedUnit.roundingKind;
      final defaultQty = double.tryParse(
          _defaultQtyController.text.replaceAll(',', '.'));
      if (_isEditing) {
        await widget.repo.update(
          widget.existing!.id,
          name: name,
          unit: unit,
          isQb: _unitLocked ? null : _isQb,
          roundingKind: _unitLocked ? null : roundingKind,
          category: Value(_category),
          alwaysInList: Value(_alwaysInList),
          defaultQty: Value(_alwaysInList ? defaultQty : null),
        );
        if (mounted) Navigator.of(context).pop(widget.existing);
      } else {
        final created = await widget.repo.create(
          name: name,
          unit: unit,
          isQb: _isQb,
          category: _category,
          roundingKind: roundingKind ?? 'weight',
          alwaysInList: _alwaysInList,
          defaultQty: _alwaysInList ? defaultQty : null,
        );
        if (mounted) Navigator.of(context).pop(created);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.ingredientFormDuplicateError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final unitEnabled = !_isQb && !_unitLocked;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_isEditing ? l.ingredientFormEditTitle : l.ingredientFormNewTitle,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l.name),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.required : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Unit>(
              initialValue: _selectedUnit,
              decoration: InputDecoration(
                labelText: l.ingredientFormUnitLabel,
                helperText: _unitLocked
                    ? l.ingredientFormUnitLocked
                    : null,
              ),
              items: [
                for (final u in Unit.values)
                  DropdownMenuItem(value: u, child: Text(u.localizedLabel(l))),
              ],
              onChanged: unitEnabled
                  ? (v) => setState(() => _selectedUnit = v!)
                  : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.ingredientFormQb),
              subtitle: Text(l.ingredientFormQbSubtitle),
              value: _isQb,
              onChanged: _unitLocked ? null : (v) => setState(() => _isQb = v),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: l.ingredientFormDepartment,
                helperText: l.ingredientFormDepartmentHelper,
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(localizedRepartoNonAssegnato(l)),
                ),
                for (final r in reparti)
                  DropdownMenuItem<String?>(value: r, child: Text(localizedReparto(r, l))),
              ],
              onChanged: (v) => setState(() => _category = v),
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.ingredientAlwaysInList),
              subtitle: Text(l.ingredientAlwaysInListSubtitle),
              value: _alwaysInList,
              onChanged: (v) => setState(() => _alwaysInList = v),
            ),
            if (_alwaysInList && !_isQb)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextFormField(
                  controller: _defaultQtyController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l.ingredientDefaultQty,
                    suffixText: _selectedUnit.dbValue,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
