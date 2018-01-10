set -e # errexit
set -u # nounset

ZeroDir="$(cd "$(dirname "$0")" && pwd)"
: ${ShiftDir:=${SHIFT_DIR:-$ZeroDir/.shift}}
: ${ShiftHomeDir:=${SHIFT_HOME_DIR:-$ZeroDir/shell.d}}
: ${ShiftPath:=${SHIFT_PATH:-$HOME/.shell.d}}

export SHIFT_DIR
export SHIFT_HOME_DIR
export SHIFT_PATH

if ! printf -- "$ShiftPath" | grep -Eq "(^|:)$ShiftHomeDir(:|$)"; then
        ShiftPath="$ShiftHomeDir${ShiftPath:+:$ShiftPath}"
fi

__imports()
{
        local repo_dir="$1"
        local repo_as="$2"

        grep -REl '\b(from|import)\s+\.' "$repo_dir" | while IFS= read -r lib; do
                ed -s "$lib" <<EOF >/dev/null || true
%g/from *\./s//from $repo_as/g
%g/import *\./s//import $repo_as/g
wq
EOF
        done
}

## Example:
## require https://$url/$package.shell.git
## require https://$url/$package.shell.git -branch $branch -rev $rev -as $name
require()
{
        local repo_url="$1"
        shift
        local repo_branch="master"
        local repo_rev="HEAD"
        local repo_as="$(printf -- '%s' "$repo_url" | sed -e 's:^.*/::' -e 's:\.git$::' -e 's:.shell$::')"

        while test $# -gt 0; do
                case $1 in
                        -branch) repo_branch="$2"; shift; shift;;
                        -rev)    repo_rev="$2";    shift; shift;;
                        -as)     repo_as="$2";     shift; shift;;
                esac
        done

        local repo_dir="$ShiftHomeDir/$repo_as"

        if test -e "$repo_dir"; then
                ## We need to search and convert relative imports every time
                ## to make them compatible with git submodules.
                __imports "$repo_dir" "$repo_as"
                return
        fi

        mkdir -p "$ShiftHomeDir"

        git clone --quiet -b "$repo_branch" "$repo_url" "$repo_dir"
        git --git-dir "$repo_dir/.git" --work-tree "$repo_dir" checkout --quiet "$repo_rev"

        __imports "$repo_dir" "$repo_as"
}

## Example:
## import $pkg/$lib
import()
{
        local pkg="${1%%/*}"
        local lib="${1#*/}"
        local ifs="$IFS"

        IFS=:
        for dir in $ShiftPath; do
                local file="$dir/$pkg/lib/$lib.sh"
                if test -e "$file"; then
                        . "$file"
                        IFS="$ifs"
                        return
                fi
        done
        IFS="$ifs"

        echo "import '$1' not found." 1>&2
        return 1
}

## Example:
## from $pkg import $lib
## from $pkg import $lib1 $lib2
from()
{
        local pkg="$1"
        shift ## Package name.
        shift ## 'import' keyword.

        for lib; do
                import "$pkg/$lib"
        done
}
