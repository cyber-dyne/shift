## This wrapper can be embedded in a project not using git submodules to easly
## acquire Shift at runtime.
set -eu

cmd_name=shift
ssh_repo="git@github.com:evilcorptech/shift.git"
http_repo="https://github.com/evilcorptech/shift.git"
repo_url="$http_repo"
repo_branch=master
repo_rev=$repo_branch
repo_dir="$(cd "$(dirname "$0")" && pwd)/.$cmd_name"
cmd_exec="$repo_dir/lib/$cmd_name.sh"

if ! test -e "$repo_dir/.git"; then
        git clone --quiet -b "$repo_branch" "$repo_url" "$repo_dir"
        git --git-dir "$repo_dir/.git" --work-tree "$repo_dir" checkout --quiet "$repo_rev"
fi

. "$cmd_exec"
