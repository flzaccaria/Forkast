// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get navDishes => 'Retter';

  @override
  String get navPlan => 'Plan';

  @override
  String get navList => 'Liste';

  @override
  String get navIngredients => 'Ingredienser';

  @override
  String get cancel => 'Annuller';

  @override
  String get save => 'Gem';

  @override
  String get add => 'Tilføj';

  @override
  String get delete => 'Slet';

  @override
  String get close => 'Luk';

  @override
  String get confirm => 'Bekræft';

  @override
  String get name => 'Navn';

  @override
  String get required => 'Påkrævet';

  @override
  String get edit => 'Rediger';

  @override
  String get qb => 'efter smag';

  @override
  String get quantoBasta => 'efter smag';

  @override
  String get bootstrapMissingConfig =>
      'Manglende konfiguration. Start med --dart-define for SUPABASE_URL, SUPABASE_ANON_KEY og POWERSYNC_URL.';

  @override
  String get bootstrapError => 'Opstartsfejl';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get settingsPlanning => 'Planlægning';

  @override
  String get settingsDefaultGuests => 'Standardantal gæster';

  @override
  String get settingsDefaultGuestsSubtitle => 'Startværdi for hver ny middag';

  @override
  String get settingsWeekStart => 'Ugen starter';

  @override
  String get settingsCatalogs => 'Kataloger';

  @override
  String get settingsCoursesVocabulary => 'Retterordforråd';

  @override
  String get settingsDevices => 'Enheder';

  @override
  String get settingsPairDevice => 'Par en enhed';

  @override
  String get settingsPairDeviceSubtitle => 'Del data med en anden telefon';

  @override
  String get settingsSync => 'Synkronisering';

  @override
  String get settingsSyncSubtitle => 'Synkroniseringsstatus mellem enheder';

  @override
  String get settingsLanguage => 'Sprog';

  @override
  String get settingsLanguageSubtitle => 'Brugerfladesprog';

  @override
  String get languageSystem => 'System';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get languageDa => 'Dansk';

  @override
  String get dishesSearchHint => 'Søg efter en ret';

  @override
  String get dishesEmptyState =>
      'Ingen retter endnu.\nTryk + for at oprette den første.';

  @override
  String get dishesNoResults => 'Ingen retter fundet.';

  @override
  String get filterAll => 'Alle';

  @override
  String get dishEditorNewTitle => 'Ny ret';

  @override
  String get dishEditorEditTitle => 'Rediger ret';

  @override
  String get dishEditorNameLabel => 'Navn på ret';

  @override
  String get dishEditorRecipeUrl => 'Opskriftslink';

  @override
  String get dishEditorNameRequired => 'Indtast retnavnet';

  @override
  String dishEditorInvalidQty(String name) {
    return 'Ugyldig mængde for $name';
  }

  @override
  String get dishEditorSaveError => 'Fejl ved gemning af ret';

  @override
  String get dishEditorDeleteError => 'Fejl ved sletning af ret';

  @override
  String get dishEditorDifficulty => 'Sværhedsgrad';

  @override
  String get dishEditorTime => 'Tid';

  @override
  String get dishEditorIngredients => 'Ingredienser';

  @override
  String get dishEditorQuantitiesNote => 'Mængder er for 4 personer';

  @override
  String get dishEditorNoIngredients => 'Ingen ingredienser tilføjet.';

  @override
  String get dishEditorCourse => 'Ret';

  @override
  String get dishEditorNoCoursesDefined =>
      'Ingen retter defineret. Tilføj dem i Indstillinger → Retterordforråd.';

  @override
  String get dishEditorCreateIngredient => 'Opret ny ingrediens';

  @override
  String get dishEditorSimilarExisting => 'Lignende ingredienser findes';

  @override
  String get dishEditorSimilarExistingMessage =>
      'Lignende ingredienser findes allerede i kataloget:';

  @override
  String get dishEditorCreateAnyway => 'Opret alligevel';

  @override
  String get dishEditorCatalogEmpty =>
      'Kataloget er tomt. Opret den første ingrediens.';

  @override
  String get planPrevWeekEmpty => 'Den forrige uge er tom.';

  @override
  String get planWeekNotEmpty => 'Denne uge er ikke tom';

  @override
  String get planWeekNotEmptyMessage =>
      'Vil du erstatte de eksisterende retter eller tilføje dem fra den forrige uge?';

  @override
  String get planMerge => 'Tilføj';

  @override
  String get planReplace => 'Erstat';

  @override
  String get planWeekCopied => 'Uge kopieret.';

  @override
  String get planCopyPrevWeek => 'Kopiér forrige uge';

  @override
  String get planNoDishes => 'Ingen retter';

  @override
  String planGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gæster',
      one: '1 gæst',
    );
    return '$_temp0';
  }

  @override
  String planWeekLabel(int week, int year) {
    return 'Uge $week · $year';
  }

  @override
  String get planToday => 'I dag';

  @override
  String get dayGuests => 'Gæster';

  @override
  String get dayAddDish => 'Tilføj ret';

  @override
  String get dayEmptyState =>
      'Ingen retter til denne middag.\nTryk \"Tilføj ret\" for at starte.';

  @override
  String get pickerTitle => 'Tilføj retter';

  @override
  String pickerAddCount(int count) {
    return 'Tilføj ($count)';
  }

  @override
  String get pickerEmptyCatalog => 'Ingen retter i kataloget.';

  @override
  String get pickerAlreadyInDinner => 'Allerede i denne middag';

  @override
  String get listEmpty =>
      'Intet på listen endnu.\nPlanlæg nogle middage, så klarer jeg resten.';

  @override
  String get listGeneratedEmpty =>
      'Det genererede lag er tomt: denne uges plan har ingen retter med ingredienser.';

  @override
  String get listModified => 'ændret';

  @override
  String get listRemoved => 'fjernet';

  @override
  String get listManualAdds => 'MANUELLE TILFØJELSER';

  @override
  String get listManualBadge => 'manuel';

  @override
  String get listEditQty => 'Rediger mængde';

  @override
  String get listRemoveFromList => 'Fjern fra listen';

  @override
  String get listRestoreCalculated => 'Gendan beregnet værdi';

  @override
  String listQtyDialogTitle(String name) {
    return 'Mængde — $name';
  }

  @override
  String get listManualTitle => 'Manuel post';

  @override
  String get listQtyLabel => 'Mængde (valgfrit)';

  @override
  String get listUnitLabel => 'Enhed (valgf.)';

  @override
  String get listManualAdd => 'Tilføj';

  @override
  String get tagsTitle => 'Retterordforråd';

  @override
  String get tagsCourses => 'Retter';

  @override
  String get tagsNewCourse => 'Ny ret';

  @override
  String get tagsRename => 'Omdøb';

  @override
  String tagsInUse(String name, int count) {
    return '\"$name\" bruges i $count retter: fjern den fra disse retter først.';
  }

  @override
  String get tagsEmptyHint =>
      'Ingen retter. Eksempler: Forret, Hovedret, Tilbehør.';

  @override
  String get ingredientFormNewTitle => 'Ny ingrediens';

  @override
  String get ingredientFormEditTitle => 'Rediger ingrediens';

  @override
  String get ingredientFormUnitLabel => 'Måleenhed';

  @override
  String get ingredientFormUnitLocked =>
      'Låst: ingrediensen bruges allerede i en ret';

  @override
  String get ingredientFormQb => 'Efter smag';

  @override
  String get ingredientFormQbSubtitle => 'Ingen mængde, ikke skaleret';

  @override
  String get ingredientFormDepartment => 'Afdeling';

  @override
  String get ingredientFormDepartmentHelper =>
      'Grupperer indkøbslisten efter afdeling';

  @override
  String get ingredientFormDuplicateError =>
      'Fejl: en ingrediens med dette navn findes allerede?';

  @override
  String get ingredientsAdded => 'Ingrediens tilføjet';

  @override
  String get ingredientsEmptyState =>
      'Ingen ingredienser endnu.\nTryk + for at tilføje den første.';

  @override
  String ingredientsUsageTitle(String name) {
    return '\"$name\" — hvor den bruges';
  }

  @override
  String get ingredientsNotUsed => 'Bruges ikke i nogen ret.';

  @override
  String ingredientsUsedInCount(String name, int count) {
    return '\"$name\" bruges i $count retter: fjern den fra disse retter først.';
  }

  @override
  String ingredientsDeleted(String name) {
    return '\"$name\" slettet.';
  }

  @override
  String get ingredientsNoMergeCandidates =>
      'Ingen ingrediens med samme enhed at flette.';

  @override
  String ingredientsMergeTitle(String name) {
    return 'Flet \"$name\" ind i…';
  }

  @override
  String ingredientsMergeSuccess(String source, String target) {
    return '\"$source\" flettet ind i \"$target\".';
  }

  @override
  String get ingredientsMergeError =>
      'Fletning mislykkedes: enheder skal matche.';

  @override
  String get ingredientsUsage => 'Hvor den bruges';

  @override
  String get ingredientsMergeDuplicate => 'Flet dublet';

  @override
  String get pairingTitle => 'Par en enhed';

  @override
  String get pairingShowCode => 'Vis kode';

  @override
  String get pairingEnterCode => 'Indtast kode';

  @override
  String get pairingShowCodeInstructions =>
      'Generer en kode og scan den med den anden telefon, eller indtast den manuelt.';

  @override
  String pairingExpiresIn(String time) {
    return 'Udløber om $time';
  }

  @override
  String get pairingGenerateError => 'Kan ikke generere koden.';

  @override
  String get pairingGenerate => 'Generer kode';

  @override
  String get pairingGenerateNew => 'Generer ny kode';

  @override
  String get pairingEnterCodeInstructions =>
      'Indtast koden vist på den anden telefon.';

  @override
  String get pairingSuccess => 'Enhed parret. Synkroniserer…';

  @override
  String get pairingError => 'Parring mislykkedes.';

  @override
  String get pairingJoin => 'Tilslut';

  @override
  String get syncTitle => 'Synkronisering';

  @override
  String get syncUnavailable => 'Synkronisering ikke tilgængelig.';

  @override
  String get syncConnected => 'Forbundet';

  @override
  String get syncConnecting => 'Forbinder…';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncNever => 'Aldrig';

  @override
  String get syncSyncedOnce => 'Data synkroniseret mindst én gang';

  @override
  String get syncWaitingFirst => 'Venter på første synkronisering';

  @override
  String get syncLastSync => 'Sidste synkronisering';

  @override
  String get syncDownload => 'Download';

  @override
  String get syncUpload => 'Upload';

  @override
  String get syncInProgress => 'I gang…';

  @override
  String get syncIdle => 'Inaktiv';

  @override
  String get syncLastError => 'Sidste fejl';

  @override
  String get syncOfflineNote =>
      'Appen virker også offline: ændringer forbliver på enheden og synkroniseres, når netværket er tilbage.';

  @override
  String get deleteDishTitle => 'Slet denne ret?';

  @override
  String deleteDishWithPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planlagte middage',
      one: '1 planlagt middag',
    );
    return 'Denne ret bruges i $_temp0: sletning fjerner den også derfra. Slet alligevel?';
  }

  @override
  String get deleteDishNoPlan => 'Retten fjernes fra kataloget. Slet?';

  @override
  String get unitGrammi => 'Gram (g)';

  @override
  String get unitChilogrammi => 'Kilogram (kg)';

  @override
  String get unitMillilitri => 'Milliliter (ml)';

  @override
  String get unitLitri => 'Liter (l)';

  @override
  String get unitPezzo => 'Styk (stk)';

  @override
  String get difficultyFacile => 'Let';

  @override
  String get difficultyMedio => 'Middel';

  @override
  String get difficultyDifficile => 'Svær';

  @override
  String get timeVeloce => 'Hurtig';

  @override
  String get timeMedio => 'Middel';

  @override
  String get timeLento => 'Langsom';

  @override
  String get departmentOrtofrutta => 'Frugt og grønt';

  @override
  String get departmentMacelleria => 'Slagter';

  @override
  String get departmentPescheria => 'Fiskehandler';

  @override
  String get departmentSalumi => 'Pålæg og ost';

  @override
  String get departmentLatticini => 'Mejeri og æg';

  @override
  String get departmentPaneForno => 'Brød og bageri';

  @override
  String get departmentDispensa => 'Spisekammer';

  @override
  String get departmentSurgelati => 'Frost';

  @override
  String get departmentBevande => 'Drikkevarer';

  @override
  String get departmentCasaCura => 'Husholdning';

  @override
  String get departmentPersonaCura => 'Personlig pleje';

  @override
  String get departmentAltro => 'Andet';

  @override
  String get departmentUnassigned => 'Ingen afdeling';

  @override
  String get ingredientsSearchHint => 'Søg efter en ingrediens';

  @override
  String get ingredientsNoResults => 'Ingen ingredienser fundet.';

  @override
  String ingredientsResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredienser',
      one: '1 ingrediens',
    );
    return '$_temp0';
  }

  @override
  String get ingredientsFilterTitle => 'Filtre';

  @override
  String get ingredientsFilterDepartment => 'Afdeling';

  @override
  String get ingredientsFilterUnit => 'Enhed';

  @override
  String get ingredientsFilterQb => 'Efter smag';

  @override
  String get ingredientsFilterQbYes => 'Kun efter smag';

  @override
  String get ingredientsFilterQbNo => 'Kun med mængde';

  @override
  String get ingredientsFilterUsage => 'Brug';

  @override
  String get ingredientsFilterUsed => 'Bruges i mindst én ret';

  @override
  String get ingredientsFilterUnused => 'Ikke brugt';

  @override
  String get ingredientsFilterReset => 'Nulstil filtre';

  @override
  String get ingredientsSortName => 'Navn';

  @override
  String get ingredientsSortDepartment => 'Afdeling';

  @override
  String get ingredientsSortUsage => 'Antal brug';

  @override
  String get ingredientsSortAsc => 'A → Z';

  @override
  String get ingredientsSortDesc => 'Z → A';

  @override
  String get ingredientsViewGrouped => 'Efter afdeling';

  @override
  String get ingredientsViewFlat => 'Flad liste';

  @override
  String ingredientsUsageCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count retter',
      one: '1 ret',
      zero: 'ikke brugt',
    );
    return '$_temp0';
  }
}
