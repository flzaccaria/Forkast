import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_da.dart';
import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('da'),
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @navDishes.
  ///
  /// In it, this message translates to:
  /// **'Piatti'**
  String get navDishes;

  /// No description provided for @navPlan.
  ///
  /// In it, this message translates to:
  /// **'Piano'**
  String get navPlan;

  /// No description provided for @navList.
  ///
  /// In it, this message translates to:
  /// **'Lista'**
  String get navList;

  /// No description provided for @navIngredients.
  ///
  /// In it, this message translates to:
  /// **'Ingredienti'**
  String get navIngredients;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'Annulla'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'Salva'**
  String get save;

  /// No description provided for @add.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In it, this message translates to:
  /// **'Chiudi'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get confirm;

  /// No description provided for @name.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @required.
  ///
  /// In it, this message translates to:
  /// **'Obbligatorio'**
  String get required;

  /// No description provided for @edit.
  ///
  /// In it, this message translates to:
  /// **'Modifica'**
  String get edit;

  /// No description provided for @qb.
  ///
  /// In it, this message translates to:
  /// **'q.b.'**
  String get qb;

  /// No description provided for @quantoBasta.
  ///
  /// In it, this message translates to:
  /// **'quanto basta'**
  String get quantoBasta;

  /// No description provided for @bootstrapMissingConfig.
  ///
  /// In it, this message translates to:
  /// **'Configurazione mancante. Lancia con --dart-define per SUPABASE_URL, SUPABASE_ANON_KEY e POWERSYNC_URL.'**
  String get bootstrapMissingConfig;

  /// No description provided for @bootstrapError.
  ///
  /// In it, this message translates to:
  /// **'Errore di avvio'**
  String get bootstrapError;

  /// No description provided for @settingsTitle.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get settingsTitle;

  /// No description provided for @settingsPlanning.
  ///
  /// In it, this message translates to:
  /// **'Pianificazione'**
  String get settingsPlanning;

  /// No description provided for @settingsDefaultGuests.
  ///
  /// In it, this message translates to:
  /// **'Commensali predefiniti'**
  String get settingsDefaultGuests;

  /// No description provided for @settingsDefaultGuestsSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Valore iniziale di ogni nuova serata'**
  String get settingsDefaultGuestsSubtitle;

  /// No description provided for @settingsWeekStart.
  ///
  /// In it, this message translates to:
  /// **'Inizio settimana'**
  String get settingsWeekStart;

  /// No description provided for @settingsCatalogs.
  ///
  /// In it, this message translates to:
  /// **'Cataloghi'**
  String get settingsCatalogs;

  /// No description provided for @settingsCoursesVocabulary.
  ///
  /// In it, this message translates to:
  /// **'Vocabolario portate'**
  String get settingsCoursesVocabulary;

  /// No description provided for @settingsDevices.
  ///
  /// In it, this message translates to:
  /// **'Dispositivi'**
  String get settingsDevices;

  /// No description provided for @settingsPairDevice.
  ///
  /// In it, this message translates to:
  /// **'Abbina un dispositivo'**
  String get settingsPairDevice;

  /// No description provided for @settingsPairDeviceSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Condividi i dati con un secondo telefono'**
  String get settingsPairDeviceSubtitle;

  /// No description provided for @settingsSync.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione'**
  String get settingsSync;

  /// No description provided for @settingsSyncSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Stato della sincronizzazione tra dispositivi'**
  String get settingsSyncSubtitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Lingua dell\'interfaccia'**
  String get settingsLanguageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @languageIt.
  ///
  /// In it, this message translates to:
  /// **'Italiano'**
  String get languageIt;

  /// No description provided for @languageEn.
  ///
  /// In it, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageDa.
  ///
  /// In it, this message translates to:
  /// **'Dansk'**
  String get languageDa;

  /// No description provided for @dishesSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca un piatto'**
  String get dishesSearchHint;

  /// No description provided for @dishesEmptyState.
  ///
  /// In it, this message translates to:
  /// **'Nessun piatto ancora.\nTocca + per creare il primo.'**
  String get dishesEmptyState;

  /// No description provided for @dishesNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun piatto trovato.'**
  String get dishesNoResults;

  /// No description provided for @filterAll.
  ///
  /// In it, this message translates to:
  /// **'Tutti'**
  String get filterAll;

  /// No description provided for @dishEditorNewTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo piatto'**
  String get dishEditorNewTitle;

  /// No description provided for @dishEditorEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica piatto'**
  String get dishEditorEditTitle;

  /// No description provided for @dishEditorNameLabel.
  ///
  /// In it, this message translates to:
  /// **'Nome del piatto'**
  String get dishEditorNameLabel;

  /// No description provided for @dishEditorNameRequired.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il nome del piatto'**
  String get dishEditorNameRequired;

  /// No description provided for @dishEditorInvalidQty.
  ///
  /// In it, this message translates to:
  /// **'Quantità non valida per {name}'**
  String dishEditorInvalidQty(String name);

  /// No description provided for @dishEditorSaveError.
  ///
  /// In it, this message translates to:
  /// **'Errore nel salvataggio del piatto'**
  String get dishEditorSaveError;

  /// No description provided for @dishEditorDeleteError.
  ///
  /// In it, this message translates to:
  /// **'Errore nell\'eliminazione del piatto'**
  String get dishEditorDeleteError;

  /// No description provided for @dishEditorDifficulty.
  ///
  /// In it, this message translates to:
  /// **'Difficoltà'**
  String get dishEditorDifficulty;

  /// No description provided for @dishEditorTime.
  ///
  /// In it, this message translates to:
  /// **'Tempo'**
  String get dishEditorTime;

  /// No description provided for @dishEditorIngredients.
  ///
  /// In it, this message translates to:
  /// **'Ingredienti'**
  String get dishEditorIngredients;

  /// No description provided for @dishEditorQuantitiesNote.
  ///
  /// In it, this message translates to:
  /// **'Le quantità sono per 4 persone'**
  String get dishEditorQuantitiesNote;

  /// No description provided for @dishEditorNoIngredients.
  ///
  /// In it, this message translates to:
  /// **'Nessun ingrediente aggiunto.'**
  String get dishEditorNoIngredients;

  /// No description provided for @dishEditorCourse.
  ///
  /// In it, this message translates to:
  /// **'Portata'**
  String get dishEditorCourse;

  /// No description provided for @dishEditorNoCoursesDefined.
  ///
  /// In it, this message translates to:
  /// **'Nessuna portata definita. Aggiungile in Impostazioni → Vocabolario portate.'**
  String get dishEditorNoCoursesDefined;

  /// No description provided for @dishEditorCreateIngredient.
  ///
  /// In it, this message translates to:
  /// **'Crea nuovo ingrediente'**
  String get dishEditorCreateIngredient;

  /// No description provided for @dishEditorCatalogEmpty.
  ///
  /// In it, this message translates to:
  /// **'Il catalogo è vuoto. Crea il primo ingrediente.'**
  String get dishEditorCatalogEmpty;

  /// No description provided for @planPrevWeekEmpty.
  ///
  /// In it, this message translates to:
  /// **'La settimana precedente è vuota.'**
  String get planPrevWeekEmpty;

  /// No description provided for @planWeekNotEmpty.
  ///
  /// In it, this message translates to:
  /// **'Questa settimana non è vuota'**
  String get planWeekNotEmpty;

  /// No description provided for @planWeekNotEmptyMessage.
  ///
  /// In it, this message translates to:
  /// **'Vuoi sostituire i piatti esistenti o aggiungere quelli della settimana precedente?'**
  String get planWeekNotEmptyMessage;

  /// No description provided for @planMerge.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get planMerge;

  /// No description provided for @planReplace.
  ///
  /// In it, this message translates to:
  /// **'Sostituisci'**
  String get planReplace;

  /// No description provided for @planWeekCopied.
  ///
  /// In it, this message translates to:
  /// **'Settimana copiata.'**
  String get planWeekCopied;

  /// No description provided for @planCopyPrevWeek.
  ///
  /// In it, this message translates to:
  /// **'Copia settimana precedente'**
  String get planCopyPrevWeek;

  /// No description provided for @planNoDishes.
  ///
  /// In it, this message translates to:
  /// **'Nessun piatto'**
  String get planNoDishes;

  /// No description provided for @planGuests.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 commensale} other{{count} commensali}}'**
  String planGuests(int count);

  /// No description provided for @planWeekLabel.
  ///
  /// In it, this message translates to:
  /// **'Settimana {week} · {year}'**
  String planWeekLabel(int week, int year);

  /// No description provided for @planToday.
  ///
  /// In it, this message translates to:
  /// **'Oggi'**
  String get planToday;

  /// No description provided for @dayGuests.
  ///
  /// In it, this message translates to:
  /// **'Commensali'**
  String get dayGuests;

  /// No description provided for @dayAddDish.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi piatto'**
  String get dayAddDish;

  /// No description provided for @dayEmptyState.
  ///
  /// In it, this message translates to:
  /// **'Nessun piatto per questa cena.\nTocca \"Aggiungi piatto\" per iniziare.'**
  String get dayEmptyState;

  /// No description provided for @pickerTitle.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi piatti'**
  String get pickerTitle;

  /// No description provided for @pickerAddCount.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi ({count})'**
  String pickerAddCount(int count);

  /// No description provided for @pickerEmptyCatalog.
  ///
  /// In it, this message translates to:
  /// **'Nessun piatto nel catalogo.'**
  String get pickerEmptyCatalog;

  /// No description provided for @pickerAlreadyInDinner.
  ///
  /// In it, this message translates to:
  /// **'Già in questa cena'**
  String get pickerAlreadyInDinner;

  /// No description provided for @listEmpty.
  ///
  /// In it, this message translates to:
  /// **'Ancora niente in lista.\nPianifica qualche cena e ci penso io.'**
  String get listEmpty;

  /// No description provided for @listGeneratedEmpty.
  ///
  /// In it, this message translates to:
  /// **'Lo strato generato è vuoto: il piano di questa settimana non ha piatti con ingredienti.'**
  String get listGeneratedEmpty;

  /// No description provided for @listModified.
  ///
  /// In it, this message translates to:
  /// **'modificato'**
  String get listModified;

  /// No description provided for @listRemoved.
  ///
  /// In it, this message translates to:
  /// **'rimosso'**
  String get listRemoved;

  /// No description provided for @listManualAdds.
  ///
  /// In it, this message translates to:
  /// **'AGGIUNTE MANUALI'**
  String get listManualAdds;

  /// No description provided for @listManualBadge.
  ///
  /// In it, this message translates to:
  /// **'manuale'**
  String get listManualBadge;

  /// No description provided for @listEditQty.
  ///
  /// In it, this message translates to:
  /// **'Modifica quantità'**
  String get listEditQty;

  /// No description provided for @listRemoveFromList.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi dalla lista'**
  String get listRemoveFromList;

  /// No description provided for @listRestoreCalculated.
  ///
  /// In it, this message translates to:
  /// **'Ripristina valore calcolato'**
  String get listRestoreCalculated;

  /// No description provided for @listQtyDialogTitle.
  ///
  /// In it, this message translates to:
  /// **'Quantità — {name}'**
  String listQtyDialogTitle(String name);

  /// No description provided for @listManualTitle.
  ///
  /// In it, this message translates to:
  /// **'Voce manuale'**
  String get listManualTitle;

  /// No description provided for @listQtyLabel.
  ///
  /// In it, this message translates to:
  /// **'Quantità (opzionale)'**
  String get listQtyLabel;

  /// No description provided for @listUnitLabel.
  ///
  /// In it, this message translates to:
  /// **'Unità (opz.)'**
  String get listUnitLabel;

  /// No description provided for @listManualAdd.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get listManualAdd;

  /// No description provided for @tagsTitle.
  ///
  /// In it, this message translates to:
  /// **'Vocabolario portate'**
  String get tagsTitle;

  /// No description provided for @tagsCourses.
  ///
  /// In it, this message translates to:
  /// **'Portate'**
  String get tagsCourses;

  /// No description provided for @tagsNewCourse.
  ///
  /// In it, this message translates to:
  /// **'Nuova portata'**
  String get tagsNewCourse;

  /// No description provided for @tagsRename.
  ///
  /// In it, this message translates to:
  /// **'Rinomina'**
  String get tagsRename;

  /// No description provided for @tagsInUse.
  ///
  /// In it, this message translates to:
  /// **'\"{name}\" è usato in {count} piatti: rimuovilo prima da quei piatti.'**
  String tagsInUse(String name, int count);

  /// No description provided for @tagsEmptyHint.
  ///
  /// In it, this message translates to:
  /// **'Nessuna portata. Esempi: Primo, Secondo, Contorno.'**
  String get tagsEmptyHint;

  /// No description provided for @ingredientFormNewTitle.
  ///
  /// In it, this message translates to:
  /// **'Nuovo ingrediente'**
  String get ingredientFormNewTitle;

  /// No description provided for @ingredientFormEditTitle.
  ///
  /// In it, this message translates to:
  /// **'Modifica ingrediente'**
  String get ingredientFormEditTitle;

  /// No description provided for @ingredientFormUnitLabel.
  ///
  /// In it, this message translates to:
  /// **'Unità di misura'**
  String get ingredientFormUnitLabel;

  /// No description provided for @ingredientFormUnitLocked.
  ///
  /// In it, this message translates to:
  /// **'Bloccata: l\'ingrediente è già usato in un piatto'**
  String get ingredientFormUnitLocked;

  /// No description provided for @ingredientFormQb.
  ///
  /// In it, this message translates to:
  /// **'Quanto basta'**
  String get ingredientFormQb;

  /// No description provided for @ingredientFormQbSubtitle.
  ///
  /// In it, this message translates to:
  /// **'Senza quantità, non riscalato'**
  String get ingredientFormQbSubtitle;

  /// No description provided for @ingredientFormDepartment.
  ///
  /// In it, this message translates to:
  /// **'Reparto'**
  String get ingredientFormDepartment;

  /// No description provided for @ingredientFormDepartmentHelper.
  ///
  /// In it, this message translates to:
  /// **'Ordina la lista della spesa per reparto'**
  String get ingredientFormDepartmentHelper;

  /// No description provided for @ingredientFormDuplicateError.
  ///
  /// In it, this message translates to:
  /// **'Errore: esiste già un ingrediente con questo nome?'**
  String get ingredientFormDuplicateError;

  /// No description provided for @ingredientsAdded.
  ///
  /// In it, this message translates to:
  /// **'Ingrediente aggiunto'**
  String get ingredientsAdded;

  /// No description provided for @ingredientsEmptyState.
  ///
  /// In it, this message translates to:
  /// **'Nessun ingrediente ancora.\nTocca + per aggiungere il primo.'**
  String get ingredientsEmptyState;

  /// No description provided for @ingredientsUsageTitle.
  ///
  /// In it, this message translates to:
  /// **'\"{name}\" — dove è usato'**
  String ingredientsUsageTitle(String name);

  /// No description provided for @ingredientsNotUsed.
  ///
  /// In it, this message translates to:
  /// **'Non è usato in nessun piatto.'**
  String get ingredientsNotUsed;

  /// No description provided for @ingredientsUsedInCount.
  ///
  /// In it, this message translates to:
  /// **'\"{name}\" è usato in {count} piatti: rimuovilo prima da quei piatti.'**
  String ingredientsUsedInCount(String name, int count);

  /// No description provided for @ingredientsDeleted.
  ///
  /// In it, this message translates to:
  /// **'\"{name}\" eliminato.'**
  String ingredientsDeleted(String name);

  /// No description provided for @ingredientsNoMergeCandidates.
  ///
  /// In it, this message translates to:
  /// **'Nessun ingrediente con la stessa unità da unire.'**
  String get ingredientsNoMergeCandidates;

  /// No description provided for @ingredientsMergeTitle.
  ///
  /// In it, this message translates to:
  /// **'Unisci \"{name}\" in…'**
  String ingredientsMergeTitle(String name);

  /// No description provided for @ingredientsMergeSuccess.
  ///
  /// In it, this message translates to:
  /// **'\"{source}\" unito in \"{target}\".'**
  String ingredientsMergeSuccess(String source, String target);

  /// No description provided for @ingredientsMergeError.
  ///
  /// In it, this message translates to:
  /// **'Unione non riuscita: le unità devono coincidere.'**
  String get ingredientsMergeError;

  /// No description provided for @ingredientsUsage.
  ///
  /// In it, this message translates to:
  /// **'Dove è usato'**
  String get ingredientsUsage;

  /// No description provided for @ingredientsMergeDuplicate.
  ///
  /// In it, this message translates to:
  /// **'Unisci doppione'**
  String get ingredientsMergeDuplicate;

  /// No description provided for @pairingTitle.
  ///
  /// In it, this message translates to:
  /// **'Abbina un dispositivo'**
  String get pairingTitle;

  /// No description provided for @pairingShowCode.
  ///
  /// In it, this message translates to:
  /// **'Mostra codice'**
  String get pairingShowCode;

  /// No description provided for @pairingEnterCode.
  ///
  /// In it, this message translates to:
  /// **'Inserisci codice'**
  String get pairingEnterCode;

  /// No description provided for @pairingShowCodeInstructions.
  ///
  /// In it, this message translates to:
  /// **'Genera un codice e inquadralo con l\'altro telefono, oppure digitalo a mano.'**
  String get pairingShowCodeInstructions;

  /// No description provided for @pairingExpiresIn.
  ///
  /// In it, this message translates to:
  /// **'Scade tra {time}'**
  String pairingExpiresIn(String time);

  /// No description provided for @pairingGenerateError.
  ///
  /// In it, this message translates to:
  /// **'Impossibile generare il codice.'**
  String get pairingGenerateError;

  /// No description provided for @pairingGenerate.
  ///
  /// In it, this message translates to:
  /// **'Genera codice'**
  String get pairingGenerate;

  /// No description provided for @pairingGenerateNew.
  ///
  /// In it, this message translates to:
  /// **'Genera nuovo codice'**
  String get pairingGenerateNew;

  /// No description provided for @pairingEnterCodeInstructions.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il codice mostrato sull\'altro telefono.'**
  String get pairingEnterCodeInstructions;

  /// No description provided for @pairingSuccess.
  ///
  /// In it, this message translates to:
  /// **'Dispositivo abbinato. Sincronizzazione in corso…'**
  String get pairingSuccess;

  /// No description provided for @pairingError.
  ///
  /// In it, this message translates to:
  /// **'Abbinamento non riuscito.'**
  String get pairingError;

  /// No description provided for @pairingJoin.
  ///
  /// In it, this message translates to:
  /// **'Unisciti'**
  String get pairingJoin;

  /// No description provided for @syncTitle.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione'**
  String get syncTitle;

  /// No description provided for @syncUnavailable.
  ///
  /// In it, this message translates to:
  /// **'Sincronizzazione non disponibile.'**
  String get syncUnavailable;

  /// No description provided for @syncConnected.
  ///
  /// In it, this message translates to:
  /// **'Connesso'**
  String get syncConnected;

  /// No description provided for @syncConnecting.
  ///
  /// In it, this message translates to:
  /// **'Connessione in corso…'**
  String get syncConnecting;

  /// No description provided for @syncOffline.
  ///
  /// In it, this message translates to:
  /// **'Offline'**
  String get syncOffline;

  /// No description provided for @syncNever.
  ///
  /// In it, this message translates to:
  /// **'Mai'**
  String get syncNever;

  /// No description provided for @syncSyncedOnce.
  ///
  /// In it, this message translates to:
  /// **'Dati sincronizzati almeno una volta'**
  String get syncSyncedOnce;

  /// No description provided for @syncWaitingFirst.
  ///
  /// In it, this message translates to:
  /// **'In attesa della prima sincronizzazione'**
  String get syncWaitingFirst;

  /// No description provided for @syncLastSync.
  ///
  /// In it, this message translates to:
  /// **'Ultima sincronizzazione'**
  String get syncLastSync;

  /// No description provided for @syncDownload.
  ///
  /// In it, this message translates to:
  /// **'Download'**
  String get syncDownload;

  /// No description provided for @syncUpload.
  ///
  /// In it, this message translates to:
  /// **'Upload'**
  String get syncUpload;

  /// No description provided for @syncInProgress.
  ///
  /// In it, this message translates to:
  /// **'In corso…'**
  String get syncInProgress;

  /// No description provided for @syncIdle.
  ///
  /// In it, this message translates to:
  /// **'Inattivo'**
  String get syncIdle;

  /// No description provided for @syncLastError.
  ///
  /// In it, this message translates to:
  /// **'Ultimo errore'**
  String get syncLastError;

  /// No description provided for @syncOfflineNote.
  ///
  /// In it, this message translates to:
  /// **'L\'app funziona anche offline: le modifiche restano sul dispositivo e si sincronizzano appena torna la rete.'**
  String get syncOfflineNote;

  /// No description provided for @deleteDishTitle.
  ///
  /// In it, this message translates to:
  /// **'Eliminare il piatto?'**
  String get deleteDishTitle;

  /// No description provided for @deleteDishWithPlans.
  ///
  /// In it, this message translates to:
  /// **'Questo piatto è usato in {count, plural, =1{1 cena pianificata} other{{count} cene pianificate}}: eliminandolo verrà rimosso anche da quelle. Eliminare comunque?'**
  String deleteDishWithPlans(int count);

  /// No description provided for @deleteDishNoPlan.
  ///
  /// In it, this message translates to:
  /// **'Il piatto verrà rimosso dal catalogo. Eliminare?'**
  String get deleteDishNoPlan;

  /// No description provided for @unitGrammi.
  ///
  /// In it, this message translates to:
  /// **'Grammi (g)'**
  String get unitGrammi;

  /// No description provided for @unitChilogrammi.
  ///
  /// In it, this message translates to:
  /// **'Chilogrammi (kg)'**
  String get unitChilogrammi;

  /// No description provided for @unitMillilitri.
  ///
  /// In it, this message translates to:
  /// **'Millilitri (ml)'**
  String get unitMillilitri;

  /// No description provided for @unitLitri.
  ///
  /// In it, this message translates to:
  /// **'Litri (l)'**
  String get unitLitri;

  /// No description provided for @unitPezzo.
  ///
  /// In it, this message translates to:
  /// **'Pezzo (pz)'**
  String get unitPezzo;

  /// No description provided for @difficultyFacile.
  ///
  /// In it, this message translates to:
  /// **'Facile'**
  String get difficultyFacile;

  /// No description provided for @difficultyMedio.
  ///
  /// In it, this message translates to:
  /// **'Medio'**
  String get difficultyMedio;

  /// No description provided for @difficultyDifficile.
  ///
  /// In it, this message translates to:
  /// **'Difficile'**
  String get difficultyDifficile;

  /// No description provided for @timeVeloce.
  ///
  /// In it, this message translates to:
  /// **'Veloce'**
  String get timeVeloce;

  /// No description provided for @timeMedio.
  ///
  /// In it, this message translates to:
  /// **'Medio'**
  String get timeMedio;

  /// No description provided for @timeLento.
  ///
  /// In it, this message translates to:
  /// **'Lento'**
  String get timeLento;

  /// No description provided for @departmentOrtofrutta.
  ///
  /// In it, this message translates to:
  /// **'Ortofrutta'**
  String get departmentOrtofrutta;

  /// No description provided for @departmentMacelleria.
  ///
  /// In it, this message translates to:
  /// **'Macelleria'**
  String get departmentMacelleria;

  /// No description provided for @departmentPescheria.
  ///
  /// In it, this message translates to:
  /// **'Pescheria'**
  String get departmentPescheria;

  /// No description provided for @departmentSalumi.
  ///
  /// In it, this message translates to:
  /// **'Salumi e formaggi'**
  String get departmentSalumi;

  /// No description provided for @departmentLatticini.
  ///
  /// In it, this message translates to:
  /// **'Latticini e uova'**
  String get departmentLatticini;

  /// No description provided for @departmentPaneForno.
  ///
  /// In it, this message translates to:
  /// **'Pane e forno'**
  String get departmentPaneForno;

  /// No description provided for @departmentDispensa.
  ///
  /// In it, this message translates to:
  /// **'Dispensa'**
  String get departmentDispensa;

  /// No description provided for @departmentSurgelati.
  ///
  /// In it, this message translates to:
  /// **'Surgelati'**
  String get departmentSurgelati;

  /// No description provided for @departmentBevande.
  ///
  /// In it, this message translates to:
  /// **'Bevande'**
  String get departmentBevande;

  /// No description provided for @departmentCasaCura.
  ///
  /// In it, this message translates to:
  /// **'Cura della casa'**
  String get departmentCasaCura;

  /// No description provided for @departmentPersonaCura.
  ///
  /// In it, this message translates to:
  /// **'Cura della persona'**
  String get departmentPersonaCura;

  /// No description provided for @departmentAltro.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get departmentAltro;

  /// No description provided for @departmentUnassigned.
  ///
  /// In it, this message translates to:
  /// **'Senza reparto'**
  String get departmentUnassigned;

  /// No description provided for @ingredientsSearchHint.
  ///
  /// In it, this message translates to:
  /// **'Cerca un ingrediente'**
  String get ingredientsSearchHint;

  /// No description provided for @ingredientsNoResults.
  ///
  /// In it, this message translates to:
  /// **'Nessun ingrediente trovato.'**
  String get ingredientsNoResults;

  /// No description provided for @ingredientsResultCount.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =1{1 ingrediente} other{{count} ingredienti}}'**
  String ingredientsResultCount(int count);

  /// No description provided for @ingredientsFilterTitle.
  ///
  /// In it, this message translates to:
  /// **'Filtri'**
  String get ingredientsFilterTitle;

  /// No description provided for @ingredientsFilterDepartment.
  ///
  /// In it, this message translates to:
  /// **'Reparto'**
  String get ingredientsFilterDepartment;

  /// No description provided for @ingredientsFilterUnit.
  ///
  /// In it, this message translates to:
  /// **'Unità'**
  String get ingredientsFilterUnit;

  /// No description provided for @ingredientsFilterQb.
  ///
  /// In it, this message translates to:
  /// **'Quanto basta'**
  String get ingredientsFilterQb;

  /// No description provided for @ingredientsFilterQbYes.
  ///
  /// In it, this message translates to:
  /// **'Solo q.b.'**
  String get ingredientsFilterQbYes;

  /// No description provided for @ingredientsFilterQbNo.
  ///
  /// In it, this message translates to:
  /// **'Solo con quantità'**
  String get ingredientsFilterQbNo;

  /// No description provided for @ingredientsFilterUsage.
  ///
  /// In it, this message translates to:
  /// **'Utilizzo'**
  String get ingredientsFilterUsage;

  /// No description provided for @ingredientsFilterUsed.
  ///
  /// In it, this message translates to:
  /// **'Usati in almeno un piatto'**
  String get ingredientsFilterUsed;

  /// No description provided for @ingredientsFilterUnused.
  ///
  /// In it, this message translates to:
  /// **'Non usati'**
  String get ingredientsFilterUnused;

  /// No description provided for @ingredientsFilterReset.
  ///
  /// In it, this message translates to:
  /// **'Azzera filtri'**
  String get ingredientsFilterReset;

  /// No description provided for @ingredientsSortName.
  ///
  /// In it, this message translates to:
  /// **'Nome'**
  String get ingredientsSortName;

  /// No description provided for @ingredientsSortDepartment.
  ///
  /// In it, this message translates to:
  /// **'Reparto'**
  String get ingredientsSortDepartment;

  /// No description provided for @ingredientsSortUsage.
  ///
  /// In it, this message translates to:
  /// **'Utilizzi'**
  String get ingredientsSortUsage;

  /// No description provided for @ingredientsSortAsc.
  ///
  /// In it, this message translates to:
  /// **'A → Z'**
  String get ingredientsSortAsc;

  /// No description provided for @ingredientsSortDesc.
  ///
  /// In it, this message translates to:
  /// **'Z → A'**
  String get ingredientsSortDesc;

  /// No description provided for @ingredientsViewGrouped.
  ///
  /// In it, this message translates to:
  /// **'Per reparto'**
  String get ingredientsViewGrouped;

  /// No description provided for @ingredientsViewFlat.
  ///
  /// In it, this message translates to:
  /// **'Lista piatta'**
  String get ingredientsViewFlat;

  /// No description provided for @ingredientsUsageCountLabel.
  ///
  /// In it, this message translates to:
  /// **'{count, plural, =0{non usato} =1{1 piatto} other{{count} piatti}}'**
  String ingredientsUsageCountLabel(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['da', 'en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'da':
      return AppLocalizationsDa();
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
