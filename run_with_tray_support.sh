#!/bin/bash
# Скрипт для запуска TextSnatcher с поддержкой иконки в трее на Wayland
# Принудительно устанавливает GDK_BACKEND=x11 для поддержки иконки в трее

# Сохраняем оригинальное значение XDG_SESSION_TYPE
ORIGINAL_SESSION_TYPE=$XDG_SESSION_TYPE

# Устанавливаем переменные окружения для принудительного использования X11 backend
export GDK_BACKEND=x11

# Запускаем приложение
echo "Запуск TextSnatcher с поддержкой иконки в трее..."
com.github.rajsolai.textsnatcher

# Восстанавливаем оригинальное значение XDG_SESSION_TYPE, если оно было
if [ ! -z "$ORIGINAL_SESSION_TYPE" ]; then
    export XDG_SESSION_TYPE=$ORIGINAL_SESSION_TYPE
fi