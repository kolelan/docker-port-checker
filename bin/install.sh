#!/bin/bash
# install.sh - Скрипт установки Docker Port Checker

echo "🐳 Установка Docker Port Checker"
echo "================================="

# URL репозитория
REPO_URL="https://github.com/kolelan/docker-port-checker.git"
TEMP_DIR="/tmp/docker-port-checker"

echo "📥 Клонирование репозитория..."
git clone $REPO_URL $TEMP_DIR

echo "📋 Копирование файлов..."
cp $TEMP_DIR/docker-port-check.sh /usr/local/bin/docker-port-check

echo "🔧 Установка прав..."
chmod +x /usr/local/bin/docker-port-check

echo "🧹 Очистка временных файлов..."
rm -rf $TEMP_DIR

echo ""
echo "✅ Установка завершена!"
echo ""
echo "Использование:"
echo "  docker-port-check                    # проверить docker-compose.yml в текущей директории"
echo "  docker-port-check docker-compose.yml # проверить конкретный файл"
echo ""
echo "GitHub: https://github.com/kolelan/docker-port-checker"
