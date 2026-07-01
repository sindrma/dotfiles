---
name: addressing-pr-feedback
description: Use when addressing PR review comments — fetches the latest review (not the full history), enumerates each unresolved comment as a checklist, drafts evidence-based pushback when reviewers are wrong, verifies typecheck+tests locally before replying, and posts a reply per comment.
---

# Addressing PR Review Comments

Drives PR-review-comment work from "fetch" to "everything green and replied." No missed comments, no broken CI, no premature "done," and no re-litigating resolved threads.

Works with both the GitHub MCP server and the `gh` CLI. MCP is flaky — fall back to `gh` on the first failure without retrying.

## Checklist

1. **Fetch the LATEST review only.** Default scope is "the most recent review" (e.g. the latest CodeRabbit pass) or "comments since the last push" — not every comment ever left. Filter out resolved threads.

   | Need | MCP (preferred) | CLI fallback |
   |---|---|---|
   | Reviews on the PR | `mcp__github__list_pull_request_reviews` (take latest by submitter) | `gh api repos/<owner>/<repo>/pulls/<N>/reviews` |
   | Inline review comments | `mcp__github__get_pull_request_comments` | `gh api repos/<owner>/<repo>/pulls/<N>/comments` |
   | Thread resolution state | (via review-thread API) | `gh api graphql` filtering by `isResolved` |

   Combine the remaining unresolved items into one numbered list with file:line for each. Every distinct ask is its own line. This is the raw list — do not present it yet; first draft a planned fix for each (step 2).

2. **Draft a planned fix for every comment, then present the plan.** For each item: read the cited file:line and research before deciding. If the comment looks wrong, grep for prior convention, check actual types / runtime behaviour, and read related tests before complying.
   - Write a concrete planned fix on each line — either **comply** ("extract X into a helper", "guard null at foo.ts:42") or **push back** ("convention already does Y — bar.ts:88", with file:line evidence).
   - Present the numbered list as `file:line — the ask — planned fix` to the user before touching code. Never silently drop a comment; a duplicate or no-op still gets a line ("duplicate of #3").

3. **Wait for the user to approve the plan and pick scope.** Show the planned-fix list and let them edit a fix, kill a draft, or say which to address (or "all"). Do not edit code until they confirm.

4. **Execute each approved fix — comply or push back, never silently drop.**
   - Make the change, or finalize the pushback reply with its file:line evidence.
   - Note which existing commit the fix lands in. **Default: amend into the feature commit** that introduced the file/feature. Only new-commit when logically separate.
   - **Never commit scratch files** (spec drafts, plan notes, thinking docs).

5. **Verify locally before reporting back.**
   - Run typecheck (e.g. `npm --workspace apps/web run typecheck`) — lint alone misses missing imports.
   - Run tests for the affected workspace(s).
   - Both must pass before suggesting push or reply.

6. **Hand the commit / push to the user.** Suggest `git commit --amend --no-edit` (default) or a new commit message (logically separate). Then `git push --force-with-lease` — never `--force`. For mid-stack PRs, hand off to `superpowers:graphite-stacked-prs` (`gt submit`).

7. **Draft all replies, show them to the user, wait for approval before posting.** Replies go on the public PR; once they're up they shape the reviewer's read of your work. Treat them like a push — never post without an explicit go-ahead.
   - Draft one reply per unresolved thread (the fix landed, or the pushback evidence, or "duplicate of thread X" — never silently drop).
   - Present them all in the chat first, grouped by file:line and comment id, so the user can edit wording or kill drafts before they go out.
   - Only after approval, post each via the per-comment reply endpoint:
     - MCP: review-comment reply tool with `in_reply_to` — pass the body as a normal string arg (no shell, no quoting risk).
     - CLI: **always pipe the body via a quoted heredoc** so apostrophes, quotes, and `$` survive verbatim — never inline `-f body='...'`:
       ```bash
       gh api -X POST repos/<owner>/<repo>/pulls/comments/<id>/replies -F body=@- <<'EOF'
       <reply text — apostrophes, "quotes", $vars all literal and safe>
       EOF
       ```
   - Avoid `gh pr comment` for inline-thread replies — it posts a top-level comment, not a thread reply.

8. **Verify CI is green.** `gh pr checks <N> --watch`. If checks fail, treat each failure as a new comment and loop back to step 2 (plan the fix). Done = every item replied AND CI green.

## When a rebase is needed first

If addressing the review requires rebasing onto a moved `main`, hand off to `resolve-conflicts` before starting the comment loop. Finish the rebase cleanly, push, then begin step 1 on the rebased branch.

## Red flags

- "Let me grab all the PR comments" — no, latest review / unresolved only.
- "I'll just fix the obvious ones first" — no, plan a fix for every comment first, then wait for approval on the plan.
- Presenting the comment list without a concrete planned fix per line — each line needs a comply/push-back plan before the user approves scope.
- "Lint is green so we're good" — no, typecheck is the gate.
- "Tests pass in my head" — no, run them.
- "I'll batch the replies later" — no, reply per comment so threads can be resolved.
- Posting a reply before the user has seen and approved the draft — replies are public; show first, post after.
- Inlining reply text with `-f body='...'` — apostrophes get eaten; pipe the body through a quoted heredoc (`-F body=@- <<'EOF'`).
- Skipping a comment as a duplicate — say so in the reply, don't silently drop.
- Complying with a reviewer claim that contradicts established convention without checking — research first.
- New commit for a one-line refinement to the feature commit — default is amend.
- Committing scratch / plan / spec docs alongside the fix.
- Retrying a flaky MCP call instead of falling back to `gh`.
- Declaring done before `gh pr checks <N>` shows green.
