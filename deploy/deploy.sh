#!/bin/bash
# ============================================================
# PAC-MAN Arcade Edition - Deployment Script für Ubuntu/Apache
# ============================================================
#
# Verwendung:
#   chmod +x deploy.sh
#   sudo ./deploy.sh
#
# Voraussetzungen:
#   - Ubuntu 20.04+ oder Debian 10+
#   - Root/sudo Zugriff
#   - Internetverbindung (für Apache-Installation falls nötig)
#
# ============================================================

set -e  # Bei Fehler abbrechen

# ── Konfiguration ────────────────────────────────
DEPLOY_DIR="/var/www/pacman"
APACHE_CONF="/etc/apache2/sites-available/pacman.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# ── Farben für Ausgabe ───────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   🟡 PAC-MAN Arcade Edition              ║"
echo "  ║      Deployment Script                   ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ── Root-Check ───────────────────────────────────
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✗ Dieses Script muss als root ausgeführt werden.${NC}"
    echo "  Bitte verwende: sudo $0"
    exit 1
fi

echo -e "${CYAN}[1/7]${NC} Prüfe Apache-Installation..."

# ── Apache installieren (falls nötig) ────────────
if ! command -v apache2 &> /dev/null; then
    echo -e "${YELLOW}  Apache2 nicht gefunden. Installiere...${NC}"
    apt update -qq
    apt install -y apache2
    echo -e "${GREEN}  ✓ Apache2 installiert${NC}"
else
    echo -e "${GREEN}  ✓ Apache2 ist bereits installiert${NC}"
fi

# ── Apache Module aktivieren ─────────────────────
echo -e "${CYAN}[2/7]${NC} Aktiviere Apache Module..."
a2enmod headers 2>/dev/null || true
a2enmod rewrite 2>/dev/null || true
a2enmod expires 2>/dev/null || true
a2enmod deflate 2>/dev/null || true
echo -e "${GREEN}  ✓ Module aktiviert (headers, rewrite, expires, deflate)${NC}"

# ── Deployment-Verzeichnis erstellen ─────────────
echo -e "${CYAN}[3/7]${NC} Erstelle Deployment-Verzeichnis..."
mkdir -p "$DEPLOY_DIR"
mkdir -p "$DEPLOY_DIR/assets"
echo -e "${GREEN}  ✓ $DEPLOY_DIR erstellt${NC}"

# ── Dateien kopieren ─────────────────────────────
echo -e "${CYAN}[4/7]${NC} Kopiere Spieldateien..."

cp "$PROJECT_DIR/index.html" "$DEPLOY_DIR/"
cp -r "$PROJECT_DIR/assets/"* "$DEPLOY_DIR/assets/" 2>/dev/null || true
cp "$SCRIPT_DIR/.htaccess" "$DEPLOY_DIR/"

echo -e "${GREEN}  ✓ Dateien kopiert:${NC}"
echo "     - index.html"
echo "     - assets/title-bg.png"
echo "     - .htaccess"

# ── Berechtigungen setzen ────────────────────────
echo -e "${CYAN}[5/7]${NC} Setze Berechtigungen..."
chown -R www-data:www-data "$DEPLOY_DIR"
find "$DEPLOY_DIR" -type d -exec chmod 755 {} \;
find "$DEPLOY_DIR" -type f -exec chmod 644 {} \;
echo -e "${GREEN}  ✓ Berechtigungen gesetzt (www-data, 644/755)${NC}"

# ── Apache VHost konfigurieren ───────────────────
echo -e "${CYAN}[6/7]${NC} Konfiguriere Apache VHost..."

if [ -f "$APACHE_CONF" ]; then
    echo -e "${YELLOW}  Vorhandene Konfiguration wird ersetzt...${NC}"
fi

cp "$SCRIPT_DIR/apache.conf" "$APACHE_CONF"
a2ensite pacman 2>/dev/null || true
echo -e "${GREEN}  ✓ VHost 'pacman' konfiguriert und aktiviert${NC}"

# ── Apache neu starten ───────────────────────────
echo -e "${CYAN}[7/7]${NC} Starte Apache neu..."

# Konfiguration testen
if apache2ctl configtest 2>/dev/null; then
    systemctl reload apache2
    echo -e "${GREEN}  ✓ Apache erfolgreich neu geladen${NC}"
else
    echo -e "${RED}  ✗ Apache-Konfigurationsfehler! Prüfe mit: apache2ctl configtest${NC}"
    exit 1
fi

# ── Zusammenfassung ──────────────────────────────
echo ""
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Deployment abgeschlossen!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""
echo -e "  Spiel erreichbar unter:"
echo -e "  ${CYAN}http://$(hostname -I | awk '{print $1}')/${NC}"
echo -e "  ${CYAN}http://localhost/${NC}"
echo ""
echo -e "  Dateien: ${DEPLOY_DIR}/"
echo -e "  Config:  ${APACHE_CONF}"
echo -e "  Logs:    /var/log/apache2/pacman-*.log"
echo ""
echo -e "  ${YELLOW}Tipp: Für HTTPS verwende:${NC}"
echo -e "  ${CYAN}sudo apt install certbot python3-certbot-apache${NC}"
echo -e "  ${CYAN}sudo certbot --apache -d deine-domain.de${NC}"
echo ""
