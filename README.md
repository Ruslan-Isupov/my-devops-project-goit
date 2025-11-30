# 💾 Universal RDS Terraform Module

Цей модуль дозволяє розгортати бази даних в AWS, підтримуючи два режими роботи:
1. **Standard RDS Instance** (для розробки та Free Tier).
2. **Amazon Aurora Cluster** (для продакшену та високої доступності).

Вибір режиму здійснюється одним прапорцем: `use_aurora`.

---

## 🚀 Приклад Використання (Usage)

### 1. Звичайна RDS
Використовується для економії коштів. Створює один інстанс.

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false  # <--- Головний перемикач (Вимкнено)

  # Параметри RDS
  engine                     = "postgres"
  engine_version             = "14.10"
  parameter_group_family_rds = "postgres14"
  instance_class             = "db.t3.micro"  # Free Tier
  allocated_storage          = 20

  # Мережа та Доступи
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnets
  subnet_public_ids   = module.vpc.public_subnets
  publicly_accessible = true
  
  username            = "postgres"
  password            = "admin123AWS23"

  # Вимикаємо зайве для економії
  multi_az                = false
  backup_retention_period = 0
}
```

### 2. Amazon Aurora Cluster (High Availability)
Створює кластер з автоматичною реплікацією.

```hcl
module "rds" {
  source = "./modules/rds"

  name       = "myapp-aurora"
  use_aurora = true   # <--- Головний перемикач (Увімкнено)

  # Параметри Aurora
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  
  aurora_replica_count          = 1  # 1 Writer + 1 Reader
  instance_class                = "db.t3.medium"

  # Мережа та Доступи (ті самі, що й для RDS)
  vpc_id              = module.vpc.vpc_id
  subnet_private_ids  = module.vpc.private_subnets
  # ...
}
```

---

## ⚙️ Опис Змінних (Variables)

| Змінна | Тип | Default | Опис |
| :--- | :--- | :--- | :--- |
| **`use_aurora`** | `bool` | `false` | **Головна логіка.** `true` створює Aurora Cluster, `false` створює звичайну RDS. |
| **`name`** | `string` | - | Унікальний ідентифікатор для ресурсів БД. |
| **`vpc_id`** | `string` | - | ID VPC, де створюється Security Group. |
| **`subnet_private_ids`** | `list` | - | Список ID приватних підмереж для розміщення БД. |
| **`username`** | `string` | - | Логін головного користувача. |
| **`password`** | `string` | - | Пароль (чутливі дані). |
| **`instance_class`** | `string` | `db.t3.medium` | Тип віртуальної машини (CPU/RAM). |
| **`publicly_accessible`**| `bool` | `false` | Чи дозволяти доступ з інтернету. |

### Змінні для Standard RDS (`use_aurora = false`)
| Змінна | Default | Опис |
| :--- | :--- | :--- |
| `engine` | `postgres` | Тип рушія (postgres, mysql). |
| `engine_version` | `14.7` | Версія рушія. |
| `allocated_storage` | `20` | Розмір диска (GB). |

### Змінні для Aurora (`use_aurora = true`)
| Змінна | Default | Опис |
| :--- | :--- | :--- |
| `engine_cluster` | `aurora-postgresql` | Тип рушія кластера. |
| `engine_version_cluster` | `15.3` | Версія Aurora. |
| `aurora_replica_count` | `1` | Кількість реплік для читання (Readers). |

---

## 🛠️ Як змінювати конфігурацію (How-to)

### 1. Як змінити тип БД (Aurora <-> RDS)?
Змініть змінну `use_aurora`:
* `true` -> Перехід на Aurora (Terraform знищить RDS і створить Кластер).
* `false` -> Перехід на RDS (Terraform знищить Кластер і створить Інстанс).

### 2. Як змінити версію (Engine)?
Для звичайної RDS змініть `engine_version` та `parameter_group_family_rds`.
*Приклад:* Оновлення з 14 на 16:
```hcl
engine_version             = "16.1"
parameter_group_family_rds = "postgres16"
```

### 3. Як змінити потужність (Instance Class)?
Змініть змінну `instance_class`.
* Для тестів (Free Tier): `db.t3.micro`
* Для навантаження: `db.r5.large`

---

## 📤 Outputs

Після застосування модуль повертає:

* **`endpoint`**: Адреса для підключення (автоматично вибирає Writer Endpoint для Aurora або Address для RDS).
* **`port`**: Порт бази даних.

