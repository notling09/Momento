import 'app_texts.dart';

/// Deutsche Texte - die Standardsprache von Momento.
class TextsDe extends AppTexts {
  const TextsDe();

  @override
  String get localeName => 'de';
  @override
  String get languageLabel => 'Deutsch';

  @override
  String get appName => 'Momento';
  @override
  String get vision => 'Dein Leben. Deine Erinnerungen.';
  @override
  String get tagline => 'Deine App für Erinnerungen und besondere Momente';

  @override
  String get actionContinue => 'Weiter';
  @override
  String get actionBack => 'Zurück';
  @override
  String get actionSave => 'Speichern';
  @override
  String get actionCancel => 'Abbrechen';
  @override
  String get actionDelete => 'Löschen';
  @override
  String get actionEdit => 'Bearbeiten';
  @override
  String get actionClose => 'Schliessen';
  @override
  String get actionRetry => 'Nochmals versuchen';
  @override
  String get actionSkip => 'Überspringen';
  @override
  String get actionShowAll => 'Alle anzeigen';
  @override
  String get actionGotIt => 'Alles klar';
  @override
  String get yes => 'Ja';
  @override
  String get no => 'Nein';
  @override
  String get loading => 'Einen Moment …';
  @override
  String get today => 'Heute';
  @override
  String get yesterday => 'Gestern';

  @override
  String get welcomeTitle => 'Schön, dass du da bist!';
  @override
  String get welcomeSubtitle => 'Deine Momente warten auf dich.';
  @override
  String get signIn => 'Anmelden';
  @override
  String get signUp => 'Registrieren';
  @override
  String get signOut => 'Abmelden';
  @override
  String get signOutConfirm => 'Möchtest du dich wirklich abmelden? Deine Erinnerungen bleiben auf diesem Gerät gespeichert.';
  @override
  String get email => 'E-Mail-Adresse';
  @override
  String get password => 'Passwort';
  @override
  String get passwordRepeat => 'Passwort wiederholen';
  @override
  String get displayName => 'Wie dürfen wir dich nennen?';
  @override
  String get displayNameHint => 'Dein Vorname';
  @override
  String get createAccount => 'Konto erstellen';
  @override
  String get noAccountYet => 'Noch kein Konto? Jetzt registrieren';
  @override
  String get alreadyHaveAccount => 'Schon dabei? Hier anmelden';
  @override
  String get privacyNote => 'Alle Erinnerungen bleiben auf deinem Gerät. Wir fragen nur nach E-Mail und Passwort – nicht mehr.';
  @override
  String get errorEmailInvalid => 'Bitte gib eine gültige E-Mail-Adresse ein.';
  @override
  String get errorPasswordShort => 'Das Passwort braucht mindestens 6 Zeichen.';
  @override
  String get errorPasswordsDiffer => 'Die beiden Passwörter stimmen nicht überein.';
  @override
  String get errorNameRequired => 'Bitte gib einen Namen ein.';
  @override
  String get errorEmailTaken => 'Für diese E-Mail gibt es auf diesem Gerät schon ein Konto.';
  @override
  String get errorWrongCredentials => 'E-Mail oder Passwort stimmen nicht.';
  @override
  String get greetingBack => 'Willkommen zurück';

  @override
  String get onboarding1Title => 'Halte fest, was zählt';
  @override
  String get onboarding1Body => 'Ein Bild, ein Ort, ein Gedanke: In Momento wird aus einem Augenblick eine Erinnerung, die bleibt.';
  @override
  String get onboarding2Title => 'Auch Düfte und Geräusche';
  @override
  String get onboarding2Body => 'Nimm das Wellenrauschen wirklich auf und notiere, wonach es geroch. Genau diese Details bringen Momente zurück.';
  @override
  String get onboarding3Title => 'Flashbacks';
  @override
  String get onboarding3Body => 'Momento zeigt dir, was du an diesem Tag vor einem Jahr erlebt hast. Ohne dass du danach suchen musst.';
  @override
  String get onboarding4Title => 'Suchen wie im Kopf';
  @override
  String get onboarding4Body => 'Beschreibe eine Erinnerung einfach so, wie du sie erzählen würdest – die Suche findet sie für dich.';
  @override
  String get onboardingStart => 'Los geht\'s';

  @override
  String get navMemories => 'Erinnerungen';
  @override
  String get navSync => 'Synchronisieren';
  @override
  String get navSearch => 'Suche';
  @override
  String get navHome => 'Start';

