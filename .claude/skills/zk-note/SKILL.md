---
name: zk-note
description: Save or retrieve notes from the user's ~/zk-notes vault. Folders: etg (work findings), ideas, journal. Use when the user wants to save a note, log a finding, capture an idea, write a journal entry, search notes, find a note by keyword or tag, or says "add to zk-notes" / "save this note" / "find notes about X" / "search my notes".
---

# ZK Note

Save and retrieve Zettelkasten notes from `~/zk-notes` using the `zk` CLI.

Always prefix every `zk` command with `ZK_NOTEBOOK_DIR=~/zk-notes`.

## Save a Note

### Workflow

1. **Ask** which folder: `etg`, `ideas`, or `journal` (use AskUserQuestion if not obvious from context)
2. For **etg / ideas**: ask for title and tags (tags optional)
3. For **journal**: no prompts — use today's date
4. **Create** the note with `zk new` and capture the path via `--print-path`
5. If tags were provided, edit `tags: []` → `tags: [tag1, tag2]` in the file
6. If the user provided content, append it after the frontmatter
7. Confirm the file path to the user

### Commands

**etg:**
```
ZK_NOTEBOOK_DIR=~/zk-notes zk new --no-input --print-path --group etg --title "TITLE" ~/zk-notes/etg
```

**ideas:**
```
ZK_NOTEBOOK_DIR=~/zk-notes zk new --no-input --print-path --title "TITLE" ~/zk-notes/ideas
```

**journal:**
```
ZK_NOTEBOOK_DIR=~/zk-notes zk new --no-input --print-path ~/zk-notes/journal
```

### Save Rules

- **Never write files manually or generate slugs** — always use `zk new`; it handles slug generation, templates, and date formatting
- Tags: edit `tags: []` → `tags: [tag1, tag2]` — bare words, no quotes
- For journal: if today's file already exists, `zk new` may create a duplicate — check first with `ls ~/zk-notes/journal/$(date +%Y-%m-%d).md`; if it exists, append to it instead

---

## Retrieve Notes

### Search by keyword (full-text search)

```
ZK_NOTEBOOK_DIR=~/zk-notes zk list --match "KEYWORD" --format short
```

### Filter by tag

```
ZK_NOTEBOOK_DIR=~/zk-notes zk list --tag "TAG" --format short
```

### List recent notes (across all folders)

```
ZK_NOTEBOOK_DIR=~/zk-notes zk list --sort created- --limit 10 --format short
```

### List notes in a specific folder

```
ZK_NOTEBOOK_DIR=~/zk-notes zk list ~/zk-notes/etg --sort created- --format short
ZK_NOTEBOOK_DIR=~/zk-notes zk list ~/zk-notes/ideas --sort created- --format short
ZK_NOTEBOOK_DIR=~/zk-notes zk list ~/zk-notes/journal --sort created- --format short
```

### Read a note

Once you have the relative path from `zk list` output (e.g. `ideas/abc123.md`), read the full file:

```
cat ~/zk-notes/ideas/abc123.md
```

### Retrieve Workflow

1. Ask the user what they're looking for (keyword, tag, folder, or recent)
2. Run the appropriate `zk list` command above
3. Show titles + paths in a compact list
4. If the user wants to read one, `cat` the full file and show the content
