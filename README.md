# 🛰️ AirTag HA Radar

[English](README.md) | [Українська](README_UA.md) | [Русский](README_RU.md)

> **Privacy-first, zero-credential Apple AirTag to Home Assistant bridge with high-aesthetic Bento Dashboards, Parking Hub, and Movement Trails.**

[![macOS](https://img.shields.io/badge/macOS-Sonoma%20%7C%20Sequoia-black?logo=apple)](https://apple.com)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024%2B-blue?logo=homeassistant)](https://home-assistant.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Zero SIP](https://img.shields.io/badge/SIP-Protected%20(No%20Root)-brightgreen)](https://apple.com)

---

## 🌟 Why AirTag HA Radar?

Most existing Apple Find My integrations for Home Assistant are either **broken** (due to Apple encrypting the local cache in macOS 14.4+) or require self-hosting heavy **Anisette Docker servers** and entering your raw Apple ID credentials with a risk of account soft-locks.

**AirTag HA Radar** takes an entirely different, elegant approach:
- 🔒 **Zero Credentials**: Never asks for your Apple ID password or 2FA codes. It connects locally to the already-authenticated native macOS Find My application.
- 🛡️ **Zero SIP Modification**: Does not require disabling System Integrity Protection or root permissions.
- ⚡ **Ultra Lightweight**: Runs as a silent macOS LaunchAgent consuming **0.0% CPU** and **~14 MB RAM**.
- 🚗 **Car Parking Radar**: 1-click walking navigation from your iPhone to your car parked anywhere via Apple Maps (`dirflg=w`) and Google Maps.
- 📈 **Bento Dashboard & Analytics**: Polished Lovelace dashboard with movement trails (`hours_to_show`), activity histograms, and zone chronology.

---

## 📐 Architecture

```text
┌────────────────┐        ┌─────────────────────────┐        ┌───────────────────────┐
│  Apple AirTags │ ──BLE─▶│  Apple Find My Network  │ ──────▶│   macOS Find My app   │
└────────────────┘        └─────────────────────────┘        └───────────┬───────────┘
                                                                         │
                                                                   ~30ms read
                                                                         │
┌─────────────────────────┐                                  ┌───────────▼───────────┐
│ Home Assistant Lovelace │◀───── REST / WebSocket API ──────│    findmy_sync.py     │
│ (Bento Radar & History) │                                  │ (Silent LaunchAgent)  │
└─────────────────────────┘                                  └───────────────────────┘
```

---

## 🚀 Quick Start in 3 Steps

### Step 1: Clone and Configure
```bash
git clone https://github.com/<your-username>/airtag-ha-radar.git
cd airtag-ha-radar
cp config.example.yaml config.yaml
```

Edit `config.yaml` with your Home Assistant URL, Long-Lived Access Token, and AirTag names:
```yaml
home_assistant:
  url: "http://homeassistant.local:8123"
  token: "YOUR_LONG_LIVED_ACCESS_TOKEN"

airtags:
  "Car":
    dev_id: "airtag_car"
    name: "My Car"
    icon: "mdi:car-side"
  "Keys":
    dev_id: "airtag_keys"
    name: "House Keys"
    icon: "mdi:key-wireless"
```

### Step 2: Install macOS Background Bridge
Run the installer to register the LaunchAgent daemon:
```bash
chmod +x macos-bridge/install.sh
./macos-bridge/install.sh
```
*The daemon will automatically start on login and run silently in the background.*

To inspect logs:
```bash
cat /tmp/airtag-ha-sync.log
```

To uninstall at any time:
```bash
./macos-bridge/uninstall.sh
```

### Step 3: Import to Home Assistant
1. **Packages**: Copy `homeassistant/packages/airtags_tracking.yaml` to your Home Assistant `includes/packages/` directory (or merge into `configuration.yaml`).
2. **Dashboard**: 
   - In Home Assistant, navigate to **Settings ➔ Dashboards ➔ Add Dashboard** (URL: `airtags-tracking`).
   - Open Raw Configuration Editor and paste the contents of `homeassistant/dashboards/airtags_bento.yaml`.

---

## 🎛️ Dashboard Features

### 1. Live Radar with Movement Trails
- Displays all AirTags on an interactive dark-mode map.
- Automatic polyline connection of recorded GPS fixes showing the exact route taken over the last 1h, 24h, or 7 days.

### 2. Car Parking Hub
- Live status indicator: `At Home (14h 20m)` or `In City / Parked`.
- **1-Click Walking Navigation**: Tap the banner to open Apple Maps with a turn-by-turn walking route directly to your car's coordinates.

### 3. Analytics & Mobility Trends
- 7-day stacked activity column chart showing time spent away from home per item.
- Chronological event feed (Logbook) recording arrivals and departures without false GPS drift triggers.

---

## 🔒 Privacy & Security First

- **No Secrets in Repo**: `config.yaml` is excluded by default via `.gitignore`.
- **Local Network Only**: All communication happens directly between your Mac and your Home Assistant LAN IP.
- **Auditable Code**: Less than 200 lines of standard Python without obscure binary blobs.

---

## 📄 License

Distributed under the [MIT License](LICENSE).
