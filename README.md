# 🤖 SimpleBot - WhatsApp VPN Bot Installer

SimpleBot adalah bot WhatsApp otomatis untuk membuat akun VPN (SSH, VMess, VLESS, Trojan, Shadowsocks) melalui perintah WhatsApp. Bot ini`.

---

## 🚀 Install Otomatis

Kamu bisa menginstal SimpleBot secara otomatis dengan satu baris perintah:

```bash
bash <(curl -sL https://raw.githubusercontent.com/Riswan481/xaraybot/main/install.sh)
```
---
## Install pm
```bash
cd ~/simplebot
pm2 start index.js --name simplebot
pm2 save
```
## Atau ini 
```bash
cd ~/simplebot
pm2 start index.js --name simplebot
pm2 save
pm2 startup
```
---

## Stop pm

```bash
pm2 delete simplebot
```
