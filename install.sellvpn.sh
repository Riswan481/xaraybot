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
# --- Menu Pilihan ---
# ==========================
clear
echo -e "${YELLOW}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}Pilih opsi instalasi:${NC}"
echo -e "  1) 🔐 Install Script Xray + SSH"
echo -e "  2) 🤖 Install Bot Sellvpn"
echo -e "${CYAN}  x) Keluar${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "$(echo -e "${YELLOW}Masukkan pilihan kamu (1/2/x): ${NC}")" INSTALL_OPTION

if [[ "$INSTALL_OPTION" == "x" || "$INSTALL_OPTION" == "X" ]]; then
  echo -e "${RED}❌ Proses dibatalkan oleh user.${NC}"
  exit 0
fi

if ! [[ "$INSTALL_OPTION" =~ ^[1-2]$ ]]; then
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
# --- Proses Instalasi ---
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
    cp "$TEMP_DIR/add-vmess" /etc/xray/
    cp "$TEMP_DIR/add-vless" /etc/xray/
    cp "$TEMP_DIR/add-trojan" /etc/xray/
    cp "$TEMP_DIR/add-ss" /etc/xray/ 2>/dev/null || true
    cp "$TEMP_DIR/add-ssh" /etc/xray/ 2>/dev/null || true
    cp "$TEMP_DIR/add-vmess-trial" /etc/xray/ 2>/dev/null || true
    cp "$TEMP_DIR/add-vless-trial" /etc/xray/ 2>/dev/null || true
    cp "$TEMP_DIR/add-trojan-trial" /etc/xray/ 2>/dev/null || true
    cp "$TEMP_DIR/add-ssh-trial" /etc/xray/ 2>/dev/null || true
  ) & loading_spinner

  # Memberikan izin eksekusi
  echo -ne "${YELLOW}🔐 Memberikan izin eksekusi...${NC}"
  (
    chmod +x /etc/xray/add-vmess
    chmod +x /etc/xray/add-vless
    chmod +x /etc/xray/add-trojan
    chmod +x /etc/xray/add-ss 2>/dev/null || true
    chmod +x /etc/xray/add-ssh 2>/dev/null || true
    chmod +x /etc/xray/add-vmess-trial 2>/dev/null || true
    chmod +x /etc/xray/add-vless-trial 2>/dev/null || true
    chmod +x /etc/xray/add-trojan-trial 2>/dev/null || true
    chmod +x /etc/xray/add-ssh-trial 2>/dev/null || true
  ) & loading_spinner

  # Membuat symlink ke /usr/bin
  echo -ne "${YELLOW}🔗 Membuat symlink ke /usr/bin...${NC}"
  (
    ln -sf /etc/xray/add-vmess /usr/bin/add-vmess
    ln -sf /etc/xray/add-vless /usr/bin/add-vless
    ln -sf /etc/xray/add-trojan /usr/bin/add-trojan
    ln -sf /etc/xray/add-ss /usr/bin/add-ss 2>/dev/null || true
    ln -sf /etc/xray/add-ssh /usr/bin/add-ssh 2>/dev/null || true
    ln -sf /etc/xray/add-vmess-trial /usr/bin/add-vmess-trial 2>/dev/null || true
    ln -sf /etc/xray/add-vless-trial /usr/bin/add-vless-trial 2>/dev/null || true
    ln -sf /etc/xray/add-trojan-trial /usr/bin/add-trojan-trial 2>/dev/null || true
    ln -sf /etc/xray/add-ssh-trial /usr/bin/add-ssh-trial 2>/dev/null || true
  ) & loading_spinner

  echo -e "${GREEN}✅ Instalasi Xray + SSH selesai.${NC}"
  echo -e "$LINE"
  echo -e "${CYAN}📌 Daftar command yang tersedia:${NC}"
  echo -e "  🔹 add-vmess"
  echo -e "  🔹 add-vless"
  echo -e "  🔹 add-trojan"
  echo -e "  🔹 add-ss"
  echo -e "  🔹 add-ssh"
  echo -e "  🔹 add-vmess-trial"
  echo -e "  🔹 add-vless-trial"
  echo -e "  🔹 add-trojan-trial"
  echo -e "  🔹 add-ssh-trial"
fi

# ==========================
# --- Menyalin File Cek ---
# ==========================
echo -ne "${YELLOW}📂 Menyalin file cek ke /etc/xray...${NC}"
(
  cp "$TEMP_DIR/cek-ssh" /etc/xray/ 2>/dev/null || true
  cp "$TEMP_DIR/cek-vmess" /etc/xray/ 2>/dev/null || true
  cp "$TEMP_DIR/cek-vless" /etc/xray/ 2>/dev/null || true
  cp "$TEMP_DIR/cek-trojan" /etc/xray/ 2>/dev/null || true
  cp "$TEMP_DIR/cek-ss" /etc/xray/ 2>/dev/null || true
) & loading_spinner

