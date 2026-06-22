# Shared shell functions — compatible with bash and zsh.
# Source from ~/.bashrc or ~/.zshrc:
#   [ -f ~/.config/shell/functions.sh ] && . ~/.config/shell/functions.sh

# Quick non-interactive Claude prompt: q your question here
q() {
  if [ $# -eq 0 ]; then
    echo "Usage: q <question>" >&2
    return 1
  fi

  local frames spinner_pid cleared
  frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  cleared=0

  # zsh: LOCAL_OPTIONS scopes the change to this function; NO_MONITOR suppresses "[N] pid/done"
  # bash: set +m disables monitor mode (job notifications)
  [ -n "$ZSH_VERSION" ] && setopt LOCAL_OPTIONS NO_MONITOR || set +m

  (
    i=0
    while true; do
      printf "\r\033[36m%s\033[0m thinking…" "${frames:$((i % 10)):1}" >/dev/tty
      i=$(( i + 1 ))
      sleep 0.08
    done
  ) &
  spinner_pid=$!

  while IFS= read -r line; do
    if [ "$cleared" = "0" ]; then
      cleared=1
      kill "$spinner_pid" 2>/dev/null
      printf "\r\033[K" >/dev/tty
    fi
    printf '%s\n' "$line"
  done < <(claude -p "$*")

  kill "$spinner_pid" 2>/dev/null
  printf "\r\033[K" >/dev/tty
}
