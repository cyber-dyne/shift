. "$__dir__/_pkg.sh"

it_should_import_a_pkg_lib()
{
        import $pkg_name/a

        test "$A" = 'lib a'
        test $(a) = 'a'

        import $pkg_name/b

        test "$A" = 'lib a'
        test $(a) = 'a'
        test "$B" = 'lib b'
        test $(b) = 'b'
}

it_should_import_all_pkg_libs()
{
        import $pkg_name/all

        test "$A" = 'lib a'
        test $(a) = 'a'
        test "$B" = 'lib b'
        test $(b) = 'b'
}

it_should_throw_error_for_lib_not_found()
{
        out="$(import $pkg_name/fake 2>&1 || test $? -eq 1)"

        test "$out" = "import '$pkg_name/fake' not found."
}
