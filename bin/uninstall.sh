#!/bin/bash
# uninstall.sh - Скрипт удаления Docker Port Checker

echo "🐳 Удаление Docker Port Checker"
echo "================================"

if [ -f "/usr/local/bin/docker-port-check" ]; then
    rm /usr/local/bin/docker-port-check
    echo "✅ Скрипт удален из /usr/local/bin/docker-port-check"
else
    echo "⚠️  Скрипт не найден в /usr/local/bin/docker-port-check"
fi

echo ""
echo "Удаление завершено."