: ${TMPDIR:=/tmp}

pkg_repo="$__dir__/fixtures/pkg"
pkg_name='pkg'

before_all() { before_all_for_pkg "$@"; }
before()     { before_for_pkg "$@";     }
after()      { after_for_pkg "$@";      }
after_all()  { after_all_for_pkg "$@";  }

before_all_for_pkg()
{
        if ! test -e "$pkg_repo/.git"; then
                git -C "$pkg_repo" init --quiet
                git -C "$pkg_repo" add -A lib/a.sh
                git -C "$pkg_repo" commit --quiet -m '' --allow-empty-message
                git -C "$pkg_repo" add -A .
                git -C "$pkg_repo" commit --quiet -m '' --allow-empty-message
        fi
}

before_for_pkg()
{
        tmp_dir="$(mktemp -d)"
        SHIFT_HOME_DIR="$tmp_dir"

        . "$__dir__/../lib/shift.sh"

        require "$pkg_repo"
}

after_for_pkg()
{
        rm -rf "$tmp_dir"
        :;
}

after_all_for_pkg()
{
        # rm -rf "$pkg_repo/.git"
        :;
}
