# Pixil Claude Code plugins

One plugin, `pixil`, with the PR flow every Pixil repository uses:

| Command | What it does |
|---|---|
| `/pixil:setup-review` | Once per repository: writes `REVIEW.md` (criteria + a **Project** section with that repo's commands), the CI review workflow, and the plugin in `.claude/settings.json`. |
| `/pixil:pr` | Check and generate locally, push, start the cloud session that runs the tests. |
| `/pixil:pr --finish` | Read the cloud test report, build, check screens on simulator and emulator, open the PR. |
| `/pixil:review-pr <n>` | Independent review in a new session; posts one review, never approves. CI runs the same file when a PR opens. |
| `/pixil:triage-review <n>` | Fix or answer every finding, resolve the threads, post the Triage outcomes record. |

## Install (once per person)

    claude plugin marketplace add pixilapps/claude-plugins
    claude plugin install pixil@pixil

Private repository: git on your machine needs a stored credential for GitHub
(`gh auth login && gh auth setup-git`). Repositories set up with `/pixil:setup-review` also offer
the plugin to anyone who trusts the folder.

Updates: `claude plugin marketplace update pixil`, or turn on auto-update for `pixil` under
**Marketplaces** in `/plugin`.

## Cloud environment (once per person)

Cloud sessions don't load plugins, so `/pixil:pr` sends `cloud-test.md` as the session's prompt.
At claude.ai/code → environment menu → new environment:

- **Setup script:** paste `plugins/pixil/cloud-setup.sh` (Flutter; keep its version in step with
  the team's Macs).
- **Network:** Limited, with package managers allowed, plus `github.com`,
  `storage.googleapis.com`, `pub.dev`, `pub.dartlang.org`.

Then `/remote-env` in your terminal and pick it. One environment serves every repository.

A session reaches only the GitHub repositories attached to it, and `claude --cloud` attaches one.
So a repository with a private git dependency (`pixilapps/flutter-pixil-framework`) names it in
`REVIEW.md` › Project › **Cloud repositories**. `/pixil:pr` then opens claude.ai/code with all of
them attached and the test prompt typed in; check the environment and press Enter. Name the
environment in **Cloud environment** and it's preselected too. Without the line, `/pixil:pr`
prints a `claude --cloud` command as before.

## CI (once per repository)

Two Actions secrets on each repository: `CLAUDE_CODE_OAUTH_TOKEN` (`claude setup-token`), and
`PIXIL_FRAMEWORK_TOKEN`, a token that can read `pixilapps/claude-plugins` (the workflow checks
the plugin out with it). The org is on GitHub Free, where private repositories get organization
secrets empty, so set them per repository:

    gh secret set CLAUDE_CODE_OAUTH_TOKEN -R pixilapps/<repo>
    gh secret set PIXIL_FRAMEWORK_TOKEN -R pixilapps/<repo>

## Changing the flow

Edit the command files here, bump nothing (no `version` is set, so installs track commits), push.
Per-repository tuning belongs in that repository's `REVIEW.md`, not here.
