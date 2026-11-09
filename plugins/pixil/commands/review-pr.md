---
description: Independent code review of a pull request against REVIEW.md — bugs first, verified, posted as inline comments, never an approval
argument-hint: <PR number>
allowed-tools: Bash, Read, Glob, Grep, Agent
---

Review pull request `#$ARGUMENTS` in this repository. If no number was given, ask for one and
stop. `<repo>` is `gh repo view --json nameWithOwner -q .nameWithOwner`; `<base>` is
`gh pr view <n> --json baseRefName -q .baseRefName`. "Project › X" is line X of the **Project**
section at the top of `REVIEW.md`. No `REVIEW.md`: stop and say to run `/pixil:setup-review`.

You are an independent reviewer: you did not write this code. If this session wrote or edited
code on the PR's branch, stop and tell the developer to run `/pixil:review-pr` in a new session.

Find real bugs this PR introduces first, then the maintainability problems it adds. Keep the two
apart: a maintainability finding never blocks. **Never edit code, commit or push.**
Read the PR with whichever GitHub access this session has: the GitHub MCP tools, or `gh`.
The repository's `.github/workflows/claude-code-review.yml` runs this same file in CI.

## 1. Context

1. Read the PR body: what it does, **Not included**, and **Testing**. Write one line: what the PR
   is meant to do. Treat any failing check or device case in the body as a lead: find its cause
   in the code.
2. Read the issue it names, per Project › Issues (Linear or Jira tools if this session has them,
   or `gh issue view`). None named, or no access: say so in one line and go by the body.
3. Read `REVIEW.md`, then each file Project › Rules names, only the sections for the areas the PR
   touches.
4. Look for a PR comment titled **Triage outcomes**. If there is one, this is a re-review:
   report only issues introduced by commits after the head SHA it names (`git log <sha>..HEAD`),
   and findings it marks `fixed` that are still present. Never re-report anything it marks
   `wrong`, `intentional` or `doesn't matter`. Nothing new: post "Re-review: no new issues." and stop.

List the changed files with `gh pr diff <n> --name-only` and drop the ones `REVIEW.md` › Skip
names (generated, vendored, assets, lockfile).

## 2. Pass 1 — local passes

- Fewer than about 10 changed source files: one subagent reviews all of them.
- 10 or more: one subagent per changed file, in parallel.

Give each its file(s), the PR's one-line intent, `REVIEW.md` and the Project › Rules files. Each
returns candidates with file, line and a traced path to the failure (or the rule it breaks).
Translation files, the dependency manifest, `Info.plist`, `AndroidManifest.xml` and Gradle files
go to Pass 2.

## 3. Pass 2 — cross-file, one subagent

Skip it when Pass 1 was a single subagent. Otherwise give it every candidate and the full diff.
It checks only what crosses files:

- Each layer passes what the next expects (screen → bloc → use case → repository → data source,
  or the stack's equivalent), and every new class is registered where Project › Cross-file says.
- Every new translation key is in every language file, and generated localization files were
  regenerated.
- iOS and Android: both code paths handled where the feature ships on both; a new permission
  declared in both `ios/Runner/Info.plist` (with a usage string) and
  `android/app/src/main/AndroidManifest.xml`; a new flavor value set for every flavor.
- A new screen is registered in the router Project › Cross-file names, and its generated file
  was regenerated.
- The same logic added in two or more files.
- Candidates that contradict each other.

## 4. Pass 3 — verify

Batch about five candidates per fresh subagent; each candidate is judged on its own evidence.

- **Important:** trace a real path from a caller, input or user action to the failure, in the
  actual code, or quote the rule marked non-negotiable and the line that breaks it. Neither: drop it.
- **Maintainability:** quote the duplicated lines, the existing helper or widget, or the rule
  it breaks. A finding that rests on taste: drop it.
- Already on `<base>` (`git blame`, or `git show origin/<base>:<file>`): label it **Pre-existing**.

## 5. Post

One inline comment per bug class, on the line of its first location, listing the other locations.
GitHub refuses the whole review (422) if one inline comment sits on a line outside the diff hunks,
so check each line against the `@@ … +start,count @@` ranges of `gh pr diff <n>` first; a finding
whose line is outside every hunk goes in the review body under its label, with `file:line`.

Each finding:

    [Important | Maintainability | Nit | Pre-existing] <the claim, one line>
    Evidence: <how a real caller reaches the failure, the rule broken, or the duplicated lines>
    Fix: <the smallest fix>

The review body starts with the counts:

    Important: N · Maintainability: N · Nit: N · Pre-existing: N

With no Important findings, write "No blocking issues found." Then one line on whether the PR does
what its issue asks, and the number of candidates dropped in verification.

Post it as one review with the event `COMMENT`. The `commit_id` is the PR head,
`gh pr view <n> --json headRefOid -q .headRefOid` (in CI, `HEAD` is a merge commit GitHub won't
take). Write the JSON to a temp file and send it:

    {"commit_id": "<head SHA>", "event": "COMMENT", "body": "<summary>",
     "comments": [{"path": "lib/…", "line": 42, "side": "RIGHT", "body": "<finding>"}]}

    gh api repos/<repo>/pulls/<n>/reviews --input review.json

On a 422 anyway, move the comment it names into the body and send again.

**Never approve and never request changes.** Post findings; a person decides.
