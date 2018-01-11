. "$__dir__/_pkg.sh"

it_should_fix_imports()
{
        rm -f "$tmp_dir/$pkg_name/lib/import.sho"
        test ! -e "$tmp_dir/$pkg_name/lib/import.sho"

        shift_fix_imports "$tmp_dir/$pkg_name" "$pkg_name"
        test -e "$tmp_dir/$pkg_name/lib/import.sho"
        test $(stat -f '%m' "$tmp_dir/$pkg_name/lib/import.sh") -le $(stat -f '%m' "$tmp_dir/$pkg_name/lib/import.sho")
}

it_should_fix_imports_after_an_update()
{
        sleep 1
        touch "$tmp_dir/$pkg_name/lib/import.sh"
        test $(stat -f '%m' "$tmp_dir/$pkg_name/lib/import.sh") -gt $(stat -f '%m' "$tmp_dir/$pkg_name/lib/import.sho")

        sleep 1
        shift_fix_imports "$tmp_dir/$pkg_name" "$pkg_name"
        test $(stat -f '%m' "$tmp_dir/$pkg_name/lib/import.sh") -lt $(stat -f '%m' "$tmp_dir/$pkg_name/lib/import.sho")
}
