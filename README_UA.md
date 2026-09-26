# 🛰️ AirTag HA Radar

[English](README.md) | [Українська](README_UA.md) | [Русский](README_RU.md)

> **Приватний міст між Apple AirTag та Home Assistant з нульовими ризиками для Apple ID, готовими Bento-дашбордами, паркувальним радаром та історією маршрутів.**

[![macOS](https://img.shields.io/badge/macOS-Sonoma%20%7C%20Sequoia-black?logo=apple)](https://apple.com)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024%2B-blue?logo=homeassistant)](https://home-assistant.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Zero SIP](https://img.shields.io/badge/SIP-Protected%20(Без%20Root)-brightgreen)](https://apple.com)

---

## 🌟 Чому саме AirTag HA Radar?

Більшість наявних рішень для інтеграції AirTag у Home Assistant або **не працюють** (після того як Apple зашифрувала локальний кеш у macOS 14.4+), або вимагають розгортання важких **Docker-контейнерів Anisette**, передачі логіна й пароля від Apple ID та несуть ризик блокування облікового запису з боку Apple.

**AirTag HA Radar** пропонує принципово інший, безпечний та чистий підхід:
- 🔒 **Zero Credentials (Без паролів):** Жодних паролів від Apple ID або кодів двофакторної автентифікації (2FA). Скрипт локально зчитує дані з уже авторизованого застосунку «Локатор» (Find My) на вашому Mac.
- 🛡️ **Zero SIP:** Не потребує вимкнення захисту System Integrity Protection або root-прав.
- ⚡ **Ультра-легкий:** Працює як непомітний системний сервіс macOS (LaunchAgent), споживаючи **0.0% CPU** та лише **~14 МБ RAM**.
- 🚗 **Паркувальний радар для авто:** Пішохідна навігація в 1 клік зі смартфона прямо до припаркованого авто через Apple Maps (`dirflg=w`) або Google Maps.
- 📈 **Bento-дашборд та аналітика:** Готові картки Lovelace з лініями пройдених маршрутів (`hours_to_show`), хронологією стоянок та активністю за днями тижня у стилі Google Tracks.

---

## 📐 Архітектура

```text
┌────────────────┐        ┌─────────────────────────┐        ┌───────────────────────┐
│  Apple AirTags │ ──BLE─▶│   Мережа Apple Find My  │ ──────▶│  Застосунок «Локатор»  │
└────────────────┘        └─────────────────────────┘        └───────────┬───────────┘
                                                                         │
                                                                   ~30ms опитування
                                                                         │
┌─────────────────────────┐                                  ┌───────────▼───────────┐
│ Home Assistant Lovelace │◀───── REST / WebSocket API ──────│    findmy_sync.py     │
│  (Bento-радар і треки)  │                                  │  (Тихий LaunchAgent)  │
└─────────────────────────┘                                  └───────────────────────┘
```

---

## 🚀 Швидкий старт за 3 кроки

### Крок 1: Клонування та налаштування
```bash
git clone https://github.com/borisgz-oss/airtag-ha-radar.git
cd airtag-ha-radar
cp config.example.yaml config.yaml
```

Відкрийте `config.yaml` та вкажіть адресу Home Assistant, довгоживучий токен доступу та назви ваших міток:
```yaml
home_assistant:
  url: "http://homeassistant.local:8123"
  token: "ВАШ_LONG_LIVED_ACCESS_TOKEN"

airtags:
  "Car":
    dev_id: "airtag_car"
    name: "Автомобіль"
    icon: "mdi:car-side"
  "Keys":
    dev_id: "airtag_keys"
    name: "Ключі"
    icon: "mdi:key-wireless"
```

### Крок 2: Встановлення фонового сервісу на macOS
Запустіть інсталяційний скрипт для реєстрації демона LaunchAgent:
```bash
chmod +x macos-bridge/install.sh
./macos-bridge/install.sh
```
*Демон автоматично стартуватиме під час входу в систему та працюватиме у фоні без відкритих вікон термінала.*

Переглянути логи роботи:
```bash
cat /tmp/airtag-ha-sync.log
```

Видалити сервіс у будь-який момент:
```bash
./macos-bridge/uninstall.sh
```

### Крок 3: Додавання в Home Assistant
1. **Пакети (Packages):** Скопіюйте файл `homeassistant/packages/airtags_tracking.yaml` до папки `includes/packages/` вашого Home Assistant (або додайте до `configuration.yaml`).
2. **Дашборд:** 
   - У Home Assistant відкрийте **Налаштування ➔ Панелі керування ➔ Додати панель** (URL: `airtags-tracking`).
   - Відкрийте «Редактор конфігурації (Raw)» та вставте вміст файлу `homeassistant/dashboards/airtags_bento.yaml`.

---

## 🎛️ Можливості дашборда

### 1. Живий радар з лініями маршрутів
- Відображення всіх AirTag на інтерактивній темній мапі.
- Автоматичне з'єднання зафіксованих GPS-точок у безперервні кольорові лінії маршрутів за 1 годину, 24 години або 7 днів.

### 2. Паркувальний радар для автомобіля
- Статус у реальному часі: `На стоянці біля дому (14 год 20 хв)` або `У місті / На виїзді`.
- **Пішохідний маршрут в 1 клік:** Натискання на статус авто миттєво відкриває Apple Maps на телефоні зі стрілками пішого маршруту безпосередньо до поточної геопозиції машини.

### 3. Аналітика та тренди мобільності
- Графік активності за 7 днів (ApexCharts): показує час, проведений поза домом за днями тижня.
- Хронологічна стрічка подій (Logbook): фіксація виїздів та повернень додому із захистом від хибних спрацьовувань через дрейф GPS.

---

## 🔒 Приватність та безпека

- **Жодних секретів у git:** Файл `config.yaml` надійно додано до `.gitignore`.
- **Лише локальна мережа:** Усі запити здійснюються напряму між вашим Mac та Home Assistant у локальній мережі.
- **Прозорий код:** Менше ніж 200 рядків стандартного зрозумілого Python без закритих бінарних файлів.

---

## 📄 Ліцензія

Проєкт розповсюджується під відкритою ліцензією [MIT License](LICENSE).
