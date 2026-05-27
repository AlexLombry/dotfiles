# Work (ManoMano) Helpers

formatjsonlog() {
  while read -r data; do
    printf "%s" "$data" | jq -r '.["@timestamp"][11:22] + " " + .level + " " + .message + "\n" + .error.stack'
  done
}

daily() {
    cd $HOME/ManoMano/meeting-notes
    vim daily.md
}

cjq() {
    echo '' | fzf --print-query --preview "cat $1 | jq {q}"
}

vaultcp() {
    if [ $# -ne 2 ]; then
        echo "Usage: vaultcp <env> <path>"
        return 1
    fi

    local env=$1
    local kvPath=$2
    local role="order"

    # Authenticate only if needed
    if ! VAULT_ADDR="https://vault-eu-west-3.${env}.manomano.com" vault token lookup -format=json > /dev/null 2>&1; then
        VAULT_ADDR="https://vault-eu-west-3.${env}.manomano.com" vault login -path=sso -method=oidc role="$role"
    fi

    local json=$(VAULT_ADDR="https://vault-eu-west-3.${env}.manomano.com" vault kv get -format=json "${env}/${kvPath}" | jq '.data.data')

    # Use printf to safely handle JSON data and escape necessary characters
    local previewCmd=$(printf "echo '%s' | jq --raw-output .\\\"{}\\\"" "$json")
    local bindCmd=$(printf "echo '%s' | jq --raw-output --join-output .\\\"{}\\\" | xclip" "$json")

    # Use echo to pass the JSON keys to fzf, preview and bind must handle complex commands properly
    echo "$json" | jq -r 'keys[]' | fzf --preview "$previewCmd" --bind "enter:execute($bindCmd)"
}

set_aws_role() {
    local role="${1:?Usage: set_aws_role <role_name>}"

    # Optional: backup current config
    local cfg="${AWS_CONFIG_FILE:-$HOME/.aws/config}"
    [ -f "$cfg" ] && cp -a "$cfg" "$cfg.bak.$(date +%Y%m%d%H%M%S)"

    # Iterate all profiles and set the role
    while IFS= read -r p; do
        [ -n "$p" ] || continue
        aws configure set "profile.$p.sso_role_name" "$role"
    done < <(aws configure list-profiles)

    echo "Set sso_role_name=$role for all profiles."
}

runmysql() {
    docker run --name mysql --platform linux/x86_64 -e MYSQL_ALLOW_EMPTY_PASSWORD=yes -v $HOME/Sites/docker/mysql/data_folder:/var/lib/mysql -p 3306:3306 -d mysql:5.7
}
