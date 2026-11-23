---
description: Ship the current branch — checks locally, push, hand the tests to a cloud session; --finish reads the report, runs the device checks and opens the PR
argument-hint: [--finish]
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Agent
---

Ship the current branch of this repository. `$ARGUMENTS` contains `--finish`: go to **B**.
Otherwise **A**.

This repository's commands are in the **Project** section at the top of `REVIEW.md`. No
`REVIEW.md`, or no Project section: stop and say to run `/pixil:setup-review` first. Below,
`<base>` is its **Base branch**, and "Project › X" is its line X.

Tests run in the cloud session, not here. Don't run Project › Test in this session unless the
developer asks for it in so many words.

## A. Check, push, hand off

1. Stop if the branch is `<base>`, `main` or `master`, or `git status --porcelain` shows changes:
   list them; committing is the developer's call.
2. `git fetch origin <base>`. Note how far behind it the branch is
   (`git rev-list --count HEAD..origin/<base>`); it gets merged in before the merge, not now.
3. Run Project › Check. Any issue: list it and stop. (Flutter: `flutter analyze` is lint and
   typecheck together and must print `No issues found!`.)
4. Run each Project › Generate command whose condition matches the branch's changes
   (`git diff --name-only origin/<base>...HEAD`). Afterwards `git status --porcelain` must stay
   empty, and Flutter's `untranslated.txt` must read `{}`; otherwise a key is missing from one
   language or generated files weren't committed. Say which and stop.
5. If the dependency manifest or lockfile changed, run Project › Dependencies and keep anything
   discontinued or with an advisory for the PR body. Report only; it never blocks.
6. `git push -u origin HEAD`.
7. Hand off. Cloud sessions can't load this plugin, so the test procedure travels in the prompt:
   `${CLAUDE_PLUGIN_ROOT}/cloud-test.md`, a blank line, then `Branch: <branch>. Base: <base>.`
   Add "Run the whole suite." after the base to run every test. The remote isn't on GitHub (cloud
   sessions clone and push only there): skip the hand-off, run Project › Test here, and keep its
   summary for the PR body's **Testing**.

   - **No Project › Cloud repositories:** print this for the developer to run in a second
     terminal, from this repository. It starts a cloud session on the environment picked with
     `/remote-env`, cloned at this branch:

         claude --cloud "$(cat '${CLAUDE_PLUGIN_ROOT}/cloud-test.md')

         Branch: <branch>. Base: <base>."

   - **Project › Cloud repositories names some:** a session reaches only the repositories
     attached to it, and `claude --cloud` attaches one, so a private git dependency would not
     install. Open claude.ai/code with this repository and those attached and the prompt typed
     in; `<environment>` is Project › Cloud environment, or empty when there's none:

         url=$(PIXIL_PROMPT="$(cat '${CLAUDE_PLUGIN_ROOT}/cloud-test.md')

         Branch: <branch>. Base: <base>." \
           PIXIL_REPOS="$(gh repo view --json nameWithOwner -q .nameWithOwner),<Cloud repositories, comma-separated>" \
           PIXIL_ENV='<environment>' \
           python3 -c 'import os, urllib.parse as u; e = os.environ; q = {"repositories": e["PIXIL_REPOS"], "prompt": e["PIXIL_PROMPT"]}; q.update({"environment": e["PIXIL_ENV"]} if e["PIXIL_ENV"] else {}); print("https://claude.ai/code?" + u.urlencode(q, quote_via=u.quote))')
         open "$url" || echo "$url"

     Tell the developer a browser tab opened with the repositories selected and the prompt typed
     in: check the environment is the one with Flutter, and press Enter. `open` failed (not a
     Mac): give them the printed link to open.
8. Stop. Say that `/pixil:pr --finish` comes next, once the cloud session has pushed
   `test-report/<branch>`.

## B. `--finish`: read the report, check on devices, open the PR

1. `git fetch origin "test-report/<branch>"`. Missing: say the cloud report isn't in yet and stop.
   Read it with `git show FETCH_HEAD:TEST-REPORT.md`.
2. Its **Tested SHA** isn't `git rev-parse HEAD`: the report is stale. Say so and stop;
   `/pixil:pr` runs again.
3. Failures, missing tests or **Environment broken**: list them. Fix failures and missing tests
   here, then commit when the developer says so and run `/pixil:pr` again. An environment problem
   is fixed in the cloud environment's settings, not in the code. Stop.
4. Device checks, on this Mac. No Project › Build (not a mobile app): skip to 5.
   Run each Project › Build command. Then run the app per Project › Run on a booted iOS simulator
   and an Android emulator (`flutter devices`). For each screen or flow the branch changed, check
   it in **every Project › Languages entry on both platforms**: layout mirrored for an RTL
   language, localized digits where `CLAUDE.md` asks for them, no overflow stripes, nothing under
   the tab bar, the loading, empty and error states. Switch language as Project › Languages says.
   Screenshot what you check (`xcrun simctl io booted screenshot`, `adb exec-out screencap -p`)
   and look at it. A layout change on a tablet or fold: also Project › Large screens. A new
   tappable: a semantics label and a 48×48 target.
   What you can't reach yourself, give the developer as a checklist and record who checked it.
   Anything still unchecked (a real fold, a flow behind a login) goes under "Still to check".
5. Open the PR, or update it:
   - No PR for the branch yet (`gh pr view --json number` fails): write the body to a file and
     `gh pr create --base <base> --title "<type>: <what it does>" --body-file <file>`.
   - A PR exists (a re-run after triage): replace only its **Testing** section,
     `gh pr edit <n> --body-file <file>`.

   The body: a paragraph naming the issue (Project › Issues) and what the PR does; **Changes**;
   **Not included** (anything deliberate or needing a design decision — the review skips these);
   **Testing** (Check; the cloud report's scope, result and SHA; the builds; the screens checked by
   platform and language, and by whom; still to check); **Dependencies** if the manifest changed.
   End it with `🤖 Generated with [Claude Code](https://claude.com/claude-code)`.
6. The report is in the PR body now: `git push origin --delete "test-report/<branch>"`.
7. Stop with the PR link. The Claude Code Review action reviews a PR when it opens; after
   `/pixil:triage-review` fixes something, the re-review is `/pixil:review-pr <n>` in a new session.
