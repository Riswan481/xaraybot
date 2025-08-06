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
echo -e "${CYAN}  x) Keluar${NC}"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "$(echo -e "${YELLOW}Masukkan pilihan kamu (1/2/3/4/5/x): ${NC}")" INSTALL_OPTION

if [[ "$INSTALL_OPTION" == "x" || "$INSTALL_OPTION" == "X" ]]; then
  echo -e "${RED}❌ Proses dibatalkan oleh user.${NC}"
  exit 0
fi

if ! [[ "$INSTALL_OPTION" =~ ^[1-5]$ ]]; then
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
# --- Install Script Xray ---
# (Tidak diubah dari versi asli)
# ==========================
if [[ "$INSTALL_OPTION" == "1" ]]; then
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
fi

# ==========================
# --- Install Bot WhatsApp ---
# ==========================
if [[ "$INSTALL_OPTION" == "2" ]]; then
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

  read -n 1 -s -r -p "➡️ Enter untuk melanjutkan pairing WhatsApp..."
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
  pm2 save
  pm2 startup

  echo -e "${GREEN}✅ Bot berhasil dijalankan di PM2 dengan nama: simplebot${NC}"
  pm2 list
fi

# ==========================
# --- Hapus Bot WhatsApp ---
# ==========================
if [[ "$INSTALL_OPTION" == "3" ]]; then
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
fi

# ==========================
# --- Install Bot Telegram ---
# ==========================
if [[ "$INSTALL_OPTION" == "4" ]]; then
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
fi

# ==========================
# --- Hapus Bot Telegram ---
# ==========================
if [[ "$INSTALL_OPTION" == "5" ]]; then
  echo -e "$LINE"
  echo -e "${RED}🗑️ Menghapus Bot Telegram...${NC}"
  echo -e "$LINE"

  echo -e "${CYAN}[🔄] Menghapus bot dan folder terkait...${NC}"
  pm2 delete Bot-Register 2>/dev/null
  rm -rf bot-regist
  echo -e "${GREEN}✅ Bot Telegram berhasil dihapus dari VPS.${NC}"
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
  echo -e "🤖 ${CYAN}Bot WA aktif dengan PM2.${NC}"
elif [[ "$INSTALL_OPTION" == "4" ]]; then
  echo -e "🤖 ${CYAN}Bot Telegram aktif dengan PM2.${NC}"
fi

echo -e "$LINE"