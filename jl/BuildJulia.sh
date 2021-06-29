#!/bin/bash

YggdrasilRoot="/home/s1131817/Yggdrasil"
HighsRoot="${YggdrasilRoot}/H/HiGHS/"
HighsCodeRoot="${YggdrasilRoot}/../projects/HiGHS/"
cd ${HighsCodeRoot}

function clc {
    COLOR_GREEN="\033[0;32m"
    COLOR_RESET="\033[0m"
    [[ -z $1 ]] && BRANCH=$(git rev-parse --abbrev-ref HEAD) || BRANCH=$1
    LAST_COMMIT_SHA=$(git rev-parse $BRANCH | tail -n 1)
    echo "$LAST_COMMIT_SHA" | tr -d '\n' | pbcopy
    echo "Copied ${COLOR_GREEN}${LAST_COMMIT_SHA} ${COLOR_RESET}from ${BRANCH}."
}

clc

cd ${HighsRoot}

~~~ todo: add sed with commit sha

julia --color=yes build_tarballs.jl --deploy=local
