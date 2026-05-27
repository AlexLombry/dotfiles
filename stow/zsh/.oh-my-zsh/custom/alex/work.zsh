# Work Helpers

formatjsonlog() {
  while read -r data; do
    printf "%s" "$data" | jq -r '.["@timestamp"][11:22] + " " + .level + " " + .message + "\n" + .error.stack'
  done
}

cjq() {
    echo '' | fzf --print-query --preview "cat $1 | jq {q}"
}

runmysql() {
    docker run --name mysql --platform linux/x86_64 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -v $HOME/Sites/docker/mysql/data_folder:/var/lib/mysql -p 3306:3306 -d mysql:5.7
}
