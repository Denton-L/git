#!/bin/sh

subcommand="$1"
branch="$2"
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

case "$subcommand" in
create)
	mkdir "$outdir"
	git config --file="$outdir/config" format.outputDirectory "patches/$branch"
	git config --file="$patchdir/common-config" includeIf."onbranch:submitted/$branch".path "$branch/config"
	;;
remove)
	rm -r "$outdir"
	git config --file="$patchdir/common-config" --remove-section includeIf."onbranch:submitted/$branch"
	;;
*)
	echo Invalid subcomand: $subcommand
	exit 1
	;;
esac
