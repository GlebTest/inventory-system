# 📦 Система Инвентаризации

Простое SaaS-приложение для управления оборудованием в офисе. Два уровня доступа: **Администратор** (управляет оборудованием) и **Сотрудник** (видит и отмечает использование).

---

## 🎯 Особенности

✅ **Две роли пользователей:**
- **Администратор** — добавляет, просматривает и удаляет оборудование
- **Сотрудник** — видит список оборудования и отмечает использование

✅ **Встроенная авторизация** — email/пароль регистрация и вход

✅ **Real-time API** — данные обновляются в реальном времени

✅ **Статистика** — количество оборудования и использований

---

## 🛠 Технический стек

| Компонент | Технология |
|-----------|-----------|
| **Backend** | PocketBase (SQLite + REST API) |
| **Frontend** | HTML/CSS/JavaScript (Vanilla) |
| **Хостинг** | Coolify (Docker) |
| **SDK** | PocketBase JavaScript SDK (CDN) |

---

## 📋 Структура проекта

```
project/
├── index.html           # Главный файл приложения
├── .env.example        # Шаблон переменных окружения
├── .gitignore          # Git конфигурация
├── README.md           # Этот файл
└── POCKETBASE_SETUP.md # Инструкции по настройке PocketBase
```

---

## 🚀 Быстрый старт

### Шаг 1: Запусти PocketBase локально (для тестирования)

```bash
# Скачай PocketBase отсюда: https://pocketbase.io/

# Запусти
./pocketbase serve

# PocketBase запустится на http://localhost:8090
# Admin панель: http://localhost:8090/_/
```

### Шаг 2: Настрой Collections в PocketBase

Следуй инструкциям в `POCKETBASE_SETUP.md`

### Шаг 3: Открой приложение

```bash
# Открой файл в браузере
open index.html

# Или запусти локальный сервер
python -m http.server 8000
# затем открой http://localhost:8000
```

### Шаг 4: Тестирование

1. **Логин/Регистрация:**
   - Email: `admin@test.com`
   - Пароль: `123456`
   - Роль: **Администратор**

2. **В админ панели:**
   - Нажми "+ Добавить оборудование"
   - Заполни название и описание
   - Нажми "Добавить"

3. **Переключись на Сотрудника:**
   - Выйди (кнопка "Выход")
   - Email: `worker@test.com`
   - Пароль: `123456`
   - Роль: **Сотрудник**
   - Видишь оборудование и можешь отметить использование

---

## 🔐 Архитектура безопасности

### API Правила (PocketBase)

**Users Collection:**
```
Create:  ❌ Никто (регистрация только через app)
Read:    👤 Только свой профиль
Update:  👤 Только свой профиль
Delete:  ❌ Никто
```

**Equipment Collection:**
```
Create:  👨‍💼 Только админ
Read:    ✅ Все (после входа)
Update:  👨‍💼 Только админ
Delete:  👨‍💼 Только админ
```

**Usage Collection:**
```
Create:  👤 Все (после входа)
Read:    👨‍💼 Админ видит всё, Сотрудник видит свои
Update:  ❌ Никто
Delete:  👨‍💼 Только админ
```

---

## 🌐 Развёртывание на Coolify

### Шаг 1: Подготовка

```bash
# Убедись что у тебя есть:
- GitHub аккаунт
- Coolify установлен
- Docker работает
```

### Шаг 2: Загрузи в GitHub

```bash
cd project
git add .
git commit -m "Initial commit: Inventory system"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/inventory-system.git
git push -u origin main
```

### Шаг 3: Создай PocketBase в Coolify

1. Открой Coolify Dashboard
2. **Новая служба → Docker Compose**
3. Используй `docker-compose.yml` (см. ниже)
4. **ВАЖНО:** Добавь Volume для `/pb_data`

**docker-compose.yml:**
```yaml
version: '3.8'
services:
  pocketbase:
    image: ghcr.io/pocketbase/pocketbase:latest
    container_name: pocketbase
    ports:
      - "8090:8090"
    volumes:
      - pb_data:/pb/pb_data
    environment:
      - ADMIN_EMAIL=admin@example.com
      - ADMIN_PASSWORD=your_secure_password
    networks:
      - default

volumes:
  pb_data:
    driver: local
```

