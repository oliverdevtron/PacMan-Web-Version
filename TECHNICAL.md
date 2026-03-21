# Technische Dokumentation – PAC-MAN Arcade Edition

## Inhaltsverzeichnis

1. [Architektur-Übersicht](#architektur-übersicht)
2. [Ordnerstruktur](#ordnerstruktur)
3. [Spielablauf (Flussdiagramm)](#spielablauf-flussdiagramm)
4. [Module & Komponenten](#module--komponenten)
5. [Game Loop](#game-loop)
6. [Labyrinth-System](#labyrinth-system)
7. [Geister-KI](#geister-ki)
8. [Schwierigkeitsgrade](#schwierigkeitsgrade)
9. [Audio-Engine](#audio-engine)
10. [Rendering-Pipeline](#rendering-pipeline)
11. [Easter Eggs](#easter-eggs)
12. [Deployment auf Ubuntu/Apache](#deployment-auf-ubuntuapache)
13. [Performance-Überlegungen](#performance-überlegungen)
14. [Bekannte Einschränkungen](#bekannte-einschränkungen)

---

## Architektur-Übersicht

Das Spiel ist als Single-File-Application implementiert (`index.html`), die alle Komponenten enthält:

```
┌─────────────────────────────────────────────────────┐
│                    index.html                        │
│                                                      │
│  ┌──────────┐  ┌───────────┐  ┌──────────────────┐ │
│  │   HTML    │  │    CSS    │  │    JavaScript    │ │
│  │  (UI/DOM) │  │  (Styling)│  │  (Game Engine)   │ │
│  └──────────┘  └───────────┘  └──────────────────┘ │
│                                        │             │
│                          ┌─────────────┼──────────┐ │
│                          │             │          │ │
│                    ┌─────▼───┐ ┌───────▼──┐ ┌────▼┐│
│                    │ Renderer│ │  Game    │ │Audio││
│                    │ (Canvas)│ │  Logic   │ │(WAA)││
│                    └─────────┘ └──────────┘ └─────┘│
│                                                      │
│  Externe Abhängigkeiten (CDN):                      │
│  • Google Fonts (Press Start 2P, Inter)             │
│  • Titelbildschirm-Grafik (./assets/title-bg.png)  │
└─────────────────────────────────────────────────────┘
```

---

## Ordnerstruktur

```
PacMan-Web-Version/
│
├── index.html              # Hauptdatei: komplettes Spiel
│                           # (~2300 Zeilen, ~80 KB)
│                           # Enthält: HTML, CSS, JavaScript
│
├── assets/
│   └── title-bg.png        # Titelbildschirm-Hintergrundbild
│                           # (1792x1024px, ~5.3 MB, generiert)
│
├── deploy/                 # Deployment-Konfiguration
│   ├── apache.conf         # Apache VHost-Konfiguration
│   ├── .htaccess           # Caching, Security, Kompression
│   └── deploy.sh           # Automatisches Deployment-Skript
│
├── README.md               # Projekt-Übersicht & Anleitung
├── TECHNICAL.md            # Diese technische Dokumentation
├── GAME_SPEC.md            # Original-Spielspezifikation
├── IMPROVEMENTS.md         # Changelog der Verbesserungen
├── LICENSE                 # MIT Lizenz
└── .gitignore              # Git Ignore Regeln
```

---

## Spielablauf (Flussdiagramm)

```
                        ┌──────────────┐
                        │  Seite laden  │
                        │  (Fonts, Init)│
                        └──────┬───────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   TITLE SCREEN      │
                    │                     │
                    │  • Schwierigkeit    │◄──────────┐
                    │    wählen           │           │
                    │  • Space/Click      │           │
                    │    zum Starten      │           │
                    │  • Konami Code?     │           │
                    └──────────┬──────────┘           │
                               │ Space/Click          │
                               ▼                      │
                    ┌─────────────────────┐           │
                    │      READY!         │           │
                    │   (2.5s Countdown)  │           │
                    │   Intro-Jingle      │           │
                    └──────────┬──────────┘           │
                               │                      │
                               ▼                      │
                ┌──────────────────────────────┐      │
                │         PLAYING              │      │
                │                              │      │
                │  ┌─────────────────────────┐ │      │
                │  │ Game Loop (60 FPS)      │ │      │
                │  │                         │ │      │
                │  │ • Pac-Man bewegen       │ │      │
                │  │ • Geister-KI updaten    │ │      │
                │  │ • Kollisionen prüfen    │ │      │
                │  │ • Modes aktualisieren   │ │      │
                │  │ • Partikel updaten      │ │      │
                │  │ • Rendern               │ │      │
                │  └──────────┬──────────────┘ │      │
                │             │                │      │
                │    ┌────────┼─────────┐      │      │
                │    │        │         │      │      │
                │    ▼        ▼         ▼      │      │
                │  Dot     Power    Frucht     │      │
                │  essen   Pellet   essen      │      │
                │  (+10)   (+50)    (+Bonus)   │      │
                │            │                 │      │
                │            ▼                 │      │
                │   ┌─────────────────┐        │      │
                │   │ FRIGHTENED MODE │        │      │
                │   │ Geister blau    │        │      │
                │   │ Combo: 200-1600 │        │      │
                │   └─────────────────┘        │      │
                └────────────┬─────────────────┘      │
                     │       │        │               │
            Alle Dots│  Geist│   ESC/ │               │
            gegessen │ trifft│  Space │               │
                     │ Pac-M.│       │               │
                     ▼       ▼        ▼               │
          ┌──────────┐ ┌─────────┐ ┌──────────┐      │
          │ LEVEL    │ │ DYING   │ │ PAUSED   │      │
          │ COMPLETE │ │(1.8s)   │ │          │      │
          │ Flash    │ │Anim.    │ │• Resume  │      │
          │ Animation│ │Death-Snd│ │• Quit    │      │
          └────┬─────┘ └────┬────┘ │• Shortcuts│     │
               │            │      │• Fun Facts│     │
               │            │      └─────┬─────┘     │
               │            │            │            │
               │            ▼            │Resume      │
               │    ┌───────────────┐    │            │
               │    │ Leben > 0?    │    │            │
               │    └───┬───────┬───┘    │            │
               │    Ja  │       │ Nein   │            │
               │        │       ▼        │            │
               │        │ ┌──────────┐   │            │
               │        │ │ GAME OVER│   │            │
               │        │ │          │   │            │
               │        │ │• Score   │   │            │
               │        │ │• Stats   │   │            │
               │        │ │• High?   │───┼──Space────►│
               │        │ └──────────┘   │            │
               │        │                │            │
               ▼        ▼                │            │
          ┌──────────────────┐           │            │
          │  Level++/Reset   │           │            │
          │  → READY!        │◄──────────┘            │
          └──────────────────┘                        │
                                                      │
                                              Quit────┘
```

---

## Module & Komponenten

### Konstanten & Konfiguration (Zeilen ~105-220)

```
COLS = 28, ROWS = 31     # Labyrinth-Dimensionen
TILE = 16                 # Pixel pro Tile
CANVAS_W = 448            # 28 * 16
CANVAS_H = 576            # (31 + 5) * 16 (+ HUD)
BASE_SPEED = 150          # Basis-Bewegungsgeschwindigkeit (px/s)
```

**Tile-Typen:**
| Code | Wert | Bedeutung |
|------|------|-----------|
| W | 0 | Wand |
| E | 1 | Leer (Pfad) |
| D | 2 | Dot (10 Punkte) |
| P | 3 | Power Pellet (50 Punkte) |
| G | 4 | Ghost House (Innenraum) |
| GD | 5 | Ghost House Tür |
| T | 6 | Tunnel (langsamer) |

### Labyrinth-Template (Zeile ~126)

28×31 Array mit dem authentischen Original-Pac-Man-Layout:
- 240 Dots + 4 Power Pellets = 244 sammelbare Items
- Symmetrisches Layout (links/rechts gespiegelt)
- Ghost House im Zentrum (Zeilen 12-16, Spalten 10-17)
- Tunnel-Eingänge bei Zeile 14 (Spalten 0 und 27)

---

## Game Loop

```
┌───────────────────────────────────────┐
│          requestAnimationFrame         │
│                  │                     │
│                  ▼                     │
│         ┌───────────────┐             │
│         │ Delta berechnen│             │
│         │ (max 50ms cap) │             │
│         └───────┬───────┘             │
│                 │                     │
│                 ▼                     │
│         ┌───────────────┐             │
│         │ accumulator += │             │
│         │   deltaTime    │             │
│         └───────┬───────┘             │
│                 │                     │
│        ┌────────▼────────┐            │
│        │ while accum >=  │            │
│        │  TICK_RATE      │──┐         │
│        │  (1000/60)      │  │         │
│        └─────────────────┘  │         │
│                             │         │
│         ┌───────────────┐   │         │
│         │  update(dt)   │◄──┘         │
│         │               │             │
│         │ • Modes       │             │
│         │ • Pac-Man     │             │
│         │ • Geister     │             │
│         │ • Kollisionen │             │
│         │ • Partikel    │             │
│         │ • Timer       │             │
│         └───────────────┘             │
│                 │                     │
│                 ▼                     │
│         ┌───────────────┐             │
│         │   render()    │             │
│         │               │             │
│         │ • Labyrinth   │             │
│         │ • Dots        │             │
│         │ • Entitäten   │             │
│         │ • Partikel    │             │
│         │ • Effekte     │             │
│         │ • HUD         │             │
│         └───────────────┘             │
│                 │                     │
│                 ▼                     │
│         nächster Frame ───────────────┘
└───────────────────────────────────────┘
```

**Timing**: Fixed Timestep (60 Hz) für Physik/Logik, variable Renderrate.

---

## Labyrinth-System

### Farbthemen pro Level-Gruppe

| Level | Farbe | Hex | Glow |
|-------|-------|-----|------|
| 1-4 | Klassisches Blau | #0066ff | #1a7aff |
| 5-8 | Lila | #9933ff | #bb66ff |
| 9-12 | Grün | #00cc66 | #33ff99 |
| 13-16 | Rot/Orange | #ff3300 | #ff6633 |
| 17+ | Gold | #ffaa00 | #ffcc44 |

### Rendering (Double-Buffer)

Das Labyrinth wird auf ein Offscreen-Canvas vorgerendert (`buildMazeCanvas()`):

1. **Hintergrund-Pass**: Halbtransparente Füllung für Wandtiefe
2. **Ghost Door**: Rosa Linie über dem Geisterhaus-Eingang
3. **Kanten-Pass 1**: Neon-Linien (2.5px, shadowBlur 14)
4. **Kanten-Pass 2**: Bloom-Effekt (6px, shadowBlur 20, 30% Opacity)

Jede Wand-Kante wird nur gezeichnet, wenn ein Nicht-Wand-Tile angrenzt.

---

## Geister-KI

### Persönlichkeiten

```
┌─────────────────────────────────────────────────────────┐
│                    GEISTER-KI-SYSTEM                     │
│                                                          │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────┐│
│  │  BLINKY  │   │  PINKY   │   │   INKY   │   │CLYDE ││
│  │  (Rot)   │   │  (Pink)  │   │  (Cyan)  │   │(Orng)││
│  │          │   │          │   │          │   │      ││
│  │ Direkte  │   │ 4 Tiles  │   │ Vektor   │   │Wechsel│
│  │ Verfol-  │   │ voraus   │   │ von      │   │bei   ││
│  │ gung     │   │ zielen   │   │ Blinky   │   │8 Tile││
│  │          │   │          │   │ verdopp. │   │Dist. ││
│  │ Scatter: │   │ Scatter: │   │ Scatter: │   │Scatter│
│  │ oben-    │   │ oben-    │   │ unten-   │   │unten-││
│  │ rechts   │   │ links    │   │ rechts   │   │links ││
│  └──────────┘   └──────────┘   └──────────┘   └──────┘│
│                                                          │
│  Modi: SCATTER ←→ CHASE ←→ FRIGHTENED → EYES           │
│                                                          │
│  Scatter/Chase Timing (Level 1):                        │
│  7s Scatter → 20s Chase → 7s → 20s → 5s → 20s → ...   │
└─────────────────────────────────────────────────────────┘
```

### Blinky (Rot) – "Shadow"
- **Chase**: Zielt direkt auf Pac-Mans aktuelle Tile-Position
- **Scatter**: Obere rechte Ecke (Col 25, Row -3)
- **Cruise Elroy**: Bei wenigen verbleibenden Dots wird Blinky schneller
  - Elroy 1: +5% Geschwindigkeit
  - Elroy 2: +10% Geschwindigkeit

### Pinky (Pink) – "Speedy"
- **Chase**: Zielt 4 Tiles voraus in Pac-Mans Blickrichtung
- **Original-Bug**: Bei "nach oben" schaut, zielt auch 4 Tiles nach links (Overflow-Bug des Originals)
- **Scatter**: Obere linke Ecke

### Inky (Cyan) – "Bashful"
- **Chase**: Berechnet Punkt 2 Tiles vor Pac-Man, zieht Vektor von Blinkys Position dorthin, verdoppelt ihn
- **Scatter**: Untere rechte Ecke
- **Besonderheit**: Abhängig von Blinkys Position → unberechenbares Verhalten

### Clyde (Orange) – "Pokey"
- **Chase**: Wenn >8 Tiles entfernt → verfolgt Pac-Man direkt. Wenn ≤8 Tiles → zieht sich zur Scatter-Ecke zurück
- **Scatter**: Untere linke Ecke

### Geister-"Dummheit" (Difficulty Feature)

Bei Easy/Normal haben Geister eine Wahrscheinlichkeit, eine suboptimale Richtung zu wählen:

```javascript
// Pseudocode
if (Math.random() < ghostDumbness) {
    // Wähle zufällige gültige Richtung statt optimaler
    ghost.dir = randomAvailableDirection();
} else {
    // Normaler KI-Algorithmus
    ghost.dir = calculateOptimalDirection(target);
}
```

---

## Schwierigkeitsgrade

### Geschwindigkeits-Tabelle

```
Geschwindigkeit = BASE_SPEED × LevelFaktor × DifficultyModifier

BASE_SPEED = TILE × 9.375 = 150 px/s

┌──────────┬────────┬──────────┬───────┬────────────┬─────────────┐
│  Level   │ Pac-Man│ Pac-Man  │ Ghost │ Ghost      │ Ghost       │
│          │ Normal │ Fright   │ Normal│ Frightened │ Tunnel      │
├──────────┼────────┼──────────┼───────┼────────────┼─────────────┤
│ 1        │  0.80  │  0.90    │ 0.75  │   0.50     │   0.40      │
│ 2-4      │  0.90  │  0.95    │ 0.85  │   0.55     │   0.45      │
│ 5-20     │  1.00  │  1.00    │ 0.95  │   0.60     │   0.50      │
│ 21+      │  0.90  │  0.90    │ 0.95  │   0.60     │   0.50      │
└──────────┴────────┴──────────┴───────┴────────────┴─────────────┘

Difficulty Modifier (multipliziert mit obigen Werten):
┌──────────┬──────────────┬──────────────┐
│          │ Ghost Speed  │ Pac Speed    │
├──────────┼──────────────┼──────────────┤
│ Easy     │ × 0.60       │ × 1.12       │
│ Normal   │ × 0.88       │ × 1.00       │
│ Hard     │ × 1.08       │ × 1.00       │
└──────────┴──────────────┴──────────────┘
```

### Frightened-Mode-Dauer (Sekunden)

| Level | Basis | × Easy (2.5) | × Normal (1.4) | × Hard (0.7) |
|-------|-------|-------------|----------------|--------------|
| 1 | 6 | 15.0 | 8.4 | 4.2 |
| 2 | 5 | 12.5 | 7.0 | 3.5 |
| 3 | 4 | 10.0 | 5.6 | 2.8 |
| 4 | 3 | 7.5 | 4.2 | 2.1 |
| 5 | 2 | 5.0 | 2.8 | 1.4 |
| 17+ | 0 | 0 (nur Richtungswechsel) | 0 | 0 |

---

## Audio-Engine

Alle Sounds werden prozedural über die **Web Audio API** generiert:

```
┌───────────────────────────────────────────────┐
│              Web Audio API Graph               │
│                                                │
│  ┌──────────┐     ┌──────────┐     ┌────────┐│
│  │Oscillator│────►│   Gain   │────►│Destina-││
│  │          │     │  Node    │     │tion    ││
│  │ type:    │     │          │     │(Speaker)│
│  │ square/  │     │ envelope │     │        ││
│  │ triangle/│     │ ramp     │     └────────┘│
│  │ sine/    │     └──────────┘               │
│  │ sawtooth │                                │
│  └──────────┘                                │
│                                                │
│  Sirene:  Oscillator → Gain → Destination    │
│           freq: 100-250 Hz (dynamisch)       │
│                                                │
│  Fright:  Oscillator → Gain → Destination    │
│           + LFO (8 Hz) moduliert Frequenz    │
└───────────────────────────────────────────────┘
```

### Sound-Katalog

| Sound | Typ | Frequenz | Dauer |
|-------|-----|----------|-------|
| Waka-waka | Triangle | 200→400→200 Hz | 100ms |
| Power Eat | Sawtooth | 600→100 Hz | 400ms |
| Ghost Eat | Square | 200→1200 Hz | 350ms |
| Death | Sine | 600→120 Hz (12 Töne) | 1.5s |
| Level Complete | Square | C5-E5-G5-C6 | 900ms |
| Extra Life | Triangle | C5-E5-G5-C6-E6 | 500ms |
| Fruit Eat | Sine | 800-1000-1200 Hz | 180ms |
| Sirene | Sine | 100-250 Hz (loop) | Endlos |

---

## Rendering-Pipeline

```
render() Ablauf:

1. Canvas skalieren (viewport-angepasst)
2. Hintergrund löschen (#0a0a12)
3. Screen-Shake anwenden (wenn aktiv)
4. Maze-Offset (HUD-Höhe)
5. ┌─ Level Complete? → Flash-Animation
   └─ Normal:
      a. Maze-Canvas (vorgerendert) zeichnen
      b. Dots & Power Pellets
      c. Fruit (wenn aktiv)
      d. Ambient-Partikel (Hintergrund)
      e. Geister (mit Glow)
      f. Pac-Man (mit Mouth-Animation)
      g. Partikel-Effekte
      h. Score-Popups
      i. Combo-Text
      j. 1UP-Flash
6. CRT-Scanlines (4% Opacity)
7. Vignetten-Gradient
8. Frightened-Tint (wenn aktiv)
9. HUD zeichnen (Score, High Score, Level, Lives, Timer)
10. Ready-Text / Level-Transition
```

---

## Easter Eggs

### Konami Code
- **Eingabe**: ↑↑↓↓←→←→BA auf dem Titelbildschirm
- **Effekt**: Regenbogen-Pac-Man (Farbwechsel), verstärkter Partikel-Trail, Extra-Leben, "SECRET MODE ACTIVATED!" Text
- **Implementierung**: Array-basierter Sequenz-Tracker, vergleicht letzte 10 Tasten

### Fun Facts
- **Eingabe**: `?` während Pause
- **Effekt**: Zeigt zufälligen Fun Fact über Pac-Man an
- **Beispiele**: "The original Pac-Man was designed by Toru Iwatani in 1980!", "Pac-Man was originally called Puck-Man in Japan"

---

## Deployment auf Ubuntu/Apache

### Voraussetzungen
- Ubuntu 20.04+ / Debian 10+
- Apache 2.4+
- Root/sudo Zugriff

### Deployment-Schritte

```
┌──────────────────────────────────────────────────┐
│            DEPLOYMENT WORKFLOW                     │
│                                                    │
│  1. git clone                                     │
│     │                                              │
│     ▼                                              │
│  2. sudo ./deploy/deploy.sh                       │
│     │                                              │
│     ├─► Apache installiert?                       │
│     │   Nein → apt install apache2                │
│     │                                              │
│     ├─► Verzeichnis /var/www/pacman erstellen      │
│     │                                              │
│     ├─► Dateien kopieren                          │
│     │   • index.html                              │
│     │   • assets/title-bg.png                     │
│     │   • deploy/.htaccess                        │
│     │                                              │
│     ├─► Apache VHost konfigurieren                │
│     │   • /etc/apache2/sites-available/pacman.conf│
│     │   • a2ensite pacman                         │
│     │                                              │
│     ├─► Apache Module aktivieren                  │
│     │   • mod_headers                             │
│     │   • mod_rewrite                             │
│     │   • mod_expires                             │
│     │   • mod_deflate                             │
│     │                                              │
│     ├─► Berechtigungen setzen                     │
│     │   • www-data:www-data                       │
│     │   • 644 (Dateien), 755 (Verzeichnisse)     │
│     │                                              │
│     └─► Apache neu laden                          │
│         systemctl reload apache2                  │
│                                                    │
│  3. Im Browser öffnen:                            │
│     http://dein-server/                            │
└──────────────────────────────────────────────────┘
```

### Konfigurationsdateien

#### Apache VHost (`deploy/apache.conf`)
- Lauscht auf Port 80
- DocumentRoot: `/var/www/pacman`
- Aktiviert Kompression (gzip) für HTML/JS/CSS
- Cache-Control Headers für Assets (30 Tage)
- Security Headers (X-Frame-Options, X-Content-Type-Options)

#### .htaccess (`deploy/.htaccess`)
- Expires-Headers für Browser-Caching
- Gzip-Kompression
- Security Headers
- Error Pages

### SSL/HTTPS (optional)

```bash
# Let's Encrypt installieren
sudo apt install certbot python3-certbot-apache
sudo certbot --apache -d pacman.deine-domain.de
```

---

## Performance-Überlegungen

| Aspekt | Lösung |
|--------|--------|
| Maze-Rendering | Offscreen-Canvas (einmalig vorgerendert) |
| Partikel | Object Pooling via Array splice |
| Game Loop | Fixed Timestep (16.67ms) mit akkumulierter Delta-Zeit |
| Canvas-Größe | Logische Größe 448×576, CSS-skaliert auf Viewport |
| Pixel Ratio | Math.min(devicePixelRatio, 2) via CSS-Skalierung |
| Fonts | Google Fonts mit preconnect |
| Scanlines | Nur alle 3 Pixel bei 4% Opacity |
| Audio | Shared AudioContext, Oszillatoren on-demand |

### Zielwerte
- **60 FPS** auf modernen Geräten
- **30+ FPS** auf älteren Mobilgeräten
- **< 100 KB** JavaScript (ohne Bild-Asset)
- **Zero Dependencies** (kein npm, kein Build)

---

## Bekannte Einschränkungen

| Einschränkung | Grund | Workaround |
|---------------|-------|------------|
| Kein Speichern | Sandboxed iframe blockiert localStorage | In-Memory State |
| Audio erst nach Klick | Browser-Policy für Auto-Play | Erster Click/Space initialisiert AudioContext |
| Tunnel-Animation | Pac-Man springt bei Tunnel-Übergang | Wrap-Around mit negativen Koordinaten |
| Level 256 | Kein Kill-Screen wie im Original | Levels setzen sich normal fort |
| Font-Ladezeit | Google Fonts CDN | document.fonts.ready vor Init |

---

## Entwicklung & Beitragen

### Lokale Entwicklung

```bash
# Einfach die Datei im Browser öffnen
open index.html

# Oder mit einem lokalen Server
python3 -m http.server 8080
# → http://localhost:8080
```

### Code-Struktur im JavaScript

| Bereich | Zeilen (ca.) | Beschreibung |
|---------|-------------|--------------|
| Konstanten | 105-220 | Maze-Template, Tabellen |
| Audio | 265-460 | Web Audio API Funktionen |
| Maze-Helpers | 460-500 | Tile-Abfragen, Wrap |
| Pac-Man | 510-900 | Erstellung, Bewegung, Essen |
| Ghost AI | 925-1125 | Targeting, Richtungswahl |
| Kollisionen | 1125-1165 | Pac-Man ↔ Ghost |
| Mode-Mgmt | 1165-1200 | Scatter/Chase/Fright Timer |
| Update Loop | 1200-1280 | State Machine |
| Rendering | 1280-1810 | Canvas Drawing |
| Game Loop | 1810-1850 | rAF + Fixed Timestep |
| Init | 1850-1855 | Startup |
| Easter Eggs | verteilt | Konami, Fun Facts |
| Mobile D-Pad | verteilt | Touch-Steuerung |
