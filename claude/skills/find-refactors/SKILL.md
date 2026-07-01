---
name: find-refactors
description: Use when reviewing a branch or PR for refactor and structural-quality opportunities — especially before merging code that may become shared, when running `/find-refactors`, when running `/loop /find-refactors`, or when concerned about hasty abstractions, business logic leaking into would-be shared components, or duplication that has been growing.
---

# Find Refactors

Splits "find refactors in this PR" into parallel category-owned subagent reviews, then synthesises one report. The bar to suggest abstraction is **deliberately high**. Two similar lines is not duplication; three is the floor, not the target. Rejecting a hasty abstraction is a successful finding.

## Inputs

- **Default:** current branch diff vs main (`git diff main...HEAD`), plus immediately surrounding files for context.
- **Optional arg:** a PR number (e.g. `/find-refactors 524`). Resolve with `gh pr view <N> --json baseRefName,headRefName,files`.

## Severity rubric (biased against churn)

| Tier | Meaning |
|------|---------|
| **critical** | Architectural mistake that will compound: business logic baked into a component destined to become shared; sibling state in two components that must agree; new code added to a shared library with leaky internals or feature-specific assumptions. |
| **high** | Concrete Rule-of-Three+ duplication with identical *intent* (not just shape) that has already caused a bug or near-miss; or a missing extraction where each new caller pays ≥30 lines of boilerplate. |
| **medium** | Locality issues — code in the wrong file/module, hook that should be extracted from a fat component, props that should be context, helper buried in an unrelated file. |
| **low** | Naming, ordering, consistency. Only worth doing if you're already touching that line. |

**Anti-pattern guard for "critical":** if your fix is "extract a generic `<X>Provider` / `<X>Manager` / `<X>Helper`" and the third real caller does not yet exist, you have over-abstracted. Downgrade or drop.

## Workflow

1. **Resolve scope.** Get the diff range and stats. Flag files under `components/`, `shared/`, `lib/`, or with generic names — these are the "may become shared" hot spots driving the state-lifting check.

2. **Run `fallow` if available.** Try `fallow --help` (and `npx fallow --help` as fallback). TS/JS codebase intelligence (https://fallow.tools/) that corroborates duplication and dead-code findings. If absent, note once at the top of the report ("`fallow` not available — prioritised by hand") and proceed.

3. **Fan out one subagent per category, in parallel.** Each gets the diff range, the rubric verbatim, the full category list with **its own category bolded**, the anti-pattern guard, and "stay in your lane — surface findings outside your lane only if critical." Forbid stream-of-thought. Categories:

   - **State location / lifting (React)** — local component state another component also needs; props drilled deeper than 2 levels; business logic written inside a component that lives or could plausibly live in `components/` or a shared lib. For each touched component, ask: does another component read/write this state? Is this component shaped to be reused (lives under `components/`, generic name, ≥2 existing callers)? Is feature-specific business logic baked into a presentational shell? If yes to any, the fix is to **lift state up** to the nearest common ancestor *before* the component is reused — not to "make the prop optional."
   - **Duplication** — Rule-of-Three+ across the diff AND adjacent files. *Intent* must be identical, not just shape.
   - **Module/file locality** — code in the wrong place; private helpers exposed; cross-layer leaks (HTTP reaching into DB, etc.).
   - **Naming & API shape** — confusing names, asymmetric verbs (`fetch` vs `get`), bool-bag options, generic suffixes (`*Helper`, `*Util`, `*Manager`).
   - **Dead / redundant** — unreachable branches, redundant guards, dead exports, commented-out code.

4. **Verify each proposal.** Drop or rule out if any of these fail:
   - **Duplication is semantic** (same intent, evolves together) — not just look-alike shape.
   - **A second real caller exists today** — not hypothetical. Hypothetical → drop or downgrade to medium.
   - **Abstraction shape is sound** — no bool-bag params (`{ withX, withY, asZ }`), no generic suffix names.
   - **Cost is net negative** — proposed refactor adds fewer lines than the duplication it removes.

   Be generous with ruling out — most "DRY this" suggestions belong there.

5. **Re-bucket severity using the rubric.** Apply the anti-pattern guard to anything marked critical.

6. **Write the final report.** Exactly this shape:

   ```
   # Refactor review — <branch> vs <base>
   <fallow availability note>

   ## Critical
   1. **<one-line claim>** — `path/to/file.ts:LINE` (+ duplicate locations if any)
      Cost: <what is bad about the current shape, concretely>
      Move: <what the refactor looks like, concretely — not "extract">

   ## High
   …

   ## Medium
   …

   ## Low
   …

   ## Ruled out
   - "<original claim>" — <reason: look-alike not semantic / single caller / hasty abstraction / cost > benefit>
   ```

   No fixes-as-diffs. No commentary. No "let me check…". If a tier is empty, write `_none_`.

## Loop integration

`/loop /find-refactors` re-runs until you stop it. The pairing:

1. Run → report.
2. Apply Critical + High.
3. Re-run. When Critical and High both read `_none_`, the loop's goal is met.

One-shot by design. Reviewing intermediate refactors between iterations is the whole point — refactor loops are where churn hides.

## Red flags

- "Extract a `<X>Provider` / `<X>Manager`" before two real callers exist — drop.
- "DRY this" with only two occurrences — Rule of Three minimum.
- Refactor that adds a `*Options` / `*Config` bag with >2 boolean flags — hasty.
- Shared component with feature-specific business logic baked in — lift state instead, do not "make the prop optional".
- "Make this more flexible / generic" without naming a concrete second use — drop.
- Bug-shaped findings ("this throws on null") — move to `/find-bugs`.
- Stream-of-thought leaking into the report — strip.
- Skipping **Ruled out** — keep it; rejected abstractions are the most useful artefact.
