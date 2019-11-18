#!/bin/sh

name="$(git config user.name)"
email="$(git config user.email)"

usage () {
	echo "$0 [--name=<name>] [--email=<email>] <range>"
	exit 1
}

while test $# -ne 0
do
	case "$1" in
	--name)
		name="$2"
		shift
		;;
	--email)
		email="$2"
		shift
		;;
	-*)
		usage
		exit 1
		;;
	*)
		break
		;;
	esac
	shift
done

FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter "
	sed -e '\${/Signed-off-by: $name <$email>/d;}'
" -- "$@"
