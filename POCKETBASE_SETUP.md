# 🔧 Настройка PocketBase Collections

Эта инструкция показывает как создать Collections в PocketBase для работы приложения Inventory System.

---

## 📋 Шаг 1: Открой Admin Panel PocketBase

1. Запусти PocketBase:
   ```bash
   ./pocketbase serve
   ```

2. Открой в браузере: **http://localhost:8090/_/**

3. Используй учетные данные администратора которые ты ввел при первом запуске

---

## 👥 Шаг 2: Создай Collection "users"

### 2.1 Создай Collection

1. Нажми **"+ New Collection"**
2. Выбери **"Blank Collection"**
3. Назови: **`users`**
4. Нажми **"Create"**

### 2.2 Добавь поля

| Поле | Тип | Обязательно | Примечание |
|------|-----|-----------|-----------|
| email | Email | ✅ | Уникальный |
| password | Password | ✅ | |
| role | Select | ✅ | Значения: `admin`, `worker` |

**Как добавить поле:**
1. Нажми **"+ Add Field"**
2. Выбери тип
3. Введи название
4. Нажми **"Save"**

### 2.3 Настрой API правила

**На вкладке "API Rules":**

| Право | Админ | Гость |
|------|-------|-------|
| **List** | ✅ | ❌ |
| **View** | 👤 (свой профиль) | ❌ |
| **Create** | ❌ | ❌ |
| **Update** | 👤 (свой) | ❌ |
| **Delete** | ❌ | ❌ |

Для Custom Rules используй:
```
@collection.users.id = @request.auth.id
```

---

## 📦 Шаг 3: Создай Collection "equipment"

### 3.1 Создай Collection

1. Нажми **"+ New Collection"**
2. Назови: **`equipment`**
3. Нажми **"Create"**

### 3.2 Добавь поля

| Поле | Тип | Обязательно |
|------|-----|-----------|
| name | Text | ✅ |
| description | Text | ❌ |
| created_by | Relation | ✅ |

**Для поля "created_by":**
- Тип: Relation
- Связь: users
- Max records: 1

### 3.3 Настрой API правила

**На вкладке "API Rules":**

```
Create Rule:
@request.auth.role = "admin"

Read Rule:
@request.auth.verified = true

Update Rule:
@request.auth.role = "admin"

Delete Rule:
@request.auth.role = "admin"
```

---

## 📊 Шаг 4: Создай Collection "usage"

### 4.1 Создай Collection

1. Нажми **"+ New Collection"**
2. Назови: **`usage`**
3. Нажми **"Create"**

### 4.2 Добавь поля

| Поле | Тип | Обязательно |
|------|-----|-----------|
| equipment | Relation | ✅ |
| used_by | Relation | ✅ |
| used_at | DateTime | ✅ |

**Для поля "equipment":**
- Связь: equipment (Max records: 1)

**Для поля "used_by":**
- Связь: users (Max records: 1)

**Для поля "used_at":**
- Тип: DateTime
- Auto Update Now: ✅

### 4.3 Настрой API правила

**На вкладке "API Rules":**

```
Create Rule:
@request.auth.verified = true

Read Rule (Admin видит всё, Worker видит свои):
@request.auth.role = "admin" || @request.auth.id = used_by.id

List Rule:
@request.auth.role = "admin" || @request.auth.id = used_by.id

Delete Rule:
@request.auth.role = "admin"

Update Rule:
❌ (запретить)
```

---

## 🔐 Шаг 5: Настрой Authentication

1. Перейди в **Settings → Auth**
2. Убедись что включены:
   - ✅ **Email/Password**
   - ✅ **Users from Public Collections**
3. Сохрани

---

## ✅ Проверка

После настройки все Collections должны быть видны в Admin Panel:

```
📚 Collections
  ├─ users (👥 3 записи)
  ├─ equipment (📦 5 записей)
  └─ usage (📊 12 записей)
```

---

## 🧪 Тестирование

### Создай тестового админа

1. Открой Admin Panel: **http://localhost:8090/_/**
2. Перейди в Collection **"users"**
3. Нажми **"+ New Record"**
4. Заполни:
   - **email:** `admin@test.com`
   - **password:** `123456`
   - **role:** `admin`
5. Нажми **"Save"**

### Создай тестового сотрудника

1. Нажми **"+ New Record"**
2. Заполни:
   - **email:** `worker@test.com`
   - **password:** `123456`
   - **role:** `worker`
3. Нажми **"Save"**

### Создай тестовое оборудование

1. Перейди в Collection **"equipment"**
2. Нажми **"+ New Record"**
3. Заполни:
   - **name:** `Ноутбук Dell`
   - **description:** `Dell XPS 15, Windows 11`
   - **created_by:** (выбери админа)
4. Нажми **"Save"**

---

## 🚀 Готово!

Теперь ты можешь открыть `index.html` и:

1. Залогиниться как **admin@test.com / 123456**
2. Добавить оборудование
3. Выйти и залогиниться как **worker@test.com / 123456**
4. Видеть оборудование и отмечать использование

---

## 📝 Если что-то не работает

### Ошибка при Create User

**Причина:** Email уже существует

**Решение:** Используй другой email адрес

### API правила не работают

**Причина:** Неправильные правила

**Решение:**
1. Проверь синтаксис правил
2. Используй точные имена полей
3. Тестируй через Admin Panel

### Relation поля не работают

**Причина:** Неправильная связь

**Решение:**
1. Убедись что выбрал правильную Collection
2. Установи Max records = 1

---

## 🎯 Полный чек-лист

- [ ] Collection `users` создана с полями: email, password, role
- [ ] Collection `equipment` создана с полями: name, description, created_by
- [ ] Collection `usage` создана с полями: equipment, used_by, used_at
- [ ] API правила настроены для каждой Collection
- [ ] Тестовые пользователи созданы
- [ ] Тестовое оборудование создано
- [ ] Авторизация работает через приложение

---

**Готово! Переходи к запуску приложения в index.html** 🎉
