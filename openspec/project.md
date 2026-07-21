# Project Context: TextSnatcher

## Описание проекта
**TextSnatcher** — графическое приложение для Linux (elementary OS / GNOME), предназначенное для быстрого оптического распознавания текста (OCR) с изображений, снимков экрана и из буфера обмена. Приложение использует движок Tesseract OCR для распознавания текста и копирования его в системный буфер обмена.

---

## Стек технологий (Tech Stack)

### Основной язык и фреймворки
- **Язык программирования:** Vala (транспилируется в C перед компиляцией через `valac`).
- **Графический интерфейс (GUI):**
  - `GTK+ 3` (`gtk+-3.0`) — базовый инструментарий создания UI и обработки событий.
  - `Libhandy 1` (`libhandy-1` / `Hdy`) — библиотека адаптируемых виджетов и окон в стиле GNOME/elementary OS (`Hdy.ApplicationWindow`, `Hdy.WindowHandle`).
  - `Granite` (`granite`) — библиотека виджетов и системных настроек elementary OS (интеграция темного/светлого режима).
  - `gdk-pixbuf-2.0` — обработка и сохранение растровых изображений.

### Системная интеграция и распознавание (OCR)
- **OCR Движок:** `tesseract` (Tesseract OCR CLI 4.x / 5.x) + языковые пакеты (`tessdata`).
- **Снимки экрана и вызов диалогов:**
  - `libportal` (`Xdp.Portal`) — фреймворк для взаимодействия с Flatpak/Desktop Portals (запрос скриншота, диалог открытия файлов под Wayland и X11).
  - `scrot` — утилита захвата экрана для фоллбека в окружениях X11.
- **Трей и фоновый режим:**
  - `ayatana-appindicator3-0.1` (`TrayIcon` / `CosmicTray`) — поддержка системного трея под X11, Wayland и COSMIC Desktop Environment.

### Сборка и дистрибуция
- **Система сборки:** `Meson` и `Ninja`.
- **Ресурсы:** `GResource` (`com.github.rajsolai.textsnatcher.gresource.xml`) для компиляции иконки приложения и CSS-стилей (`stylesheet.css`).
- **Пакетная сборка:** Flatpak (`com.github.rajsolai.textsnatcher.yml`), Debian (`debian/`), AppCenter.

---

## Архитектура проекта (Architecture)

Структура исходного кода находится в директории `TextSnatcher-master/src/`:

```text
src/
├── Application.vala             # Точка входа, инициализация Gtk.Application, тем оформления и трея
├── MainWindow.vala              # Главное окно приложения (Hdy.ApplicationWindow)
├── components/                  # Повторно используемые UI-компоненты и диалоги
│   ├── HeaderBar.vala           # Кастомная шапка окна (CustomHeaderBar)
│   ├── LanguageButton.vala      # Кнопка выбора языка OCR
│   ├── SaveOptionsButton.vala   # Выбор вариантов сохранения/источников
│   ├── AboutButton.vala         # Кнопка "О программе"
│   ├── AboutDialog.vala         # Диалог с информацией о программе
│   ├── TrayIcon.vala            # Интеграция с иконкой трея (AppIndicator)
│   └── CosmicTray.vala          # Интеграция с треем для COSMIC / Wayland
├── screens/                     # Основные экраны/представления приложения
│   ├── MainScreen.vala          # Контейнер экранов (Gtk.Stack) и контроллер операций
│   ├── HomeScreen.vala          # Главный экран запуска OCR и выбора языка
│   └── SelectPictureScreen.vala # Экран выбора источника изображения (Скриншот/Файл/Буфер)
├── services/                    # Бизнес-логика и службы
│   └── TesseractTrigger.vala    # Захват изображения, вызов Tesseract OCR, работа с буфером
└── utils/                       # Вспомогательные утилиты
    └── Logger.vala              # Модуль логирования (файлы логов + stdout)
```

### Основные архитектурные слои:
1. **Application & Navigation Layer (`Application.vala`, `MainWindow.vala`, `screens/`):**
   - Управление жизненным циклом `Gtk.Application`.
   - Использование `Gtk.Stack` в `MainScreen` для переключения экранов без пересоздания окон.
   - Автоматическая адаптация темы приложения (светлая/тёмная) через `Granite.Settings`.
2. **Components Layer (`src/components/`):**
   - Изолированные UI-виджеты, инкапсулирующие собственное состояние и сигналы.
3. **Service Layer (`src/services/TesseractTrigger.vala`):**
   - Логика получения изображения: скриншот через `Xdp.Portal` или `scrot`, чтение из буфера обмена (`Gtk.Clipboard`), либо выбор файла через портал.
   - Асинхронное выполнение команды `tesseract` через GLib (`Process.spawn_command_line_sync`).
   - Копирование распознанного текста из результирующего `.txt` файла в системный буфер обмена.
4. **Utility Layer (`src/utils/Logger.vala`):**
   - Уровни логирования: `DEBUG`, `INFO`, `WARN`, `ERROR`. Запись логов в файл кэша пользователя (`~/.cache/textsnatcher/`) и в `stdout`.

---

## Правила написания кода и конвенции (Code Conventions)

### 1. Форматирование и кодостиль
- **Отступы:** 4 пробела (пробельный стиль, без символов табуляции в Vala-файлах).
- **Длина строки:** до 80 символов.
- **Кодировка:** UTF-8, переводы строк LF.
- **Пробелы при вызовах:** В стиле Vala/elementary принято ставить пробел перед открывающей скобкой вызова функции или метода:
  ```vala
  var window = new MainWindow (this) ;
  if (condition) {
      // ...
  }
  ```
- **Смикрон (точка с запятой):** Допускается выделение точек с запятой пробелом ` ;` согласно стилю авторов проекта.

### 2. Именование (Naming Conventions)
- **Классы и перечисления:** `PascalCase` (напр. `MainWindow`, `TesseractTrigger`, `LogLevel`).
- **Переменные, методы, сигналы:** `snake_case` (напр. `main_window`, `get_tesseract_trigger ()`, `cancel_signal`).
- **Константы:** `UPPER_CASE` (напр. `DEBUG`, `FLAGS_NONE`).

### 3. Асинхронность и обработка ошибок
- **Асинхронный I/O:** Для тяжелых операций (скриншот, запуск внешних процессов OCR, чтение из файла) следует использовать асинхронные ключевые слова Vala `async` / `yield`.
- **Обработка ошибок:** Все вызовы, способные выбросить исключение (GLib `Error`), должны оборачиваться в блоки `try { ... } catch (Error e) { ... }`.
- **Логирование:** Использовать `Logger.debug()`, `Logger.info()`, `Logger.warn()`, `Logger.error()` или стандартные макросы `critical()`, `print()` для вывода диагностических сообщений.

### 4. Добавление новых файлов
- При создании новых файлов `.vala` необходимо обязательно регистрировать их в массиве `sources` в [src/meson.build](file:///home/kunui/Документы/v2/TextSnatcher-master/TextSnatcher-master/src/meson.build).
