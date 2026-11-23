---
description: Set up this repository for the pixil PR flow — REVIEW.md with its Project section, the CI review, the plugin in project settings
allowed-tools: Bash, Read, Edit, Write, Glob, Grep
---

Set up this repository for `/pixil:pr`, `/pixil:review-pr` and `/pixil:triage-review`. Work on
the current branch; **never commit or push**. End by showing the developer what changed.

## 1. `REVIEW.md`

- Exists with a **Project** section: leave it alone, say so, go to 2.
- Exists without one: add the Project section from `${CLAUDE_PLUGIN_ROOT}/templates/REVIEW.md`
  at the top, and leave the rest.
- Missing: start from `${CLAUDE_PLUGIN_ROOT}/templates/REVIEW.md`.

Fill every `{{…}}` from the repository; never guess. A value you can't find becomes `TODO` with
what you looked for.

- **Base branch:** `develop` if `origin/develop` exists, else the default branch
  (`gh repo view --json defaultBranchRef -q .defaultBranchRef.name`).
- **Issues:** the key pattern in `git log --oneline -50` and `gh pr list --state all -L 20`
  (`PXL-123` → Linear or Jira `PXL-####`; `#12` → GitHub issues).
- **Rules:** `.specify/memory/constitution.md` if it exists, and `CLAUDE.md`.
- **Install, Check, Generate, Test, Dependencies:** the template's Flutter lines; `flutter gen-l10n`
  only if `l10n.yaml` exists; `rps gen` if `pubspec.yaml` has a `scripts:` entry `gen`, else
  `dart run build_runner build -d` if `build_runner` is a dependency. Not Flutter: the matching
  `package.json` scripts, Gradle tasks or Xcode scheme, and the template's Flutter-only lines go.
- **Build, Run:** the develop (or development) entry point under `lib/` (`main_develop.dart`), the
  flavor name from `android/app/build.gradle*` `productFlavors`, `--dart-define-from-file` with
  the dev JSON if `app_env/` has one, the dev app id for that flavor (Gradle
  `applicationIdSuffix` / `applicationId`, `PRODUCT_BUNDLE_IDENTIFIER` in
  `ios/Runner.xcodeproj/project.pbxproj`). Not a mobile app: drop Build, Run, Languages and Large
  screens.
- **Languages:** the locales of the translation files (`*.arb`); mark ar, he, fa and ur as RTL.
  How to switch language on Android: from `CLAUDE.md` or the settings feature; else `TODO`.
- **Large screens:** `rps dev-lab` if `pubspec.yaml` has that script, else `none`.
- **Cloud repositories:** every `git:` dependency in `pubspec.yaml` whose URL is on `github.com`,
  as `owner/repo`. None: drop the line.
- **Cloud environment:** the environment's name if the developer gives it. Otherwise drop the
  line; the browser then picks the environment, and the developer checks it before sending.
- **Cross-file:** the folder where dependencies are registered (`get_it`/`injectable` setup), the
  router class and its generated file.
- **Helpers to reuse:** the shared helpers `CLAUDE.md` tells people to use (number formatting,
  padding, spacing, palette, database), by name and path.
- **Skip › Generated:** the generated localization output and any vendored package folders.

Then make the criteria fit the repository: replace the template's generic wording with this
repository's names where `CLAUDE.md` gives them (its secure storage service, its env class, its
RTL and numeral rules), drop lines for things the repository doesn't have (no RTL language → the
RTL lines go; no `initEvents` → that line goes), and cite rule numbers when Rules has a
constitution. Keep it short: a line the repository can't break is noise.

## 2. CI review

- Not a GitHub repository (`gh repo view` fails): skip, and say the review runs only as
  `/pixil:review-pr` locally and its posting step needs GitHub.
- `.github/workflows/claude-code-review.yml` missing: copy
  `${CLAUDE_PLUGIN_ROOT}/templates/claude-code-review.yml`.
- It exists: show the developer how it differs from the template and ask before replacing it.
  Keep any test or build job it has; only the review job follows the template.
- The review action runs only a workflow file identical to the default branch's copy. When the
  base branch isn't the default branch (`develop` vs `main`), tell the developer the same file
  must also land on the default branch, in a one-file PR, or the review skips itself.

## 3. `.claude/settings.json`

Merge these in and keep everything else in the file, so teammates who trust the folder get the
plugin:

    "extraKnownMarketplaces": {
      "pixil": { "source": { "source": "github", "repo": "pixilapps/claude-plugins" } }
    },
    "enabledPlugins": { "pixil@pixil": true }

## 4. `CLAUDE.md`

No mention of `/pixil:pr` yet: add a short **Pull Requests** section:

    PR flow: `/pixil:pr` → cloud tests → `/pixil:pr --finish` → review (CI on open, or
    `/pixil:review-pr <n>` in a new session) → `/pixil:triage-review <n>`. Criteria and this
    repo's commands: `REVIEW.md`. Cloud sessions test but never fix; builds and screen checks run
    on a Mac in `/pixil:pr --finish`.

## 5. Report

`git status --short`, every `TODO` left in `REVIEW.md`, and what's still needed outside the
repository: the `CLAUDE_CODE_OAUTH_TOKEN` and `PIXIL_FRAMEWORK_TOKEN` Actions secrets on this
repository (`gh secret list` shows which are missing; org secrets don't reach private repositories
on GitHub Free), and the cloud environment (once per person, not per repository).
