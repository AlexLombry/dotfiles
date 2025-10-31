# Git
alias nah="git reset --hard; git clean -df;"
alias wip='git status && git add . && git commit -m "Work In Progress"'
alias gpra='git pull --rebase --autostash'
alias glfh="git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10"
