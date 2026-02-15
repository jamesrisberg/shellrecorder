# shellrecorder — record terminal sessions to files
#
# Source this file in your shell:
#   source ./shellrecorder.sh
#
# Works with: zsh, bash (and falls back to 'exit' for others)
#
# Then use:
#   rec [filename]  — start recording
#   stoprec         — stop and save

rec() {
  if [ -n "$_SHELLREC" ]; then
    printf 'Already recording.\n'
    return 1
  fi

  local file="${1:-rec_$(date +%Y%m%d_%H%M%S).txt}"
  [[ "$file" != /* ]] && file="$PWD/$file"

  local tmp rcdir shell_name
  tmp=$(mktemp "${TMPDIR:-/tmp}/shellrec.XXXXXX")
  rcdir=$(mktemp -d "${TMPDIR:-/tmp}/shellrec_rc.XXXXXX")
  shell_name=$(basename "$SHELL")

  # Build the rc snippet that injects stoprec into the subshell
  local snippet
  snippet='stoprec() { exit; }
rec() { printf "Already recording.\n"; return 1; }'

  case "$shell_name" in
    zsh)
      local real_zdotdir="${ZDOTDIR:-$HOME}"
      for f in .zshenv .zprofile .zlogin .zlogout; do
        [ -f "$real_zdotdir/$f" ] && ln -s "$real_zdotdir/$f" "$rcdir/$f"
      done
      cat > "$rcdir/.zshrc" << INNER
[ -f '${real_zdotdir}/.zshrc' ] && source '${real_zdotdir}/.zshrc'
${snippet}
INNER
      ;;
    bash)
      cat > "$rcdir/.bashrc" << INNER
[ -f '${HOME}/.bashrc' ] && source '${HOME}/.bashrc'
${snippet}
INNER
      ;;
  esac

  printf 'Recording → %s\n' "$file"
  printf 'Type "stoprec" when done.\n'

  # Start recording — shell-specific subshell setup
  case "$shell_name" in
    zsh)
      ZDOTDIR="$rcdir" _SHELLREC=1 script -q "$tmp"
      ;;
    bash)
      if [ "$(uname -s)" = "Darwin" ]; then
        _SHELLREC=1 script -q "$tmp" bash --rcfile "$rcdir/.bashrc"
      else
        _SHELLREC=1 script -qc "bash --rcfile '$rcdir/.bashrc'" "$tmp"
      fi
      ;;
    *)
      printf '(stoprec unavailable in %s — type "exit" to stop)\n' "$shell_name"
      _SHELLREC=1 script -q "$tmp"
      ;;
  esac

  rm -rf "$rcdir"

  # Strip escape sequences, process carriage returns, and clean backspaces
  perl -pe '
    s/\e\[ [?>=<]* [0-9;]* [a-zA-Z~]//gx;   # CSI sequences (colors, modes, cursor)
    s/\e\] .*? (?:\a|\e\\)//gx;              # OSC sequences (titles, hyperlinks)
    s/\e[()][A-Z0-9]//g;                     # charset selection
    s/\e[a-zA-Z]//g;                         # two-char escapes
    s/^.*\r(?!\n)//;                          # carriage return overwrites (PROMPT_EOL_MARK etc)
    s/\r//g;                                  # remaining \r
  ' < "$tmp" | col -b > "$file"
  rm -f "$tmp"

  printf 'Saved → %s (%s lines)\n' "$file" "$(wc -l < "$file" | tr -d ' ')"
}

stoprec() {
  if [ -n "$_SHELLREC" ]; then
    exit
  else
    printf 'No recording in progress.\n'
  fi
}
