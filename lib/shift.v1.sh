: ${ShiftHomeDir:=${SHIFT_HOME_DIR:-$ZeroDir/shell.d}}
: ${ShiftPath:=${SHIFT_PATH:-$HOME/.shell.d}}

export SHIFT_DIR
export SHIFT_HOME_DIR
export SHIFT_PATH

if ! printf -- "$ShiftPath" | grep -Eq "(^|:)$ShiftHomeDir(:|$)"; then
        ShiftPath="$ShiftHomeDir${ShiftPath:+:$ShiftPath}"
fi

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
                shift_fix_imports "$repo_dir" "$repo_as"
                return
        fi

        mkdir -p "$ShiftHomeDir"

        git clone --quiet -b "$repo_branch" "$repo_url" "$repo_dir"
        git --git-dir "$repo_dir/.git" --work-tree "$repo_dir" checkout --quiet "$repo_rev"

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
shift_get_mtime()
{
        case "$(uname -s)" in
                Linux)  stat -c '%Y' "$@";;
                Darwin) stat -f '%m' "$@";;
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

        grep -R -l --exclude '*.sho' -E '\b(from|import)\s+\.' "$repo_dir/lib" \
        | while IFS= read -r lib; do
                if test -e "${lib}o"; then
                        local lib_mtime=$(shift_get_mtime "$lib")
                        local obj_mtime=$(shift_get_mtime "${lib}o")

                        if test $lib_mtime -le $obj_mtime; then
                                ## In case the converted library exists and has
                                ## a modification time newer than the original
                                ## one we have nothing to do and we can skip
                                ## the conversion.
                                continue
                        fi
                fi

                ## ed is faster than using cat+sed.
                ed -s "$lib" <<EOF >"${lib}o"
%g/from *\./s//from $repo_as/g
%g/import *\./s//import $repo_as/g
%p
EOF
        done
}