# ==========================
# --- Memberikan Izin Eksekusi pada File Cek ---
# ==========================
echo -ne "${YELLOW}🔐 Memberikan izin eksekusi pada file cek...${NC}"
(
  chmod +x /etc/xray/cek-ssh
  chmod +x /etc/xray/cek-vmess
  chmod +x /etc/xray/cek-vless
  chmod +x /etc/xray/cek-trojan
  chmod +x /etc/xray/cek-ss
) & loading_spinner

# ==========================
# --- Daftar Command Cek ---
# ==========================
echo -e "${GREEN}✅ Semua file cek disalin dan diberikan izin eksekusi.${NC}"
echo -e "$LINE"
echo -e "${CYAN}📌 Daftar command cek yang tersedia:${NC}"
echo -e "  🔹 cek-ssh"
echo -e "  🔹 cek-vmess"
echo -e "  🔹 cek-vless"
echo -e "  🔹 cek-trojan"
echo -e "  🔹 cek-ss"
echo -e "$LINE"

# ==========================
# --- Selesai ---
# ==========================
echo -e "${GREEN}✅ Semua proses selesai!${NC}"
echo -e "${CYAN}Terima kasih telah menggunakan script ini. Selamat mencoba!${NC}"
echo -e "$LINE"

# ==========================
# --- Opsi Install BotVPN4 ---
# ==========================
if [[ "$INSTALL_OPTION" == "2" ]]; then
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi BotVPN4 (Bot Order VPN Otomatis)...${NC}"
  echo -e "$LINE"

  # Fungsi hapus bot lama
  hapus_bot_lama() {
    echo -e "${YELLOW}Menghapus bot lama jika ada...${NC}"
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
    echo -e "${GREEN}Bot lama berhasil dihapus.${NC}"
  }

  # Fungsi install package dan dependencies
  pasang_package() {
    echo -e "${CYAN}Memulai pengecekan dan instalasi dependensi...${NC}"

    # Install Node.js v20 (stabil untuk Debian 10+/Ubuntu 20+)
    if ! command -v node >/dev/null 2>&1 || ! node -v | grep -q 'v20'; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt-get install -y nodejs
    fi

    # Downgrade npm ke versi 10 agar kompatibel
    npm install -g npm@10

    # Install dependencies APT
    apt update
    apt install -y build-essential libcairo2-dev libpango1.0-dev \
        libjpeg-dev libgif-dev librsvg2-dev pkg-config libpixman-1-dev git curl cron
  }

  # Fungsi setup bot
  setup_bot() {
    timedatectl set-timezone Asia/Jakarta

    # Clone Bot
    if [ ! -d /root/BotVPN4 ]; then
        git clone https://github.com/script-vpn-premium/BotVPN4.git /root/BotVPN4
    fi

    # Install dependencies
    cd /root/BotVPN4 || exit
    npm install sqlite3 express crypto telegraf axios dotenv canvas node-fetch form-data
    npm rebuild canvas
    rm -rf node_modules
    npm install
    npm uninstall node-fetch
    npm install node-fetch@2
    chmod +x /root/BotVPN4/*
  }

  # Fungsi jalankan konfigurasi dan input user
  server_app() {
    clear
    echo -e "${YELLOW}────────────────────────────────────────────${NC}"
    echo -e "${CYAN}🎉 Selamat Datang di Bot Order VPN Otomatis 🎉${NC}"
    echo -e "${GREEN}🔐 Layanan VPN Premium • Cepat • Mudah • Aman${NC}"
    echo -e "${BLUE}🤖 Powered by RISWAN - Bot Telegram Modifikasi${NC}"
    echo -e "${YELLOW}────────────────────────────────────────────${NC}"

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

    # Simpan konfigurasi ke file .vars.json
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

    # Deteksi lokasi node secara otomatis
    NODE_PATH=$(which node)
    if [ -z "$NODE_PATH" ]; then
        echo -e "${RED}Node.js tidak ditemukan. Pastikan Node.js sudah terinstall.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Node.js ditemukan di: $NODE_PATH${NC}"

    # Buat file autorun menggunakan path node absolut
    cat >/usr/bin/sellvpn <<EOF
#!/bin/bash
cd /root/BotVPN4 || exit 1
$NODE_PATH app.js
EOF
    chmod +x /usr/bin/sellvpn

    # Buat systemd service file dengan ExecStart menggunakan path node absolut
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
    echo -e "${GREEN}Bot berhasil diinstal dan sedang berjalan.${NC}"
  }

  # Jalankan seluruh proses install Bot Sellvpn
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