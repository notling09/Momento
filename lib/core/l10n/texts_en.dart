import 'app_texts.dart';

/// English translation.
class TextsEn extends AppTexts {
  const TextsEn();

  @override
  String get localeName => 'en';
  @override
  String get languageLabel => 'English';

  @override
  String get appName => 'Momento';
  @override
  String get vision => 'Your life. Your memories.';
  @override
  String get tagline => 'Your app for memories and special moments';

  @override
  String get actionContinue => 'Continue';
  @override
  String get actionBack => 'Back';
  @override
  String get actionSave => 'Save';
  @override
  String get actionCancel => 'Cancel';
  @override
  String get actionDelete => 'Delete';
  @override
  String get actionEdit => 'Edit';
  @override
  String get actionClose => 'Close';
  @override
  String get actionRetry => 'Try again';
  @override
  String get actionSkip => 'Skip';
  @override
  String get actionShowAll => 'Show all';
  @override
  String get actionGotIt => 'Got it';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get loading => 'One moment …';
  @override
  String get today => 'Today';
  @override
  String get yesterday => 'Yesterday';

  @override
  String get welcomeTitle => 'Good to see you!';
  @override
  String get welcomeSubtitle => 'Your moments are waiting.';
  @override
  String get signIn => 'Sign in';
  @override
  String get signUp => 'Sign up';
  @override
  String get signOut => 'Sign out';
  @override
  String get signOutConfirm => 'Sign out? Your memories stay saved on this device.';
  @override
  String get email => 'Email address';
  @override
  String get password => 'Password';
  @override
  String get passwordRepeat => 'Repeat password';
  @override
  String get displayName => 'What should we call you?';
  @override
  String get displayNameHint => 'Your first name';
  @override
  String get createAccount => 'Create account';
  @override
  String get noAccountYet => 'No account yet? Sign up';
  @override
  String get alreadyHaveAccount => 'Already here? Sign in';
  @override
  String get privacyNote => 'Every memory stays on your device. We only ask for an email and a password – nothing else.';
  @override
  String get errorEmailInvalid => 'Please enter a valid email address.';
  @override
  String get errorPasswordShort => 'The password needs at least 6 characters.';
  @override
  String get errorPasswordsDiffer => 'The two passwords do not match.';
  @override
  String get errorNameRequired => 'Please enter a name.';
  @override
  String get errorEmailTaken => 'There is already an account for this email on this device.';
  @override
  String get errorWrongCredentials => 'Email or password is not correct.';
  @override
  String get greetingBack => 'Welcome back';

  @override
  String get onboarding1Title => 'Keep what matters';
  @override
  String get onboarding1Body => 'A picture, a place, a thought: Momento turns a moment into a memory that stays.';
  @override
  String get onboarding2Title => 'Scents and sounds too';
  @override
  String get onboarding2Body => 'Actually record the waves, and note what the air smelled like. Those details are what bring a moment back.';
  @override
  String get onboarding3Title => 'Flashbacks';
  @override
  String get onboarding3Body => 'Momento shows you what you lived through on this day a year ago – without you having to look for it.';
  @override
  String get onboarding4Title => 'Search the way you remember';
  @override
  String get onboarding4Body => 'Describe a memory the way you would tell it, and the search will find it for you.';
  @override
  String get onboardingStart => 'Let\'s go';

  @override
  String get navMemories => 'Memories';
  @override
  String get navSync => 'Sync';
  @override
  String get navSearch => 'Search';
  @override
  String get navHome => 'Home';

