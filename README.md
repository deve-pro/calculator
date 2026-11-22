# Sine Scientific Calculator

A responsive Flutter calculator with switchable Standard and Scientific modes, live previews, a custom expression parser, and simple email/password accounts managed by Supabase Auth. Scientific features include trigonometry (degrees/radians), inverse trig, logarithms, square roots, powers, factorials, constants, percentages, and standard arithmetic.

## Run locally

Install Flutter stable 3.47 or newer and Python 3, then generate the Android runner and fetch dependencies:

```sh
flutter create --platforms=android --org com.devepro --project-name calculator .
python3 tooling/configure_android_deeplinks.py
flutter pub get
flutter run
```

The app is configured to use your Supabase project `snirkcljtqpxoaixmwob` with its public publishable client key. You can override those public client settings at build time if needed:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=your-publishable-key
```

Only use the Supabase **publishable** key in the app. Never put a Supabase secret or `service_role` key in Flutter source or a client build.

## Accounts

Create an account with an email address and password, then sign in with those credentials. Supabase Auth manages the accounts (`auth.users`). Email/password sign-up is enabled in the connected project, and email confirmation is required. New users receive a confirmation link and can sign in after confirming their email. No Google OAuth Client ID or Client Secret is needed.

The app redirects email confirmation back into Android using `io.supabase.calculator://login-callback/`; the build workflow adds the required Android intent filter. For Flutter web, add the deployed app's origin to Supabase Dashboard → **Authentication → URL Configuration → Redirect URLs**. For iOS, register `io.supabase.calculator` as a URL scheme in the Runner target before building there.

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
