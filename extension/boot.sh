#!/bin/zsh
# Jarvis-style boot sequence shown in the terminal before Claude starts. zsh on purpose:
# macOS ships bash 3.2, which mangles multibyte names (Radomír, Vendelín) in substrings.
# Usage: zsh boot.sh <name> <model label> <command...>   (the command is exec'ed at the end)
name=$1; model=$2; shift 2
[[ "$(locale charmap 2>/dev/null)" == "UTF-8" ]] || export LC_CTYPE=en_US.UTF-8
C=$'\e[36m'; B=$'\e[1;36m'; D=$'\e[2m'; G=$'\e[32m'; W=$'\e[97m'; R=$'\e[0m'
printf '\e[?25l'                          # hide cursor
trap 'printf "\e[?25h"' EXIT
clear

type_out() { local s=$1 i; for ((i = 1; i <= ${#s}; i++)); do printf '%s' "${s[i]}"; sleep 0.012; done; printf '\n'; }
step() {                                  # step "text" <ticks of 50 ms>
  local text=$1 ticks=${2:-10} i=0 frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  while (( i < ticks )); do
    printf "\r  %s%s%s %s%s%s" "$C" "${frames[$((i % 10 + 1))]}" "$R" "$D" "$text" "$R"; i=$((i + 1)); sleep 0.05
  done
  printf "\r  %s✔%s %s\n" "$G" "$R" "$text"
}
bar() {                                   # progress bar, 28 cells
  local n=28 i
  for ((i = 1; i <= n; i++)); do
    printf "\r  %s[%-28s]%s %s%3d%%%s" "$B" "${(l:i::█:)}" "$R" "$D" $((i * 100 / n)) "$R"; sleep 0.03
  done; printf '\n'
}

printf "\n  %s◆ %s%s%s\n" "$B" "$W" "${(U)name}" "$R"
printf "  %s%s%s\n\n" "$D" "${(l:${#name}+4::━:)}" "$R"
type_out "  ${D}Probouzím agenta ${name}…${R}"
echo
step "Načítám paměť projektu" 10
step "Připojuji nástroje a oprávnění" 8
step "Model: ${model:-výchozí}" 6
echo
bar
printf "\n  %s●%s %s%s je online.%s\n\n" "$G" "$R" "$W" "$name" "$R"
sleep 0.4
printf '\e[?25h'
exec "$@"
