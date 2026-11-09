---
description: Answer every /pixil:review-pr finding on a pull request — fix the real bugs, record the rest with a reason
argument-hint: <PR number>
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Agent
---

Triage the review on pull request `#$ARGUMENTS` in this repository. If no number was given, ask
for one and stop. `<owner>/<name>` is `gh repo view --json nameWithOwner -q .nameWithOwner`.
"Project › X" is line X of the **Project** section at the top of `REVIEW.md`.

Read the inline threads and the review summary with the GitHub MCP tools or `gh`. Reviews posted
before `REVIEW.md` existed may use `[BLOCKER]`, `[SHOULD FIX]` and `[NIT]`: read them as
Important, Maintainability and Nit.

List the threads with their ids and first comment:

    gh api graphql -f query='query{repository(owner:"<owner>",name:"<name>"){pullRequest(number:<n>){reviewThreads(first:100){nodes{id isResolved path line comments(first:1){nodes{databaseId body}}}}}}}'

## 1. Decide each finding

- **fixed** — a real bug this PR introduced. Fix it.
- **wrong** — it does not reproduce. Give the traced reason.
- **intentional** — cite the issue (Project › Issues), the PR's **Not included**, or the rule in
  a Project › Rules file that makes it deliberate.
- **doesn't matter** — real, but not worth the code it would add.

## 2. Fix

- Fix Important findings, and Maintainability findings you judge `fixed`; a refactor keeps
  behaviour the same. Fix a Nit only on a line you are already changing.
- **Never remove or change what a user sees on your own judgement**: an element, text or a
  translation key, a screen, a loading, empty or error state, styling. When a fix would, stop and
  show the developer the finding, the change and before/after; make it only on their yes.
- Remove code as dead only after a search across the source, tests, tools and every translation
  file finds no caller.
- Before reporting, read your own diff and revert any visible change the developer didn't approve.
- When a finding names a bug class, fix every instance.
- Leave Pre-existing findings alone; list them for a follow-up.
- Run Project › Check, and each Project › Generate command whose condition your fixes match.
- A fix that touches a screen or a flow is tested again through `/pixil:pr`, which sends the
  tests to the cloud session. Do not run Project › Test or a device here unless the developer asks.
- Commit and push only when the developer says so.

## 3. Record — after the fixes are pushed

The re-review compares the PR head against this record, so it goes up only once every fix is on
GitHub. If no push is approved yet, stop and say the record is waiting on it.

- Reply on each thread with its outcome in one line, then resolve it:

      gh api repos/<owner>/<name>/pulls/<n>/comments/<databaseId>/replies -f body='<outcome>'
      gh api graphql -f query='mutation{resolveReviewThread(input:{threadId:"<id>"}){thread{isResolved}}}'

  (or the GitHub MCP tools, if this session has them).
- Post one PR comment titled **Triage outcomes**: the pushed head SHA it covers
  (`git rev-parse HEAD`, after the push), then a table of finding, label, outcome, and reason or
  commit. Write it to a file and post it with `gh pr comment <n> --body-file <file>`.
- For each `wrong` or `intentional` finding that could come up again, propose one line for
  `REVIEW.md`'s **Learned from triage**, with the PR number. Add it only on the developer's yes.

## 4. Stop

Report the counts per outcome and every user-visible change made with approval. If a fix touched
a screen or a flow, say the next step is `/pixil:pr`, then `/pixil:review-pr <n>` in a new
session. On the third round with Important findings still open, say the approach needs a
person's look.