  @override
  String get homeWelcome => 'Schön, dass du da bist!';
  @override
  String get homeWelcomeSub => 'Deine Momente warten auf dich.';
  @override
  String get flashbackSection => 'Heute vor 1 Jahr';
  @override
  String flashbackYearsAgo(int years) =>
      years == 1 ? 'Heute vor 1 Jahr' : 'Heute vor $years Jahren';
  @override
  String get flashbackNoneTitle => 'Heute noch keine Flashbacks';
  @override
  String get flashbackNoneBody => 'Sobald deine Erinnerungen ein Jahr alt sind, tauchen sie hier von selbst wieder auf.';
  @override
  String get albumsSection => 'Deine Alben';
  @override
  String get albumsSectionSub => 'Gruppiere Momente, Düfte und Sounds.';
  @override
  String get albumsEmptyCardTitle => 'Erstelle Alben für deine schönsten Momente.';
  @override
  String get createAlbum => 'Neues Album erstellen';
  @override
  String get onThisDay => 'An diesem Tag';
  @override
  String get recentSection => 'Zuletzt festgehalten';
  @override
  String get recentSectionSub => 'Deine neusten Momente.';
  @override
  String get statsMemories => 'Erinnerungen';
  @override
  String get statsAlbums => 'Alben';
  @override
  String get statsScents => 'Düfte';
  @override
  String get statsSounds => 'Sounds';

  @override
  String get memories => 'Erinnerungen';
  @override
  String get memory => 'Erinnerung';
  @override
  String get newMemory => 'Neue Erinnerung';
  @override
  String get editMemory => 'Erinnerung bearbeiten';
  @override
  String get memoryTitle => 'Titel';
  @override
  String get memoryTitleHint => 'Ein perfekter Abend am See';
  @override
  String get memoryStory => 'Was ist passiert?';
  @override
  String get memoryStoryHint => 'Erzähl in ein paar Sätzen, woran du dich erinnern möchtest …';
  @override
  String get memoryPlace => 'Ort';
  @override
  String get memoryPlaceHint => 'z. B. Zürichsee';
  @override
  String get memoryDate => 'Datum und Uhrzeit';
  @override
  String get memoryFeeling => 'Gefühl';
  @override
  String get memoryPeople => 'Mit wem?';
  @override
  String get memoryPeopleHint => 'Namen mit Komma trennen';
  @override
  String get memoryPhoto => 'Bild';
  @override
  String get memorySceneLabel => 'Oder wähle ein Motiv';
  @override
  String get memoryPhotoAdd => 'Bild hinzufügen';
  @override
  String get memoryPhotoChange => 'Bild ersetzen';
  @override
  String get memoryPhotoRemove => 'Bild entfernen';
  @override
  String get memoryFromCamera => 'Kamera';
  @override
  String get memoryFromGallery => 'Galerie';
  @override
  String get memoryScent => 'Duft';
  @override
  String get memoryScentHint => 'Wonach hat dieser Moment gerochen?';
  @override
  String get memoryScentIntensity => 'Intensität';
  @override
  String get memorySound => 'Geräusch';
  @override
  String get memorySoundRecord => 'Aufnahme starten';
  @override
  String get memorySoundStop => 'Aufnahme beenden';
  @override
  String get memorySoundPlay => 'Abspielen';
  @override
  String get memorySoundPause => 'Pause';
  @override
  String get memorySoundDelete => 'Aufnahme löschen';
  @override
  String get memorySoundLabel => 'Beschreibung des Geräuschs';
  @override
  String get memorySoundLabelHint => 'z. B. Wellenrauschen';
  @override
  String get memorySoundPermission => 'Für die Aufnahme braucht Momento Zugriff auf das Mikrofon. Du kannst ihn in den Geräte-Einstellungen erlauben.';
  @override
  String get memorySoundFailed => 'Die Aufnahme hat nicht geklappt. Versuch es nochmals.';
  @override
  String get memoryCapturedOn => 'Erfasst am';
  @override
  String get memoryFavorite => 'Zu den Lieblingsmomenten';
  @override
  String get memoryDeleteConfirm => 'Diese Erinnerung endgültig löschen?';
  @override
  String get memorySaved => 'Erinnerung gespeichert';
  @override
  String get memoryDeleted => 'Erinnerung gelöscht';
  @override
  String get memoriesEmptyTitle => 'Hier ist noch alles leer';
  @override
  String get memoriesEmptyBody => 'Halte deinen ersten Moment fest – ein Bild, ein Duft oder ein Geräusch genügt schon.';
  @override
  String get errorTitleRequired => 'Gib deiner Erinnerung einen Titel.';
  @override
  String get filterAll => 'Alle';
  @override
  String get filterFavorites => 'Lieblinge';
  @override
  String get filterWithScent => 'Mit Duft';
  @override
  String get filterWithSound => 'Mit Sound';
  @override
  String memoryCount(int count) =>
      count == 1 ? '1 Erinnerung' : '$count Erinnerungen';

