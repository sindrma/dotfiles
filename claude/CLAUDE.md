# Global preferences

## Git workflow

- **Never push directly to `main`** (or `master`) on any repo. Integration to the main branch always goes through a pull request.
- When finishing a development branch, do not offer "merge locally to main" as an option — present push + PR, keep-as-is, or discard.
- This applies regardless of project, language, or repo conventions.

## Conventional commits

- **Always** use Conventional Commits style for both branches and commit messages, on every repo. This is a standing default — do not ask, and do not defer to per-project conventions.
- **Branches:** `<type>/<desc>` (e.g. `fix/document-details-stale-branches`). No username prefixes. When there's an issue/ticket, include its identifier in `<desc>` (e.g. `fix/lex-678-...`) so trackers auto-link the branch.
- **Commit messages:** `<type>(<scope>)?: <subject>` (e.g. `fix(document-details): exclude inactive conditional branches`). Imperative, lowercase subject, no trailing period.
- Standard types: `feat`, `fix`, `chore`, `docs`, `refactor`, `build`, `test`, `perf`, `ci`, `style`, `revert`.

## Git command execution

- **Main session:** check in with me before running state-changing git — `commit`, `push`, `rebase`, `reset`, `branch -d/-D`, and `checkout` when used to switch branches. Read-only git (`status`, `diff`, `log`, `fetch`, `show`) is unrestricted, and so is workspace setup (`git worktree add` and related). Branch switching specifically: tell me which branch I need and let me switch.
- **Subagents dispatched into a dedicated workspace** can run any git command themselves, including state-changing ones — that's the point of giving them an isolated worktree.

## Commits

- Do **not** commit spec/plan/design documents unless I explicitly ask. Treat them as scratch and let me decide whether they belong in the repo.
- For small refinements to a feature I'm actively working on, **amend into the most recent commit** (`git commit --amend --no-edit`) rather than stacking separate "fix" or "refinement" commits. Create a new commit only when the change is logically separate from the previous one, or when I ask for one. This overrides the default "always create new commits" guidance for me.
- Safety carve-out: if a pre-commit hook fails, the commit did **not** happen — fix the issue, re-stage, and create a NEW commit. Never `--amend` after a hook failure (that would silently modify the prior commit).
- Confirm before force-pushing an amended commit, and always use `--force-with-lease`, never plain `--force`.

## Verification before claiming green

- `lint` doesn't catch missing imports or type errors. Before claiming work is passing, run the project's typecheck (e.g. `npm --workspace apps/web run typecheck`) AND the relevant test command — not just lint.
- For UI work, I verify visually myself — don't spin up dev servers or curl loops to "confirm" the UI unless I ask.

## Multi-step plans

- After approving a written plan with more than ~3 phases, check in after each major phase rather than executing the whole plan in one autonomous run. A one-line "phase N done, moving to N+1" is enough — I just want a chance to redirect.
