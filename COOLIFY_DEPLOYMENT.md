# 🌐 Руководство по развёртыванию на Coolify

Этот гайд покажет как развернуть приложение на Coolify.

---

## 📋 Предварительные требования

- ✅ Coolify установлен и запущен
- ✅ GitHub аккаунт
- ✅ Docker работает
- ✅ Доступ к серверу с Coolify

---

## 🚀 Шаг 1: Подготовь репозиторий GitHub

### 1.1 Инициализируй Git локально

```bash
cd project
git init
git add .
git commit -m "Initial commit: Inventory System"
git branch -M main
```

### 1.2 Создай репозиторий на GitHub

1. Открой https://github.com/new
2. Назови репозиторий: **`inventory-system`**
3. Описание: **Inventory Management System**
4. Выбери **Public** (для простоты, или Private + добавь Coolify ключ)
5. Нажми **Create Repository**

### 1.3 Загрузи на GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/inventory-system.git
git push -u origin main
```

---

## 🔧 Шаг 2: Развёртывание PocketBase в Coolify

### 2.1 Открой Coolify Dashboard

1. Перейди на **http://your-server-ip:3000**
2. Залогинься в свой Coolify аккаунт
3. Выбери свой **Project** или создай новый

### 2.2 Добавь Docker Compose сервис

1. Нажми **"+ New"**
2. Выбери **"Docker Compose"**
3. Назови: **`PocketBase - Inventory`**

### 2.3 Вставь docker-compose.yml

```yaml
version: '3.8'

services:
  pocketbase:
    image: ghcr.io/pocketbase/pocketbase:latest
    container_name: inventory_pocketbase
    ports:
      - "8090:8090"
    volumes:
      - pb_data:/pb/pb_data
    environment:
      - ADMIN_EMAIL=admin@inventory.local
      - ADMIN_PASSWORD=YOUR_SECURE_PASSWORD_HERE
    networks:
      - inventory_net
    restart: unless-stopped

networks:
  inventory_net:
    driver: bridge

volumes:
  pb_data:
    driver: local
```

**ВАЖНО:** Замени `YOUR_SECURE_PASSWORD_HERE` на свой пароль!

### 2.4 Настрой Volume

1. В Coolify перейди в **Settings** этого сервиса
2. Найди **Volumes** раздел
3. Добавь:
   - **Container Path:** `/pb/pb_data`
   - **Host Path:** `/data/pb_data` (или другой на сервере)
4. Сохрани

### 2.5 Настрой Port

1. Убедись что в Compose указан порт **8090**
2. Доступ будет по: `http://your-server-ip:8090`

### 2.6 Запусти

1. Нажми **"Deploy"**
2. Дождись пока контейнер запустится
3. Проверь статус: должен быть **green/running**

### 2.7 Проверь что работает

Открой в браузере: **http://your-server-ip:8090/_/**

Должна появиться форма входа в PocketBase Admin Panel.

---

## 🎨 Шаг 3: Развёртывание Frontend в Coolify

### 3.1 Создай сервис для Frontend

1. Нажми **"+ New"**
2. Выбери **"Docker"** или **"Static Site"**
3. Назови: **`Inventory Frontend`**

### 3.2 Если Static Site

1. **Git Repository:** `https://github.com/YOUR_USERNAME/inventory-system.git`
2. **Branch:** `main`
3. **Build Command:** (оставь пусто)
4. **Publish Directory:** `.`
5. Нажми **"Deploy"**

### 3.3 Если Docker

Создай `Dockerfile` в корне проекта:

```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Затем в Coolify:
1. **Git Repository:** твой репозиторий
2. **Dockerfile:** `Dockerfile`
3. **Port:** `80`
4. Нажми **"Deploy"**

### 3.4 Настрой Environment переменные

1. В Coolify перейди в **Settings** Frontend сервиса
2. Найди **Environment Variables**
3. Добавь:
   ```
   VITE_POCKETBASE_URL=http://your-server-ip:8090
   ```
4. Сохрани

### 3.5 Получи URL Frontend

После деплоя Coolify даст тебе URL, например:
```
https://inventory-frontend-abc123.coolify.io
```

---

## 🔗 Шаг 4: Обнови конфигурацию

### 4.1 Обнови index.html

Измени строку в `index.html`:

```javascript
// ДО:
const pbUrl = 'http://localhost:8090';

