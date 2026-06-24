// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navDishes => 'Piatti';

  @override
  String get navPlan => 'Piano';

  @override
  String get navList => 'Lista';

  @override
  String get navIngredients => 'Ingredienti';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get add => 'Aggiungi';

  @override
  String get delete => 'Elimina';

  @override
  String get close => 'Chiudi';

  @override
  String get confirm => 'Conferma';

  @override
  String get name => 'Nome';

  @override
  String get required => 'Obbligatorio';

  @override
  String get edit => 'Modifica';

  @override
  String get qb => 'q.b.';

  @override
  String get quantoBasta => 'quanto basta';

  @override
  String get bootstrapMissingConfig =>
      'Configurazione mancante. Lancia con --dart-define per SUPABASE_URL, SUPABASE_ANON_KEY e POWERSYNC_URL.';

  @override
  String get bootstrapError => 'Errore di avvio';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsPlanning => 'Pianificazione';

  @override
  String get settingsDefaultGuests => 'Commensali predefiniti';

  @override
  String get settingsDefaultGuestsSubtitle =>
      'Valore iniziale di ogni nuova serata';

  @override
  String get settingsWeekStart => 'Inizio settimana';

  @override
  String get settingsCatalogs => 'Cataloghi';

  @override
  String get settingsCoursesVocabulary => 'Vocabolario portate';

  @override
  String get settingsDevices => 'Dispositivi';

  @override
  String get settingsPairDevice => 'Abbina un dispositivo';

  @override
  String get settingsPairDeviceSubtitle =>
      'Condividi i dati con un secondo telefono';

  @override
  String get settingsSync => 'Sincronizzazione';

  @override
  String get settingsSyncSubtitle =>
      'Stato della sincronizzazione tra dispositivi';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSubtitle => 'Lingua dell\'interfaccia';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languageEn => 'English';

  @override
  String get languageDa => 'Dansk';

  @override
  String get dishesSearchHint => 'Cerca un piatto';

  @override
  String get dishesEmptyState =>
      'Nessun piatto ancora.\nTocca + per creare il primo.';

  @override
  String get dishesNoResults => 'Nessun piatto trovato.';

  @override
  String get filterAll => 'Tutti';

  @override
  String get dishEditorNewTitle => 'Nuovo piatto';

  @override
  String get dishEditorEditTitle => 'Modifica piatto';

  @override
  String get dishEditorNameLabel => 'Nome del piatto';

  @override
  String get dishEditorNameRequired => 'Inserisci il nome del piatto';

  @override
  String dishEditorInvalidQty(String name) {
    return 'Quantità non valida per $name';
  }

  @override
  String get dishEditorSaveError => 'Errore nel salvataggio del piatto';

  @override
  String get dishEditorDeleteError => 'Errore nell\'eliminazione del piatto';

  @override
  String get dishEditorDifficulty => 'Difficoltà';

  @override
  String get dishEditorTime => 'Tempo';

  @override
  String get dishEditorIngredients => 'Ingredienti';

  @override
  String get dishEditorQuantitiesNote => 'Le quantità sono per 4 persone';

  @override
  String get dishEditorNoIngredients => 'Nessun ingrediente aggiunto.';

  @override
  String get dishEditorCourse => 'Portata';

  @override
  String get dishEditorNoCoursesDefined =>
      'Nessuna portata definita. Aggiungile in Impostazioni → Vocabolario portate.';

  @override
  String get dishEditorCreateIngredient => 'Crea nuovo ingrediente';

  @override
  String get dishEditorCatalogEmpty =>
      'Il catalogo è vuoto. Crea il primo ingrediente.';

  @override
  String get planPrevWeekEmpty => 'La settimana precedente è vuota.';

  @override
  String get planWeekNotEmpty => 'Questa settimana non è vuota';

  @override
  String get planWeekNotEmptyMessage =>
      'Vuoi sostituire i piatti esistenti o aggiungere quelli della settimana precedente?';

  @override
  String get planMerge => 'Aggiungi';

  @override
  String get planReplace => 'Sostituisci';

  @override
  String get planWeekCopied => 'Settimana copiata.';

  @override
  String get planCopyPrevWeek => 'Copia settimana precedente';

  @override
  String get planNoDishes => 'Nessun piatto';

  @override
  String planGuests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commensali',
      one: '1 commensale',
    );
    return '$_temp0';
  }

  @override
  String planWeekLabel(int week, int year) {
    return 'Settimana $week · $year';
  }

  @override
  String get planToday => 'Oggi';

  @override
  String get dayGuests => 'Commensali';

  @override
  String get dayAddDish => 'Aggiungi piatto';

  @override
  String get dayEmptyState =>
      'Nessun piatto per questa cena.\nTocca \"Aggiungi piatto\" per iniziare.';

  @override
  String get pickerTitle => 'Aggiungi piatti';

  @override
  String pickerAddCount(int count) {
    return 'Aggiungi ($count)';
  }

  @override
  String get pickerEmptyCatalog => 'Nessun piatto nel catalogo.';

  @override
  String get pickerAlreadyInDinner => 'Già in questa cena';

  @override
  String get listEmpty =>
      'Ancora niente in lista.\nPianifica qualche cena e ci penso io.';

  @override
  String get listGeneratedEmpty =>
      'Lo strato generato è vuoto: il piano di questa settimana non ha piatti con ingredienti.';

  @override
  String get listModified => 'modificato';

  @override
  String get listRemoved => 'rimosso';

  @override
  String get listManualAdds => 'AGGIUNTE MANUALI';

  @override
  String get listManualBadge => 'manuale';

  @override
  String get listEditQty => 'Modifica quantità';

  @override
  String get listRemoveFromList => 'Rimuovi dalla lista';

  @override
  String get listRestoreCalculated => 'Ripristina valore calcolato';

  @override
  String listQtyDialogTitle(String name) {
    return 'Quantità — $name';
  }

  @override
  String get listManualTitle => 'Voce manuale';

  @override
  String get listQtyLabel => 'Quantità (opzionale)';

  @override
  String get listUnitLabel => 'Unità (opz.)';

  @override
  String get listManualAdd => 'Aggiungi';

  @override
  String get tagsTitle => 'Vocabolario portate';

  @override
  String get tagsCourses => 'Portate';

  @override
  String get tagsNewCourse => 'Nuova portata';

  @override
  String get tagsRename => 'Rinomina';

  @override
  String tagsInUse(String name, int count) {
    return '\"$name\" è usato in $count piatti: rimuovilo prima da quei piatti.';
  }

  @override
  String get tagsEmptyHint =>
      'Nessuna portata. Esempi: Primo, Secondo, Contorno.';

  @override
  String get ingredientFormNewTitle => 'Nuovo ingrediente';

  @override
  String get ingredientFormEditTitle => 'Modifica ingrediente';

  @override
  String get ingredientFormUnitLabel => 'Unità di misura';

  @override
  String get ingredientFormUnitLocked =>
      'Bloccata: l\'ingrediente è già usato in un piatto';

  @override
  String get ingredientFormQb => 'Quanto basta';

  @override
  String get ingredientFormQbSubtitle => 'Senza quantità, non riscalato';

  @override
  String get ingredientFormDepartment => 'Reparto';

  @override
  String get ingredientFormDepartmentHelper =>
      'Ordina la lista della spesa per reparto';

  @override
  String get ingredientFormDuplicateError =>
      'Errore: esiste già un ingrediente con questo nome?';

  @override
  String get ingredientsAdded => 'Ingrediente aggiunto';

  @override
  String get ingredientsEmptyState =>
      'Nessun ingrediente ancora.\nTocca + per aggiungere il primo.';

  @override
  String ingredientsUsageTitle(String name) {
    return '\"$name\" — dove è usato';
  }

  @override
  String get ingredientsNotUsed => 'Non è usato in nessun piatto.';

  @override
  String ingredientsUsedInCount(String name, int count) {
    return '\"$name\" è usato in $count piatti: rimuovilo prima da quei piatti.';
  }

  @override
  String ingredientsDeleted(String name) {
    return '\"$name\" eliminato.';
  }

  @override
  String get ingredientsNoMergeCandidates =>
      'Nessun ingrediente con la stessa unità da unire.';

  @override
  String ingredientsMergeTitle(String name) {
    return 'Unisci \"$name\" in…';
  }

  @override
  String ingredientsMergeSuccess(String source, String target) {
    return '\"$source\" unito in \"$target\".';
  }

  @override
  String get ingredientsMergeError =>
      'Unione non riuscita: le unità devono coincidere.';

  @override
  String get ingredientsUsage => 'Dove è usato';

  @override
  String get ingredientsMergeDuplicate => 'Unisci doppione';

  @override
  String get pairingTitle => 'Abbina un dispositivo';

  @override
  String get pairingShowCode => 'Mostra codice';

  @override
  String get pairingEnterCode => 'Inserisci codice';

  @override
  String get pairingShowCodeInstructions =>
      'Genera un codice e inquadralo con l\'altro telefono, oppure digitalo a mano.';

  @override
  String pairingExpiresIn(String time) {
    return 'Scade tra $time';
  }

  @override
  String get pairingGenerateError => 'Impossibile generare il codice.';

  @override
  String get pairingGenerate => 'Genera codice';

  @override
  String get pairingGenerateNew => 'Genera nuovo codice';

  @override
  String get pairingEnterCodeInstructions =>
      'Inserisci il codice mostrato sull\'altro telefono.';

  @override
  String get pairingSuccess =>
      'Dispositivo abbinato. Sincronizzazione in corso…';

  @override
  String get pairingError => 'Abbinamento non riuscito.';

  @override
  String get pairingJoin => 'Unisciti';

  @override
  String get syncTitle => 'Sincronizzazione';

  @override
  String get syncUnavailable => 'Sincronizzazione non disponibile.';

  @override
  String get syncConnected => 'Connesso';

  @override
  String get syncConnecting => 'Connessione in corso…';

  @override
  String get syncOffline => 'Offline';

  @override
  String get syncNever => 'Mai';

  @override
  String get syncSyncedOnce => 'Dati sincronizzati almeno una volta';

  @override
  String get syncWaitingFirst => 'In attesa della prima sincronizzazione';

  @override
  String get syncLastSync => 'Ultima sincronizzazione';

  @override
  String get syncDownload => 'Download';

  @override
  String get syncUpload => 'Upload';

  @override
  String get syncInProgress => 'In corso…';

  @override
  String get syncIdle => 'Inattivo';

  @override
  String get syncLastError => 'Ultimo errore';

  @override
  String get syncOfflineNote =>
      'L\'app funziona anche offline: le modifiche restano sul dispositivo e si sincronizzano appena torna la rete.';

  @override
  String get deleteDishTitle => 'Eliminare il piatto?';

  @override
  String deleteDishWithPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cene pianificate',
      one: '1 cena pianificata',
    );
    return 'Questo piatto è usato in $_temp0: eliminandolo verrà rimosso anche da quelle. Eliminare comunque?';
  }

  @override
  String get deleteDishNoPlan =>
      'Il piatto verrà rimosso dal catalogo. Eliminare?';

  @override
  String get unitGrammi => 'Grammi (g)';

  @override
  String get unitChilogrammi => 'Chilogrammi (kg)';

  @override
  String get unitMillilitri => 'Millilitri (ml)';

  @override
  String get unitLitri => 'Litri (l)';

  @override
  String get unitPezzo => 'Pezzo (pz)';

  @override
  String get difficultyFacile => 'Facile';

  @override
  String get difficultyMedio => 'Medio';

  @override
  String get difficultyDifficile => 'Difficile';

  @override
  String get timeVeloce => 'Veloce';

  @override
  String get timeMedio => 'Medio';

  @override
  String get timeLento => 'Lento';

  @override
  String get departmentOrtofrutta => 'Ortofrutta';

  @override
  String get departmentMacelleria => 'Macelleria';

  @override
  String get departmentPescheria => 'Pescheria';

  @override
  String get departmentSalumi => 'Salumi e formaggi';

  @override
  String get departmentLatticini => 'Latticini e uova';

  @override
  String get departmentPaneForno => 'Pane e forno';

  @override
  String get departmentDispensa => 'Dispensa';

  @override
  String get departmentSurgelati => 'Surgelati';

  @override
  String get departmentBevande => 'Bevande';

  @override
  String get departmentCasaCura => 'Cura della casa';

  @override
  String get departmentPersonaCura => 'Cura della persona';

  @override
  String get departmentAltro => 'Altro';

  @override
  String get departmentUnassigned => 'Senza reparto';

  @override
  String get ingredientsSearchHint => 'Cerca un ingrediente';

  @override
  String get ingredientsNoResults => 'Nessun ingrediente trovato.';

  @override
  String ingredientsResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredienti',
      one: '1 ingrediente',
    );
    return '$_temp0';
  }

  @override
  String get ingredientsFilterTitle => 'Filtri';

  @override
  String get ingredientsFilterDepartment => 'Reparto';

  @override
  String get ingredientsFilterUnit => 'Unità';

  @override
  String get ingredientsFilterQb => 'Quanto basta';

  @override
  String get ingredientsFilterQbYes => 'Solo q.b.';

  @override
  String get ingredientsFilterQbNo => 'Solo con quantità';

  @override
  String get ingredientsFilterUsage => 'Utilizzo';

  @override
  String get ingredientsFilterUsed => 'Usati in almeno un piatto';

  @override
  String get ingredientsFilterUnused => 'Non usati';

  @override
  String get ingredientsFilterReset => 'Azzera filtri';

  @override
  String get ingredientsSortName => 'Nome';

  @override
  String get ingredientsSortDepartment => 'Reparto';

  @override
  String get ingredientsSortUsage => 'Utilizzi';

  @override
  String get ingredientsSortAsc => 'A → Z';

  @override
  String get ingredientsSortDesc => 'Z → A';

  @override
  String get ingredientsViewGrouped => 'Per reparto';

  @override
  String get ingredientsViewFlat => 'Lista piatta';

  @override
  String ingredientsUsageCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count piatti',
      one: '1 piatto',
      zero: 'non usato',
    );
    return '$_temp0';
  }
}
