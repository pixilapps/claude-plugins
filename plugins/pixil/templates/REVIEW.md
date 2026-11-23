# Review criteria — {{App name}}

What `/pixil:review-pr` flags and what it skips. The procedures are in the `pixil` plugin
(`pixilapps/claude-plugins`); this file is the part to tune per repository. When a finding keeps
coming back as `wrong` or `intentional`, `/pixil:triage-review` proposes a line for the last
section.

## Project

The commands read these lines. `/pixil:setup-review` fills them from the repository; fix any it
got wrong, and replace every `TODO`.

- **Base branch:** {{develop}}
- **Issues:** {{Linear `ABC-###` | Jira `ABC-###` | GitHub issues}}
- **Rules:** {{`.specify/memory/constitution.md`, `CLAUDE.md`}}
- **Install:** `flutter pub get`
- **Check:** `flutter analyze` (must print `No issues found!`)
- **Generate:** `flutter gen-l10n` when a translation file changed (`untranslated.txt` must read
  `{}`); {{`rps gen` | `dart run build_runner build -d`}} when a route or generated model changed
- **Test:** `flutter test`
- **Dependencies:** `flutter pub outdated` (report only)
- **Cloud repositories:** {{each private GitHub repository the app pulls in as a git dependency,
  `owner/repo`, comma-separated: the cloud test session needs it attached}}
- **Cloud environment:** {{the claude.ai/code environment with Flutter, by name, for `/pixil:pr`
  to preselect}}
- **Build:** `flutter build apk --debug --flavor {{develop}} -t {{lib/main/main_develop.dart}} {{--dart-define-from-file=app_env/jsonFiles/devEnv.json}}`;
  `flutter build ios --debug --simulator` with the same flavor, target and define
