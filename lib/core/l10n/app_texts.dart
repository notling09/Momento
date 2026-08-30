import 'package:flutter/widgets.dart';

import 'texts_de.dart';
import 'texts_en.dart';

/// Alle sichtbaren Texte der App an einem Ort.
///
/// Bewusst als abstrakte Klasse mit Gettern umgesetzt statt als Map: so meldet
/// der Compiler sofort, wenn eine Uebersetzung fehlt.
abstract class AppTexts {
  const AppTexts();

  static const supportedLocales = <Locale>[Locale('de'), Locale('en')];

  static AppTexts of(BuildContext context) =>
      Localizations.of<AppTexts>(context, AppTexts) ?? const TextsDe();

  static AppTexts forLocale(Locale locale) =>
      locale.languageCode == 'en' ? const TextsEn() : const TextsDe();

  String get localeName;
  String get languageLabel;

  // --- Marke --------------------------------------------------------------
  String get appName;
  String get vision;
  String get tagline;

  // --- Allgemein ----------------------------------------------------------
  String get actionContinue;
  String get actionBack;
  String get actionSave;
  String get actionCancel;
  String get actionDelete;
  String get actionEdit;
  String get actionClose;
  String get actionRetry;
  String get actionSkip;
  String get actionShowAll;
  String get actionGotIt;
  String get yes;
  String get no;
  String get loading;
  String get today;
  String get yesterday;

  // --- Willkommen / Auth --------------------------------------------------
  String get welcomeTitle;
  String get welcomeSubtitle;
  String get signIn;
  String get signUp;
  String get signOut;
  String get signOutConfirm;
  String get email;
  String get password;
  String get passwordRepeat;
  String get displayName;
  String get displayNameHint;
  String get createAccount;
  String get noAccountYet;
  String get alreadyHaveAccount;
  String get privacyNote;
  String get errorEmailInvalid;
  String get errorPasswordShort;
  String get errorPasswordsDiffer;
  String get errorNameRequired;
  String get errorEmailTaken;
  String get errorWrongCredentials;
  String get greetingBack;

  // --- Onboarding ---------------------------------------------------------
  String get onboarding1Title;
  String get onboarding1Body;
  String get onboarding2Title;
  String get onboarding2Body;
  String get onboarding3Title;
  String get onboarding3Body;
  String get onboarding4Title;
  String get onboarding4Body;
  String get onboardingStart;

  // --- Navigation ---------------------------------------------------------
  String get navMemories;
  String get navSync;
  String get navSearch;
  String get navHome;

  // --- Startseite ---------------------------------------------------------
  String get homeWelcome;
  String get homeWelcomeSub;
  String get flashbackSection;
  String flashbackYearsAgo(int years);
  String get flashbackNoneTitle;
  String get flashbackNoneBody;
  String get albumsSection;
  String get albumsSectionSub;
  String get albumsEmptyCardTitle;
  String get createAlbum;
  String get onThisDay;
  String get recentSection;
  String get recentSectionSub;
  String get statsMemories;
  String get statsAlbums;
  String get statsScents;
  String get statsSounds;

  // --- Erinnerungen -------------------------------------------------------
  String get memories;
  String get memory;
  String get newMemory;
  String get editMemory;
  String get memoryTitle;
  String get memoryTitleHint;
  String get memoryStory;
  String get memoryStoryHint;
  String get memoryPlace;
  String get memoryPlaceHint;
  String get memoryDate;
  String get memoryFeeling;
  String get memoryPeople;
  String get memoryPeopleHint;
  String get memoryPhoto;
  String get memorySceneLabel;
  String get memoryPhotoAdd;
  String get memoryPhotoChange;
  String get memoryPhotoRemove;
  String get memoryFromCamera;
  String get memoryFromGallery;
  String get memoryScent;
  String get memoryScentHint;
  String get memoryScentIntensity;
  String get memorySound;
  String get memorySoundRecord;
  String get memorySoundStop;
  String get memorySoundPlay;
  String get memorySoundPause;
  String get memorySoundDelete;
  String get memorySoundLabel;
  String get memorySoundLabelHint;
  String get memorySoundPermission;
  String get memorySoundFailed;
  String get memoryCapturedOn;
  String get memoryFavorite;
  String get memoryDeleteConfirm;
  String get memorySaved;
  String get memoryDeleted;
  String get memoriesEmptyTitle;
  String get memoriesEmptyBody;
  String get errorTitleRequired;
  String get filterAll;
  String get filterFavorites;
  String get filterWithScent;
  String get filterWithSound;
  String memoryCount(int count);

