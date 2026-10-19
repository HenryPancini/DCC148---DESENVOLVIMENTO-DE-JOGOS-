#!/bin/sh
printf '\033c\033]0;%s\a' Frogger
base_path="$(dirname "$(realpath "$0")")"
"$base_path/.x86_64" "$@"
