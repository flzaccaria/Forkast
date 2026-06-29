// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navDishes => 'Dishes';

  @override
  String get navPlan => 'Plan';

  @override
  String get navList => 'List';

  @override
  String get navIngredients => 'Ingredients';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get name => 'Name';

  @override
  String get required => 'Required';

  @override
  String get edit => 'Edit';

  @override
  String get qb => 'to taste';

  @override
  String get quantoBasta => 'to taste';

  @override
  String get bootstrapMissingConfig =>
      'Missing configuration. Launch with --dart-define for SUPABASE_URL, SUPABASE_ANON_KEY and POWERSYNC_URL.';

  @override
  String get bootstrapError => 'Startup error';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPlanning => 'Planning';

  @override
  String get settingsDefaultGuests => 'Default guests';

  @override
  String get settingsDefaultGuestsSubtitle =>
      'Starting value for each new dinner';

  @override
  String get settingsWeekStart => 'Week starts on';

  @override
  String get settingsCatalogs => 'Catalogs';

  @override
  String get settingsCoursesVocabulary => 'Course vocabulary';

  @override
  String get settingsDevices => 'Devices';

  @override
  String get settingsPairDevice => 'Pair a device';

  @override
  String get settingsPairDeviceSubtitle => 'Share data with a second phone';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsSyncSubtitle => 'Sync status between devices';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Interface language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get languageDa => 'Dansk';

  @override
  String get dishesSearchHint => 'Search a dish';

  @override
  String get dishesEmptyState =>
      'No dishes yet.\nTap + to create the first one.';

  @override
  String get dishesNoResults => 'No dishes found.';

  @override
  String get filterAll => 'All';

  @override
  String get dishEditorNewTitle => 'New dish';

  @override
  String get dishEditorEditTitle => 'Edit dish';

  @override
  String get dishEditorNameLabel => 'Dish name';

  @override
  String get dishEditorRecipeUrl => 'Recipe link';

  @override
  String get dishEditorNameRequired => 'Enter the dish name';

  @override
  String dishEditorInvalidQty(String name) {
    return 'Invalid quantity for $name';
  }

  @override
  String get dishEditorSaveError => 'Error saving dish';

  @override
  String get dishEditorDeleteError => 'Error deleting dish';

  @override
  String get dishEditorDifficulty => 'Difficulty';

  @override
  String get dishEditorTime => 'Time';

  @override
  String get dishEditorIngredients => 'Ingredients';

  @override
  String get dishEditorQuantitiesNote => 'Quantities are for 4 people';

  @override
  String get dishEditorNoIngredients => 'No ingredients added.';

  @override
  String get dishEditorCourse => 'Course';

  @override
  String get dishEditorNoCoursesDefined =>
      'No courses defined. Add them in Settings → Course vocabulary.';

  @override
  String get dishEditorCreateIngredient => 'Create new ingredient';

  @override
  String get dishEditorSimilarExisting => 'Similar ingredients exist';

  @override
  String get dishEditorSimilarExistingMessage =>
      'Similar ingredients already exist in the catalog:';

  @override
  String get dishEditorCreateAnyway => 'Create anyway';

  @override
  String get dishEditorCatalogEmpty =>
      'Catalog is empty. Create the first ingredient.';

  @override
  String get planPrevWeekEmpty => 'The previous week is empty.';

  @override
  String get planWeekNotEmpty => 'This week is not empty';

  @override
  String get planWeekNotEmptyMessage =>
      'Do you want to replace the existing dishes or add those from the previous week?';

  @override
  String get planMerge => 'Add';

  @override
  String get planReplace => 'Replace';

  @override
  String get planWeekCopied => 'Week copied.';

  @override
  String get planCopyPrevWeek => 'Copy previous week';

  @override
  String get planNoDishes => 'No dishes';

  @override
  String planGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count guests',
      one: '1 guest',
    );
    return '$_temp0';
  }

  @override
  String planWeekLabel(int week, int year) {
    return 'Week $week · $year';
  }

  @override
  String get planToday => 'Today';

  @override
  String get dayGuests => 'Guests';

  @override
  String get dayAddDish => 'Add dish';

  @override
  String get dayEmptyState =>
      'No dishes for this dinner.\nTap \"Add dish\" to start.';

  @override
  String get pickerTitle => 'Add dishes';

  @override
  String pickerAddCount(int count) {
    return 'Add ($count)';
  }

  @override
  String get pickerEmptyCatalog => 'No dishes in the catalog.';

  @override
  String get pickerAlreadyInDinner => 'Already in this dinner';

  @override
  String get listEmpty =>
      'Nothing in the list yet.\nPlan some dinners and I\'ll take care of it.';

  @override
  String get listGeneratedEmpty =>
      'The generated layer is empty: this week\'s plan has no dishes with ingredients.';

  @override
  String get listModified => 'modified';

  @override
  String get listRemoved => 'removed';

  @override
  String get listManualAdds => 'MANUAL ADDITIONS';

  @override
  String get listManualBadge => 'manual';

  @override
  String get listEditQty => 'Edit quantity';

  @override
  String get listRemoveFromList => 'Remove from list';

  @override
  String get listRestoreCalculated => 'Restore calculated value';

  @override
  String listQtyDialogTitle(String name) {
    return 'Quantity — $name';
  }

  @override
  String get listManualTitle => 'Manual entry';

  @override
  String get listQtyLabel => 'Quantity (optional)';

  @override
  String get listUnitLabel => 'Unit (opt.)';

  @override
  String get listManualAdd => 'Add';

  @override
  String get tagsTitle => 'Course vocabulary';

  @override
  String get tagsCourses => 'Courses';

  @override
  String get tagsNewCourse => 'New course';

  @override
  String get tagsRename => 'Rename';

  @override
  String tagsInUse(String name, int count) {
    return '\"$name\" is used in $count dishes: remove it from those dishes first.';
  }

  @override
  String get tagsEmptyHint => 'No courses. Examples: Starter, Main, Side.';

  @override
  String get ingredientFormNewTitle => 'New ingredient';

  @override
  String get ingredientFormEditTitle => 'Edit ingredient';

  @override
  String get ingredientFormUnitLabel => 'Unit of measure';

  @override
  String get ingredientFormUnitLocked =>
      'Locked: the ingredient is already used in a dish';

  @override
  String get ingredientFormQb => 'To taste';

  @override
  String get ingredientFormQbSubtitle => 'No quantity, not rescaled';

  @override
  String get ingredientFormDepartment => 'Department';

  @override
  String get ingredientFormDepartmentHelper =>
      'Groups the shopping list by department';

  @override
  String get ingredientFormDuplicateError =>
      'Error: an ingredient with this name already exists?';

  @override
  String get ingredientsAdded => 'Ingredient added';

  @override
  String get ingredientsEmptyState =>
      'No ingredients yet.\nTap + to add the first one.';

  @override
  String ingredientsUsageTitle(String name) {
    return '\"$name\" — where it\'s used';
  }

  @override
  String get ingredientsNotUsed => 'Not used in any dish.';

  @override
  String ingredientsUsedInCount(String name, int count) {
    return '\"$name\" is used in $count dishes: remove it from those dishes first.';
  }

  @override
  String ingredientsDeleted(String name) {
    return '\"$name\" deleted.';
  }

  @override
  String get ingredientsNoMergeCandidates =>
      'No ingredient with the same unit to merge.';

  @override
  String ingredientsMergeTitle(String name) {
    return 'Merge \"$name\" into…';
  }

  @override
  String ingredientsMergeSuccess(String source, String target) {
    return '\"$source\" merged into \"$target\".';
  }

  @override
  String get ingredientsMergeError => 'Merge failed: units must match.';

  @override
  String get ingredientsUsage => 'Where it\'s used';

  @override
  String get ingredientsMergeDuplicate => 'Merge duplicate';

  @override
  String get pairingTitle => 'Pair a device';

  @override
  String get pairingShowCode => 'Show code';

  @override
  String get pairingEnterCode => 'Enter code';

  @override
  String get pairingShowCodeInstructions =>
      'Generate a code and scan it with the other phone, or type it manually.';

  @override
  String pairingExpiresIn(String time) {
    return 'Expires in $time';
  }

  @override
  String get pairingGenerateError => 'Unable to generate the code.';

  @override
  String get pairingGenerate => 'Generate code';

  @override
  String get pairingGenerateNew => 'Generate new code';

  @override
  String get pairingEnterCodeInstructions =>
      'Enter the code shown on the other phone.';

  @override
  String get pairingSuccess => 'Device paired. Syncing…';

  @override
  String get pairingError => 'Pairing failed.';

  @override
  String get pairingJoin => 'Join';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncUnavailable => 'Sync not available.';

  @override
  String get syncConnected => 'Connected';

  @override
  String get syncConnecting => 'Connecting…';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncNever => 'Never';

  @override
  String get syncSyncedOnce => 'Data synced at least once';

  @override
  String get syncWaitingFirst => 'Waiting for first sync';

  @override
  String get syncLastSync => 'Last sync';

  @override
  String get syncDownload => 'Download';

  @override
  String get syncUpload => 'Upload';

  @override
  String get syncInProgress => 'In progress…';

  @override
  String get syncIdle => 'Idle';

  @override
  String get syncLastError => 'Last error';

  @override
  String get syncOfflineNote =>
      'The app works offline too: changes stay on the device and sync when the network is back.';

  @override
  String get deleteDishTitle => 'Delete this dish?';

  @override
  String deleteDishWithPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planned dinners',
      one: '1 planned dinner',
    );
    return 'This dish is used in $_temp0: deleting it will also remove it from those. Delete anyway?';
  }

  @override
  String get deleteDishNoPlan =>
      'The dish will be removed from the catalog. Delete?';

  @override
  String get unitGrammi => 'Grams (g)';

  @override
  String get unitChilogrammi => 'Kilograms (kg)';

  @override
  String get unitMillilitri => 'Millilitres (ml)';

  @override
  String get unitLitri => 'Litres (l)';

  @override
  String get unitPezzo => 'Piece (pc)';

  @override
  String get difficultyFacile => 'Easy';

  @override
  String get difficultyMedio => 'Medium';

  @override
  String get difficultyDifficile => 'Hard';

  @override
  String get timeVeloce => 'Quick';

  @override
  String get timeMedio => 'Medium';

  @override
  String get timeLento => 'Slow';

  @override
  String get departmentOrtofrutta => 'Fruit & Vegetables';

  @override
  String get departmentMacelleria => 'Butcher';

  @override
  String get departmentPescheria => 'Fishmonger';

  @override
  String get departmentSalumi => 'Deli & Cheese';

  @override
  String get departmentLatticini => 'Dairy & Eggs';

  @override
  String get departmentPaneForno => 'Bread & Bakery';

  @override
  String get departmentDispensa => 'Pantry';

  @override
  String get departmentSurgelati => 'Frozen';

  @override
  String get departmentBevande => 'Beverages';

  @override
  String get departmentCasaCura => 'Household';

  @override
  String get departmentPersonaCura => 'Personal care';

  @override
  String get departmentAltro => 'Other';

  @override
  String get departmentUnassigned => 'No department';

  @override
  String get ingredientsSearchHint => 'Search an ingredient';

  @override
  String get ingredientsNoResults => 'No ingredients found.';

  @override
  String ingredientsResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredients',
      one: '1 ingredient',
    );
    return '$_temp0';
  }

  @override
  String get ingredientsFilterTitle => 'Filters';

  @override
  String get ingredientsFilterDepartment => 'Department';

  @override
  String get ingredientsFilterUnit => 'Unit';

  @override
  String get ingredientsFilterQb => 'To taste';

  @override
  String get ingredientsFilterQbYes => 'To taste only';

  @override
  String get ingredientsFilterQbNo => 'With quantity only';

  @override
  String get ingredientsFilterUsage => 'Usage';

  @override
  String get ingredientsFilterUsed => 'Used in at least one dish';

  @override
  String get ingredientsFilterUnused => 'Not used';

  @override
  String get ingredientsFilterReset => 'Clear filters';

  @override
  String get ingredientsSortName => 'Name';

  @override
  String get ingredientsSortDepartment => 'Department';

  @override
  String get ingredientsSortUsage => 'Usage count';

  @override
  String get ingredientsSortAsc => 'A → Z';

  @override
  String get ingredientsSortDesc => 'Z → A';

  @override
  String get ingredientsViewGrouped => 'By department';

  @override
  String get ingredientsViewFlat => 'Flat list';

  @override
  String ingredientsUsageCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dishes',
      one: '1 dish',
      zero: 'not used',
    );
    return '$_temp0';
  }

  @override
  String get ingredientAlwaysInList => 'Always in list';

  @override
  String get ingredientAlwaysInListSubtitle =>
      'Automatically added to the shopping list';

  @override
  String get ingredientDefaultQty => 'Default quantity';

  @override
  String get ingredientsFilterRecurring => 'Recurring';

  @override
  String get ingredientsFilterRecurringOnly => 'Recurring only';

  @override
  String get ingredientsFilterNonRecurring => 'Non-recurring';

  @override
  String get listResetChecks => 'Reset checks';

  @override
  String get listResetConfirm =>
      'Clear all check marks? Plan, rows, overrides and manual items stay untouched.';

  @override
  String get listResetDone => 'Checks reset.';

  @override
  String get listExcludeThisWeek => 'Exclude this week';

  @override
  String get listIncludeAgain => 'Include again';

  @override
  String get listRecurringLabel => 'recurring';

  @override
  String get historyTitle => 'Past weeks';

  @override
  String get historyEmpty => 'No past weeks.';

  @override
  String get dishNeverPlanned => 'never';

  @override
  String get dishThisWeek => 'this week';

  @override
  String get dishOneWeekAgo => '1 week ago';

  @override
  String dishWeeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String get dishSortLeastRecent => 'Least recent';

  @override
  String get dishFilterNotMadeSince => 'Not made for over';

  @override
  String dishFilterWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
    );
    return '$_temp0';
  }

  @override
  String get dishLastPlannedLabel => 'Last made';

  @override
  String get surpriseMe => 'Surprise me';

  @override
  String surpriseMePartial(int filled, int total) {
    return 'Filled $filled of $total days. Not enough dishes available.';
  }

  @override
  String get surpriseMeRegenerate => 'Regenerate';

  @override
  String get surpriseMeUndo => 'Undo';

  @override
  String get surpriseMeNoDishes => 'No dishes available for the empty days.';

  @override
  String get surpriseMeSuccess => 'Plan completed!';
}