  // --- Gefuehle -----------------------------------------------------------
  String get feelingJoy;
  String get feelingNostalgia;
  String get feelingLove;
  String get feelingCalm;
  String get feelingExcitement;
  String get feelingGratitude;
  String get feelingWistful;
  String get feelingProud;

  // --- Duefte -------------------------------------------------------------
  String get scentPickerTitle;
  String get scentPickerSub;
  String get scentCustom;
  String get scentCustomHint;
  String get scentNone;
  String get scentSeaBreeze;
  String get scentSunscreen;
  String get scentRainOnAsphalt;
  String get scentFreshBread;
  String get scentPineForest;
  String get scentCampfire;
  String get scentCoffee;
  String get scentFreshLaundry;
  String get scentCutGrass;
  String get scentVanilla;
  String get scentCinnamon;
  String get scentOldBooks;
  String get scentGrandmasHome;
  String get scentSnowAir;
  String get scentFlowerMeadow;
  String get scentCitrus;
  String get intensityLight;
  String get intensityClear;
  String get intensityIntense;

  // --- Alben --------------------------------------------------------------
  String get albums;
  String get album;
  String get newAlbum;
  String get editAlbum;
  String get albumName;
  String get albumNameHint;
  String get albumDescription;
  String get albumDescriptionHint;
  String get albumPickMemories;
  String get albumEmptyTitle;
  String get albumEmptyBody;
  String get albumDeleteConfirm;
  String get albumSaved;
  String get errorAlbumNameRequired;
  String get errorAlbumNeedsMemories;
  String albumMemoryCount(int count);

  // --- Suche --------------------------------------------------------------
  String get searchTitle;
  String get searchSubtitle;
  String get searchHint;
  String get searchIdeas;
  String get searchNoResultsTitle;
  String get searchNoResultsBody;
  String get searchStartTitle;
  String get searchStartBody;
  String searchResultCount(int count);
  String get searchWhyMatched;
  String get searchExample1;
  String get searchExample2;
  String get searchExample3;
  String get searchExample4;
  String get matchedTitle;
  String get matchedStory;
  String get matchedScent;
  String get matchedSound;
  String get matchedPlace;
  String get matchedPeople;
  String get matchedFeeling;
  String get matchedSeason;
  String get matchedTime;

  // --- Synchronisieren ----------------------------------------------------
  String get syncTitle;
  String get syncSubtitle;
  String get syncNow;
  String get syncRunning;
  String get syncAllDone;
  String get syncAllDoneBody;
  String syncPending(int count);
  String get syncPendingBody;
  String get syncLastRun;
  String get syncNever;
  String get syncQueueTitle;
  String get syncStatePending;
  String get syncStateSynced;
  String get syncStateFailed;
  String get syncOfflineHint;
  String syncFinished(int count);
  String get syncCloudTitle;
  String get syncCloudBody;

  // --- Profil / Einstellungen --------------------------------------------
  String get menu;
  String get profile;
  String get profileOptionalNote;
  String get profileSaved;
  String get birthday;
  String get birthdayNotSet;
  String get about;
  String get aboutTitle;
  String get settings;
  String get appearance;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get language;
  String get languageGerman;
  String get languageEnglish;
  String get data;
  String get demoDataTitle;
  String get demoDataBody;
  String get demoDataReload;
  String get demoDataRemove;
  String get demoDataRemoved;
  String get demoDataLoaded;
  String get dangerZone;
  String get deleteAllTitle;
  String get deleteAllBody;
  String get deleteAllConfirm;
  String get deleteAllDone;
  String get version;

  // --- Ueber Momento ------------------------------------------------------
  String get aboutIntro;
  String get aboutIdeaLabel;
  String get aboutDevLabel;
  String get aboutSourceLabel;
  String get aboutSourceValue;
  String get aboutThanks;
  String get aboutConceptTitle;
  String get aboutConceptBody;
}

/// Bindet [AppTexts] an Flutters Lokalisierungssystem.
class AppTextsDelegate extends LocalizationsDelegate<AppTexts> {
  const AppTextsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppTexts.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppTexts> load(Locale locale) async => AppTexts.forLocale(locale);

  @override
  bool shouldReload(AppTextsDelegate old) => false;
}
