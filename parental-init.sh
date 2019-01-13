#!/usr/bin/env bash
# Bash completion for parental

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


_parental() {
  query=${COMP_WORDS[1]}
  posi=$(parental -n 1 "$query*")
  index=$(strindex "$posi" "$query")
  splited="${posi:((index))}"
  COMPREPLY=(trim "$splited")
}

complete -F _parental parental

# Alias for parental

parentalGreedy() {
  parental -g "$@"
}

alias ..=parental
alias ...=parentalGreedy
