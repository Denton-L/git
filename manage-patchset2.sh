#!/bin/sh

die () {
	echo "$@"
	exit 1
}

while test $# != 0
do
	case "$1" in
	--branch)
		branch="$2"
		shift
		;;
	--*)
		die "invalid option: $1"
		;;
	*)
		break
		;;
	esac
	shift
done

if test $# = 0
then
	die "no subcommand given"
fi
subcommand="$1"
shift

name=
version=

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
format-patch)
	if test -z "$version"
	then
		die "no version number given"
	fi

	base=
	reply_to=
	while test $# != 0
	do
		case "$1" in
			--in-reply-to)
				reply_to="$2"
				shift
				;;
			--*)
				die "invalid option: $1"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if test $# = 0
	then
		die "no base given"
	fi
	base="$1"
	shift

	reroll_count=
	range_diff=
	in_reply_to=

	if test "$version" -gt 1
	then
		prev_version=$(($version - 1))
		reroll_count="--reroll-count=$version"
		range_diff="--range-diff=$base..$name/v$prev_version"
	fi
	if test -n "$reply_to"
	then
		in_reply_to=--in-reply-to="$reply_to"
	fi

	git -c "include.path=$PWD/$outdir/config" format-patch ${reroll_count:+"$reroll_count"} ${range_diff:+"$range_diff"} ${in_reply_to:+"$in_reply_to"} "$base"
	;;
*)
	die "invalid subcomand: $subcommand"
	;;
esac
