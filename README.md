# Calculator

A responsive calculator app written in Flutter. It supports the four basic operations, decimals, percentages, unary negatives, live previews, and a custom expression evaluator. The app has no third-party runtime dependencies.

## Run locally

Install the Flutter stable SDK, then generate the Android runner once (this repository keeps the Flutter app source and generates platform boilerplate when needed):

```sh
flutter create --platforms=android --org com.devepro --project-name calculator .
flutter pub get
flutter run
```

To build an APK locally:

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

## Build and publish an APK

Push a version tag to this repository:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The **Build and publish Android APK** workflow runs on branch pushes and pull requests to `main`. It generates the Android project files, runs `flutter analyze` and the tests, builds the release APK, and uploads it as a downloadable workflow artifact (`calculator-apk-*`, retained for 30 days). Push a `v*` tag to also create or update a GitHub Release and attach `app-release.apk`. You can start it manually from **Actions → Build and publish Android APK → Run workflow**; leave the release tag empty to build an artifact only, or enter a tag to publish a release.

The workflow uses Flutter's default Android signing configuration. Configure a production keystore and GitHub secrets separately before distributing updates through Google Play.