  @override
  String get homeWelcome => 'Good to see you!';
  @override
  String get homeWelcomeSub => 'Your moments are waiting.';
  @override
  String get flashbackSection => 'One year ago today';
  @override
  String flashbackYearsAgo(int years) =>
      years == 1 ? 'One year ago today' : '$years years ago today';
  @override
  String get flashbackNoneTitle => 'No flashbacks today';
  @override
  String get flashbackNoneBody => 'As soon as your memories turn a year old, they will show up here on their own.';
  @override
  String get albumsSection => 'Your albums';
  @override
  String get albumsSectionSub => 'Group moments, scents and sounds.';
  @override
  String get albumsEmptyCardTitle => 'Create albums for your favourite moments.';
  @override
  String get createAlbum => 'Create new album';
  @override
  String get onThisDay => 'On this day';
  @override
  String get recentSection => 'Recently captured';
  @override
  String get recentSectionSub => 'Your newest moments.';
  @override
  String get statsMemories => 'Memories';
  @override
  String get statsAlbums => 'Albums';
  @override
  String get statsScents => 'Scents';
  @override
  String get statsSounds => 'Sounds';

  @override
  String get memories => 'Memories';
  @override
  String get memory => 'Memory';
  @override
  String get newMemory => 'New memory';
  @override
  String get editMemory => 'Edit memory';
  @override
  String get memoryTitle => 'Title';
  @override
  String get memoryTitleHint => 'A perfect evening by the lake';
  @override
  String get memoryStory => 'What happened?';
  @override
  String get memoryStoryHint => 'Write a few sentences about what you want to remember …';
  @override
  String get memoryPlace => 'Place';
  @override
  String get memoryPlaceHint => 'e.g. Lake Zurich';
  @override
  String get memoryDate => 'Date and time';
  @override
  String get memoryFeeling => 'Feeling';
  @override
  String get memoryPeople => 'Who was there?';
  @override
  String get memoryPeopleHint => 'Separate names with commas';
  @override
  String get memoryPhoto => 'Picture';
  @override
  String get memorySceneLabel => 'Or pick an artwork';
  @override
  String get memoryPhotoAdd => 'Add a picture';
  @override
  String get memoryPhotoChange => 'Replace picture';
  @override
  String get memoryPhotoRemove => 'Remove picture';
  @override
  String get memoryFromCamera => 'Camera';
  @override
  String get memoryFromGallery => 'Gallery';
  @override
  String get memoryScent => 'Scent';
  @override
  String get memoryScentHint => 'What did this moment smell like?';
  @override
  String get memoryScentIntensity => 'Intensity';
  @override
  String get memorySound => 'Sound';
  @override
  String get memorySoundRecord => 'Start recording';
  @override
  String get memorySoundStop => 'Stop recording';
  @override
  String get memorySoundPlay => 'Play';
  @override
  String get memorySoundPause => 'Pause';
  @override
  String get memorySoundDelete => 'Delete recording';
  @override
  String get memorySoundLabel => 'Describe the sound';
  @override
  String get memorySoundLabelHint => 'e.g. waves rolling in';
  @override
  String get memorySoundPermission => 'Momento needs access to the microphone to record. You can allow it in your device settings.';
  @override
  String get memorySoundFailed => 'The recording did not work. Please try again.';
  @override
  String get memoryCapturedOn => 'Captured on';
  @override
  String get memoryFavorite => 'Add to favourites';
  @override
  String get memoryDeleteConfirm => 'Delete this memory for good?';
  @override
  String get memorySaved => 'Memory saved';
  @override
  String get memoryDeleted => 'Memory deleted';
  @override
  String get memoriesEmptyTitle => 'Nothing here yet';
  @override
  String get memoriesEmptyBody => 'Capture your first moment – a picture, a scent or a sound is enough.';
  @override
  String get errorTitleRequired => 'Give your memory a title.';
  @override
  String get filterAll => 'All';
  @override
  String get filterFavorites => 'Favourites';
  @override
  String get filterWithScent => 'With scent';
  @override
  String get filterWithSound => 'With sound';
  @override
  String memoryCount(int count) => count == 1 ? '1 memory' : '$count memories';

