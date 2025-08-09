#!/bin/bash

# ==========================
# --- Konfigurasi awal ---
# ==========================
REPO_URL="https://github.com/Riswan481/xaraybot.git"
TEMP_DIR="/tmp/xaraybot-install"
WHITELIST_URL="https://raw.githubusercontent.com/Riswan481/xaraybot/main/allowed_ips.txt"


# Ambil IP publik VPS
MYIP=$(curl -sS ipv4.icanhazip.com)

# Cek IP
if ! curl -sS "$WHITELIST_URL" | grep -qw "$MYIP"; then
    echo "❌ IP $MYIP tidak terdaftar di whitelist."
    echo "Hubungi admin untuk mendaftarkan IP VPS Anda."
    exit 1
fi

echo "✅ IP $MYIP terdaftar, melanjutkan proses..."

# Deteksi OS
detect_os() {
    if [ -f /etc/debian_version ]; then
        OS="debian"
    elif [ -f /etc/redhat-release ]; then
        OS="redhat"
    elif [ -f /etc/alpine-release ]; then
        OS="alpine"
    elif [ "$(uname)" == "Darwin" ]; then
        OS="macos"
    elif [ "$(uname -o 2>/dev/null)" == "Android" ] || [ -n "$ANDROID_ROOT" ]; then
        OS="termux"
    else
        OS="unknown"
    fi
}

# Install dependencies
install_deps() {
    case "$OS" in
        debian)
            sudo apt update -y && sudo apt upgrade -y
            sudo apt install -y curl git
            curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -
            sudo apt install -y nodejs
            ;;
        redhat)
            sudo yum install -y curl git nodejs npm
            ;;
        alpine)
            sudo apk update && sudo apk add curl git nodejs npm
            ;;
        macos)
            brew install curl git node
            ;;
        termux)
            pkg update -y && pkg install -y curl git nodejs
            ;;
        *)
            echo "⚠ OS tidak dikenali, silakan install manual: curl git nodejs npm"
            ;;
    esac

    if ! command -v pm2 &>/dev/null; then
        npm install -g pm2
    fi
}

# Menu
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "   📦 MENU BOT TELEGRAM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Install bot (PM2)"
echo "2. Hapus bot"
echo "0. Keluar"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Pilih opsi: " opsi

detect_os

if [ "$opsi" == "1" ]; then
    echo "🚀 Mulai instalasi bot Telegram..."
    install_deps

    echo "📌 Node.js: $(node -v)"
    echo "📌 NPM: $(npm -v)"

    if [ -d "$BOT_DIR" ]; then
        echo "🗑 Menghapus folder lama..."
        rm -rf "$BOT_DIR"
    fi

    echo "📥 Meng-clone repo bot..."
    git clone "$REPO_URL" "$BOT_DIR"

    cd "$BOT_DIR" || exit
    git checkout main
    npm install

    echo "▶ Menjalankan bot dengan PM2..."
    pm2 start bot.js --name "$BOT_NAME"
    pm2 save

    if [ "$(whoami)" == "root" ]; then
        pm2 startup systemd
        systemctl enable pm2-root
        systemctl start pm2-root
    else
        pm2 startup systemd -u $(whoami) --hp $(eval echo ~$USER)
        sudo systemctl enable pm2-$(whoami)
        sudo systemctl start pm2-$(whoami)
    fi

    echo "✅ Bot berjalan di background."
    echo "ℹ Cek status: pm2 status"
    echo "ℹ Lihat log: pm2 logs $BOT_NAME"

elif [ "$opsi" == "2" ]; then
    echo "🛑 Menghapus bot Telegram..."
    if pm2 list | grep -q "$BOT_NAME"; then
        pm2 stop "$BOT_NAME"
        pm2 delete "$BOT_NAME"
    fi
    [ -d "$BOT_DIR" ] && rm -rf "$BOT_DIR"
    echo "✅ Bot dihapus."

elif [ "$opsi" == "0" ]; then
    echo "Keluar..."
    exit 0
else
    echo "⚠ Pilihan tidak valid!"
fi