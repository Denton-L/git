#!/bin/sh

subcommand="$1"
branch="$2"

name=
version=

die () {
	echo "$@"
	exit 1
}

if test -z "$branch"
then
	branch="$(git branch --show-current)"
fi

case "$branch" in
*/*)
	name="${branch%/*}"
	version="${branch##*/v}"
	;;
*)
	name="$branch"
	;;
esac

case "$version" in
*[!0-9]*)
	die "bad version number: $version"
	;;
esac

patchdir="$(dirname "$0")"
outdir="$patchdir/$name"

case "$subcommand" in
create)
	mkdir -p "$outdir"
	git config --file="$outdir/config" format.outputDirectory "patches/$name"
	git config --file="$patchdir/common-config" includeIf."onbranch:$name/*".path "$name/config"
	;;
remove)
	rm -r "$outdir"
	git config --file="$patchdir/common-config" --remove-section includeIf."onbranch:$name/*".path
	git for-each-ref --format="$(refname:short)" "refs/heads/$name" | while read b
	do
		git config --file="$patchdir/common-config" --remove-section branch."$b"
	done
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
	die "invalid subcomand: $subcommand"
	;;
esac
