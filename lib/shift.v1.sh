: ${ShiftHomeDir:=${SHIFT_HOME_DIR:-$ZeroDir/shift.d}}
: ${ShiftPath:=${SHIFT_PATH:-$HOME/.shift.d}}

export SHIFT_HOME_DIR
export SHIFT_PATH

if ! printf -- "$ShiftPath" | grep -Eq "(^|:)$ShiftHomeDir(:|$)"; then
        ShiftPath="$ShiftHomeDir${ShiftPath:+:$ShiftPath}"
fi

case "$(uname -s)" in
        Linux)  ShiftOS=Linux;;
        Darwin) ShiftOS=MacOS;;
esac

## Public API.
## Example:
## require https://$url/$package.shell.git
## require https://$url/$package.shell.git -branch $branch -rev $rev -as $name
require()
{(
        local repo_url="$1"
        shift
        local repo_branch="master"
        local repo_rev="HEAD"
        local repo_as="$(printf -- '%s' "$repo_url" | sed -e 's:^.*/::' -e 's:\.git$::' -e 's:.sh$::')"

        while test $# -gt 0; do
                case $1 in
                        -branch) repo_branch="$2"; shift; shift;;
                        -rev)    repo_rev="$2";    shift; shift;;
                        -as)     repo_as="$2";     shift; shift;;
                esac
        done

        local repo_dir="$ShiftHomeDir/$repo_as"

        if test ! -e "$repo_dir"; then
                mkdir -p "$ShiftHomeDir"

                git clone --quiet -b "$repo_branch" "$repo_url" "$repo_dir"
                git --git-dir "$repo_dir/.git" --work-tree "$repo_dir" checkout --quiet "$repo_rev"
        fi

        shift_fix_imports "$repo_dir" "$repo_as"

        if test -e "$repo_dir/Shfile.sh"; then
                . "$repo_dir/Shfile.sh"
        fi
)}

## Public API.
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

                if ! test -e "$file"; then
                        continue
                fi

                if test -e "${file}o"; then
                        file="${file}o"
                fi

                . "$file"
                IFS="$ifs"
                return
        done
        IFS="$ifs"

        echo "import '$1' not found." 1>&2
        return 1
}

## Public API.
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

## Internal API.
## Example:
## shift_get_lib_mtimes "$repo_dir
shift_get_lib_mtimes()
{
        case "$ShiftOS" in
                Linux) find "$1/lib" -type d -print0 | xargs -0 stat -c '%Y';;
                MacOS) find "$1/lib" -type d -print0 | xargs -0 stat -f '%m';;
        esac
}

## Internal API.
## Example:
## shift_fix_imports "$repo_dir" "$repo_as"
shift_fix_imports()
{
        local repo_dir="$1"
        local repo_as="$2"

        if test ! -e "$repo_dir/lib"; then
                ## Packages without a lib directory are possible (meta package).
                ## In this case we have nothing to process.
                return
        fi

        local stats_file="$repo_dir/.lib.stats"

        if test -e "$stats_file"; then
                local old_stats="$(cat "$stats_file")"
                local new_stats="$(shift_get_lib_mtimes "$repo_dir")"

                if test "$old_stats" = "$new_stats"; then
                        return
                fi
        fi

        find "$repo_dir/lib" -type f -iname "*.sh" \
        | while IFS= read -r lib; do
                local libo="${lib}o"

                ## ed is faster than using cat+sed.
                cp -f "$lib" "$libo"
                ed -s "$libo" <<EOF
%g/from *\./s//from $repo_as/g
%g/import *\./s//import $repo_as/g
wq
EOF
        done

        shift_get_lib_mtimes "$repo_dir" > "$stats_file"
}
