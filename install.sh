#!/bin/bash

# ==========================
# --- Konfigurasi awal ---
# ==========================
REPO_URL="https://github.com/Riswan481/xaraybot.git"
TEMP_DIR="/tmp/xaraybot-install"
WHITELIST_URL="https://raw.githubusercontent.com/Riswan481/xaraybot/main/allowed_ips.txt"

# ==========================
# --- Warna & Garis ---
# ==========================
YELLOW='\033[1;33m'
GREEN='\033[1;92m'
BLUE='\033[1;94m'
CYAN='\033[1;96m'
RED='\033[1;91m'
NC='\033[0m'
LINE="${CYAN}
═══════════════════════════════════════════════════════════════${NC}"

# Warna tambahan untuk Bot SellVPN
orange="\e[38;5;130m"
blue_bsvpn="\e[38;5;39m"
green_bsvpn="\e[38;5;82m"
red_bsvpn="\e[38;5;196m"
neutral_bsvpn="\e[0m"

# ==========================
# --- Fungsi loading ---
# ==========================
loading_spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\\'
  while kill -0 $pid 2>/dev/null; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  wait $pid
}

# ==========================
# --- Fungsi Bot SellVPN ---
# ==========================
hapus_bot_lama() {
    echo -e "${orange}Menghapus bot lama...${neutral_bsvpn}"
    systemctl stop sellvpn.service 2>/dev/null
    systemctl disable sellvpn.service 2>/dev/null
    rm -f /etc/systemd/system/sellvpn.service
    rm -f /usr/bin/sellvpn /usr/bin/server_sellvpn /etc/cron.d/server_sellvpn
    rm -rf /root/BotVPN4

    if command -v pm2 &>/dev/null; then
        pm2 delete sellvpn &>/dev/null
        pm2 save &>/dev/null
    fi

    systemctl daemon-reload
    echo -e "${green_bsvpn}Bot lama berhasil dihapus.${neutral_bsvpn}"
}

pasang_package() {
    echo -e "${blue_bsvpn}Memulai pengecekan dan instalasi dependensi...${neutral_bsvpn}"

    # Install Node.js v20 (stable)
    if ! command -v node >/dev/null 2>&1 || ! node -v | grep -q 'v20'; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi

    # Downgrade npm ke versi 10 untuk kompatibilitas
    npm install -g npm@10

    # Install dependensi APT lainnya
    apt update
    apt install -y build-essential libcairo2-dev libpango1.0-dev \
        libjpeg-dev libgif-dev librsvg2-dev pkg-config libpixman-1-dev git curl cron
}

