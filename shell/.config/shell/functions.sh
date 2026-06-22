# Shared shell functions — compatible with bash and zsh.
# Source from ~/.bashrc or ~/.zshrc:
#   [ -f ~/.config/shell/functions.sh ] && . ~/.config/shell/functions.sh

# Quick non-interactive Claude prompt: q your question here
q() {
  if [ $# -eq 0 ]; then
    echo "Usage: q <question>" >&2
    return 1
  fi

  local sentinel frames i
  sentinel=$(mktemp)
  frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'

  # Spinner runs until sentinel file is removed
  (
    i=0
    while [ -f "$sentinel" ]; do
      printf "\r\033[36m%s\033[0m thinking…" "${frames:$((i % 10)):1}" >&2
      i=$(( i + 1 ))
      sleep 0.08
    done
    printf "\r\033[K" >&2
  ) &

  # Remove sentinel (stopping spinner) on first line of output
  claude -p "$*" | while IFS= read -r line; do
    rm -f "$sentinel"
    printf '%s\n' "$line"
  done

  rm -f "$sentinel"
}
