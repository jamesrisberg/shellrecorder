# shellrecorder

Record terminal sessions to clean text files. Two commands: `rec` and `stoprec`.

## Install

```bash
brew install jamesrisberg/shellrecorder/shellrecorder
```

## Usage

```bash
rec              # start recording (auto-named with timestamp)
rec myfile.txt   # start recording to a specific file

# ... do whatever you want ...

stoprec          # stop and save
```

Recordings are saved to `~/.shellrecorder/recordings/` by default. Pass an absolute path to save elsewhere.

## What it does

`rec` starts a recording session using the Unix `script` command. Everything you type and see in the terminal is captured. When you run `stoprec`, the session ends and the output is cleaned — ANSI escape codes, control characters, and terminal artifacts are stripped — leaving you with a readable text file.

## Limitations

TUI applications (Claude Code, vim, htop, etc.) won't produce clean output. These apps redraw the screen using cursor positioning, which can't be reconstructed into linear text. Handling specific TUI cases like Claude Code is on the roadmap.

## Shell support

Works with **zsh** and **bash**. Other shells fall back to `exit` instead of `stoprec`.
