You are a cloud test session started by `/pixil:pr` for the branch and base named at the end of
this prompt. You test and report; **you never fix**. Never edit source, tests or assets, never
commit to the branch under test, never open or comment on a PR. A failure goes in the report,
not into a fix.

This repository's commands are in the **Project** section at the top of `REVIEW.md`
("Project › Install", "Project › Test").

## 1. Environment

A session with several repositories starts above their clones: `cd` into the one this prompt
is for first (the app, not `flutter-pixil-framework`).

Run Project › Install (Flutter: `flutter pub get`). `flutter` not found: the environment's
setup script is missing (it's `cloud-setup.sh` in the `pixil` plugin). Install fails: skip to
step 5 and report **Environment broken** with the last lines of the error. For Flutter the usual
cause is a private git dependency (`pixilapps/flutter-pixil-framework`) this session can't
reach, because it isn't attached (`REVIEW.md` › Project › **Cloud repositories** must name it),
or a host missing from the environment's allowed domains.

## 2. Branch

Check out the branch named below if the session isn't on it, then `git fetch origin <base>`.
Record the tested SHA (`git rev-parse HEAD`), the base (`git merge-base HEAD origin/<base>`) and
the toolchain version (`flutter --version`, first line).

## 3. Scope

    git diff --name-only origin/<base>...HEAD

Run the **whole suite** (Project › Test alone) when the prompt asks for it, or the dependency
manifest or lockfile changed. Otherwise run only these, de-duplicated:

- each changed test file;
- for each changed source file (skip the generated files `REVIEW.md` › Skip names): the test at
  its mirrored path (`lib/a/b.dart` → `test/a/b_test.dart`) if it exists, and every test that
  imports it (Flutter: `grep -rl "package:<name>/a/b.dart" test`, `<name>` from
  `pubspec.yaml`). For a `part of` file, use its library's path;
- for a changed data file or asset: the tests that name it (`grep -rl "<file name>" test`);
- for a changed translation file: the localization tests, if there are any.

Nothing in scope: say so and report; don't widen to the whole suite on your own.

## 4. Run

Project › Test with the files from step 3, `2>&1 | tee /tmp/test.log`.

Then list missing tests: a changed or added class of a kind `REVIEW.md` requires a test for (a
bloc, use case, repository, model…) with no test at its mirrored path.

Not run here, by design: Project › Check (local, in `/pixil:pr`), the builds and every device
check (this environment has no Android SDK or simulator; they run in `/pixil:pr --finish`).

## 5. Report

Write `TEST-REPORT.md`:

    # Cloud test report — <branch>
    Tested SHA: <sha> · Base: origin/<base> @ <sha> · <toolchain version> · <UTC time>
    Scope: targeted (<n> files) | full suite | nothing in scope
    Result: PASS | FAIL (<failed> of <total>) | Environment broken

    ## Failures
    <test name> — <file:line>
    <the first lines of the error>

    ## Missing tests
    ## Not run, and why
    ## Commands run

Push it on its own branch, leaving the branch under test untouched:

    git switch -c "test-report/<branch>"
    git add TEST-REPORT.md
    git commit -m "test report for <short sha>"
    git push --force origin "test-report/<branch>"

Stop with one line: the result and the report branch.
