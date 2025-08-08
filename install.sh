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

# ==========================
# --- Fungsi Loading Spinner ---
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
# --- Fungsi hapus bot lama sellvpn ---
# ==========================
hapus_bot_lama_sellvpn() {
    echo -e "${YELLOW}🧹 Menghapus bot lama sellvpn jika ada...${NC}"
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
    echo -e "${GREEN}✅ Bot lama sellvpn berhasil dihapus.${NC}"
}

# ==========================
# --- Fungsi install dependency untuk sellvpn ---
# ==========================
install_dependencies_sellvpn() {
    echo -e "${YELLOW}📦 Memulai instalasi dependensi untuk sellvpn...${NC}"

    # Install Node.js v20 (stabil untuk Debian/Ubuntu terbaru)
    if ! command -v node >/dev/null 2>&1 || ! node -v | grep -q '^v20'; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi

    # Downgrade npm ke versi 10 agar kompatibel
    npm install -g npm@10

    # Install dependencies apt
    apt update
    apt install -y build-essential libcairo2-dev libpango1.0-dev \
        libjpeg-dev libgif-dev librsvg2-dev pkg-config libpixman-1-dev git curl cron
}

# ==========================
# --- Fungsi setup bot sellvpn ---
# ==========================
setup_bot_sellvpn() {
    timedatectl set-timezone Asia/Jakarta

    if [ ! -d /root/BotVPN4 ]; then
        echo -e "${YELLOW}📥 Meng-clone repo BotVPN4...${NC}"
        git clone https://github.com/script-vpn-premium/BotVPN4.git /root/BotVPN4
    else
        echo -e "${YELLOW}📂 Folder BotVPN4 sudah ada, melewati clone.${NC}"
    fi

    cd /root/BotVPN4 || { echo -e "${RED}❌ Gagal masuk ke folder BotVPN4${NC}"; exit 1; }

    echo -e "${YELLOW}📦 Menginstall package npm yang diperlukan...${NC}"
    npm install sqlite3 express crypto telegraf axios dotenv canvas node-fetch form-data
    npm rebuild canvas
    rm -rf node_modules
    npm install
    npm uninstall node-fetch
    npm install node-fetch@2
    chmod +x /root/BotVPN4/*
}

# ==========================
# --- Fungsi konfigurasi dan jalankan bot sellvpn ---
# ==========================
konfigurasi_jalankan_sellvpn() {
    echo ""
    echo -e "${CYAN}────────────────────────────────────────────${NC}"
    echo -e "${GREEN}🎉 Selamat Datang di Bot Order VPN Otomatis 🎉${NC}"
    echo -e "${YELLOW}🔐 Layanan VPN Premium • Cepat • Mudah • Aman${NC}"
    echo -e "${BLUE}🤖 Powered by RISWAN - Bot Telegram Modifikasi${NC}"
    echo -e "${CYAN}────────────────────────────────────────────${NC}"
    echo ""

    read -rp "Masukkan token bot: " token
    while [ -z "$token" ]; do read -rp "Token bot tidak boleh kosong. Masukkan token bot: " token; done

    read -rp "Masukkan admin ID: " adminid
    while [ -z "$adminid" ]; do read -rp "Admin ID tidak boleh kosong. Masukkan admin ID: " adminid; done

    read -rp "Masukkan nama store: " namastore
    while [ -z "$namastore" ]; do read -rp "Nama store tidak boleh kosong. Masukkan nama store: " namastore; done

    read -rp "Masukkan DATA QRIS: " dataqris
    while [ -z "$dataqris" ]; do read -rp "DATA QRIS tidak boleh kosong. Masukkan DATA QRIS: " dataqris; done

    read -rp "Masukkan MERCHANT ID: " merchantid
    while [ -z "$merchantid" ]; do read -rp "MERCHANT ID tidak boleh kosong. Masukkan MERCHANT ID: " merchantid; done

    read -rp "Masukkan API KEY: " apikey
    while [ -z "$apikey" ]; do read -rp "API KEY tidak boleh kosong. Masukkan API KEY: " apikey; done

    read -rp "Masukkan Chat ID Group Telegram: " chatid_group
    while [ -z "$chatid_group" ]; do read -rp "Chat ID Group tidak boleh kosong. Masukkan Chat ID Group Telegram: " chatid_group; done

    read -rp "Masukkan Username Saweria: " username_saweria
    while [ -z "$username_saweria" ]; do read -rp "Username Saweria tidak boleh kosong. Masukkan Username Saweria: " username_saweria; done

    read -rp "Masukkan Email Saweria: " saweria_email
    while [ -z "$saweria_email" ]; do read -rp "Email Saweria tidak boleh kosong. Masukkan Email Saweria: " saweria_email; done

    # Simpan konfigurasi
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

    # Cari path node.js
    NODE_PATH=$(command -v node)
    if [ -z "$NODE_PATH" ]; then
        echo -e "${RED}❌ Node.js tidak ditemukan. Pastikan Node.js sudah terinstall.${NC}"
        exit 1
    fi

    # Buat script untuk menjalankan bot
    cat >/usr/bin/sellvpn <<EOF
#!/bin/bash
cd /root/BotVPN4 || exit 1
$NODE_PATH app.js
EOF
    chmod +x /usr/bin/sellvpn

    # Buat systemd service
    cat >/etc/systemd/system/sellvpn.service <<EOF
[Unit]
Description=App Bot sellvpn Service
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

    echo -e "${GREEN}✅ Bot sellvpn berhasil diinstal dan berjalan.${NC}"
    echo -e "📡 Status Service: $(systemctl is-active sellvpn)"
}

# ==========================
# --- Install Script Xray ---
# ==========================
install_xray() {
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
  echo -e "${GREEN}✅ Instalasi Xray selesai.${NC}"
}

# ==========================
# --- Install Bot WhatsApp ---
# ==========================
install_bot_whatsapp() {
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi Bot WhatsApp...${NC}"
  echo -e "$LINE"

  echo -ne "${YELLOW}📦 Menginstal nodejs, npm, git, jq...${NC}"
  (apt install -y nodejs npm git jq) & loading_spinner

  echo -ne "${YELLOW}📥 Clone repo bot WhatsApp...${NC}"
  (git clone https://github.com/Riswan481/xaraybot.git simplebot) & loading_spinner

  cd simplebot || exit

  echo -ne "${YELLOW}📦 Menginstall package npm...${NC}"
  (npm install) & loading_spinner

  echo -ne "${YELLOW}📦 Menginstall PM2...${NC}"
  (npm install -g pm2) & loading_spinner

  read -rp "$(echo -e "${YELLOW}📱 Masukkan nomor WhatsApp owner (cth: 6281234567890): ${NC}")" OWNER_NUMBER

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

  cd ~/simplebot || exit
  pm2 delete simplebot 2>/dev/null
  pm2 start index.js --name simplebot
  pm2 startup

  echo -e "${GREEN}✅ Bot berhasil dijalankan di PM2 dengan nama: simplebot${NC}"
  pm2 list
}

# ==========================
# --- Hapus Bot WhatsApp ---
# ==========================
hapus_bot_whatsapp() {
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
}

# ==========================
# --- Install Bot Telegram ---
# ==========================
install_bot_telegram() {
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi Bot Telegram...${NC}"
  echo -e "$LINE"

  echo -e "${CYAN}[1]${NC} Mengupdate sistem dan install Node.js..."
  apt update && apt install -y nodejs npm git unzip curl
  sleep 1

  echo -e "${CYAN}[2]${NC} Clone repo bot-regist..."
  git clone https://github.com/Riswan481/bot-regist.git
  cd bot-regist || { echo -e "${RED}❌ Gagal masuk ke folder bot-regist${NC}"; exit 1; }

  echo -e "${CYAN}[3]${NC} Install dependency npm..."
  npm install
  npm install -g pm2

  echo -e "${CYAN}[4]${NC} Menjalankan bot dengan PM2..."
  pm2 start bot.js --name Bot-Register
  pm2 save

  echo -e "${GREEN}✅ Bot Telegram berhasil dijalankan!${NC}"
  echo -e "${YELLOW}🔁 Jalankan ulang setelah reboot dengan: ${CYAN}pm2 resurrect${NC}"
}

# ==========================
# --- Hapus Bot Telegram ---
# ==========================
hapus_bot_telegram() {
  echo -e "$LINE"
  echo -e "${RED}🗑️ Menghapus Bot Telegram...${NC}"
  echo -e "$LINE"

  echo -e "${CYAN}[🔄] Menghapus bot dan folder terkait...${NC}"
  pm2 delete Bot-Register 2>/dev/null
  rm -rf bot-regist
  echo -e "${GREEN}✅ Bot Telegram berhasil dihapus dari VPS.${NC}"
}

# ==========================
# --- Menu Utama ---
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
echo -e "  6) 🤖 Install Bot Sellvpn"
echo -e "${CYAN}  x) Keluar${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -rp "$(echo -e "${YELLOW}Masukkan pilihan kamu (1/2/3/4/5/6/x): ${NC}")" INSTALL_OPTION

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
# --- Eksekusi opsi sesuai pilihan ---
# ==========================
case "$INSTALL_OPTION" in
  1)
    install_xray
    ;;
  2)
    install_bot_whatsapp
    ;;
  3)
    hapus_bot_whatsapp
    ;;
  4)
    install_bot_telegram
    ;;
  5)
    hapus_bot_telegram
    ;;
  6)
    hapus_bot_lama_sellvpn
    install_dependencies_sellvpn
    setup_bot_sellvpn
    konfigurasi_jalankan_sellvpn
    ;;
esac

# ==========================
# --- Selesai ---
# ==========================
echo ""
echo -e "$LINE"
echo -e "${GREEN}✅ Instalasi selesai!${NC}"

case "$INSTALL_OPTION" in
  1)
    echo -e "📂 ${CYAN}Xray command: add-vmess | add-vless | add-trojan | add-ss${NC}"
    ;;
  2)
    echo -e "🤖 ${CYAN}Bot WhatsApp aktif dengan PM2.${NC}"
    ;;
  4)
    echo -e "🤖 ${CYAN}Bot Telegram aktif dengan PM2.${NC}"
    ;;
  6)
    echo -e "🤖 ${CYAN}Bot Sellvpn aktif dan berjalan dengan systemd (sellvpn.service).${NC}"
    ;;
esac

echo -e "$LINE"