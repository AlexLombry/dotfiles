# Navigation Helpers

# Create a new directory and enter it
mkcd() {
    mkdir -p "$@" && cd "$@"
}

hist() {
    history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# fd shorthand
fn() {
    fd "$1"
}

# navigation
cx() {
    cd "$@" && l;
}

fcd() {
    cd "$(fd -t d --hidden --exclude .git | fzf)" && ls;
}

f() {
    fd -t f --hidden --exclude .git | fzf | pbcopy
}

fv() {
    nvim "$(fd -t f --hidden --exclude .git | fzf)"
}

# Go to the root of the current git project, or just go one folder up
up() {
  export git_dir="$(git rev-parse --show-toplevel 2> /dev/null)"
  if [ -z $git_dir ]
  then
    cd ..
  else
    cd $git_dir
  fi
}

cdf() {
    # cd into whatever is the forefront Finder window.
    local path=$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')
    echo "$path"
    cd "$path"
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
o() {
    if [ $# -eq 0 ]; then
        open .;
    else
        open "$@";
    fi;
}
