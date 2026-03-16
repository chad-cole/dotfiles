---
name: note
description: Create an atomic note (Zettelkasten-style) as a GitHub issue in Chad's PKM project board. Use when Chad says "make a note", "note this", "remember this", "add to backlog", or wants to capture an idea, observation, or task for later.
---

# Atomic Note (Zettelkasten)

Create a single atomic note as a GitHub issue and add it to Chad's Personal Knowledge Management project board in the Backlog column.

## Zettelkasten Principles (Sönke Ahrens — How to Take Smart Notes)

1. **One idea per note.** Each note captures exactly one concept, observation, or insight. If there are two ideas, make two notes.
2. **Write in your own words.** Never copy-paste. The act of rephrasing is what creates understanding.
3. **Make it self-contained.** A reader (future Chad) should understand the note without needing the original context. Include enough background.
4. **Connect to what exists.** Reference related notes, issues, code, or concepts. The value of a note is in its connections.
5. **Write for your future self.** Not a reminder — a complete thought. "Why" matters more than "what".

## Note Format

### Title
- Short, specific, declarative
- States the insight or concept, not just the topic
- Good: "PKCE prevents auth code interception by binding verifier to challenge"
- Bad: "PKCE notes" or "OAuth stuff"

### Body
```markdown
{One or two paragraphs explaining the idea in your own words}

## Context
{Where this came from — conversation, code review, RFC, incident, etc.}

## Connections
- Related to #{issue_number} — {brief explanation of relationship}
- See also: {link to code, doc, RFC, or external resource}
- Tags: {comma-separated keywords for discoverability}
```

## Procedure

### Step 1: Distill the idea

From whatever Chad said, extract the single atomic idea. If there are multiple ideas, create multiple notes (ask Chad first).

Rewrite in clear, self-contained language. Add context so it makes sense in 6 months.

### Step 2: Create the issue

```bash
gh issue create \
  --repo chad-cole/pkm \
  --title "<declarative title>" \
  --body "<formatted body>"
```

### Step 3: Add to the project board

Get the issue node ID and add it to the project:

```bash
# Get the issue node ID (from the URL returned by gh issue create)
ISSUE_ID=$(gh api graphql -f query='
{
  repository(owner: "chad-cole", name: "pkm") {
    issue(number: ISSUE_NUM) { id }
  }
}' --jq '.data.repository.issue.id')

# Add to project
ITEM_ID=$(gh api graphql -f query="
mutation {
  addProjectV2ItemById(input: {
    projectId: \"PVT_kwHOA2lj6M4BK40B\"
    contentId: \"$ISSUE_ID\"
  }) {
    item { id }
  }
}" --jq '.data.addProjectV2ItemById.item.id')

# Set status to Backlog
gh api graphql -f query="
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: \"PVT_kwHOA2lj6M4BK40B\"
    itemId: \"$ITEM_ID\"
    fieldId: \"PVTSSF_lAHOA2lj6M4BK40Bzg6n_xY\"
    value: { singleSelectOptionId: \"8b413dcf\" }
  }) {
    projectV2Item { id }
  }
}"
```

### Step 4: Confirm

Tell Chad:
- The note title
- The issue URL
- That it's in the Backlog column
- Any connections you identified to existing notes or work

## Project Board Reference

| Field | Value |
|-------|-------|
| Project ID | `PVT_kwHOA2lj6M4BK40B` |
| Status Field ID | `PVTSSF_lAHOA2lj6M4BK40Bzg6n_xY` |
| Backlog Option ID | `8b413dcf` |
| Todo Option ID | `f75ad846` |
| In Progress Option ID | `47fc9ee4` |
| Done Option ID | `98236657` |
| To Read Option ID | `c8eb6287` |
| Writing Ideas Option ID | `8aee8467` |
| Blocked Option ID | `2656153d` |
| Repo | `chad-cole/pkm` |
| Board URL | https://github.com/users/chad-cole/projects/6/views/1 |

## Status Selection Guide

- **Backlog** — default for new notes (ideas, observations, captured thoughts)
- **Todo** — note requires action (a task disguised as a note)
- **To Read** — note is about something to read later
- **Writing Ideas** — note seeds a blog post, doc, or presentation
- **In Progress** — actively being worked on
