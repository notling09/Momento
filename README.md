# Momento

**[momento.niltonbc.ch](https://momento.niltonbc.ch)** – Übersicht und Download
**[app.momento.niltonbc.ch](https://app.momento.niltonbc.ch)** – die App direkt im Browser (auch auf dem iPhone)

**Deine App für Erinnerungen und besondere Momente**
*Dein Leben. Deine Erinnerungen.*

Momento hält nicht nur Bilder fest, sondern das, was einen Moment wirklich
ausmacht: den Ort, die Menschen, das Gefühl – und vor allem **Düfte und
Geräusche**. Aus einem Augenblick wird so eine Erinnerung, die sich später
wieder erleben lässt.

---

## Woher die Idee kommt

Momento entstand als Geschäftsidee im Rahmen der Berufsmaturität. Der
Businessplan «Momento AG» (GBMc, 10. Mai 2026) beschreibt Marke, Logo,
Farbwelt, Zielgruppe und Funktionsumfang der App – gebaut wurde sie damals
nicht. Dieses Repository ist die Umsetzung genau dieses Konzepts.

| Rolle | Personen |
|---|---|
| Idee & Konzept | Sara Alina Dörring, Djellza Imeraj, Blerta Zejnaj, Dalila Barroso Carvalho |
| Entwicklung | Nilton Barroso Carvalho |

Die Namen erscheinen auch in der App selbst unter **Menü → Über Momento**.

---

## Funktionen

- **Registrierung und Anmeldung** mit E-Mail und Passwort (Passwörter werden
  gesalzen und als SHA-256-Hash gespeichert, nie im Klartext).
- **Kurze Einführung** beim ersten Öffnen.
- **Startseite mit Flashbacks**: Was habe ich an diesem Tag vor einem Jahr
  erlebt? Taucht von selbst auf.
- **Erinnerungen** mit Titel, Text, Datum, Ort, Personen, Gefühl, Bild,
  Duft und Geräusch.
- **Geräusche wirklich aufnehmen** – Mikrofonaufnahme direkt in der App, mit
  Wellenform und Wiedergabe.
- **Düfte** aus einer kuratierten Palette (16 Düfte mit Symbol, Farbe und
  Intensität) oder frei beschrieben.
- **Alben**, die Erinnerungen, Düfte und Geräusche gruppieren.
- **Semantische Suche**: Erinnerungen lassen sich beschreiben statt exakt
  benennen. Die Suche kennt Synonyme, versteht Jahreszeiten und Tageszeiten
  und verzeiht Tippfehler.
- **Synchronisieren** mit sichtbarer Warteschlange – neue Erinnerungen warten
  dort, bis sie verarbeitet sind.
- **Light- und Dark-Mode**, **Deutsch und Englisch** umschaltbar.
- **Beispiel-Erinnerungen** beim ersten Start, jederzeit entfernbar.
- **Sicherung**: alle Erinnerungen samt Bildern und Tonaufnahmen als ZIP-Datei
  herausschreiben und wieder einlesen (dazufügen oder alles ersetzen).

---

## Vom Businessplan zur App

| Businessplan | Umsetzung im Code |
|---|---|
| Kap. 7.1 Marke, Gefühle | [`momento_colors.dart`](lib/core/theme/momento_colors.dart), [`feeling.dart`](lib/data/models/feeling.dart) |
| Kap. 7.2 Login, Einführung | [`welcome_screen.dart`](lib/features/auth/welcome_screen.dart), [`onboarding_screen.dart`](lib/features/onboarding/onboarding_screen.dart) |
| Kap. 7.2 Startseite, Flashbacks | [`home_screen.dart`](lib/features/home/home_screen.dart) |
| Kap. 7.2 Menü, Profil, Sprache, Dark-Mode | [`home_shell.dart`](lib/features/home/home_shell.dart), [`settings_screen.dart`](lib/features/settings/settings_screen.dart) |
| Kap. 7.2 Untere Leiste mit drei Knöpfen | [`home_shell.dart`](lib/features/home/home_shell.dart) (`MomentoNavBar`) |
| Kap. 7.2 Düfte und Geräusche | [`scent.dart`](lib/data/models/scent.dart), [`sound_recorder_field.dart`](lib/widgets/sound_recorder_field.dart) |
| Kap. 7.2 Alben | [`albums_screen.dart`](lib/features/albums/albums_screen.dart) |
| Kap. 7.2 Suche per Beschreibung | [`memory_search.dart`](lib/core/utils/memory_search.dart) |
| Abbildung 1 (Startansicht) | 1:1 nachgebaut; das Originalbild ist in der App unter «Über Momento» zu sehen |
| Abb. 4 / 5 (Logo, App-Icon) | [`assets/brand/`](assets/brand) – aus dem PDF extrahiert und freigestellt |

### Drei bewusste Abweichungen

**1. Kein Ausweisfoto bei der Registrierung.**
Der Businessplan sieht in Kapitel 7.2 ein Foto der ID vor. Ein Ausweis
gehört zu den besonders schützenswerten Personendaten (revDSG Art. 5), und
für eine Erinnerungs-App gibt es keinen Zweck, der diese Erhebung
rechtfertigen würde. Nach dem Grundsatz der Datensparsamkeit fragt Momento
deshalb nur nach E-Mail, Passwort und einem Namen.

**2. Düfte werden beschrieben, nicht gemessen.**
Der Businessplan sagt, Düfte würden «automatisch übertragen». Kein
Smartphone besitzt einen Geruchssensor – das ist technisch nicht möglich.
Momento löst es ehrlich: eine kuratierte Duftpalette mit Intensitätsregler
plus Freitext. Geräusche dagegen **werden** wirklich aufgenommen.

**3. Bilder ja, Videos nein.**
Der Businessplan spricht im Abschnitt «Sinn und Zweck» von «Bilder oder
Videos». Videos hätten zwei Dinge gebrochen, die heute funktionieren: Die
Sicherung baut das ZIP-Archiv vollständig im Arbeitsspeicher auf – das
trägt bei Fotos, bei Videos nicht mehr. Und die Web-Version legt Medien im
Browserspeicher ab (rund 5 MB); ein einziges Video sprengt das sofort.
Videos aufzunehmen wäre also kein zusätzlicher Knopf, sondern ein Umbau
der Datenhaltung. Diese Entscheidung wurde bewusst getroffen und nicht
vergessen.

---

## Technik

| | |
|---|---|
| Sprache | Dart 3.12 |
| Framework | Flutter 3.44 (Material 3) |
| Plattformen | Android, iOS, Web – ein Quellcode |
| Speicherung | lokal auf dem Gerät (JSON über `shared_preferences`), Medien als Dateien bzw. Base64 im Browser |
| Zustand | `ChangeNotifier` + `InheritedNotifier` – ohne zusätzliche Bibliothek |

### Aufbau

```
lib/
├── core/
│   ├── l10n/              Alle Texte auf Deutsch und Englisch
│   ├── theme/             Farben, Verläufe, Schriften, Material-Theme
│   ├── utils/             Suche, Textwerkzeuge, Datumsformate, WAV-Kodierung
│   └── momento_controller.dart   Der zentrale Zustand der App
├── data/
│   ├── models/            Erinnerung, Album, Duft, Gefühl, Konto
│   ├── local/             Lokaler Speicher, Mediendateien, Beispieldaten, Klangsynthese
│   └── repositories/      Schnittstellen + lokale Umsetzung
├── features/              Ein Ordner pro Bildschirm
└── widgets/               Wiederverwendbare Bausteine
```

### Warum Repositories?

Jeder Zugriff auf Daten läuft über eine Schnittstelle
([`MemoryRepository`](lib/data/repositories/memory_repository.dart) und
Geschwister). Heute steht dahinter der lokale Speicher. Wenn Momento später
in die Cloud soll, wird nur eine zweite Umsetzung dieser Schnittstellen
gebraucht – die Bildschirme bleiben unverändert.

### Zwei Details, auf die ich stolz bin

**Gezeichnete Titelbilder.** Erinnerungen ohne eigenes Foto bekommen eine von
zehn Szenen, die zur Laufzeit gemalt werden
([`scene_cover.dart`](lib/widgets/scene_cover.dart)): Sonnenuntergang am See,
Strand, Berge, Stadt bei Nacht, Wald, Schneefall, Fest, Regen am Fenster,
Herbstpark, Frühlingswiese. Keine Bilddateien, in jeder Auflösung scharf und
immer in den Markenfarben.

**Erzeugte Umgebungsgeräusche.** Die Beispiel-Erinnerungen lassen sich
wirklich anhören. Wellen, Regen, Wind, Feuer und Vögel werden aus
gefiltertem Rauschen berechnet
([`ambience_synth.dart`](lib/data/local/ambience_synth.dart)) – keine
fremden Audiodateien nötig.

---

## Tests

```bash
flutter test
```

59 Tests in fünf Gruppen:

- [`test/memory_search_test.dart`](test/memory_search_test.dart) – die Suche:
  findet sie eine Erinnerung über den Ort, über einen Oberbegriff, der nirgends
  wörtlich vorkommt, über den Duft, über eine Person, über die Jahreszeit, trotz
  Tippfehler und über Sprachgrenzen hinweg?
- [`test/storage_test.dart`](test/storage_test.dart) – Konten, Passwort-Hashing,
  Speichern über Neustarts hinweg und die Warteschlange des Sync-Knopfes.
- [`test/backup_test.dart`](test/backup_test.dart) – die Sicherung: Überstehen
  Erinnerungen, Alben und Tonaufnahmen den Weg aus der App heraus und wieder
  hinein? Wird eine fremde Datei abgelehnt?
- [`test/app_info_test.dart`](test/app_info_test.dart) – wacht darüber, dass die
  Versionsnummer im Code und in der `pubspec.yaml` nicht auseinanderlaufen.
- [`test/screens_test.dart`](test/screens_test.dart) – rendert jeden Bildschirm
  und legt ihn als Bild unter [`test/goldens/`](test/goldens) ab:

```bash
flutter test --update-goldens test/screens_test.dart
```

So lässt sich das Aussehen der App prüfen, ohne ein Gerät anzuschliessen –
inklusive Dark-Mode und englischer Oberfläche.

Die Uhr der App ist dabei eine Abhängigkeit wie jede andere: Der Controller
bekommt sie beim Start übergeben, und die Bildvergleiche setzen ein festes
«heute». Sonst würden sie an jedem neuen Tag fehlschlagen, weil auf der
Startseite Datumsangaben stehen.

---

## Starten

Voraussetzung: [Flutter](https://docs.flutter.dev/get-started/install) 3.44
oder neuer.

```bash
flutter pub get
```

Auf einem angeschlossenen Android-Gerät oder Emulator:

```bash
flutter run
```

Im Browser:

```bash
flutter run -d chrome
```

### APK für Android bauen

```bash
flutter build apk --release
```

Die fertige Datei liegt danach unter
`build/app/outputs/flutter-apk/app-release.apk` und lässt sich direkt auf
einem Android-Handy installieren. Sie enthält alle drei
Prozessor-Architekturen und ist deshalb rund 54 MB gross.

Für den Download über eine Website ist die aufgeteilte Variante besser:

```bash
flutter build apk --release --split-per-abi
```

Das ergibt drei kleinere Dateien. Für praktisch jedes heutige Android-Handy
ist `app-arm64-v8a-release.apk` die richtige; `app-release.apk` funktioniert
dafür überall und ist die sichere Wahl, wenn man nicht wählen lassen möchte.

> Zum Installieren muss man auf dem Handy einmalig «Installation aus
> unbekannten Quellen» für den Browser oder Dateimanager erlauben – das ist
> bei jeder APK ausserhalb des Play Stores so.

> Hinweis: Der Release-Build ist derzeit mit dem Debug-Schlüssel signiert.
> Für eine Veröffentlichung im Play Store wäre ein eigener Signaturschlüssel
> nötig; zum Weitergeben der APK genügt das so.

### Website

Die Downloadseite liegt in [`website/`](website) – statisches HTML, kein Build.
Anleitung zum Ansehen und Veröffentlichen: [website/README.md](website/README.md).

### Web bauen

```bash
flutter build web --release
```

Der Ordner `build/web` lässt sich direkt statisch hosten.

### Markenbilder neu erzeugen

Logo, App-Icon und alle Launcher-Icons werden aus den Bildern des
Businessplans abgeleitet:

```bash
dart run tool/prepare_brand_assets.dart
```

---

## Lizenzen und Quellen

- Logo, App-Icon und das Konzeptbild der Startseite stammen aus dem
  Businessplan «Momento AG» und wurden dort mit ChatGPT erstellt
  (Abbildungen 1, 4 und 5).
- Schriften: [Quicksand](https://fonts.google.com/specimen/Quicksand) und
  [Baloo 2](https://fonts.google.com/specimen/Baloo+2), beide unter der
  SIL Open Font License 1.1.
- Alle Illustrationen in der App (Szenen, Onboarding-Grafiken) sind eigener
  Code, keine fremden Bilddateien.
