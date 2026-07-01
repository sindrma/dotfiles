---
name: resolve-conflicts
description: Use when rebasing onto main, resolving rebase or merge conflicts, recovering from a half-finished rebase, or preparing a branch for force-push after upstream changes — covers worktree-context check, lockfile regeneration vs hand-merge, ours/theirs intent confirmation, and the typecheck+test gate before any force-push.
---

# Resolve Conflicts

Drives "rebase onto main and resolve conflicts" from start to a clean force-push-ready branch. Hard rules: regenerate lockfiles, never hand-merge them; confirm `--ours` vs `--theirs` *intent* in words before running either flag; verify with typecheck + tests before any push.

Works with both the GitHub MCP and the `gh` CLI. MCP is flaky — fall back to `gh` on the first failure without retrying.

The user runs all state-changing `git` (`rebase`, `commit`, `push`, branch-switching `checkout`) themselves. The model edits files, runs read-only git, runs typecheck/tests, and tells the user the next git command to run.

## Pre-flight check

- **Worktree context matches the branch.** `pwd` and `git rev-parse --show-toplevel` agree. Investigating a worktree branch from the main repo masks node_modules leaks and tool-version skew. If they disagree, stop and tell the user.
- **Working tree clean.** `git status` shows no unintended uncommitted changes. If there are, ask.
- **Rebase target current.** Ask the user to `git fetch origin` so the target branch is fresh.

## Workflow

1. **State intent and hand off the rebase command.** Tell the user the exact command (`git rebase origin/main` typically). Wait for them to run it.

2. **At each conflict, classify the file before resolving.**

   | File class | Strategy |
   |---|---|
   | `yarn.lock`, `package-lock.json`, `pnpm-lock.yaml` | Take the rebased-onto version, then **regenerate** from `package.json`. Never hand-merge. |
   | `package.json` | Merge by hand; preserve both sides' added dependencies. For version conflicts, pick the newer compatible version. |
   | Numbered migration files | Renumber if both sides added migrations at the same index. Check migration runner conventions first. |
   | Generated files (`*.gen.*`, `dist/`, snapshots) | Regenerate from source rather than merging. |
   | Source code | Read both sides, understand intent, merge by hand. Run the ours/theirs intent check below before any shortcut flag. |

3. **`--ours` / `--theirs` intent check.** During a **rebase**, `--ours` = the branch you are rebasing *onto* (e.g. `main`), `--theirs` = your feature branch. Opposite of what it feels like, and opposite of merge semantics. Before either flag:
   - Write in plain English which side you want ("I want the version from my feature branch").
   - Translate to the flag. "My branch" during a rebase = `--theirs`.
   - If ambiguous at all, ask the user.

4. **Regenerate lockfiles** after `package.json` is resolved. Tell the user to run `yarn install` / `npm install` / `pnpm install`. Stage the regenerated lockfile.

5. **Run the verification gate.** Once conflicts are resolved and the rebase has finished, the model runs:
   - **Typecheck** (`npm --workspace apps/web run typecheck` or equivalent). Non-negotiable.
   - **Tests** for the affected workspace(s).
   - **Build**, if the rebase touched build config, generated files, or framework upgrades.

   Fix and re-run on failure. Do not suggest force-push until all gates pass.

6. **Force-push, only after explicit confirmation.** Tell the user the branch is ready and to run `git push --force-with-lease`. Never `--force`. For Graphite stacks, use `gt submit` — see `superpowers:graphite-stacked-prs`.

## GitHub MCP vs CLI

For inspecting PR context, prefer MCP when responsive. On first failure, fall back to `gh` and stay there.

| Need | MCP | CLI fallback |
|---|---|---|
| PR base/head branches | `mcp__github__get_pull_request` | `gh pr view <N> --json baseRefName,headRefName` |
| Files changed in PR | `mcp__github__list_pull_request_files` | `gh pr view <N> --json files` |
| CI / reviewer state | `mcp__github__get_pull_request_status` | `gh pr checks <N>` |
| Conflict files in branch | (no direct MCP) | `git diff --name-only --diff-filter=U` |

For the rebase itself, always local `git`. Neither MCP nor `gh` rebases remotely.

## Hand-off to other skills

- **Conflicts resolved on a PR with open review comments** → `addressing-pr-feedback` (verify the rebase didn't undo a review fix before replying).
- **Mid-stack rebase on a Graphite stack** → `graphite-stacked-prs` (use `gt restack`, not raw `git rebase`).

## Red flags

- "I'll just take `--theirs` everywhere to be safe" — no, classify per file class.
- "yarn.lock is small, I can hand-merge" — no, regenerate from `package.json`.
- "Typecheck passed on the last commit, I'll skip it" — no, the merge changed code paths.
- "I'll force-push and let CI catch it" — no, gate runs locally first.
- `--force` instead of `--force-with-lease`.
- Resolving from the main repo when the branch lives in a worktree.
- Running state-changing git on the user's behalf — user runs `rebase` / `commit` / `push` / branch-switching `checkout` themselves.
- More than ~5 conflicting source files without pausing — large conflicts often mean the rebase target or branch base is wrong.
- Retrying a flaky MCP call instead of falling back to `gh`.
