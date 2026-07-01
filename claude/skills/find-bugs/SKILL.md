---
name: find-bugs
description: Use when reviewing a branch or PR for bugs before requesting review or merge — especially when wanting a thorough multi-lens pass beyond an eyeball review, when running `/find-bugs`, when running `/loop /find-bugs`, or when driving toward "no critical or high bugs remaining" as a merge gate.
---

# Find Bugs

Splits "find bugs in this PR" into parallel category-owned subagent reviews, then synthesises one verified report. Hard rules: every claim cites file:line, every severity matches the rubric, every finding survives a re-read of the actual code before it lands in the report.

## Inputs

- **Default:** current branch diff vs main (`git diff main...HEAD`).
- **Optional arg:** a PR number (e.g. `/find-bugs 524`). Resolve with `gh pr view <N> --json baseRefName,headRefName,files` and diff against `baseRefName`.

## Severity rubric

| Tier | Meaning | Calibration |
|------|---------|-------------|
| **critical** | Data loss, security breach, prod crash, money/legal risk | One sentence: "this loses data / leaks secrets / crashes prod / breaks the law." If you cannot write that sentence, it is not critical. |
| **high** | Wrong behaviour for normal user actions, hidden corruption within a session, persistent regression | Would block merge if the reviewer noticed it. |
| **medium** | Wrong behaviour under edge cases, missing validation, error UX swallowed | Would land a "please fix before merge" review comment. |
| **low** | Cosmetic, dead code, minor a11y, unclear copy | Worth mentioning, not worth blocking on. |

## Workflow

1. **Resolve scope.** Get the diff range and a size estimate (`git diff <base>...HEAD --stat`). If the diff is empty, stop.

2. **Fan out one subagent per category, in parallel.** Always cover these lenses; combine adjacent ones only on tiny diffs:
   - logic / correctness / state machine
   - concurrency / async / race conditions / stale closures
   - security / injection / auth / secrets / prompt injection
   - type safety / null & undefined / contract drift
   - error handling / failure modes / retries / observability
   - data integrity / DB / migrations / transactions
   - performance & accessibility (combined — both touch user-perceived UX)

   Each subagent gets: the diff range, the rubric verbatim, the full category list with **its own category bolded**, and "stay in your lane — surface findings outside your lane only if critical, otherwise drop." Return a flat list with file:line, one-line claim, 2–3 sentence rationale, proposed tier. **Forbid stream-of-thought.**

3. **Verify every claim against the actual code.** Open the files. Read the lines. Trace call paths. For each finding:
   - Does this path actually execute under the conditions claimed?
   - Does an upstream type, framework guarantee, or DB constraint already prevent it?
   - Is there an existing test that proves the opposite?

   Anything unsubstantiated goes to **Ruled out** with the reason. Speculative claims ("likely…", "could possibly…", unverified "dead code" / "unreachable" assertions) rule out by default.

4. **Re-bucket severity using the rubric, not the subagent's vote.** Subagents over-rank. Apply the one-sentence calibration test for "critical." Downgrade if it doesn't pass.

5. **Write the final report.** Exactly this shape:

   ```
   # Bug review — <branch> vs <base>

   ## Critical
   1. **<one-line claim>** — `path/to/file.ts:LINE`
      <2–3 sentence rationale: trigger and user impact. No fix.>

   ## High
   …

   ## Medium
   …

   ## Low
   …

   ## Ruled out
   - "<original claim>" — <reason it doesn't hold, with file:line evidence>
   ```

   No fixes. No commentary. No "let me check…". If a tier is empty, write `_none_`.

## Loop integration

`/loop /find-bugs` re-runs until you stop it. The pairing:

1. Run → report.
2. Fix Critical + High.
3. Re-run. When Critical and High both read `_none_`, the goal is met.

One-shot by design — does not self-loop or auto-fix. Reviewing the fixes between iterations is the whole point.

## Red flags

- Single-pass review with no fan-out — re-dispatch.
- Trusting the subagent's severity — apply the rubric yourself.
- A "critical" finding without a one-sentence user-impact summary — downgrade.
- Speculative / unverified claims ("likely a race", "X is dead code", "could be exploited" without naming the attack vector) — verify against the code or rule out.
- Refactor / naming nits — drop or move to `/find-refactors`.
- Stream-of-thought leaking into the report — strip.
- Skipping the **Ruled out** section — keep it; the negative evidence is valuable.
