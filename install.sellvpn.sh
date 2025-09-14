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
LINE="${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
# --- Warna ---
# ==========================
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m' # reset warna

# ==========================
# --- Menu ---
# ==========================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Pilih opsi instalasi${NC}"
echo -e "${GREEN}[1] Install Script Xray + SSH${NC}"
echo -e "${GREEN}[2] Install Bot Sellvpn${NC}"
echo -e "${GREEN}[x] Keluar${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -p "$(echo -e "${GREEN}Masukkan pilihan kamu (1/2/x): ${NC}")" INSTALL_OPTION

if [[ "$INSTALL_OPTION" == "x" || "$INSTALL_OPTION" == "X" ]]; then
  echo -e "${GREEN}❌ Proses dibatalkan oleh user.${NC}"
  exit 0
fi

if ! [[ "$INSTALL_OPTION" =~ ^[1-2]$ ]]; then
  echo -e "${GREEN}❌ Pilihan tidak valid. Instalasi dibatalkan.${NC}"
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
  echo -e "❌ ${GREEN}Maaf, IP kamu ($MY_IP) tidak terdaftar di whitelist.${NC}"
  echo -e "➡️ ${YELLOW}Hubungi admin 6285888801241 untuk mendaftarkan IP kamu.${NC}"
  echo -e "$LINE"
  exit 1
fi

# ==========================
# --- Proses Instalasi Xray ---
# ==========================
if [[ "$INSTALL_OPTION" == "1" ]]; then
  echo -e "$LINE"
  echo -e "${BLUE}🚀 Memulai instalasi script Xray + SSH...${NC}"
  echo -e "$LINE"

  # Update dan install dependencies
  echo -ne "${YELLOW}📦 Update sistem dan install curl & git...${NC}"
  (
    apt update -y -o Acquire::ForceIPv4=true && \
    apt upgrade -y --no-install-recommends && \
    apt install -y curl git
  ) & loading_spinner

  # Clone repository
  echo -ne "${YELLOW}📥 Meng-clone repo: $REPO_URL ...${NC}"
  (git clone "$REPO_URL" "$TEMP_DIR") & loading_spinner

  # Membuat folder dan menyalin file
  echo -ne "${YELLOW}📁 Membuat folder /etc/xray...${NC}"
  (mkdir -p /etc/xray) & loading_spinner

  echo -ne "${YELLOW}📂 Menyalin file script ke /etc/xray...${NC}"
  (
    cp "$TEMP_DIR/"add-* /etc/xray/ 2>/dev/null || true
  ) & loading_spinner

  # Memberikan izin eksekusi
  echo -ne "${YELLOW}🔐 Memberikan izin eksekusi...${NC}"
  (chmod +x /etc/xray/add-* 2>/dev/null || true) & loading_spinner

  # Membuat symlink ke /usr/bin
  echo -ne "${YELLOW}🔗 Membuat symlink ke /usr/bin...${NC}"
  (
    for f in /etc/xray/add-*; do
      ln -sf "$f" /usr/bin/$(basename "$f")
    done
  ) & loading_spinner

  echo -e "${GREEN}✅ Instalasi Xray + SSH selesai.${NC}"
  echo -e "$LINE"
fi

# ==========================
# --- Bagian Install Bot Sellvpn (versi baru) ---
# ==========================
if [[ "$INSTALL_OPTION" == "2" ]]; then
  # Colors
  green="\e[38;5;82m"
  red="\e[38;5;196m"
  neutral="\e[0m"
  orange="\e[38;5;130m"
  blue="\e[38;5;39m"
  yellow="\e[38;5;226m"
  purple="\e[38;5;141m"
  bold_white="\e[1;37m"
  reset="\e[0m"
  pink="\e[38;5;205m"

  hapus_bot_lama() {
      echo -e "${orange}Menghapus bot lama...${neutral}"
      systemctl stop sellvpn.service 2>/dev/null
      systemctl disable sellvpn.service 2>/dev/null
      rm -f /etc/systemd/system/sellvpn.service
      rm -f /usr/bin/sellvpn /usr/bin/server_sellvpn /etc/cron.d/server_sellvpn
      rm -rf /root/BotVPN4

      if command -v pm2 &> /dev/null; then
          pm2 delete sellvpn &> /dev/null
          pm2 save &> /dev/null
      fi

      systemctl daemon-reload
      echo -e "${green}Bot lama berhasil dihapus.${neutral}"
  }

  pasang_package() {
      echo -e "${blue}Memulai pengecekan dan instalasi dependensi...${reset}"
      if ! command -v node >/dev/null 2>&1 || ! node -v | grep -q 'v20'; then
          curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
          apt-get install -y nodejs
      fi
      npm install -g npm@10
      apt update
      apt install -y build-essential libcairo2-dev libpango1.0-dev \
          libjpeg-dev libgif-dev librsvg2-dev pkg-config libpixman-1-dev git curl cron
  }

  setup_bot() {
      timedatectl set-timezone Asia/Jakarta
      if [ ! -d /root/BotVPN4 ]; then
          git clone https://github.com/script-vpn-premium/BotVPN4.git /root/BotVPN4
      fi
      cd /root/BotVPN4
      npm install sqlite3 express crypto telegraf axios dotenv canvas node-fetch form-data
      npm rebuild canvas
      rm -rf node_modules
      npm install
      npm uninstall node-fetch
      npm install node-fetch@2
      chmod +x /root/BotVPN4/*
  }

  server_app() {
      clear
      echo -e "${orange}─────────────────────────────────────────${neutral}"
      echo -e "${green}- BOT SELLVPN TELEGRAM PGETUNNEL${neutral}"
      echo -e "${orange}─────────────────────────────────────────${neutral}"

      read -p "Masukkan token bot: " token
      read -p "Masukkan admin ID: " adminid
      read -p "Masukkan nama store: " namastore
      read -p "Masukkan DATA QRIS: " dataqris
      read -p "Masukkan MERCHANT ID: " merchantid
      read -p "Masukkan API KEY: " apikey
      read -p "Masukkan Chat ID Group Telegram: " chatid_group
      read -p "Masukkan Username Saweria: " username_saweria
      read -p "Masukkan Email Saweria: " saweria_email

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
          echo -e "${red}Node.js tidak ditemukan. Pastikan Node.js sudah terinstall.${neutral}"
          exit 1
      fi

      cat >/usr/bin/sellvpn <<EOF
#!/bin/bash
cd /root/BotVPN4 || exit 1
$NODE_PATH app.js
EOF
      chmod +x /usr/bin/sellvpn

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
      systemctl start sellvpn
      service cron restart

      echo -e "Status Server: $(systemctl is-active sellvpn)"
      echo -e "${green}Bot berhasil diinstal dan sedang berjalan.${neutral}"
  }

  hapus_bot_lama
  pasang_package
  setup_bot
  server_app
fi

# ==========================
# --- Selesai ---
# ==========================
echo ""
echo -e "$LINE"
echo -e "${GREEN}✅ Instalasi selesai!${NC}"

if [[ "$INSTALL_OPTION" == "1" ]]; then
  echo -e "📂 ${CYAN}Xray command: add-vmess | add-vless | add-trojan | add-ss${NC}"
elif [[ "$INSTALL_OPTION" == "2" ]]; then
  echo -e "🤖 ${CYAN}BotVPN4 aktif dan berjalan dengan systemd (sellvpn.service).${NC}"
fi

echo -e "$LINE"
