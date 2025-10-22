#!/bin/bash

# Упрощенная версия скрипта проверки портов

COMPOSE_FILE="${1:-docker-compose.yml}"

if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo "Ошибка: Файл $COMPOSE_FILE не найден"
    exit 1
fi

echo "Проверка портов из $COMPOSE_FILE:"

# Извлекаем порты
ports=$(grep -E "[[:space:]]*-\s+\"[0-9]+:[0-9]+\"" "$COMPOSE_FILE" | sed 's/.*"\([0-9]*\):[0-9]*".*/\1/' | sort -u)

for port in $ports; do
    if ss -tulpn | grep -q ":$port "; then
        echo "❌ Порт $port занят:"
        ss -tulpn | grep ":$port "
        echo "---"
    else
        echo "✅ Порт $port свободен"
    fi
done