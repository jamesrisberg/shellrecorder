# shellrecorder

Record terminal sessions to clean, readable files. Includes first-class support for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) sessions.

## Install

```bash
brew install jamesrisberg/shellrecorder/shellrecorder
```

## Usage

```bash
rec              # start recording (auto-named with timestamp)
rec mysession    # start recording with a specific name

# ... do whatever you want ...

stoprec          # stop and save
```

Recordings are saved to `~/.shellrecorder/recordings/` by default. Pass an absolute path to save elsewhere.

## Configuration

Settings live in `~/.shellrecorder/config` (created automatically on first run):

```
recordings_dir=~/.shellrecorder/recordings
```

| Key | Description | Default |
|-----|-------------|---------|
| `recordings_dir` | Directory where recordings are saved | `~/.shellrecorder/recordings` |

Each recording produces two files:
- `.md` — clean, readable output (terminal commands + output, Claude Code sessions rendered as markdown)
- `.raw` — raw terminal capture

## Claude Code support

If you run Claude Code during a recording, shellrecorder automatically detects the session and replaces the raw TUI output with a clean transcript. The result is a single `.md` file with everything in chronological order:

````
```
(base) user@host ~ % ls
file1.txt  file2.txt
(base) user@host ~ % claude
```

### Claude Code — claude-opus-4-6

**User:** explain this codebase

Here's an overview of the project...

> **Glob** `**/*` in `.`
> **Read** `src/main.py`

The main entry point is...

```
(base) user@host ~ % echo "back to terminal"
back to terminal
```
````

You can also render any Claude Code session directly:

```bash
clauderec <session-id>    # render a session by ID
clauderec <path.jsonl>    # render from a JSONL file
```

Session IDs are printed at the end of every Claude Code session (`claude --resume <id>`).

## Shell support

Works with **zsh** and **bash**. Other shells fall back to `exit` instead of `stoprec`.
