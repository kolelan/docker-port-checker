#!/bin/bash

# Скрипт для проверки свободных портов перед запуском docker-compose
# Проверяет порты, указанные в docker-compose.yml и показывает процессы/контейнеры, которые их занимают

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Файл docker-compose.yml (можно изменить через аргумент)
COMPOSE_FILE="${1:-docker-compose.yml}"

# Проверка существования файла
if [[ ! -f "$COMPOSE_FILE" ]]; then
    echo -e "${RED}Ошибка: Файл $COMPOSE_FILE не найден${NC}"
    echo "Использование: $0 [docker-compose-file]"
    exit 1
fi

echo -e "${BLUE}Проверка файла: $COMPOSE_FILE${NC}"
echo

# Функция для получения портов из docker-compose.yml
get_ports_from_compose() {
    local file="$1"
    local ports=()

    # Используем yq для парсинга YAML (если установлен)
    if command -v yq >/dev/null 2>&1; then
        echo -e "${BLUE}Используем yq для парсинга YAML...${NC}" >&2
        while IFS= read -r port_mapping; do
            if [[ -n "$port_mapping" ]]; then
                # Извлекаем хост-порт из формата "host:container"
                host_port=$(echo "$port_mapping" | cut -d':' -f1)
                # Убираем кавычки если есть
                host_port=$(echo "$host_port" | sed "s/['\"]//g")

                # Обрабатываем диапазоны портов
                if [[ $host_port =~ ^([0-9]+)-([0-9]+)$ ]]; then
                    local start_port="${BASH_REMATCH[1]}"
                    local end_port="${BASH_REMATCH[2]}"
                    for port in $(seq "$start_port" "$end_port"); do
                        ports+=("$port")
                    done
                elif [[ $host_port =~ ^[0-9]+$ ]]; then
                    ports+=("$host_port")
                fi
            fi
        done < <(yq e '.services[].ports[]' "$file" 2>/dev/null | grep -v null)
    else
        # Альтернативный метод через grep (более простой, но менее надежный)
        echo -e "${YELLOW}yq не установлен, используем grep для парсинга...${NC}" >&2
        while IFS= read -r line; do
            # Ищем строки с портами в форматах: "HOST:CONTAINER", 'HOST:CONTAINER', HOST:CONTAINER
            if [[ $line =~ \ *-\ *[\"\']?([0-9]+)(-[0-9]+)?:([0-9]+) ]]; then
                host_port="${BASH_REMATCH[1]}"
                ports+=("$host_port")
            fi
        done < <(grep -E "ports:" -A 20 "$file" | grep -E "[[:space:]]*-\s+[\"']?[0-9]+:" | sed "s/[\"']//g")
    fi

    # Убираем дубликаты и сортируем
    printf '%s\n' "${ports[@]}" | sort -nu
}

# Функция для проверки занятости порта
check_port() {
    local port="$1"
    local result=""

    # Проверяем, слушает ли порт какой-либо процесс
    if command -v ss >/dev/null 2>&1; then
        # Используем ss (более современная утилита)
        result=$(ss -tulpn 2>/dev/null | grep -E ":$port[[:space:]]" || true)
    elif command -v netstat >/dev/null 2>&1; then
        # Используем netstat (устаревшая, но широко доступная)
        result=$(netstat -tulpn 2>/dev/null | grep -E ":$port[[:space:]]" || true)
    else
        echo -e "${YELLOW}Предупреждение: Не найдены утилиты ss или netstat${NC}" >&2
        return 1
    fi

    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

# Функция для получения информации о контейнере по порту
get_container_by_port() {
    local port="$1"
    docker ps --format "table {{.Names}}\t{{.Ports}}" 2>/dev/null | grep -E ":$port->" || true
}

# Функция для получения детальной информации о процессе
get_process_info() {
    local port_info="$1"
    local pid=""

    # Извлекаем PID из вывода ss/netstat
    if [[ $port_info =~ pid=([0-9]+) ]]; then
        pid="${BASH_REMATCH[1]}"
        # Получаем информацию о процессе
        if [[ -f "/proc/$pid/comm" ]]; then
            local process_name=$(cat "/proc/$pid/comm" 2>/dev/null || echo "неизвестно")
            local cmdline=$(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ' | head -c 100 || echo "неизвестно")
            echo "PID: $pid, Процесс: $process_name, Команда: $cmdline"
        else
            echo "PID: $pid (процесс не найден)"
        fi
    else
        echo "Не удалось определить PID"
    fi
}

# Основная логика
main() {
    local all_ports
    all_ports=$(get_ports_from_compose "$COMPOSE_FILE")

    if [[ -z "$all_ports" ]]; then
        echo -e "${YELLOW}В файле $COMPOSE_FILE не найдено объявленных портов${NC}"
        exit 0
    fi

    echo -e "${BLUE}Найдены порты для проверки:${NC}"
    echo "$all_ports"
    echo

    local occupied_ports=()
    local free_ports=()

    # Проверяем каждый порт
    while IFS= read -r port; do
        if [[ -n "$port" ]]; then
            echo -n "Проверка порта $port... "

            local port_info
            if port_info=$(check_port "$port"); then
                echo -e "${RED}ЗАНЯТ${NC}"
                occupied_ports+=("$port:$port_info")
            else
                echo -e "${GREEN}СВОБОДЕН${NC}"
                free_ports+=("$port")
            fi
        fi
    done <<< "$all_ports"

    echo

    # Выводим информацию о занятых портах
    if [[ ${#occupied_ports[@]} -gt 0 ]]; then
        echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║                 ЗАНЯТЫЕ ПОРТЫ                               ║${NC}"
        echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo

        for port_info in "${occupied_ports[@]}"; do
            IFS=':' read -r port info <<< "$port_info"
            echo -e "${YELLOW}Порт $port занят:${NC}"
            echo "  Информация о соединении: $info"

            # Проверяем Docker контейнеры
            local container_info
            container_info=$(get_container_by_port "$port")
            if [[ -n "$container_info" ]]; then
                echo -e "  ${BLUE}Docker контейнер: $container_info${NC}"
            else
                echo -e "  ${BLUE}Информация о процессе:${NC}"
                echo "  $(get_process_info "$info")"
            fi
            echo
        done

        echo -e "${RED}ВНИМАНИЕ: Некоторые порты заняты! Docker-compose может не запуститься.${NC}"
        echo
    fi

    # Выводим информацию о свободных портах
    if [[ ${#free_ports[@]} -gt 0 ]]; then
        echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║                 СВОБОДНЫЕ ПОРТЫ                              ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        printf '%s\n' "${free_ports[@]}"
        echo
    fi

    # Итоговый статус
    if [[ ${#occupied_ports[@]} -eq 0 ]]; then
        echo -e "${GREEN}✓ Все порты свободны. Можно запускать docker-compose up${NC}"
        exit 0
    else
        echo -e "${RED}✗ Найдены занятые порты. Перед запуском docker-compose необходимо освободить порты.${NC}"
        exit 1
    fi
}

# Запуск основной функции
main "$@"