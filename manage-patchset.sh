#!/bin/sh

subcommand="$1"
branch="$2"

infer_branch=

if test -z "$branch"
then
	branch="$(git branch --show-current)"
	infer_branch=true
fi

case "$branch" in
submitted/*)
	;;
*/)
	if test -n "$infer_branch"
	then
		echo BUG: inferred branch with trailing slash
		exit 1
	fi
	branch="submitted/${branch%/}"
	;;
*)
	if test -n "$infer_branch"
	then
		echo Missing \'submitted/\' prefix
		exit 1
	else
		branch="submitted/$branch"
	fi
	;;
esac
branch_part="${branch##submitted/}"

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
