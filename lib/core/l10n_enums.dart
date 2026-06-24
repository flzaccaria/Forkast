import '../l10n/generated/app_localizations.dart';
import 'dish_enums.dart';
import 'unit.dart';

extension UnitL10n on Unit {
  String localizedLabel(AppLocalizations l) => switch (this) {
        Unit.grammi => l.unitGrammi,
        Unit.chilogrammi => l.unitChilogrammi,
        Unit.millilitri => l.unitMillilitri,
        Unit.litri => l.unitLitri,
        Unit.pezzo => l.unitPezzo,
      };
}

extension DifficultyL10n on Difficulty {
  String localizedLabel(AppLocalizations l) => switch (this) {
        Difficulty.facile => l.difficultyFacile,
        Difficulty.medio => l.difficultyMedio,
        Difficulty.difficile => l.difficultyDifficile,
      };
}

extension TimeEstimateL10n on TimeEstimate {
  String localizedLabel(AppLocalizations l) => switch (this) {
        TimeEstimate.veloce => l.timeVeloce,
        TimeEstimate.medio => l.timeMedio,
        TimeEstimate.lento => l.timeLento,
      };
}

/// Maps the Italian department key (stored in DB) to a localized display label.
String localizedReparto(String? key, AppLocalizations l) {
  if (key == null) return l.departmentUnassigned;
  return switch (key) {
    'Ortofrutta' => l.departmentOrtofrutta,
    'Macelleria' => l.departmentMacelleria,
    'Pescheria' => l.departmentPescheria,
    'Salumi e formaggi' => l.departmentSalumi,
    'Latticini e uova' => l.departmentLatticini,
    'Pane e forno' => l.departmentPaneForno,
    'Dispensa' => l.departmentDispensa,
    'Surgelati' => l.departmentSurgelati,
    'Bevande' => l.departmentBevande,
    'Cura della casa' => l.departmentCasaCura,
    'Cura della persona' => l.departmentPersonaCura,
    'Altro' => l.departmentAltro,
    _ => key,
  };
}

/// Label for the "unassigned department" option (used in dropdowns).
String localizedRepartoNonAssegnato(AppLocalizations l) =>
    l.departmentUnassigned;