// ПОСЛЕ:
const pbUrl = 'http://your-server-ip:8090';
// или
const pbUrl = process.env.VITE_POCKETBASE_URL || 'http://localhost:8090';
```

### 4.2 Коммит и push

```bash
git add .
git commit -m "Update PocketBase URL for production"
git push
```

Frontend автоматически перезагрузится в Coolify.

---

## 🔒 Шаг 5: Настрой HTTPS (SSL/TLS)

### Опция 1: Встроенный HTTPS в Coolify (рекомендуется)

1. В Coolify Settings сервиса
2. Найди **"SSL"** или **"HTTPS"**
3. Выбери **"Let's Encrypt"**
4. Введи свой домен (если есть)
5. Coolify автоматически получит и настроит сертификат

### Опция 2: Обратный прокси (Nginx)

Если у тебя есть свой домен:

```nginx
server {
    listen 443 ssl;
    server_name pb.yourdomain.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://pocketbase:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## ✅ Проверка развёртывания

### Чек-лист

- [ ] PocketBase работает: `http://your-server-ip:8090/_/`
- [ ] Frontend доступен через Coolify URL
- [ ] Collections созданы (users, equipment, usage)
- [ ] API правила настроены
- [ ] HTTPS работает (если настроен)
- [ ] Приложение открывается без ошибок
- [ ] Логин работает
- [ ] Админ может добавить оборудование
- [ ] Сотрудник видит оборудование

### Тестирование функциональности

1. **Админ логин:**
   ```
   Email: admin@test.com
   Password: 123456
   Role: admin
   ```

2. **Добавь оборудование:**
   - Нажми "+ Добавить оборудование"
   - Заполни форму
   - Проверь что оборудование появилось

3. **Сотрудник логин:**
   ```
   Email: worker@test.com
   Password: 123456
   Role: worker
   ```

4. **Отметь использование:**
   - Выбери оборудование
   - Нажми "Отметить использование"
   - Проверь что использование записалось

---

## 🐛 Решение проблем

### PocketBase не запускается

**Проверки:**
```bash
# Посмотри логи
docker logs inventory_pocketbase

# Проверь порт
netstat -tulpn | grep 8090

# Проверь Volume
docker volume ls
```

### Frontend не видит PocketBase

**Проверь:**
1. `VITE_POCKETBASE_URL` переменная правильная
2. PocketBase действительно запущен
3. Нет CORS ошибок (посмотри консоль браузера)
4. URL доступен с сервера

### Ошибка "Collection not found"

**Решение:**
1. Открой PocketBase Admin Panel
2. Создай Collections (смотри POCKETBASE_SETUP.md)
3. Установи API правила

### Volume не сохраняет данные

**Проверка:**
```bash
# Проверь что volume определен
docker volume ls

# Проверь точку монтирования в контейнере
docker inspect inventory_pocketbase | grep -A 3 Mounts
```

---

## 📊 Мониторинг

### В Coolify Dashboard

1. Каждый сервис показывает статус
2. Можешь видеть логи
3. Можешь рестартовать сервис
4. Можешь обновить переменные окружения

### Проверка здоровья

```bash
# PocketBase health check
curl http://your-server-ip:8090/api/health

# Frontend доступность
curl -I https://your-frontend-url.coolify.io
```

---

## 🔄 Обновления и Деплой

### Если что-то изменилось локально

1. Коммит в git:
   ```bash
   git add .
   git commit -m "Update something"
   git push
   ```

2. В Coolify:
   - Frontend автоматически перезагрузится
   - Или нажми "Redeploy"

### Обновление PocketBase

1. В Coolify перейди в Settings
2. Обнови версию образа: `ghcr.io/pocketbase/pocketbase:latest`
3. Нажми "Redeploy"
4. Данные сохранятся в Volume

---

## 🎉 Готово!

Твое приложение теперь развёрнуто на Coolify!

**URLs для запоминания:**
- 📦 **PocketBase Admin:** `http://your-server-ip:8090/_/`
- 🎨 **Frontend:** `https://your-frontend-url.coolify.io`
- 📊 **Coolify Dashboard:** `http://your-server-ip:3000`

---

**Автор:** Inventory System  
**Дата:** 2024
