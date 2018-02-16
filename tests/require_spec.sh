. "$__dir__/_pkg.sh"

it_should_require_a_package()
{
        test -e "$tmp_dir/$pkg_name/.git"
        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        test -e "$tmp_dir/$pkg_name/lib/all.sho"
        grep -q "^import $pkg_name" "$tmp_dir/$pkg_name/lib/all.sho"
        ! grep -q "^import *\." "$tmp_dir/$pkg_name/lib/all.sho"
        grep -q "^from $pkg_name import" "$tmp_dir/$pkg_name/lib/all.sho"
        ! grep -q "^from *\. import" "$tmp_dir/$pkg_name/lib/all.sho"
        grep -q "^import $pkg_name" "$tmp_dir/$pkg_name/lib/import.sho"
        ! grep -q "^import *\." "$tmp_dir/$pkg_name/lib/import.sho"
        grep -q "^from $pkg_name import" "$tmp_dir/$pkg_name/lib/import_from.sho"
        ! grep -q "^from *\. import" "$tmp_dir/$pkg_name/lib/import_from.sho"
}

it_should_require_a_package_with_a_name()
{
        require "$pkg_repo" -as $pkg_name.v1

        test -e "$tmp_dir/$pkg_name.v1/.git"
        grep -q "^from $pkg_name\.v1 import" "$tmp_dir/$pkg_name.v1/lib/all.sho"
        ! grep -q "^from *\. import" "$tmp_dir/$pkg_name.v1/lib/all.sho"
        grep -q "^import $pkg_name\.v1" "$tmp_dir/$pkg_name.v1/lib/all.sho"
        ! grep -q "^import *\." "$tmp_dir/$pkg_name.v1/lib/all.sho"
}

it_should_require_a_package_with_a_rev()
{
        rm -rf "$tmp_dir/$pkg_name"

        require "$pkg_repo" -rev origin/master~1

        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        ! test -e "$tmp_dir/$pkg_name/lib/b.sh"
}

it_should_require_a_package_with_an_older_rev()
{
        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        test -e "$tmp_dir/$pkg_name/lib/b.sh"

        require "$pkg_repo" -rev 1.0

        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        ! test -e "$tmp_dir/$pkg_name/lib/b.sh"
}

it_should_require_a_package_with_an_newer_rev()
{
        rm -rf "$tmp_dir/$pkg_name"

        require "$pkg_repo" -rev 1.0

        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        ! test -e "$tmp_dir/$pkg_name/lib/b.sh"

        require "$pkg_repo" -rev 1.1

        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        test -e "$tmp_dir/$pkg_name/lib/b.sh"
}

it_should_require_a_package_with_an_newer_rev_from_the_remote()
{
        require "$pkg_repo" -rev origin/master

        git clone --quiet "$pkg_repo" "$tmp_dir/${pkg_name}-remote"
        echo "c" > "$tmp_dir/${pkg_name}-remote/lib/c.sh"
        git -C "$tmp_dir/${pkg_name}-remote" add .
        git -C "$tmp_dir/${pkg_name}-remote" commit --quiet -m '' --allow-empty-message
        git -C "$tmp_dir/${pkg_name}-remote" tag -a -m '' 2.0
        git -C "$tmp_dir/$pkg_name" remote set-url origin "$tmp_dir/${pkg_name}-remote"

        ! test -e "$tmp_dir/$pkg_name/lib/c.sh"
        require "$pkg_repo" -rev 2.0
        test -e "$tmp_dir/$pkg_name/lib/c.sh"
}

it_should_require_a_package_with_its_dependencies()
{
        rm -rf "$tmp_dir/$pkg_name"

        require "$other_pkg_repo"

        test -e "$tmp_dir/$other_pkg_name/Shfile.sh"
        test -e "$tmp_dir/$pkg_name/lib/a.sh"
}