- **Run:** `flutter run -d <id>` with the same flavor, target and define; dev app id `{{com.pixilapps.app.dev}}`
- **Languages:** {{ar (RTL), en}}. Switch on Android: {{the app's language setting}}; on iOS:
  `xcrun simctl launch booted <app id> -AppleLanguages "(ar)"`
- **Large screens:** {{none}}
- **Cross-file:** dependencies registered in {{`lib/core/dependencies/`}}; screens in
  {{`AppRouter`, generated `lib/core/routes/routes.gr.dart`}}
- **Helpers to reuse:** {{the project's own, named from CLAUDE.md: number formatting, padding,
  spacing tokens, palette, database service…}}

## Evidence

Every finding names a file and line and carries evidence: for an Important finding, the path a
real caller, input or user action takes to the failure, or the non-negotiable rule it breaks; for
a Maintainability finding, the duplicated lines, the existing helper or widget, or the rule it
breaks. No evidence, no finding. A problem already on the base branch is **Pre-existing**,
whatever it would otherwise be. The Project › Rules files come first; this file does not repeat
them, it says how a breach is labelled.

## Important — blocks the merge

- A breach of a rule a Project › Rules file marks **NON-NEGOTIABLE** (or must/never). Cite it.
- A token, password or API secret stored outside secure storage (Keychain/Keystore through the
  project's secure storage service): in Hive, `SharedPreferences`, a file, a log line, or
  committed source.
- A hard-coded base URL, push-notification id or other environment value instead of `AppEnv`
  (filled by `--dart-define-from-file`) or the project's equivalent.
- A string shown to users that is hard-coded in a widget, or missing from any language's
  translation file.
- A number shown in an RTL language with Western digits where `CLAUDE.md` requires localized
  digits.
- RTL: `EdgeInsets` with `left`/`right`, `Alignment.centerLeft`/`Right`, `Positioned(left:)`,
  `TextAlign.left`, or a hand-rolled `Directionality.of(context)` where the directional form is
  needed (only when Project › Languages has an RTL language).
- `Platform.isIOS` / `Platform.isAndroid` handling one platform only when the feature ships on both.
- A permission (notifications, exact alarms, location, camera…) requested without handling denial
  and permanent denial.
- A network call on a user-facing path with no failure or offline handling: a repository that
  doesn't return a failure (`Left(Failure)`), a bloc call outside the framework's `apiCall<T>`, a
  second connectivity source.
- An entry event in `initEvents` that is not safe to receive twice (the framework re-sends it when
  the connection comes back).
- Route arguments, deep links, notification payloads or home-widget taps used without validation.
- A controller, `StreamSubscription`, `Timer`, `AnimationController`, `FocusNode` or listener never
  disposed; a `BuildContext` used after an `await` without a `mounted` check, or held in a bloc.
- Stored user data that won't survive an update: a Hive field index reused or a field removed with
  no migration; a bundled database's schema changed without a migration.
- A new bloc, use case, repository or mapper with no test at the mirrored `test/` path, when a
  Project › Rules file requires tests.
- A call to an API endpoint that isn't confirmed ready; a mocked or invented endpoint.
- Behaviour that contradicts the PR's stated intent or its issue.
- Crashes, wrong conditions, race conditions, `emit` after `close`, a `!` on a value that can be
  null at runtime.

## Maintainability — never blocks

Changed code only.

- **Naming:** vague names (`data`, `item`, `res`, `val`) where a domain name exists; names that
  mislead; files named against the feature's existing pattern.
- **Repeated code:** the same widget, formatting, mapping or validation added twice, or re-written
  where a shared one exists (Project › Helpers to reuse, a feature group's shared folder). Never
  extract small one-off logic.
- **Complexity:** a widget or bloc doing several jobs; nesting deeper than early returns need; a
  build method holding logic.
- **Architecture:** business logic in a widget instead of the bloc or a use case; data access
  outside a repository; an import of another feature's internals instead of `lib/core/` or the
  group's shared folder.
- **Performance**, with the reason: `ListView(children:)` over a long list instead of a builder;
  a missing `const`; nested `BlocBuilder`s or a rebuild scope wider than the state it reads;
  `IntrinsicHeight`/`IntrinsicWidth`; an image decoded at full size; a database query run on
  every build.
- **Theme:** a raw `Color`/`Colors.*` or raw size where the project has palette or spacing tokens.
- **Missing states:** a new data read with no loading, empty or error state.
- **Dead code** the analyzer doesn't catch; inconsistent error handling across one flow.

## Nit — at most three per review

Changed lines only, and only when it helps.

## Skip — never report

- Test results, device behaviour, layout on a device: the test runs own these.
- Anything Project › Check catches.
- Formatting, and preferences with no maintainability cost to name.
- A refactor of code the PR does not touch.
- Removing or changing anything a user sees (an element, text, a screen, a state, styling),
  unless it is the fix for a traced Important bug. The UI matches the design on purpose.
- "Dead" code without proof: a search across the source, tests, tools and every translation file
  that finds no caller.
- Generated, vendored and binary files: `*.g.dart`, `*.gr.dart`, `*.freezed.dart`,
  {{the generated localization files}}, `pubspec.lock`, `assets/**`, `ios/Pods/`, `build/`,
  {{vendored packages}}.
- Anything the PR body lists under **Not included**, as intended, or as needing a design decision.

## Examples

1. **Important**
   ```dart
   await prefs.setString('accessToken', token);
   ```
   `SharedPreferences` is a plain plist/XML file; anything with the app's data can read the token.
   Fix: store it through the secure storage service.

2. **Important** (RTL)
   ```dart
   padding: EdgeInsets.only(left: 16),
   ```
   In Arabic the gap lands on the wrong side. Fix: `EdgeInsetsDirectional.only(start: 16)`, or the
   project's padding helper.

3. **Do not flag**
   ```dart
   final isLastPage = page == _kLastPage;
   ```
   One-off logic used once; extracting it adds indirection with no reuse.

4. **Maintainability**
   ```dart
   final label = '$count'.replaceAllMapped(RegExp(r'\d'), (m) => '٠١٢٣٤٥٦٧٨٩'[int.parse(m[0]!)]);
   ```
   Re-writes a digit mapping a shared helper already owns, so the two drift apart. Fix: call the
   helper Project › Helpers to reuse names.

5. **Nit**
   ```dart
   final res = await _repository.getOrder(id); // in a five-line method
   ```
   The name could be clearer; nothing breaks.

## Learned from triage

One line each: what not to flag (or what to flag), and the PR it came from. Added only when the
developer accepts a `/pixil:triage-review` proposal.