setup_bot() {
    timedatectl set-timezone Asia/Jakarta

    if [ ! -d /root/BotVPN4 ]; then
        git clone https://github.com/script-vpn-premium/BotVPN4.git /root/BotVPN4
    fi

    cd /root/BotVPN4 || { echo -e "${red_bsvpn}Gagal masuk folder /root/BotVPN4${neutral_bsvpn}"; exit 1; }

    npm install sqlite3 express crypto telegraf axios dotenv canvas node-fetch form-data
    npm rebuild canvas

    # Pastikan modul node-fetch versi 2
    npm uninstall node-fetch
    npm install node-fetch@2

    chmod +x /root/BotVPN4/*
}

server_app() {
    clear
    echo -e "${orange}────────────────────────────────────────────${neutral_bsvpn}"
    echo -e "${CYAN}🎉 Selamat Datang di Bot Order VPN Otomatis 🎉${NC}"
    echo -e "${GREEN}🔐 Layanan VPN Premium • Cepat • Mudah • Aman${NC}"
    echo -e "${BLUE}🤖 Powered by RISWAN - Bot Telegram Modifikasi${NC}"
    echo -e "${orange}────────────────────────────────────────────${neutral_bsvpn}"

    read -p "Masukkan token bot: " token
    while [ -z "$token" ]; do read -p "Masukkan token bot: " token; done

    read -p "Masukkan admin ID: " adminid
    while [ -z "$adminid" ]; do read -p "Masukkan admin ID: " adminid; done

    read -p "Masukkan nama store: " namastore
    while [ -z "$namastore" ]; do read -p "Masukkan nama store: " namastore; done

    read -p "Masukkan DATA QRIS: " dataqris
    while [ -z "$dataqris" ]; do read -p "Masukkan DATA QRIS: " dataqris; done

    read -p "Masukkan MERCHANT ID: " merchantid
    while [ -z "$merchantid" ]; do read -p "Masukkan MERCHANT ID: " merchantid; done

    read -p "Masukkan API KEY: " apikey
    while [ -z "$apikey" ]; do read -p "Masukkan API KEY: " apikey; done

    read -p "Masukkan Chat ID Group Telegram: " chatid_group
    while [ -z "$chatid_group" ]; do read -p "Masukkan Chat ID Group Telegram: " chatid_group; done

    read -p "Masukkan Username Saweria: " username_saweria
    while [ -z "$username_saweria" ]; do read -p "Masukkan Username Saweria: " username_saweria; done

    read -p "Masukkan Email Saweria: " saweria_email
    while [ -z "$saweria_email" ]; do read -p "Masukkan Email Saweria: " saweria_email; done

    cat >/root/BotVPN4/.vars.json <<EOF
{
  "BOT_TOKEN": "$token",
  "USER_ID": "$adminid",
  "NAMA_STORE": "$namastore",
  "PORT": "50123",
  "DATA_QRIS": "$dataqris",
  "MERCHANT_ID": "$merchantid",
  "API_KEY": "$apikey",
  "GROUP_CHAT_ID": "$chatid_group",
  "SAWERIA_USERNAME": "$username_saweria",
  "SAWERIA_EMAIL": "$saweria_email"
}
EOF

    NODE_PATH=$(which node)
    if [ -z "$NODE_PATH" ]; then
        echo -e "${red_bsvpn}Node.js tidak ditemukan. Pastikan Node.js sudah terinstall.${neutral_bsvpn}"
        exit 1
    fi
    echo -e "${green_bsvpn}Node.js ditemukan di: $NODE_PATH${neutral_bsvpn}"

    cat >/usr/bin/sellvpn <<EOF
#!/bin/bash
cd /root/BotVPN4 || exit 1
$NODE_PATH app.js
EOF
    chmod +x /usr/bin/sellvpn

    cat >/etc/systemd/system/sellvpn.service <<EOF
[Unit]
Description=App Bot SellVPN Service
After=network.target

[Service]
ExecStart=$NODE_PATH /root/BotVPN4/app.js
WorkingDirectory=/root/BotVPN4
Restart=always
RestartSec=3
User=root
Environment=NODE_ENV=production
Environment=TZ=Asia/Jakarta
StandardOutput=append:/var/log/sellvpn.log
StandardError=append:/var/log/sellvpn-error.log
LimitNOFILE=10000

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable sellvpn
    systemctl restart sellvpn
    service cron restart

    echo -e "Status Server: $(systemctl is-active sellvpn)"
    echo -e "${green_bsvpn}Bot berhasil diinstal dan sedang berjalan.${neutral_bsvpn}"
}

# ==========================
# --- Menu Pilihan ---
# ==========================
clear
echo -e "${YELLOW}"
echo "═══════════════════════════════════════════════════════════════"
echo "🚀 INSTALLER SCRIPT XRAY & BOT WHATSAPP/TELEGRAM by RISWAN "
echo "═══════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo -e "${GREEN}Pilih opsi instalasi:${NC}"
echo -e "  1) 🔐 Install Script Xray"
echo -e "  2) 🤖 Install Bot WhatsApp"
echo -e "  3) 🗑️ Hapus Bot WhatsApp"
echo -e "  4) 🤖 Install Bot Telegram"
echo -e "  5) 🗑️ Hapus Bot Telegram"
echo -e "  6) 🤖 Install Bot SellVPN"
echo -e "${CYAN}  x) Keluar${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "$(echo -e "${YELLOW}Masukkan pilihan kamu (1/2/3/4/5/6/x): ${NC}")" INSTALL_OPTION

if [[ "$INSTALL_OPTION" == "x" || "$INSTALL_OPTION" == "X" ]]; then
  echo -e "${RED}❌ Proses dibatalkan oleh user.${NC}"
  exit 0
fi

if ! [[ "$INSTALL_OPTION" =~ ^[1-6]$ ]]; then
  echo -e "${RED}❌ Pilihan tidak valid. Instalasi dibatalkan.${NC}"
  exit 1
fi

# ==========================
# --- Cek IP & Izin ---
# ==========================
MY_IP=$(curl -s ipv4.icanhazip.com)
echo -e "$LINE"
echo -e "🌐 ${YELLOW}IP VPS Kamu:${NC} $MY_IP"
echo -e "🔍 ${YELLOW}Mengecek izin akses...${NC}"
echo -e "$LINE"

if curl -s "$WHITELIST_URL" | grep -q "$MY_IP"; then
  echo -e "✅ ${GREEN}IP kamu terdaftar di whitelist.${NC}"
else
  echo -e "❌ ${RED}Maaf, IP kamu ($MY_IP) tidak terdaftar di whitelist.${NC}"
  echo -e "➡️ ${YELLOW}Hubungi admin 6285888801241 untuk mendaftarkan IP kamu.${NC}"
  echo -e "$LINE"
  exit 1
fi

# ==========================
# --- Ganti mirror APT ---
# ==========================
echo -ne "${YELLOW}🌐 Mengganti mirror APT...${NC}"
(
  if grep -q 'ubuntu' /etc/os-release 2>/dev/null; then
    sed -i 's|http://.*.ubuntu.com|http://mirror.biznetgio.com/ubuntu|g' /etc/apt/sources.list
  elif grep -q 'debian' /etc/os-release 2>/dev/null; then
    sed -i 's|http://deb.debian.org|http://kartolo.sby.datautama.net.id/debian|g' /etc/apt/sources.list
  fi
) & loading_spinner

# ==========================
# --- Proses Instalasi ---
# ==========================

if [[ "$INSTALL_OPTION" == "1" ]]; then
  # Install Script Xray (tidak diubah)
  echo -e "$LINE"
  echo -e "${BLUE}🚀 Memulai instalasi script Xray...${NC}"
  echo -e "$LINE"

  echo -ne "${YELLOW}📦 Update sistem dan install curl & git...${NC}"
  (
    apt update -y -o Acquire::ForceIPv4=true && \
    apt upgrade -y --no-install-recommends && \
    apt install -y curl git
  ) & loading_spinner

  echo -ne "${YELLOW}🧹 Menghapus folder sementara lama...${NC}"
  (rm -rf "$TEMP_DIR") & loading_spinner

  echo -ne "${YELLOW}📥 Meng-clone repo: $REPO_URL ...${NC}"
  (git clone "$REPO_URL" "$TEMP_DIR") & loading_spinner

  echo -ne "${YELLOW}📁 Membuat folder /etc/xray...${NC}"
  (mkdir -p /etc/xray) & loading_spinner

  echo -ne "${YELLOW}📂 Menyalin file script ke /etc/xray...${NC}"
  (
    cp "$TEMP_DIR/add-vmess" /etc/xray/
    cp "$TEMP_DIR/add-vless" /etc/xray/
    cp "$TEMP_DIR/add-trojan" /etc/xray/
    cp "$TEMP_DIR/add-ss" /etc/xray/ 2>/dev/null || true
  ) & loading_spinner

  echo -ne "${YELLOW}🔐 Memberikan izin eksekusi...${NC}"
  (
    chmod +x /etc/xray/add-vmess
    chmod +x /etc/xray/add-vless
    chmod +x /etc/xray/add-trojan
    chmod +x /etc/xray/add-ss 2>/dev/null || true
  ) & loading_spinner

  echo -ne "${YELLOW}🔗 Membuat symlink ke /usr/bin...${NC}"
  (
    ln -sf /etc/xray/add-vmess /usr/bin/add-vmess
    ln -sf /etc/xray/add-vless /usr/bin/add-vless
    ln -sf /etc/xray/add-trojan /usr/bin/add-trojan
    ln -sf /etc/xray/add-ss /usr/bin/add-ss 2>/dev/null || true
  ) & loading_spinner

  echo -ne "${YELLOW}🧽 Menghapus folder sementara...${NC}"
  (rm -rf "$TEMP_DIR") & loading_spinner

elif [[ "$INSTALL_OPTION" == "2" ]]; then
  # ==========================
  # --- Install Bot WhatsApp ---
  # ==========================
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi Bot WhatsApp...${NC}"
  echo -e "$LINE"

  echo -ne "${YELLOW}📦 Menginstal nodejs, npm, git, jq...${NC}"
  (apt update -y && apt install -y nodejs npm git jq) & loading_spinner

  # Cek apakah folder simplebot sudah ada, jika ya hapus dulu supaya tidak error saat clone
  if [[ -d simplebot ]]; then
    echo -ne "${YELLOW}🧹 Folder simplebot sudah ada, menghapus dulu...${NC}"
    (rm -rf simplebot) & loading_spinner
  fi

  echo -ne "${YELLOW}📥 Clone repo bot WhatsApp...${NC}"
  (git clone https://github.com/Riswan481/xaraybot.git simplebot) & loading_spinner

  cd simplebot || { echo -e "${RED}❌ Gagal masuk ke folder simplebot${NC}"; exit 1; }

  echo -ne "${YELLOW}📦 Menginstall package npm...${NC}"
  (npm install) & loading_spinner

  echo -ne "${YELLOW}📦 Menginstall PM2...${NC}"
  (npm install -g pm2) & loading_spinner

  read -p "$(echo -e "${YELLOW}📱 Masukkan nomor WhatsApp owner (cth: 6281234567890): ${NC}")" OWNER_NUMBER

  if [[ -f settings.js ]]; then
    if grep -q "global\.owner" settings.js; then
      sed -i -E "s/global\.owner *= *[\"'][^\"']*[\"']/global.owner = \"$OWNER_NUMBER\"/" settings.js
      echo -e "${YELLOW}✅ global.owner berhasil diubah ke string: \"$OWNER_NUMBER\"${NC}"
    else
      echo -e "${RED}❌ Tidak ditemukan baris global.owner di settings.js${NC}"
    fi
  else
    echo -e "${RED}❌ File settings.js tidak ditemukan!${NC}"
  fi

  read -n 1 -s -r -p "➡️ Tekan Enter untuk melanjutkan pairing WhatsApp..."
  echo ""

  echo -e "${YELLOW}🔑 Menjalankan pairing WhatsApp...${NC}"
  echo -e "${YELLOW}🕒 Tunggu sampai muncul '✅ Bot terhubung!', lalu tekan CTRL+C...${NC}"
  echo ""

  node index.js

  echo -e ""
  echo -e "${GREEN}✅ Pairing sukses. Menjalankan bot di PM2...${NC}"

  cd simplebot || exit

  pm2 delete simplebot 2>/dev/null
  pm2 start index.js --name simplebot
  pm2 save
  pm2 startup

  echo -e "${GREEN}✅ Bot berhasil dijalankan di PM2 dengan nama: simplebot${NC}"
  pm2 list

elif [[ "$INSTALL_OPTION" == "3" ]]; then
  # Hapus Bot WhatsApp
  echo -e "$LINE"
  echo -e "${RED}🗑️ Menghapus Bot WhatsApp...${NC}"
  echo -e "$LINE"

  echo -ne "${YELLOW}📍 Menghapus folder simplebot...${NC}"
  (rm -rf simplebot) & loading_spinner

  echo -ne "${YELLOW}🧹 Menghapus PM2 dan proses bot...${NC}"
  (
    pm2 stop simplebot >/dev/null 2>&1
    pm2 delete simplebot >/dev/null 2>&1
    pm2 save
  ) & loading_spinner

  echo -e "${GREEN}✅ Bot WhatsApp berhasil dihapus.${NC}"

elif [[ "$INSTALL_OPTION" == "4" ]]; then
  # Install Bot Telegram
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi Bot Telegram...${NC}"
  echo -e "$LINE"

  echo -e "${CYAN}[1]${NC} Mengupdate sistem dan install Node.js..."
  apt update && apt install -y nodejs npm git unzip curl
  sleep 1

  echo -e "${CYAN}[2]${NC} Clone repo bot-regist..."
  git clone https://github.com/Riswan481/bot-regist.git
  cd bot-regist || { echo -e "${RED}❌ Gagal masuk ke folder bot-regist${NC}"; exit 1; }

echo -e "${CYAN}[3]${NC} Install dependensi Node.js..."
  npm install
  npm install pm2 -g

  echo -e "${CYAN}[4]${NC} Setup konfigurasi bot..."
  read -p "Masukkan token bot Telegram: " BOT_TOKEN
  read -p "Masukkan user admin Telegram (ID): " ADMIN_ID
  read -p "Masukkan nama store: " NAMA_STORE

  cat >.env <<EOF
BOT_TOKEN=$BOT_TOKEN
ADMIN_ID=$ADMIN_ID
NAMA_STORE=$NAMA_STORE
EOF

  echo -e "${CYAN}[5]${NC} Menjalankan bot dengan pm2..."
  pm2 start index.js --name bottelegram
  pm2 save
  pm2 startup

  echo -e "${GREEN}✅ Bot Telegram berhasil diinstall dan dijalankan.${NC}"

elif [[ "$INSTALL_OPTION" == "5" ]]; then
  # Hapus Bot Telegram
  echo -e "$LINE"
  echo -e "${RED}🗑️ Menghapus Bot Telegram...${NC}"
  echo -e "$LINE"

  pm2 stop bottelegram 2>/dev/null
  pm2 delete bottelegram 2>/dev/null
  pm2 save

  rm -rf bot-regist

  echo -e "${GREEN}✅ Bot Telegram berhasil dihapus.${NC}"

elif [[ "$INSTALL_OPTION" == "6" ]]; then
  # Install Bot SellVPN
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi Bot SellVPN...${NC}"
  echo -e "$LINE"

  hapus_bot_lama
  pasang_package
  setup_bot
  server_app

else
  echo -e "${RED}Pilihan tidak dikenali.${NC}"
fi

echo -e "$LINE"
echo -e "${GREEN}🔚 Proses selesai. Terima kasih sudah menggunakan script ini.${NC}"
echo -e "$LINE"