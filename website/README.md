# Momento – Website

Die Downloadseite für die App. Eine einzige statische HTML-Datei, kein
Framework, kein Build-Schritt.

```
website/
├── index.html      die ganze Seite (Inhalt und Gestaltung)
├── brand/          Logo, App-Icon, Konzeptbild aus dem Businessplan
└── screens/        Screenshots der App in doppelter Auflösung
```

## Lokal ansehen

```bash
node tool/serve_website.js
```

Danach `http://127.0.0.1:5050` im Browser öffnen. (Ein Doppelklick auf
`index.html` funktioniert auch, aber über den Server verhält sich alles
genau wie später auf Vercel.)

## Screenshots neu erzeugen

Die Bilder in `screens/` entstehen automatisch aus der App – kein Handy
nötig, keine Bildbearbeitung:

```bash
flutter test --update-goldens tool/website_screenshots_test.dart
```

Wenn sich die App sichtbar verändert, einmal ausführen und die neuen Bilder
mitcommitten.

## Auf Vercel veröffentlichen

**Voraussetzung:** Die APK-Dateien müssen als GitHub Release hochgeladen sein
(siehe unten), sonst zeigen die Download-Knöpfe ins Leere.

### Variante A – über die Vercel-Website (einfacher)

1. Auf [vercel.com](https://vercel.com) mit dem GitHub-Konto anmelden
2. **Add New… → Project** und das Repository `Momento` auswählen
3. Bei **Root Directory** auf *Edit* klicken und `website` auswählen
4. Framework Preset bleibt auf **Other**, Build Command und Install Command
   leer lassen
5. **Deploy**

Ab dann wird die Seite bei jedem Push auf `main` automatisch neu
veröffentlicht.

### Variante B – über die Kommandozeile

```bash
npx vercel --cwd website
```

Beim ersten Mal fragt Vercel nach Anmeldung und Projektname. Für die
öffentliche Version danach:

```bash
npx vercel --cwd website --prod
```

## APKs als GitHub Release bereitstellen

Die Download-Knöpfe zeigen auf ein Release mit dem Tag `v1.0.0`. So entsteht es:

1. Im Repository auf **Releases → Create a new release**
2. Bei *Choose a tag* `v1.0.0` eintippen und **Create new tag on publish** wählen
3. Titel: `Momento 1.0.0`
4. Diese drei Dateien aus `build/app/outputs/flutter-apk/` hineinziehen –
   die Namen müssen unverändert bleiben, sonst stimmen die Links nicht:
   - `app-arm64-v8a-release.apk`
   - `app-armeabi-v7a-release.apk`
   - `app-release.apk`
5. **Publish release**

Bei einer neuen Version: neues Release mit neuem Tag anlegen und in
`index.html` die drei Links von `v1.0.0` auf den neuen Tag ändern
(dreimal suchen und ersetzen).

## Veröffentlicht unter

https://momento-eta-six.vercel.app

Die Adresse steht in `index.html` bei den `og:`-Angaben. Wenn du der Seite
später eine eigene Domain gibst, dort an vier Stellen anpassen (canonical,
og:url, og:image, twitter:image).
