# Git
alias nah="git reset --hard; git clean -df;"
alias wip='git status && git add . && git commit -m "Work In Progress"'
alias gpra='git pull --rebase --autostash'
alias glfh="git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10"
alias amend='git commit --verbose --amend'

# Open a github/gitlab repo in the browser
hb() {
  if [ ! -d .git ] && ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "ERROR: This isnt a git directory" && return false
  fi
  git_url=$(git config --get remote.origin.url)
  if [[ $git_url == https://gitlab* ]]; then
    url=${git_url%.git}
  elif [[ $git_url == https://github* ]]; then
    url=${git_url%.git}
  elif [[ $git_url == git@gitlab* ]]; then
    url=${git_url:4}
    url=${url/\:/\/}
    url="https://${url%.git}"
  elif [[ $git_url == git@github* ]]; then
    url=${git_url:4}
    url=${url/\:/\/}
    url="https://${url%.git}"
  elif [[ $git_url == git://github* ]]; then
    url=${git_url:4}
    url=${url/\:/\/}
    url="https://${url%.git}"
  else
    echo "ERROR: Remote origin is invalid" && return false
  fi
  open $url
}

pull_all_project() {
    # Define the directory containing your git projects
    projects_dir=$PWD

    # Loop through each directory in the projects_dir
    for dir in "$projects_dir"/*; do
      if [ -d "$dir/.git" ]; then
        echo "Updating project in $dir"
        cd "$dir"
        git pull --rebase --autostash
      else
        echo "Skipping $dir, not a git repository"
      fi
    done
}
