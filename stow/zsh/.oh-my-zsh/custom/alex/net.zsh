# Network Helpers

# All the dig info
digga() {
    dig +nocmd "$1" any +multiline +noall +answer
}

ncx() {
    nc -l -n -vv -p $1 -k
}

ipinfo() {
    curl http://ipinfo.io/$1
}

freeport() {
  PORT=$1
  PID=`lsof -ti tcp:$PORT`
  if [ -z "$PID" ]; then
    echo "No process running on port $PORT"
  else
    kill -KILL $PID
  fi
}

whoseport() {
  lsof -i ":$1" | grep LISTEN
}

killport() {
  lsof -t -i ":$1" | xargs kill -9
}
