#!/bin/bash
# Скрипт для запуска TextSnatcher с поддержкой иконки в трее на Wayland
# Запускает приложение в режиме XWayland, где поддержка системного трея лучше

# Проверяем, запущен ли сеанс Wayland
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # Если запущен Wayland, пробуем запустить приложение через XWayland
    if command -v Xwayland &> /dev/null; then
        # Создаем временный X сервер и запускаем приложение в нем
        echo "Запуск TextSnatcher в режиме XWayland для поддержки иконки в трее..."
        env GDK_BACKEND=x11 com.github.rajsolai.textsnatcher
    else
        echo "Xwayland не установлен. Запуск приложения без поддержки иконки в трее..."
        com.github.rajsolai.textsnatcher
    fi
else
    # Если сеанс X11, просто запускаем приложение
    com.github.rajsolai.textsnatcher
fi