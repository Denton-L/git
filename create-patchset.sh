#!/bin/sh

branch="$1"
if test -z "$branch"
then
    branch="$(git branch --show-current)"
    no_prefix="${branch##submitted/}"
    if test "$branch" = "$no_prefix"
    then
	echo Missing \'submitted/\' prefix
	exit 1
    fi
    branch="$no_prefix"
fi

patchdir="$(dirname "$0")"
outdir="$patchdir/$branch"

mkdir "$outdir"
git config --file="$outdir/config" format.outputDirectory "patches/$branch"
git config --file="$patchdir/common-config" includeIf."onbranch:submitted/$branch".path "$branch/config"
