#!/usr/bin/env bash
# Bash completion for find-outer

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


_find-outer() {
  query=${COMP_WORDS[1]}
  posi=$(find-outer -n 1 "$query*")
  index=$(strindex "$posi" "$query")
  splited="${posi:((index))}"
  COMPREPLY=(trim "$splited")
}

complete -F _find-outer find-outer

# Alias for find-outer

find-outerGreedy() {
  find-outer -g "$@"
}

alias ..=find-outer
alias ...=find-outerGreedy