### Шаг 4: Создай Frontend в Coolify

1. **Новая служба → Static Site**
2. Подключи GitHub репозиторий
3. **Build Command:** (оставь пусто, статический сайт)
4. **Publish Directory:** `.`
5. **Environment Variables:**
   ```
   VITE_POCKETBASE_URL=https://pb-yourdomain.com
   ```

---

## 📝 Переменные окружения

Скопируй `.env.example` в `.env`:

```bash
cp .env.example .env
```

**Необходимые переменные:**

| Переменная | Значение | Где использовать |
|-----------|---------|-----------------|
| `VITE_POCKETBASE_URL` | URL PocketBase (с HTTPS на продакшене) | Frontend `index.html` |

**Пример для Coolify:**
```
VITE_POCKETBASE_URL=https://pb.my-app.com
```

**Пример локально:**
```
VITE_POCKETBASE_URL=http://localhost:8090
```

---

## 🔑 Важно! Persistent Volumes

**Это КРИТИЧЕСКИ ВАЖНО!**

Без Persistent Volumes все данные теряются при перезагрузке контейнера!

**В docker-compose.yml:**
```yaml
volumes:
  pb_data:
    driver: local

services:
  pocketbase:
    volumes:
      - pb_data:/pb/pb_data  ← Это обязательно!
```

**В Coolify UI:**
1. Перейди в Settings сервиса
2. Добавь Volume: `/pb_data`
3. Сохрани

---

## 🧪 Тестирование

### Локальное тестирование

```bash
# 1. Запусти PocketBase
./pocketbase serve

# 2. В новом терминале запусти HTTP сервер
python -m http.server 8000

# 3. Открой http://localhost:8000 в браузере
```

### Тестовые учетные данные

| Роль | Email | Пароль |
|-----|-------|--------|
| Админ | `admin@test.com` | `123456` |
| Сотрудник | `worker@test.com` | `123456` |

---

## 🐛 Решение проблем

### Ошибка: "Failed to fetch from PocketBase"

**Причина:** Неправильный URL PocketBase

**Решение:**
1. Проверь консоль браузера (F12)
2. Убедись что PocketBase работает
3. Проверь `VITE_POCKETBASE_URL` переменную

### Ошибка: "Collection not found"

**Причина:** Collections не созданы в PocketBase

**Решение:**
1. Следуй инструкциям в `POCKETBASE_SETUP.md`
2. Создай Collections: `users`, `equipment`, `usage`
3. Настрой API правила

### Данные теряются при перезагрузке

**Причина:** Нет Persistent Volume

**Решение:**
- Добавь Volume в docker-compose или Coolify Settings

---

## 📊 Collections в PocketBase

### Users
- `id` (Auto)
- `email` (Text)
- `password` (Password)
- `role` (Select: admin, worker)
- `created` (Date Auto)

### Equipment
- `id` (Auto)
- `name` (Text)
- `description` (Text)
- `created_by` (Relation → users)
- `created` (Date Auto)

### Usage
- `id` (Auto)
- `equipment` (Relation → equipment)
- `used_by` (Relation → users)
- `used_at` (DateTime Auto)

---

## 🎨 Кастомизация

### Изменить цвета

В `index.html` найди стиль:
```css
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
```

Замени на свои цвета.

### Добавить новые поля

1. Создай новое поле в PocketBase Collection
2. Обнови форму в HTML
3. Обнови JavaScript код для сохранения

---

## 📞 Поддержка

Если что-то не работает:

1. Проверь консоль браузера (F12 → Console)
2. Проверь PocketBase Admin Panel
3. Проверь переменные окружения
4. Убедись что Collections созданы корректно

---

## 📄 Лицензия

MIT

---

## ✅ Контрольный список для сдачи

- [ ] Фронтенд работает на Coolify
- [ ] PocketBase работает с Persistent Volumes
- [ ] Авторизация (регистрация + вход) работает
- [ ] Админ может добавлять/удалять оборудование
- [ ] Сотрудник видит оборудование и может отметить использование
- [ ] README.md заполнен
- [ ] GitHub репозиторий создан и публичен
- [ ] Все URLs в README актуальны
- [ ] HTTPS сертификаты настроены (на продакшене)

---

**Автор:** Inventory System  
**Дата:** 2024  
**Версия:** 1.0
