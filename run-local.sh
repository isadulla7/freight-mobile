#!/bin/bash
set -euo pipefail

# =============================================================
#  Freight — USB telefonda ishga tushirish
#
#  Ishlatish:
#     ./run-local.sh              — USB rejimi (adb reverse, tavsiya etiladi)
#     ./run-local.sh wifi         — Wi-Fi rejimi (kompyuter IP orqali)
#
#  Skript bajaradi:
#     1. Backend'ni ishga tushiradi (Docker yoki Gradle)
#     2. Telefonni backendga ulaydi (adb reverse yoki Wi-Fi IP)
#     3. flutter run
#
#  Sozlamalar:
#     BACKEND_DIR=/path/to/freight-backend ./run-local.sh
#     BASE_URL=http://192.168.1.5:8080/api/v1 ./run-local.sh wifi
# =============================================================

MODE="usb"
if [ "${1:-}" = "wifi" ] || [ "${1:-}" = "usb" ]; then
    MODE="$1"
    shift
fi

MOBILE_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="${BACKEND_DIR:-$(cd "$MOBILE_DIR/../freight-backend" 2>/dev/null && pwd || echo "")}"
API_PORT=8080
HEALTH_URL="http://localhost:${API_PORT}/actuator/health"

info()  { echo -e "\033[0;36m>>>\033[0m $*"; }
ok()    { echo -e "\033[0;32m✓\033[0m $*"; }
fail()  { echo -e "\033[0;31m✗\033[0m $*" >&2; }

backend_is_up() {
    curl -sf "$HEALTH_URL" > /dev/null 2>&1
}

# ---------------------------------------------------------------
# 1. Backend
# ---------------------------------------------------------------
if backend_is_up; then
    ok "Backend allaqachon ishlayapti (localhost:${API_PORT})"
else
    if [ -z "$BACKEND_DIR" ] || [ ! -d "$BACKEND_DIR" ]; then
        fail "Backend papkasi topilmadi."
        echo "   freight-backend'ni shu papka yoniga qo'ying, yoki:"
        echo "   BACKEND_DIR=/path/to/freight-backend ./run-local.sh"
        exit 1
    fi

    info "Backend ishga tushirilmoqda: $BACKEND_DIR"

    if docker info > /dev/null 2>&1; then
        # --- Docker yo'li (JDK kerak emas) ---
        info "Docker orqali (postgres + redis + backend)..."
        ( cd "$BACKEND_DIR" && docker compose up -d postgres redis backend )
    else
        # --- Gradle yo'li (JDK 25 kerak) ---
        info "Docker ishlamayapti — Gradle orqali (JDK 25 kerak)..."
        ( cd "$BACKEND_DIR" && docker compose up -d postgres redis ) 2>/dev/null || {
            fail "Docker infra ishga tushmadi. Docker Desktop'ni yoqing."
            exit 1
        }

        ( cd "$BACKEND_DIR" && \
          DB_URL=jdbc:postgresql://localhost:5432/freight \
          DB_USERNAME=freight \
          DB_PASSWORD=freight \
          REDIS_HOST=localhost \
          REDIS_PORT=6379 \
          REDIS_PASSWORD="" \
          REDIS_SSL_ENABLED=false \
          JWT_PRIVATE_KEY="" \
          FREIGHT_SECURITY_DEPLOYMENT=LOCAL \
          SERVER_PORT=${API_PORT} \
          ./gradlew bootRun > /tmp/freight-backend.log 2>&1 & )

        echo "   Loglar: /tmp/freight-backend.log"
    fi

    info "Backend tayyor bo'lishini kutish (bir necha daqiqa olishi mumkin)..."
    for i in $(seq 1 180); do
        if backend_is_up; then
            ok "Backend tayyor!"
            break
        fi
        if [ "$i" -eq 180 ]; then
            fail "Backend 6 daqiqada ishga tushmadi."
            echo "   Loglarni ko'ring: docker logs freight-backend"
            echo "                    yoki: tail -50 /tmp/freight-backend.log"
            exit 1
        fi
        sleep 2
    done
fi

# ---------------------------------------------------------------
# 2. Telefonni backendga ulash
# ---------------------------------------------------------------
if ! command -v adb > /dev/null 2>&1; then
    fail "adb topilmadi. Android SDK Platform Tools o'rnating."
    echo "   Yoki PATH ga qo'shing: ~/Android/Sdk/platform-tools"
    exit 1
fi

DEVICES=$(adb devices | tail -n +2 | grep -w "device" | cut -f1 || true)

if [ -z "$DEVICES" ]; then
    fail "Ulangan qurilma topilmadi."
    echo "   • Telefonni USB orqali ulang"
    echo "   • Sozlamalar → Developer options → USB debugging yoqing"
    echo "   • Telefondagi 'Allow USB debugging?' oynasida OK bosing"
    exit 1
fi

if [ "$MODE" = "wifi" ]; then
    # Wi-Fi: kompyuterning lokal IP manzili
    LOCAL_IP=""
    if command -v ip > /dev/null 2>&1; then
        LOCAL_IP=$(ip route get 1 2>/dev/null | awk '{print $7; exit}')
    elif command -v ifconfig > /dev/null 2>&1; then
        LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
    fi

    if [ -z "$LOCAL_IP" ]; then
        fail "Lokal IP aniqlanmadi. Qo'lda bering:"
        echo "   BASE_URL=http://192.168.1.5:${API_PORT}/api/v1 ./run-local.sh"
        exit 1
    fi

    ok "Kompyuter IP: $LOCAL_IP"
    echo "   Telefon shu Wi-Fi tarmoqda bo'lsin."
    BASE_URL="${BASE_URL:-http://${LOCAL_IP}:${API_PORT}/api/v1}"
else
    # USB: adb reverse — tarmoqqa bog'liq emas
    for dev in $DEVICES; do
        adb -s "$dev" reverse tcp:${API_PORT} tcp:${API_PORT} > /dev/null
        ok "adb reverse sozlandi: $dev"
    done
    BASE_URL="${BASE_URL:-http://localhost:${API_PORT}/api/v1}"
fi

# ---------------------------------------------------------------
# 3. Flutter run
# ---------------------------------------------------------------
echo ""
echo "=============================================="
echo "  Rejim   : $MODE"
echo "  Backend : ${BASE_URL}"
echo "  Swagger : http://localhost:${API_PORT}/swagger-ui/index.html"
echo "  OTP kodi: 123456"
echo "=============================================="
echo ""

cd "$MOBILE_DIR"
exec flutter run --dart-define=BASE_URL="$BASE_URL" "$@"
