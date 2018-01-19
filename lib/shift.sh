set -e # errexit
set -u # nounset

ZeroDir="$(cd "$(dirname "$0")" && pwd)"
: ${ShiftDir:=${SHIFT_DIR:-$ZeroDir/.shift}}
: ${ShiftApi:=${SHIFT_API:-1}}

export SHIFT_DIR
export SHIFT_API

## Internal API.
## Example:
## shift_api 1
shift_api()
{
        . "$ShiftDir/lib/shift.v$1.sh"
}

shift_api $ShiftApi