  @override
  String get feelingJoy => 'Freude';
  @override
  String get feelingNostalgia => 'Nostalgie';
  @override
  String get feelingLove => 'Liebe';
  @override
  String get feelingCalm => 'Ruhe';
  @override
  String get feelingExcitement => 'Aufregung';
  @override
  String get feelingGratitude => 'Dankbarkeit';
  @override
  String get feelingWistful => 'Wehmut';
  @override
  String get feelingProud => 'Stolz';

  @override
  String get scentPickerTitle => 'Wonach hat es gerochen?';
  @override
  String get scentPickerSub => 'Wähle einen Duft oder beschreibe ihn selbst. Düfte lassen sich nicht messen – aber erinnern.';
  @override
  String get scentCustom => 'Eigener Duft';
  @override
  String get scentCustomHint => 'Beschreibe den Duft in eigenen Worten';
  @override
  String get scentNone => 'Kein Duft';
  @override
  String get scentSeaBreeze => 'Seebrise';
  @override
  String get scentSunscreen => 'Sonnencreme';
  @override
  String get scentRainOnAsphalt => 'Regen auf Asphalt';
  @override
  String get scentFreshBread => 'Frisches Brot';
  @override
  String get scentPineForest => 'Tannenwald';
  @override
  String get scentCampfire => 'Lagerfeuer';
  @override
  String get scentCoffee => 'Kaffee';
  @override
  String get scentFreshLaundry => 'Frische Wäsche';
  @override
  String get scentCutGrass => 'Frisch gemähtes Gras';
  @override
  String get scentVanilla => 'Vanille';
  @override
  String get scentCinnamon => 'Zimt';
  @override
  String get scentOldBooks => 'Alte Bücher';
  @override
  String get scentGrandmasHome => 'Grossmutters Wohnung';
  @override
  String get scentSnowAir => 'Schneeluft';
  @override
  String get scentFlowerMeadow => 'Blumenwiese';
  @override
  String get scentCitrus => 'Zitrusfrüchte';
  @override
  String get intensityLight => 'zart';
  @override
  String get intensityClear => 'deutlich';
  @override
  String get intensityIntense => 'intensiv';

  @override
  String get albums => 'Alben';
  @override
  String get album => 'Album';
  @override
  String get newAlbum => 'Neues Album';
  @override
  String get editAlbum => 'Album bearbeiten';
  @override
  String get albumName => 'Name des Albums';
  @override
  String get albumNameHint => 'z. B. Sommer 2025';
  @override
  String get albumDescription => 'Beschreibung';
  @override
  String get albumDescriptionHint => 'Worum geht es in diesem Album?';
  @override
  String get albumPickMemories => 'Erinnerungen auswählen';
  @override
  String get albumEmptyTitle => 'Noch keine Alben';
  @override
  String get albumEmptyBody => 'Fasse zusammen, was zusammengehört: eine Reise, ein Sommer, ein Mensch.';
  @override
  String get albumDeleteConfirm => 'Album löschen? Die Erinnerungen darin bleiben erhalten.';
  @override
  String get albumSaved => 'Album gespeichert';
  @override
  String get errorAlbumNameRequired => 'Gib dem Album einen Namen.';
  @override
  String get errorAlbumNeedsMemories => 'Wähle mindestens eine Erinnerung aus.';
  @override
  String albumMemoryCount(int count) =>
      count == 1 ? '1 Erinnerung' : '$count Erinnerungen';

  @override
  String get searchTitle => 'Suche';
  @override
  String get searchSubtitle => 'Beschreibe die Erinnerung – wir finden sie.';
  @override
  String get searchHint => 'z. B. der Abend am See mit Hund';
  @override
  String get searchIdeas => 'Probier es damit';
  @override
  String get searchNoResultsTitle => 'Nichts gefunden';
  @override
  String get searchNoResultsBody => 'Versuch es mit anderen Worten – ein Ort, ein Gefühl, ein Duft oder ein Name.';
  @override
  String get searchStartTitle => 'Erzähl, woran du denkst';
  @override
  String get searchStartBody => 'Die Suche versteht ganze Sätze und sucht in Titeln, Texten, Orten, Menschen, Düften und Geräuschen.';
  @override
  String searchResultCount(int count) =>
      count == 1 ? '1 Treffer' : '$count Treffer';
  @override
  String get searchWhyMatched => 'Gefunden über';
  @override
  String get searchExample1 => 'Sonnenuntergang am Wasser';
  @override
  String get searchExample2 => 'als es nach Lagerfeuer roch';
  @override
  String get searchExample3 => 'Winter mit der Familie';
  @override
  String get searchExample4 => 'lachen mit Freunden';
  @override
  String get matchedTitle => 'Titel';
  @override
  String get matchedStory => 'Text';
  @override
  String get matchedScent => 'Duft';
  @override
  String get matchedSound => 'Geräusch';
  @override
  String get matchedPlace => 'Ort';
  @override
  String get matchedPeople => 'Personen';
  @override
  String get matchedFeeling => 'Gefühl';
  @override
  String get matchedSeason => 'Jahreszeit';
  @override
  String get matchedTime => 'Tageszeit';

