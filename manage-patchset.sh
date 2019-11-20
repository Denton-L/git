#!/bin/sh

subcommand="$1"
branch="$2"
if test -z "$branch"
then
	branch="$(git branch --show-current)"
fi

branch_part="${branch##submitted/}"
if test "$branch" = "$branch_part"
then
	echo Missing \'submitted/\' prefix
	exit 1
fi

patchdir="$(dirname "$0")"
outdir="$patchdir/$branch_part"

case "$subcommand" in
create)
	mkdir "$outdir"
	git config --file="$outdir/config" format.outputDirectory "patches/$branch_part"
	git config --file="$patchdir/common-config" includeIf."onbranch:$branch".path "$branch_part/config"
	;;
remove)
	rm -r "$outdir"
	git config --file="$patchdir/common-config" --remove-section includeIf."onbranch:$branch"
	git config --file="$patchdir/common-config" --remove-section branch."$branch"
	;;
sync)
	git config --get-regexp --name-only branch\\."$branch"\\.\* |
		while IFS='
' read key
		do
			git config --file="$patchdir/common-config" "$key" "$(git config "$key")"
		done
	git config --remove-section branch."$branch"
	;;
*)
	echo Invalid subcomand: $subcommand
	exit 1
	;;
esac
