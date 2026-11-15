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

## Publish an APK to a GitHub Release

Push a version tag to this repository:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The **Build and publish Android APK** workflow generates the Android project files, runs `flutter analyze` and the tests, builds the release APK, then creates or updates a GitHub Release for that tag and attaches `app-release.apk`. You can also start the workflow from **Actions → Build and publish Android APK → Run workflow** and enter a release tag.

The workflow uses Flutter's default Android signing configuration. Configure a production keystore and GitHub secrets separately before distributing updates through Google Play.