  @override
  String get feelingJoy => 'Joy';
  @override
  String get feelingNostalgia => 'Nostalgia';
  @override
  String get feelingLove => 'Love';
  @override
  String get feelingCalm => 'Calm';
  @override
  String get feelingExcitement => 'Excitement';
  @override
  String get feelingGratitude => 'Gratitude';
  @override
  String get feelingWistful => 'Wistful';
  @override
  String get feelingProud => 'Proud';

  @override
  String get scentPickerTitle => 'What did it smell like?';
  @override
  String get scentPickerSub => 'Pick a scent or describe your own. Scents cannot be measured – but they can be remembered.';
  @override
  String get scentCustom => 'Your own scent';
  @override
  String get scentCustomHint => 'Describe the scent in your own words';
  @override
  String get scentNone => 'No scent';
  @override
  String get scentSeaBreeze => 'Sea breeze';
  @override
  String get scentSunscreen => 'Sunscreen';
  @override
  String get scentRainOnAsphalt => 'Rain on warm asphalt';
  @override
  String get scentFreshBread => 'Fresh bread';
  @override
  String get scentPineForest => 'Pine forest';
  @override
  String get scentCampfire => 'Campfire';
  @override
  String get scentCoffee => 'Coffee';
  @override
  String get scentFreshLaundry => 'Fresh laundry';
  @override
  String get scentCutGrass => 'Freshly cut grass';
  @override
  String get scentVanilla => 'Vanilla';
  @override
  String get scentCinnamon => 'Cinnamon';
  @override
  String get scentOldBooks => 'Old books';
  @override
  String get scentGrandmasHome => 'Grandma\'s home';
  @override
  String get scentSnowAir => 'Snowy air';
  @override
  String get scentFlowerMeadow => 'Flower meadow';
  @override
  String get scentCitrus => 'Citrus';
  @override
  String get intensityLight => 'faint';
  @override
  String get intensityClear => 'clear';
  @override
  String get intensityIntense => 'intense';

  @override
  String get albums => 'Albums';
  @override
  String get album => 'Album';
  @override
  String get newAlbum => 'New album';
  @override
  String get editAlbum => 'Edit album';
  @override
  String get albumName => 'Album name';
  @override
  String get albumNameHint => 'e.g. Summer 2025';
  @override
  String get albumDescription => 'Description';
  @override
  String get albumDescriptionHint => 'What is this album about?';
  @override
  String get albumPickMemories => 'Choose memories';
  @override
  String get albumEmptyTitle => 'No albums yet';
  @override
  String get albumEmptyBody => 'Bring together what belongs together: a trip, a summer, a person.';
  @override
  String get albumDeleteConfirm => 'Delete this album? The memories inside will stay.';
  @override
  String get albumSaved => 'Album saved';
  @override
  String get errorAlbumNameRequired => 'Give the album a name.';
  @override
  String get errorAlbumNeedsMemories => 'Choose at least one memory.';
  @override
  String albumMemoryCount(int count) => count == 1 ? '1 memory' : '$count memories';

  @override
  String get searchTitle => 'Search';
  @override
  String get searchSubtitle => 'Describe the memory – we will find it.';
  @override
  String get searchHint => 'e.g. that evening by the lake with the dog';
  @override
  String get searchIdeas => 'Try one of these';
  @override
  String get searchNoResultsTitle => 'Nothing found';
  @override
  String get searchNoResultsBody => 'Try other words – a place, a feeling, a scent or a name.';
  @override
  String get searchStartTitle => 'Tell us what you are thinking of';
  @override
  String get searchStartBody => 'The search understands whole sentences and looks through titles, texts, places, people, scents and sounds.';
  @override
  String searchResultCount(int count) => count == 1 ? '1 match' : '$count matches';
  @override
  String get searchWhyMatched => 'Found through';
  @override
  String get searchExample1 => 'sunset over the water';
  @override
  String get searchExample2 => 'when it smelled of campfire';
  @override
  String get searchExample3 => 'winter with the family';
  @override
  String get searchExample4 => 'laughing with friends';
  @override
  String get matchedTitle => 'Title';
  @override
  String get matchedStory => 'Text';
  @override
  String get matchedScent => 'Scent';
  @override
  String get matchedSound => 'Sound';
  @override
  String get matchedPlace => 'Place';
  @override
  String get matchedPeople => 'People';
  @override
  String get matchedFeeling => 'Feeling';
  @override
  String get matchedSeason => 'Season';
  @override
  String get matchedTime => 'Time of day';

