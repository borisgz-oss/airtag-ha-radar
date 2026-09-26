# 🛰️ AirTag HA Radar

[English](README.md) | [Українська](README_UA.md) | [Русский](README_RU.md)

> **Приватный мост между Apple AirTag и Home Assistant с нулевыми рисками для Apple ID, готовыми Bento-дашбордами, парковочным радаром и историей маршрутов.**

[![macOS](https://img.shields.io/badge/macOS-Sonoma%20%7C%20Sequoia-black?logo=apple)](https://apple.com)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2024%2B-blue?logo=homeassistant)](https://home-assistant.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Zero SIP](https://img.shields.io/badge/SIP-Protected%20(Без%20Root)-brightgreen)](https://apple.com)

---

## 🌟 Почему AirTag HA Radar?

Большинство существующих способов завести AirTag в Home Assistant либо **сломаны** (после того как Apple зашифровала локальный кэш в macOS 14.4+), либо требуют поднимать тяжелые **Docker-контейнеры Anisette**, вводить логин и пароль от Apple ID и рисковать блокировкой аккаунта со стороны Apple.

**AirTag HA Radar** предлагает принципиально другой, безопасный и чистый подход:
- 🔒 **Zero Credentials (Без паролей):** Никаких паролей от Apple ID или кодов двухфакторки (2FA). Скрипт локально считывает данные из уже авторизованного приложения «Локатор» на вашем Mac.
- 🛡️ **Zero SIP:** Не требует отключения System Integrity Protection или root-прав.
- ⚡ **Ультра-легковесный:** Работает как тихий системный сервис macOS (LaunchAgent), потребляя **0.0% CPU** и всего **~14 МБ RAM**.
- 🚗 **Парковочный радар для авто:** Пешеходная навигация в 1 клик с вашего смартфона прямо к припаркованной машине через Apple Maps (`dirflg=w`) или Google Maps.
- 📈 **Bento-дашборд и аналитика:** Готовые карточки Lovelace с линиями пройденных маршрутов (`hours_to_show`), хронологией стоянок и активностью по дням недели в стиле Google Tracks.

---

## 📐 Архитектура

```text
┌────────────────┐        ┌─────────────────────────┐        ┌───────────────────────┐
│  Apple AirTags │ ──BLE─▶│    Сеть Apple Find My   │ ──────▶│ Приложение «Локатор»   │
└────────────────┘        └─────────────────────────┘        └───────────┬───────────┘
                                                                         │
                                                                   ~30ms опрос
                                                                         │
┌─────────────────────────┐                                  ┌───────────▼───────────┐
│ Home Assistant Lovelace │◀───── REST / WebSocket API ──────│    findmy_sync.py     │
│ (Bento-радар и треки)   │                                  │  (Тихий LaunchAgent)  │
└─────────────────────────┘                                  └───────────────────────┘
```

---

## 🚀 Быстрый старт за 3 шага

### Шаг 1: Клонирование и настройка
```bash
git clone https://github.com/borisgz-oss/airtag-ha-radar.git
cd airtag-ha-radar
cp config.example.yaml config.yaml
```

Откройте `config.yaml` и укажите адрес Home Assistant, долгоживущий токен и названия ваших меток:
```yaml
home_assistant:
  url: "http://homeassistant.local:8123"
  token: "ВАШ_LONG_LIVED_ACCESS_TOKEN"

airtags:
  "Car":
    dev_id: "airtag_car"
    name: "Машина"
    icon: "mdi:car-side"
  "Keys":
    dev_id: "airtag_keys"
    name: "Ключи"
    icon: "mdi:key-wireless"
```

### Шаг 2: Установка фонового сервиса на macOS
Запустите установочный скрипт для регистрации демона LaunchAgent:
```bash
chmod +x macos-bridge/install.sh
./macos-bridge/install.sh
```
*Демон будет автоматически стартовать при входе в систему и работать в фоне без открытых окон терминала.*

Посмотреть логи работы:
```bash
cat /tmp/airtag-ha-sync.log
```

Удалить сервис в любой момент:
```bash
./macos-bridge/uninstall.sh
```

### Шаг 3: Добавление в Home Assistant
1. **Пакеты (Packages):** Скопируйте файл `homeassistant/packages/airtags_tracking.yaml` в папку `includes/packages/` вашего Home Assistant (или объедините с `configuration.yaml`).
2. **Дашборд:** 
   - В Home Assistant откройте **Настройки ➔ Панели управления ➔ Добавить панель** (URL: `airtags-tracking`).
   - Откройте «Редактор конфигурации (Raw)» и вставьте содержимое файла `homeassistant/dashboards/airtags_bento.yaml`.

---

## 🎛️ Возможности дашборда

### 1. Живой радар с нитками маршрутов
- Отображение всех AirTag на интерактивной темной карте.
- Автоматическое соединение зафиксированных GPS-точек в непрерывные цветные линии маршрутов за 1 час, 24 часа или 7 дней.

### 2. Парковочный радар для автомобиля
- Статус в реальном времени: `На стоянке у дома (14 ч 20 м)` или `В городе / На выезде`.
- **Пешеходный маршрут в 1 клик:** Нажатие на статус авто мгновенно открывает Apple Maps на телефоне со стрелками пешего маршрута прямо к текущему положению машины.

### 3. Аналитика и тренды мобильности
- График активности за 7 дней (ApexCharts): показывает время, проведенное вне дома по дням недели.
- Хронологическая лента событий (Logbook): фиксация выездов и возвращений домой с защитой от ложных срабатываний из-за дрейфа GPS.

---

## 🔒 Приватность и безопасность

- **Секреты не уходят в git:** Файл `config.yaml` надежно внесен в `.gitignore`.
- **Только локальная сеть:** Все запросы идут напрямую между вашим Mac и Home Assistant в локальной сети.
- **Прозрачный код:** Менее 200 строк стандартного читаемого Python без проприетарных бинарников.

---

## ☕ Поддержка и донаты

Если этот проект помог вам отслеживать машину, спас потерянный багаж или просто сделал жизнь проще, вы можете поддержать автора:

[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-ea4aaa?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/borisgz-oss)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-Donate-yellow?logo=buymeacoffee&logoColor=black)](https://buymeacoffee.com/borisgz)

---

## 📄 Лицензия

Проект распространяется под открытой лицензией [MIT License](LICENSE).

