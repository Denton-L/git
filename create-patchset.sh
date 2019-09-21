#!/bin/sh

branch="$1"
if test -z "$branch"
then
    branch=$(git branch --show-current | sed -e 's|^submitted/||')
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
