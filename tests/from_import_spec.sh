. "$__dir__/_pkg.sh"

it_should_import_a_lib_from_a_pkg()
{
        from $pkg_name import a

        test "$A" = 'lib a'
        test $(a) = 'a'

        from $pkg_name import b

        test "$A" = 'lib a'
        test $(a) = 'a'
        test "$B" = 'lib b'
        test $(b) = 'b'
}

it_should_import_multiple_libs_from_a_pkg()
{
        from $pkg_name import a b

        test "$A" = 'lib a'
        test $(a) = 'a'
        test "$B" = 'lib b'
        test $(b) = 'b'
}

it_should_import_all_libs_from_a_pkg()
{
        from $pkg_name import all

        test "$A" = 'lib a'
        test $(a) = 'a'
        test "$B" = 'lib b'
        test $(b) = 'b'
}
