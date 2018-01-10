. "$__dir__/_pkg.sh"

it_should_require_one_package()
{
        set -- "$__file__"

        . "$__dir__/../lib/shift.sh"

        require "$pkg_repo"

        test -e "$tmp_dir/$pkg_name/.git"
        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        grep -q "^import $pkg_name" "$tmp_dir/$pkg_name/lib/all.sh"
        ! grep -q "^import *\." "$tmp_dir/$pkg_name/lib/all.sh"
        grep -q "^from $pkg_name import" "$tmp_dir/$pkg_name/lib/all.sh"
        ! grep -q "^from *\. import" "$tmp_dir/$pkg_name/lib/all.sh"
        grep -q "^import $pkg_name" "$tmp_dir/$pkg_name/lib/import.sh"
        ! grep -q "^import *\." "$tmp_dir/$pkg_name/lib/import.sh"
        grep -q "^from $pkg_name import" "$tmp_dir/$pkg_name/lib/import_from.sh"
        ! grep -q "^from *\. import" "$tmp_dir/$pkg_name/lib/import_from.sh"
}

it_should_require_one_package_with_a_name()
{
        set -- "$__file__"

        . "$__dir__/../lib/shift.sh"

        require "$pkg_repo" -as $pkg_name.v1

        test -e "$tmp_dir/$pkg_name.v1/.git"
        grep -q "^from $pkg_name\.v1 import" "$tmp_dir/$pkg_name.v1/lib/all.sh"
        ! grep -q "^from *\. import" "$tmp_dir/$pkg_name.v1/lib/all.sh"
        grep -q "^import $pkg_name\.v1" "$tmp_dir/$pkg_name.v1/lib/all.sh"
        ! grep -q "^import *\." "$tmp_dir/$pkg_name.v1/lib/all.sh"
}

it_should_require_one_package_with_a_branch_and_rev()
{
        set -- "$__file__"

        . "$__dir__/../lib/shift.sh"

        require "$pkg_repo" -branch master -rev HEAD~1

        test -e "$tmp_dir/$pkg_name/lib/a.sh"
        ! test -e "$tmp_dir/$pkg_name/lib/b.sh"
}
