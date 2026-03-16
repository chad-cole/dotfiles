---
name: make-pr
description: Review local changes, run checks, fix issues, and push a draft PR via Graphite. Use when Chad says "make a pr", "push this", "review this and make a pr", "pr this", or anything about submitting current work. Always operates on the current directory and current branch only.
---

# Make a PR

Review local changes in the current directory (`.`), run all checks, fix easy issues, and push a draft PR via Graphite.

## Procedure

### Step 1: Understand the changes

```bash
git diff --stat
git diff
git log --oneline @{upstream}..HEAD 2>/dev/null || git log --oneline -5
```

Read the diffs carefully. Understand what changed and why. If the "why" isn't clear from context, **ask Chad** before writing the PR body.

### Step 2: Detect the project type

Check what's in the current directory to determine backend vs frontend:

- **Ruby/Rails (backend):** Look for `Gemfile`, `*.rb` files in diff, `dev.yml`
- **TypeScript/JavaScript (frontend):** Look for `package.json`, `*.ts`/`*.tsx` files in diff

If the diff contains both, run checks for both.

### Step 3: Run checks

#### Backend (Ruby)
```bash
shadowenv exec -- dev tc        # Typecheck (Sorbet)
shadowenv exec -- dev style     # Lint (RuboCop)
shadowenv exec -- dev test      # Tests
```

#### Frontend (TypeScript/JavaScript)
```bash
shadowenv exec -- yarn type-check   # TypeScript
shadowenv exec -- yarn lint         # ESLint
shadowenv exec -- yarn test         # Tests
```

Run them in order. **Stop and fix** if something fails before moving to the next check.

### Step 4: Fix or ask

- **Easy fixes** (lint violations, type errors with obvious fixes, missing type signatures): fix them, stage the fix, and move on.
- **Big decisions** (test failures that indicate a design problem, ambiguous type errors, conflicting lint rules): **ask Chad** what to do. Don't guess.

If you made fixes, stage them:
```bash
git add -p  # or git add specific files
git commit --amend --no-edit  # amend into the existing commit if it's a single commit
# OR
git commit -m "Fix lint/type issues

Co-authored-by: AI"
```

### Step 5: Write the PR body

Keep it concise but meaningful. Focus on **why**, not just what.

Format:
```markdown
## Why

{1-3 sentences on why this change is needed. What problem does it solve? What does it enable?}

## What

{Brief description of the approach. Bullet points for multiple changes.}

## Tophat

{Steps for a reviewer to manually verify the change. Be specific — what to click, what URL to visit, what command to run, what to expect. If it's a backend-only change, describe how to verify via console, API call, or test.}

## Notes

{Optional: anything a reviewer should know — risk, follow-ups, decisions made.}
```

**Don't:**
- Generate a wall of text
- List every file changed
- Repeat the diff in prose
- Write "This PR..." — just say what it does

**Do:**
- Explain the motivation
- Call out non-obvious decisions
- Mention if something is behind a flag

If you don't know why the change was made, **ask Chad**.

If you don't know how to tophat the change, **ask Chad**. Don't make up verification steps you're not sure about.

### Step 6: Push via Graphite

```bash
gt stack submit --draft
```

If this is a new branch that hasn't been submitted before:
```bash
gt stack submit --draft
```

Graphite will handle creating the PR. If it asks for a title/body interactively, use the title from the commit and the body from Step 5.

If the branch isn't tracked by Graphite yet:
```bash
gt branch track
gt stack submit --draft
```

### Step 7: Confirm

Tell Chad:
- The PR URL
- What checks passed/failed
- Any fixes you made
- Any questions you have

## Important Rules

1. **Always operate on `.` (current directory) and current branch only.** Never switch branches.
2. **Always run checks before pushing.** No exceptions.
3. **Fix easy things silently.** Don't ask about obvious lint/type fixes.
4. **Ask about hard things.** Don't guess on design decisions.
5. **Draft PRs only.** Never push a PR as ready for review.
6. **Use Graphite CLI (`gt`), not `gh pr create`.** Chad uses Graphite for stacking.
7. **Commit messages include `Co-authored-by: AI`** when you made changes.
