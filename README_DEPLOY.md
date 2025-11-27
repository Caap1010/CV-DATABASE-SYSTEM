**Deployment Guide**

This document explains how to make the CV database web app live and set up CI/CD so changes auto-deploy.

1) Push this repository to GitHub

  - Create a GitHub repository and push your local repo:

```powershell
git remote add origin https://github.com/<your-username>/<your-repo>.git
git branch -M main
git push -u origin main
```

2) Firebase setup (recommended for database + hosting)

- Install FlutterFire CLI and configure your Firebase project:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

- The `flutterfire configure` command will generate `lib/firebase_options.dart` with platform-specific FirebaseOptions. If you prefer manual setup, copy `lib/firebase_options_template.dart` to `lib/firebase_options.dart` and fill in the values from the Firebase console.

- Create a Hosting site in Firebase and confirm project ID. To deploy from GitHub Actions you'll need a `FIREBASE_TOKEN` secret (generate with `firebase login:ci`).

3) GitHub Actions

- `CI` workflow (`.github/workflows/ci.yml`) runs `flutter analyze`, `flutter test`, and builds the web app on push/PR to `main`.
- `deploy-gh-pages` workflow (`.github/workflows/deploy-gh-pages.yml`) builds the web app and deploys `build/web` to GitHub Pages on push to `main`.
- `deploy-firebase` workflow (`.github/workflows/deploy-firebase.yml`) builds the web app and deploys to Firebase Hosting. It requires the `FIREBASE_TOKEN` secret.

7) Firestore & Storage rules

- I added example rules in `firebase/firestore.rules` and `firebase/storage.rules`.
- Current defaults allow public reads and require authenticated writes for uploads/creates. Adjust to your security policy:
  - For private CVs, change `allow read: if true` to `allow read: if request.auth != null` and require `ownerId` checks for updates/deletes.
- Add index `firebase/firestore.indexes.json` (createdAt descending) to speed up listing.
8) Enable resume uploads (optional)

- To enable file uploads for resumes you need to:
  1. Add `firebase_storage` and `file_picker` to `pubspec.yaml`.
  2. Implement upload logic (I scaffolded `FirebaseService.uploadResume` earlier; re-enable it after installing the packages).
  3. Update `lib/pages/cv_form_page.dart` to wire file picking to the upload helper.


4) Adding secrets to GitHub

- In your GitHub repository: Settings → Secrets → Actions → Add `FIREBASE_TOKEN` (value from `firebase login:ci`).

5) Android / iOS release automation

- I added templates for Android/iOS release workflows. To publish to Play Store or App Store you must provide signing keys and store credentials as repository secrets (keystore file content, passwords, and API tokens). I will help you configure these if you want.

6) Next steps I can do for you

- Push this repo to GitHub for you (provide the repo URL or grant access).
- Run `flutterfire configure` for you if you provide Firebase project access and credentials.
- Add Auth/Firestore UI integrations (I scaffolded a `FirebaseService` in `lib/services/firebase_service.dart`).
