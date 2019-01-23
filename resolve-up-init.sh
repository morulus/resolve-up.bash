#!/usr/bin/env bash
# Bash completion for resolve-up

strindex() {
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] && echo -1 || echo "${#x}"
}

trim()
{
  local trimmed="$1"

  # Strip leading space.
  trimmed="${trimmed## }"
  # Strip trailing space.
  trimmed="${trimmed%% }"

  echo "$trimmed"
}


_resolve-up() {
  query=${COMP_WORDS[1]}
  posi=$(resolve-up -n 1 "$query*")
  index=$(strindex "$posi" "$query")
  splited="${posi:((index))}"
  COMPREPLY=(trim "$splited")
}

complete -F _resolve-up resolve-up

# Alias for resolve-up

resolve-upGreedy() {
  resolve-up -g "$@"
}

alias ..=resolve-up
alias ...=resolve-upGreedy
