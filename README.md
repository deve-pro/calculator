# Sine Scientific Calculator

A responsive Flutter calculator with switchable Standard and Scientific modes, live previews, and a custom expression parser. Scientific features include trigonometry (degrees/radians), inverse trig, logarithms, square roots, powers, factorials, constants, percentages, and standard arithmetic.

## Run locally

Install Flutter stable 3.47 or newer and Python 3, then generate the Android runner and fetch dependencies:

```sh
flutter create --platforms=android --org com.devepro --project-name calculator .
python3 tooling/configure_android.py
flutter pub get
flutter run
```

The app uses the Supabase project below only for the optional public install counter. The publishable key is a public client key; never put a Supabase secret or `service_role` key in Flutter source or a client build.

## Device account and privacy

Sine creates a random local account ID automatically for each app installation. There is no login, email, or password. Existing Supabase Auth accounts are no longer used by the app and are not deleted. By default the ID stays on the device; clearing app data or reinstalling can create a new ID. This is a per-install profile, not an identity tied to a physical device, and it does not sync between devices. Calculator activity is never sent to the counter.

The first-run prompt asks separately whether to include this installation in the public counter. If you opt in, that random installation ID is sent to Supabase—not personal details or calculator activity. You can opt out at any time from the account icon; the app asks Supabase to remove that ID from the count. The calculator works normally without consent, and the count is an approximate number of opted-in installations—not verified people or all active users. As with any unauthenticated public counter, it is not resistant to deliberate fake submissions.

### Opted-in installations

<!-- INSTALL_COUNT_START -->
**0 opted-in installations**
<!-- INSTALL_COUNT_END -->

GitHub Actions refreshes this aggregate daily and can be run manually from the Actions tab. The migration for the counter is in `supabase/migrations/20261122000000_device_install_counter.sql`.

## Tests and builds

```sh
flutter analyze
flutter test
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`.

Push a version tag to publish a GitHub Release:

```sh
git tag v1.0.0
git push origin v1.0.0
```

The **Build and publish Android APK** workflow runs on branch pushes and pull requests to `main`. It analyzes and tests the app, builds a release APK, and uploads it as a downloadable workflow artifact (retained for 30 days). Push a `v*` tag to also attach the APK to a GitHub Release. Configure a production signing keystore separately before distributing updates through Google Play.
