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
cat <<EOF >"$outdir/config"
[format]
	outputDirectory = patches/$branch
EOF

cat <<EOF >>"$patchdir/common-config"
[includeIf "onbranch:submitted/$branch"]
	path = $branch/config
EOF
