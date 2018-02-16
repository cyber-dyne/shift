before_all() { before_all_for_pkg "$@"; }
before()     { before_for_pkg "$@";     }
after()      { after_for_pkg "$@";      }
after_all()  { after_all_for_pkg "$@";  }

before_all_for_pkg()
{
        pkg_name='pkg1'
        pkg_repo="$__dir__/fixtures/$pkg_name"

        other_pkg_name='pkg2'
        other_pkg_repo="$__dir__/fixtures/$other_pkg_name"

        if ! test -e "$pkg_repo/.git"; then
                git -C "$pkg_repo" init --quiet
                git -C "$pkg_repo" add -A lib/a.sh
                git -C "$pkg_repo" commit --quiet -m '' --allow-empty-message
                git -C "$pkg_repo" tag 1.0
                git -C "$pkg_repo" add -A .
                git -C "$pkg_repo" commit --quiet -m '' --allow-empty-message
                git -C "$pkg_repo" tag 1.1
        fi

        if ! test -e "$other_pkg_repo/.git"; then
                echo "require '$pkg_repo'" > "$other_pkg_repo/Shfile.sh"
                git -C "$other_pkg_repo" init --quiet
                git -C "$other_pkg_repo" add -A .
                git -C "$other_pkg_repo" commit --quiet -m '' --allow-empty-message
        fi
}

before_for_pkg()
{
        : ${TMPDIR:=/tmp}

        tmp_dir="$(mktemp -d)"
        SHIFT_HOME_DIR="$tmp_dir"

        . "$__dir__/.shift/lib/shift.sh"

        require "$pkg_repo"
}

after_for_pkg()
{
        rm -rf "$tmp_dir"
}

after_all_for_pkg()
{
        rm -rf "$pkg_repo/.git"
        rm -rf "$other_pkg_repo/.git"
        rm -f "$other_pkg_repo/Shfile.sh"
}