  @override
  String get syncTitle => 'Synchronisieren';
  @override
  String get syncSubtitle => 'Neue Erinnerungen werden hier verarbeitet und gesichert.';
  @override
  String get syncNow => 'Jetzt synchronisieren';
  @override
  String get syncRunning => 'Wird synchronisiert …';
  @override
  String get syncAllDone => 'Alles synchronisiert';
  @override
  String get syncAllDoneBody => 'Jede Erinnerung ist verarbeitet und sicher abgelegt.';
  @override
  String syncPending(int count) =>
      count == 1 ? '1 Erinnerung wartet' : '$count Erinnerungen warten';
  @override
  String get syncPendingBody => 'Diese Momente wurden festgehalten, aber noch nicht verarbeitet.';
  @override
  String get syncLastRun => 'Zuletzt synchronisiert';
  @override
  String get syncNever => 'noch nie';
  @override
  String get syncQueueTitle => 'Warteschlange';
  @override
  String get syncStatePending => 'wartet';
  @override
  String get syncStateSynced => 'synchronisiert';
  @override
  String get syncStateFailed => 'fehlgeschlagen';
  @override
  String get syncOfflineHint => 'Auch ohne Internet geht nichts verloren: Momento merkt sich alles und holt es hier nach.';
  @override
  String syncFinished(int count) => count == 1
      ? '1 Erinnerung synchronisiert'
      : '$count Erinnerungen synchronisiert';
  @override
  String get syncCloudTitle => 'Später: Sicherung in der Cloud';
  @override
  String get syncCloudBody => 'Momento speichert heute alles nur auf deinem Gerät. Die Synchronisation ist so gebaut, dass sich später eine Cloud-Sicherung anschliessen lässt.';

  @override
  String get menu => 'Menü';
  @override
  String get profile => 'Profil';
  @override
  String get profileOptionalNote => 'Alle Angaben sind freiwillig.';
  @override
  String get profileSaved => 'Profil gespeichert';
  @override
  String get birthday => 'Geburtstag';
  @override
  String get birthdayNotSet => 'nicht angegeben';
  @override
  String get about => 'Über Momento';
  @override
  String get aboutTitle => 'Über Momento';
  @override
  String get settings => 'Einstellungen';
  @override
  String get appearance => 'Darstellung';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Hell';
  @override
  String get themeDark => 'Dunkel';
  @override
  String get language => 'Sprache';
  @override
  String get languageGerman => 'Deutsch';
  @override
  String get languageEnglish => 'Englisch';
  @override
  String get data => 'Daten';
  @override
  String get demoDataTitle => 'Beispiel-Erinnerungen';
  @override
  String get demoDataBody => 'Momento startet mit einigen Beispielen, damit du sofort siehst, wie sich die App anfühlt.';
  @override
  String get demoDataReload => 'Beispiele neu laden';
  @override
  String get demoDataRemove => 'Beispiele entfernen';
  @override
  String get demoDataRemoved => 'Beispiele entfernt';
  @override
  String get demoDataLoaded => 'Beispiele geladen';
  @override
  String get dangerZone => 'Achtung';
  @override
  String get deleteAllTitle => 'Alle Erinnerungen löschen';
  @override
  String get deleteAllBody => 'Das kann nicht rückgängig gemacht werden.';
  @override
  String get deleteAllConfirm => 'Wirklich alles löschen? Alle Erinnerungen und Alben verschwinden für immer.';
  @override
  String get deleteAllDone => 'Alles gelöscht';
  @override
  String get version => 'Version';

  @override
  String get aboutIntro => 'Momento entstand als Geschäftsidee im Rahmen der Berufsmaturität – und ist hier zur echten App geworden.';
  @override
  String get aboutIdeaLabel => 'Idee & Konzept';
  @override
  String get aboutDevLabel => 'Entwicklung';
  @override
  String get aboutSourceLabel => 'Grundlage';
  @override
  String get aboutSourceValue => 'Businessplan «Momento AG», GBMc, 10. Mai 2026';
  @override
  String get aboutThanks => 'Für Dalila – damit du deinen Kolleginnen endlich die fertige App zeigen kannst.';
  @override
  String get aboutConceptTitle => 'Vom Konzept zur App';
  @override
  String get aboutConceptBody => 'Farben, Logo, Aufbau und Funktionen stammen eins zu eins aus dem Businessplan. Links das ursprüngliche Konzeptbild.';
}
