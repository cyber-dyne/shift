. "$__dir__/_pkg.sh"

it_should_fix_imports()
{
        sleep 1

        rm -f "$tmp_dir/$pkg_name/lib/import.sho"
        test ! -e "$tmp_dir/$pkg_name/lib/import.sho"

        shift_fix_imports "$tmp_dir/$pkg_name" "$pkg_name"
        test -e "$tmp_dir/$pkg_name/lib/import.sh"
        test -e "$tmp_dir/$pkg_name/lib/import.sho"
}

it_should_fix_imports_after_an_update()
{
        sleep 1

        test ! -e "$tmp_dir/$pkg_name/lib/new.sh"
        test ! -e "$tmp_dir/$pkg_name/lib/new.sho"
        echo " " > "$tmp_dir/$pkg_name/lib/new.sh" ## ed complains in case of empty file.
        shift_fix_imports "$tmp_dir/$pkg_name" "$pkg_name"
        test -e "$tmp_dir/$pkg_name/lib/new.sh"
        test -e "$tmp_dir/$pkg_name/lib/new.sho"
}
