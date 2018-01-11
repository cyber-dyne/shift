before_all()
{
        : ${TMPDIR:=/tmp}
}

it_should_have_default_values()
{
        unset SHIFT_DIR
        unset SHIFT_HOME_DIR
        unset SHIFT_PATH

        . "$__dir__/.shift/lib/shift.sh"

        test "$ShiftDir"     = "$__dir__/.shift"
        test "$ShiftHomeDir" = "$__dir__/shell.d"
        test "$ShiftPath"    = "$ShiftHomeDir:$HOME/.shell.d"
}

it_should_support_custom_values()
{
        SHIFT_DIR="$__dir__/.."
        SHIFT_HOME_DIR="$TMPDIR/shift_home"
        SHIFT_PATH="$TMPDIR/shift_path"

        . "$__dir__/.shift/lib/shift.sh"

        test "$ShiftDir"     = "$__dir__/.."
        test "$ShiftHomeDir" = "$TMPDIR/shift_home"
        test "$ShiftPath"    = "$ShiftHomeDir:$TMPDIR/shift_path"
}
