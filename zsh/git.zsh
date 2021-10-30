# Git
alias nah="git reset --hard; git clean -df;"

alias git-count-lines="git ls-files | xargs -n1 git blame --line-porcelain | sed -n 's/^author //p' | sort -f | uniq -ic | sort -nr"
alias wip='git status && git add . && git commit -m "Work In Progress"'
alias gpra='git pull --rebase --autostash'

# git root
function git-give-credit() {
    git commit --amend --author $1 <$2> -C HEAD
}

# a simple git rename file function
# git does not track case-sensitive changes to a filename.
function git-rename() {
    git mv $1 "${2}-"
    git mv "${2}-" $2
}

# Rename branches
function git-rename-branch()
{
    git branch -m $1 $2
    git push origin :$1
    git push --set-upstream origin $2
}

function git-update() {
    git pull --rebase --autostash
    git checkout develop
    git pull --rebase --autostash
    git checkout master
}

# take this repo and copy it to somewhere else minus the .git stuff.
function git-export(){
    mkdir -p "$1"
    git archive master | tar -x -C "$1"
}

function git-upstream() {
    echo "Launch git branch --set-upstream-to=origin/$1 $1"
    git branch --set-upstream-to=origin/$1 $1
}

alias glfh="git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10"
