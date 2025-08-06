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
# --- Konfirmasi Pilihan ---
# ==========================
clear
echo -e "${YELLOW}"
echo "═══════════════════════════════════════════════════════════════"
echo "       🚀 INSTALLER SCRIPT XRAY & BOT WHATSAPP by RISWAN        "
echo "═══════════════════════════════════════════════════════════════"
echo -e "${NC}"
echo -e "${GREEN}Pilih opsi instalasi:${NC}"
echo -e "  1) 🔐 Install Script Xray saja"
echo -e "  2) 🤖 Install Bot WhatsApp saja"
echo -e "  3) 🚀 Install Keduanya (Xray + Bot WA)"
echo -e "  4) 🗑️ Hapus Bot WhatsApp"
echo "═══════════════════════════════════════════════════════════════"
echo ""

read -p "$(echo -e "${YELLOW}Masukkan pilihan kamu (1/2/3/4): ${NC}")" INSTALL_OPTION

if [[ "$INSTALL_OPTION" != "1" && "$INSTALL_OPTION" != "2" && "$INSTALL_OPTION" != "3" && "$INSTALL_OPTION" != "4" ]]; then
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
# --- Hapus Bot WhatsApp ---
# ==========================
if [[ "$INSTALL_OPTION" == "4" ]]; then
  echo -e "$LINE"
  echo -e "${RED}🗑️ Menghapus Bot WhatsApp...${NC}"
  echo -e "$LINE"

  echo -ne "${YELLOW}⏳ Menghapus proses PM2...${NC}"
  (
    pm2 stop simplebot
    pm2 delete simplebot
    pm2 save
  ) & loading_spinner

  echo -ne "${YELLOW}🧹 Menghapus folder bot (simplebot)...${NC}"
  (rm -rf simplebot) & loading_spinner

  echo -ne "${YELLOW}🧹 Menghapus PM2 global...${NC}"
  (npm uninstall -g pm2) & loading_spinner

  echo -e "${GREEN}✅ Bot berhasil dihapus.${NC}"
  echo -e "$LINE"
  exit 0
fi

# ==========================
# --- Instalasi Script Xray ---
# ==========================
if [[ "$INSTALL_OPTION" == "1" || "$INSTALL_OPTION" == "3" ]]; then
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
# --- Instalasi Bot WA ---
# ==========================
if [[ "$INSTALL_OPTION" == "2" || "$INSTALL_OPTION" == "3" ]]; then
  echo -e "$LINE"
  echo -e "${BLUE}🤖 Instalasi Bot WhatsApp...${NC}"
  echo -e "$LINE"

  echo -ne "${YELLOW}📦 Menginstal nodejs, npm, git, jq...${NC}"
  (
    apt install -y nodejs npm git jq
  ) & loading_spinner

  echo -ne "${YELLOW}📥 Clone repo bot WhatsApp...${NC}"
  (git clone https://github.com/script-vpn-premium/scriptbot.git simplebot) & loading_spinner

  echo ""
  read -p "$(echo -e "${YELLOW}📱 Masukkan nomor WhatsApp owner (cth: 6281234567890): ${NC}")" OWNER_NUMBER

  cd simplebot || exit
  SETTINGS_FILE="settings.js"

  echo -ne "${YELLOW}📦 Menginstall package npm...${NC}" && (npm install) & loading_spinner
  echo -ne "${YELLOW}📦 Menginstall PM2...${NC}" && (npm install -g pm2) & loading_spinner

  # Tambahkan atau update owner number
  if grep -q "global\.owner *= *\"" $SETTINGS_FILE; then
    sed -i "s/global\.owner *= *\"[^\"]*\"/global.owner = \"$OWNER_NUMBER\"/" $SETTINGS_FILE
    echo -e "${YELLOW}✅ global.owner berhasil diatur ke: $OWNER_NUMBER${NC}"
  else
    echo "global.owner = \"$OWNER_NUMBER\"" >> $SETTINGS_FILE
    echo -e "${YELLOW}⚠️ Baris global.owner belum ada, ditambahkan manual.${NC}"
  fi
  sleep 3

  echo -e "${YELLOW}🔑 Menjalankan pairing WhatsApp...${NC}"
  echo -e "${YELLOW}🕒 Tunggu sampai muncul '✅ Bot terhubung!', lalu proses akan lanjut otomatis...${NC}"
  echo ""
  node index.js

  echo -e "${GREEN}✅ Pairing sukses. Menjalankan bot di PM2...${NC}"
  pm2 start index.js --name simplebot
  pm2 save
  pm2 startup
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
else
  echo -e "🤖 ${CYAN}Bot WA aktif dengan PM2.${NC}"
  echo -e "📂 ${CYAN}Xray command: add-vmess | add-vless | add-trojan | add-ss${NC}"
fi

echo -e "$LINE"
echo -e "${BLUE}"
cat << "EOF"
   __  __      ____        _   
  |  \/  |_ __| __ )  ___ | |_ 
  | |\/| | '__|  _ \ / _ \| __|
  | |  | | |  | |_) | (_) | |_ 
  |_|  |_|_|  |____/ \___/ \__|

EOF
echo -e "${CYAN}        ✅ Xray & Bot WA Installer by Riswan ✅${NC}"
echo -e "$LINE"
echo -e "${GREEN}🎉 Semua proses selesai tanpa error. Silakan gunakan fiturnya!${NC}"