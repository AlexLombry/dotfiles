#!/usr/bin/env bash
set -euo pipefail

# =========================
# Default configuration
# =========================
IMAGE="${IMAGE:-kasmweb/chromium:aarch64-1.18.0-rolling-weekly}"
NAME="${NAME:-chromium-sandbox}"
PLATFORM="${PLATFORM:-linux/arm64/v8}"
PORT="${PORT:-6901}"                 # Hosting port of container to 6901
TZ="${TZ:-Europe/Paris}"
SHM_SIZE="${SHM_SIZE:-1g}"
CPUS="${CPUS:-2}"
MEMORY="${MEMORY:-2g}"
VNC_PW="${VNC_PW:-}"                 # if empty will be generated
OPEN_BROWSER="${OPEN_BROWSER:-1}"    # 1 => Automatically open noVNC

usage() {
  cat <<EOF
Usage: $(basename "$0") [URL] [--stop] [--status] [--port N] [--password XXX] [--no-open]
  URL            : Link to open in sandboxed Chromium (default: about:blank)
  --stop         : Stop and delete the container
  --status       : Display the status and access URL
  --port N       : Expose the container on https://localhost:N (default 6901)
  --password XXX : VNC/noVNC password (otherwise generated)
  --no-open      : "Do not automatically open the UI in the browser"
  ENV vars       : IMAGE, NAME, PLATFORM, TZ, SHM_SIZE, CPUS, MEMORY, VNC_PW
Examples :
  $(basename "$0") "https://exemple.com"
  PORT=6902 $(basename "$0") "https://site-suspect.tld"
  $(basename "$0") --stop
EOF
}

# ===============
# Parse arguments
# ===============
URL="about:blank"
ACTION="run"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --stop)   ACTION="stop"; shift ;;
    --status) ACTION="status"; shift ;;
    --port)   PORT="${2:-6901}"; shift 2 ;;
    --password) VNC_PW="${2:-}"; shift 2 ;;
    --no-open) OPEN_BROWSER=0; shift ;;
    -h|--help) usage; exit 0 ;;
    *) URL="$1"; shift ;;
  esac
done

# =========================
# Nice functions
# =========================
rand_pw() {
  # Generate a random password
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 12 | tr -d '\n' | tr '/+' 'Xy'
  else
    date +%s | sha256sum 2>/dev/null | cut -c1-16 || echo "password"
  fi
}

port_in_use() {
  local p="$1"
  if command -v lsof >/dev/null 2>&1; then
    lsof -i :"$p" -sTCP:LISTEN >/dev/null 2>&1
  else
    nc -z localhost "$p" >/dev/null 2>&1
  fi
}

find_free_port() {
  local start="${1:-6901}"
  local p="$start"
  for _ in {1..20}; do
    if ! port_in_use "$p"; then
      echo "$p"; return 0
    fi
    p=$((p+1))
  done
  echo "$start"
}

open_browser() {
  local url="$1"
  if [[ "$OPEN_BROWSER" -eq 1 ]]; then
    if command -v open >/dev/null 2>&1; then
      open "$url"
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "$url"
    else
      echo "→ Manually open : $url"
    fi
  else
    echo "Available UI : $url"
  fi
}

wait_ready() {
  local url="$1"
  echo "⏳ Waiting noVNC UI for $url ..."
  for _ in {1..60}; do
    if curl -sk --max-time 2 "$url" >/dev/null 2>&1; then
      echo "✅ UI Ready."
      return 0
    fi
    sleep 1
  done
  echo "⚠️ The noVNC UI is not responding yet. Try to open it anyway. : $url"
}

container_running() {
  docker ps --format '{{.Names}}' | grep -qx "$NAME"
}

container_exists() {
  docker ps -a --format '{{.Names}}' | grep -qx "$NAME"
}

launch_url_in_container() {
  local url="$1"
  # Try chromium, chromium-browser, google-chrome (just in case)
  docker exec "$NAME" bash -lc '
    BROWSER=$(command -v chromium || command -v chromium-browser || command -v google-chrome || echo "")
    if [[ -z "$BROWSER" ]]; then
      echo "Chromium not found in the container." >&2
      exit 1
    fi
    pkill -f "$BROWSER" 2>/dev/null || true
    # --no-sandbox is generally necessary in a non-privileged container
    nohup "$BROWSER" --no-sandbox --password-store=basic "'"$url"'" >/dev/null 2>&1 &
  '
}

# ===============
# Actions simples
# ===============
if [[ "$ACTION" == "stop" ]]; then
  if container_exists; then
    docker stop "$NAME" >/dev/null
    echo "🛑 Container stopped and removed : $NAME"
  else
    echo "ℹ️  No container named $NAME."
  fi
  exit 0
fi

if [[ "$ACTION" == "status" ]]; then
  if container_running; then
    echo "✅ $NAME is currently running."
    echo "   Access : https://localhost:$PORT"
    echo "   (Auto-signed certificat to accept)"
  else
    echo "⛔ $NAME is not running."
  fi
  exit 0
fi

# ======================
# Launch / Reuse
# ======================
if ! container_running; then
  # Port selection: if requested and occupied, we switch automatically.
  if port_in_use "$PORT"; then
    echo "⚠️  Port $PORT est busy. Looking for a free port..."
    PORT="$(find_free_port "$PORT")"
    echo "→ Port usage $PORT."
  fi

  # Mot de passe VNC
  if [[ -z "$VNC_PW" ]]; then
    VNC_PW="$(rand_pw)"
    echo "🔐 Username is : kasm_user"
    echo "🔐 VNC generated password : $VNC_PW"
  fi

  echo "🚀 Launching container $NAME (image: $IMAGE)"
  docker run -d --rm \
    --name "$NAME" \
    --platform="$PLATFORM" \
    -e TZ="$TZ" \
    -e VNC_PW="$VNC_PW" \
    --shm-size="$SHM_SIZE" \
    --cpus="$CPUS" --memory="$MEMORY" \
    --security-opt no-new-privileges \
    --pids-limit=512 \
    --cap-drop=ALL \
    -p "127.0.0.1:$PORT:6901" \
    "$IMAGE" >/dev/null

  UI_URL="https://localhost:$PORT"
  wait_ready "$UI_URL"
  open_browser "$UI_URL"
else
  echo "ℹ️  Container already running : $NAME"
  # Finding port with docker inspect
  MAP_PORT="$(docker inspect "$NAME" --format='{{range $p, $conf := .NetworkSettings.Ports}}{{if eq $p "6901/tcp"}}{{(index $conf 0).HostPort}}{{end}}{{end}}' 2>/dev/null || true)"
  UI_URL="https://localhost:${MAP_PORT:-$PORT}"
  echo "→ UI : $UI_URL"
  open_browser "$UI_URL"
fi

# ======================
# Opening requested URL
# ======================
if [[ -n "${URL:-}" ]]; then
  echo "🌐 Opening URL in sandbox : $URL"
  launch_url_in_container "$URL" || {
    echo "❌ Impossible to run Chromium into the container. Logs :"
    docker logs "$NAME" --tail 100
    exit 1
  }
fi

echo "✅ Ready UI : $UI_URL"
echo "🛑 To STOP : $(basename "$0") --stop"
