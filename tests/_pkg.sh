: ${TMPDIR:=/tmp}

pkg_repo="$__dir__/fixtures/pkg"
pkg_name='pkg'

before_all()
{
        if ! test -e "$pkg_repo/.git"; then
                git -C "$pkg_repo" init --quiet
                git -C "$pkg_repo" add -A lib/a.sh
                git -C "$pkg_repo" commit --quiet -m '' --allow-empty-message
                git -C "$pkg_repo" add -A .
                git -C "$pkg_repo" commit --quiet -m '' --allow-empty-message
        fi
}

before()
{
        tmp_dir="$(mktemp -d)"
        SHIFT_HOME_DIR="$tmp_dir"
}

after()
{
        rm -rf "$tmp_dir"
}

after_all()
{
        # rm -rf "$pkg_repo/.git"
        true
}
