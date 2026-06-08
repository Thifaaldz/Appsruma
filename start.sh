#!/usr/bin/env bash
set -euo pipefail

APP="${1:-}"
shift || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${APP}" != "owner" && "${APP}" != "tenant" ]]; then
  cat <<'EOF'
Usage: ./start.sh owner|tenant [flutter args...]

Examples:
  ./start.sh owner
  ./start.sh tenant -d <device-id>
EOF
  exit 1
fi

case "${APP}" in
  owner)
    PROJECT_DIR="${SCRIPT_DIR}/rumaowner"
    ;;
  tenant)
    PROJECT_DIR="${SCRIPT_DIR}/rumatenant"
    ;;
esac

detect_ip() {
  if command -v ip >/dev/null 2>&1; then
    local routed_ip
    routed_ip="$(ip route get 1.1.1.1 2>/dev/null | awk '/src/ { for (i = 1; i <= NF; i++) if ($i == "src") { print $(i + 1); exit } }')"
    if [[ -n "${routed_ip}" ]]; then
      printf '%s\n' "${routed_ip}"
      return 0
    fi
  fi

  if command -v hostname >/dev/null 2>&1; then
    local host_ip
    host_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    if [[ -n "${host_ip}" ]]; then
      printf '%s\n' "${host_ip}"
      return 0
    fi
  fi

  return 1
}

BACKEND_IP="${RUMA_BACKEND_IP:-$(detect_ip)}"
if [[ -z "${BACKEND_IP:-}" ]]; then
  echo "Failed to detect local IP. Set RUMA_BACKEND_IP manually." >&2
  exit 1
fi

BACKEND_URL="${RUMA_API_BASE_URL:-http://${BACKEND_IP}:8080/api}"

cd "${PROJECT_DIR}"
flutter run --dart-define="RUMA_API_BASE_URL=${BACKEND_URL}" "$@"