  @override
  String get syncTitle => 'Sync';
  @override
  String get syncSubtitle => 'New memories are processed and secured here.';
  @override
  String get syncNow => 'Sync now';
  @override
  String get syncRunning => 'Syncing …';
  @override
  String get syncAllDone => 'Everything is synced';
  @override
  String get syncAllDoneBody => 'Every memory has been processed and stored safely.';
  @override
  String syncPending(int count) =>
      count == 1 ? '1 memory is waiting' : '$count memories are waiting';
  @override
  String get syncPendingBody => 'These moments were captured but not processed yet.';
  @override
  String get syncLastRun => 'Last synced';
  @override
  String get syncNever => 'never';
  @override
  String get syncQueueTitle => 'Queue';
  @override
  String get syncStatePending => 'waiting';
  @override
  String get syncStateSynced => 'synced';
  @override
  String get syncStateFailed => 'failed';
  @override
  String get syncOfflineHint => 'Nothing gets lost without internet: Momento remembers everything and catches up here.';
  @override
  String syncFinished(int count) =>
      count == 1 ? '1 memory synced' : '$count memories synced';
  @override
  String get syncCloudTitle => 'Later: backup in the cloud';
  @override
  String get syncCloudBody => 'Today Momento keeps everything on your device only. Syncing is built so a cloud backup can be plugged in later.';

  @override
  String get menu => 'Menu';
  @override
  String get profile => 'Profile';
  @override
  String get profileOptionalNote => 'Everything here is optional.';
  @override
  String get profileSaved => 'Profile saved';
  @override
  String get birthday => 'Birthday';
  @override
  String get birthdayNotSet => 'not set';
  @override
  String get about => 'About Momento';
  @override
  String get aboutTitle => 'About Momento';
  @override
  String get settings => 'Settings';
  @override
  String get appearance => 'Appearance';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get language => 'Language';
  @override
  String get languageGerman => 'German';
  @override
  String get languageEnglish => 'English';
  @override
  String get data => 'Data';
  @override
  String get demoDataTitle => 'Example memories';
  @override
  String get demoDataBody => 'Momento starts with a few examples so you can see right away how the app feels.';
  @override
  String get demoDataReload => 'Reload examples';
  @override
  String get demoDataRemove => 'Remove examples';
  @override
  String get demoDataRemoved => 'Examples removed';
  @override
  String get demoDataLoaded => 'Examples loaded';
  @override
  String get dangerZone => 'Careful';
  @override
  String get deleteAllTitle => 'Delete all memories';
  @override
  String get deleteAllBody => 'This cannot be undone.';
  @override
  String get deleteAllConfirm => 'Really delete everything? All memories and albums will be gone for good.';
  @override
  String get deleteAllDone => 'Everything deleted';
  @override
  String get version => 'Version';

  @override
  String get aboutIntro => 'Momento started as a business idea during vocational baccalaureate school – and became a real app here.';
  @override
  String get aboutIdeaLabel => 'Idea & concept';
  @override
  String get aboutDevLabel => 'Development';
  @override
  String get aboutSourceLabel => 'Based on';
  @override
  String get aboutSourceValue => 'Business plan "Momento AG", GBMc, 10 May 2026';
  @override
  String get aboutThanks => 'For Dalila – so you can finally show your classmates the finished app.';
  @override
  String get aboutConceptTitle => 'From concept to app';
  @override
  String get aboutConceptBody => 'Colours, logo, structure and features come straight from the business plan. On the left is the original concept image.';
}
