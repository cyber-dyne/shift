: ${ShiftHomeDir:=${SHIFT_HOME_DIR:-$ZeroDir/shift.d}}
: ${ShiftPath:=${SHIFT_PATH:-$HOME/.shift.d}}
: ${ShiftDebugFlag:=${SHIFT_DEBUG:-no}}

export SHIFT_HOME_DIR
export SHIFT_PATH
export SHIFT_DEBUG

if ! printf -- "$ShiftPath" | grep -Eq "(^|:)$ShiftHomeDir(:|$)"; then
        ShiftPath="$ShiftHomeDir${ShiftPath:+:$ShiftPath}"
fi

if test "$ShiftDebugFlag" != 'no'; then
        set -x ## xtrace
fi

case "$(uname -s)" in
        Linux)  ShiftOS=Linux;;
        Darwin) ShiftOS=MacOS;;
esac

## Public API.
## Example:
## require https://$url/$package.shell.git
## require https://$url/$package.shell.git -rev $rev -as $name
require()
{(
        local repo_url="$1"
        shift
        local repo_rev="HEAD"
        local repo_as="$(printf -- '%s' "$repo_url" | sed -e 's:^.*/::' -e 's:\.git$::' -e 's:.sh$::')"

        while test $# -gt 0; do
                case $1 in
                        -rev) repo_rev="$2"; shift; shift;;
                        -as)  repo_as="$2";  shift; shift;;
                esac
        done

        local repo_dir="$ShiftHomeDir/$repo_as"

        if test ! -e "$repo_dir"; then
                mkdir -p "$ShiftHomeDir"

                git clone --quiet "$repo_url" "$repo_dir"
                git -C "$repo_dir" checkout --quiet "HEAD^0"                    ## Detached.
                for branch in $(git -C "$repo_dir" for-each-ref --format '%(refname:short)' refs/heads/); do
                        git -C "$repo_dir" branch --quiet -d "$branch"
                done
        fi

        local receipt_file="$repo_dir/receipt"
        touch "$receipt_file"
        local receipt_rev="$(cat "$receipt_file")"

        if test "$repo_rev" != "$receipt_rev"; then
                git -C "$repo_dir" fetch --quiet --all --prune
                git -C "$repo_dir" checkout --quiet "$repo_rev^0"               ## Detached.
                printf -- '%s' "$repo_rev" > "$receipt_file"
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

        local stats_file="$repo_dir/lib.stats"

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
                ed -s "$libo" <<EOF 1>/dev/null 2>&1 || true
%g/from *\./s//from $repo_as/g
%g/import *\./s//import $repo_as/g
wq
EOF
        done

        shift_get_lib_mtimes "$repo_dir" > "$stats_file"
}
