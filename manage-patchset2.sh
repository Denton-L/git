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
	git config --get-regexp --name-only 'branch\.'"$name"'/.*' | while read key
		do
			git config --file="$patchdir/common-config" --unset "$key"
		done
	;;
sync)
	git config --get-regexp --name-only 'branch\.'"$name"'/.*' | while read key
		do
			git config --file="$patchdir/common-config" "$key" "$(git config "$key")"
			git config --unset "$key"
		done
	;;
next)
	if test -z "$version"
	then
		die "no version number given"
	fi

	next_version=$(($version + 1))
	next_branch="$name/v$next_version"
	git branch "$next_branch"
	git config --get-regexp --name-only 'branch\.'"$name/v$version"'\..*' | while read key
		do
			git config --file="$patchdir/common-config" "branch.$next_branch.${key##*.}" $(git config "$key")
		done
	;;
*)
	die "invalid subcomand: $subcommand"
	;;
esac
