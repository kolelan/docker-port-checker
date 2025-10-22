```markdown
# Docker Port Checker

[Русский](#русский) | [English](#english)

## Русский

### Описание

**Docker Port Checker** - это bash-скрипт для проверки занятости портов перед запуском `docker-compose up`. Скрипт автоматически анализирует ваш `docker-compose.yml` файл, находит все объявленные порты и проверяет, не заняты ли они другими процессами или Docker-контейнерами.

### Особенности

- 🔍 **Автоматический парсинг** - анализирует `docker-compose.yml` и извлекает все порты
- 📊 **Детальная информация** - показывает какие процессы или контейнеры занимают порты
- 🎨 **Цветной вывод** - наглядное отображение свободных и занятых портов
- 🐳 **Docker интеграция** - определяет Docker-контейнеры, использующие порты
- ⚡ **Простота использования** - один скрипт, без зависимостей

### Установка

```bash
# Клонируйте репозиторий
git clone https://github.com/kolelan/docker-port-checker.git
cd docker-port-checker

# Сделайте скрипт исполняемым
chmod +x docker-port-check.sh
```

### Использование

```bash
# Проверить порты из docker-compose.yml в текущей директории
./docker-port-check.sh

# Проверить порты из конкретного файла
./docker-port-check.sh docker-compose.prod.yml

# Проверить порты из файла в другой директории
./docker-port-check.sh /path/to/your/docker-compose.yml
```

### Пример вывода

```
Проверка файла: docker-compose.yml

Найдены порты для проверки:
5159
5439
6379
9001

Проверка порта 5159... СВОБОДЕН
Проверка порта 5439... ЗАНЯТ
Проверка порта 6379... СВОБОДЕН
Проверка порта 9001... ЗАНЯТ

╔══════════════════════════════════════════════════════════════╗
║                 ЗАНЯТЫЕ ПОРТЫ                                ║
╚══════════════════════════════════════════════════════════════╝

Порт 5439 занят:
  Информация о соединении: tcp LISTEN 0 4096 0.0.0.0:5439 0.0.0.0:* users:(("docker-proxy",pid=1234,fd=14))
  Docker контейнер: postgres13 (0.0.0.0:5439->5432/tcp)

Порт 9001 занят:
  Информация о соединении: tcp LISTEN 0 4096 0.0.0.0:9001 0.0.0.0:* users:(("node",pid=5678,fd=21))
  Информация о процессе: PID: 5678, Процесс: node, Команда: node server.js

✗ Найдены занятые порты. Перед запуском docker-compose необходимо освободить порты.
```

### Преимущества

- **Экономит время** - автоматически проверяет все порты вместо ручной проверки
- **Предотвращает ошибки** - показывает конфликты до запуска контейнеров
- **Детальная диагностика** - указывает точную причину занятости порта
- **Универсальность** - работает с любым `docker-compose.yml` файлом

### Совместимость

- ✅ Linux (Ubuntu, Debian, CentOS, etc.)
- ✅ macOS
- ✅ WSL (Windows Subsystem for Linux)
- ✅ Docker & Docker Compose

### Лицензия

MIT License

---

## English

### Description

**Docker Port Checker** is a bash script that checks port availability before running `docker-compose up`. The script automatically analyzes your `docker-compose.yml` file, finds all declared ports, and checks if they are occupied by other processes or Docker containers.

### Features

- 🔍 **Automatic parsing** - analyzes `docker-compose.yml` and extracts all ports
- 📊 **Detailed information** - shows which processes or containers are using ports
- 🎨 **Colored output** - visual display of free and occupied ports
- 🐳 **Docker integration** - identifies Docker containers using ports
- ⚡ **Easy to use** - single script, no dependencies

### Installation

```bash
# Clone the repository
git clone https://github.com/kolelan/docker-port-checker.git
cd docker-port-checker

# Make the script executable
chmod +x docker-port-check.sh
```

### Usage

```bash
# Check ports from docker-compose.yml in current directory
./docker-port-check.sh

# Check ports from specific file
./docker-port-check.sh docker-compose.prod.yml

# Check ports from file in another directory
./docker-port-check.sh /path/to/your/docker-compose.yml
```

### Example Output

```
Checking file: docker-compose.yml

Found ports to check:
5159
5439
6379
9001

Checking port 5159... FREE
Checking port 5439... OCCUPIED
Checking port 6379... FREE
Checking port 9001... OCCUPIED

╔══════════════════════════════════════════════════════════════╗
║                 OCCUPIED PORTS                               ║
╚══════════════════════════════════════════════════════════════╝

Port 5439 occupied:
  Connection info: tcp LISTEN 0 4096 0.0.0.0:5439 0.0.0.0:* users:(("docker-proxy",pid=1234,fd=14))
  Docker container: postgres13 (0.0.0.0:5439->5432/tcp)

Port 9001 occupied:
  Connection info: tcp LISTEN 0 4096 0.0.0.0:9001 0.0.0.0:* users:(("node",pid=5678,fd=21))
  Process info: PID: 5678, Process: node, Command: node server.js

✗ Found occupied ports. You need to free ports before running docker-compose.
```

### Benefits

- **Saves time** - automatically checks all ports instead of manual checking
- **Prevents errors** - shows conflicts before container startup
- **Detailed diagnostics** - indicates exact reason for port occupation
- **Universal** - works with any `docker-compose.yml` file

### Compatibility

- ✅ Linux (Ubuntu, Debian, CentOS, etc.)
- ✅ macOS
- ✅ WSL (Windows Subsystem for Linux)
- ✅ Docker & Docker Compose

### License

MIT License
```

