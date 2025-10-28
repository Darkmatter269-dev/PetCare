PetCare (Flutter)

Short setup & run instructions for developers 

## Requirements
- Flutter SDK (stable). Ensure Flutter is on PATH and meets project SDK >= 3.9.2.
- Android SDK / Android Studio (for Android builds) or Xcode (for iOS).
- A connected device or emulator.

## Quick start (Windows PowerShell)
1. Clone the repo and open the project folder.

```powershell
cd "C:\path\to\repo\flutter_application_1"
flutter pub get
flutter analyze
flutter devices
flutter run -d <deviceId>
```

2. If you change native files or assets, do a clean rebuild:

```powershell
flutter clean
flutter pub get
flutter run
```

## Permissions
- Android: `android/app/src/main/AndroidManifest.xml` already declares contacts permissions:
```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_CONTACTS" />
```
- iOS: If building for iOS, add to `ios/Runner/Info.plist`:
```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts so you can add them to PetCare.</string>
```

The app requests contacts permission at runtime using `permission_handler` — accept the prompt on the device.

## Key files
- `lib/main.dart` — app entry & route setup
- `lib/screens/` — UI screens (GettingStarted, Auth, Home, MyPets, Calendar, Contacts, Alerts)
- `lib/models/` — models and ChangeNotifier stores (Pet, Schedule)
- `lib/widgets/in_page_nav.dart` — in-page navigation component
- `assets/images/` — images used by the app (ensure assets listed in `pubspec.yaml` exist)

## Important dependencies
Listed in `pubspec.yaml` (examples):
- provider
- flutter_contacts
- permission_handler
- url_launcher

## Common issues & quick fixes
- "Unable to load asset": ensure the file exists in `assets/images/` and is listed in `pubspec.yaml`, then run `flutter pub get` and a full rebuild.
- Permission denied for contacts: check the Android manifest has `<uses-permission android:name="android.permission.READ_CONTACTS"/>`, then accept the runtime prompt or enable permissions in OS settings.
- Gradle/build errors from old plugins: run `flutter pub upgrade` or replace plugins that use the v1 Android embedding.



---

If you'd like, I can commit this `README.md` for you now. Tell me to proceed and I'll add and commit it to the repo.
