# Compose 中的环境变量与扩展

## 一、环境变量的几种传递方式

### 1. 直接在 `environment` 中写死
yaml

services:

app:

image: my-app

environment:

SPRING_PROFILES_ACTIVE: prod

DB_URL: jdbc:mysql://db:3306/mydb

DB_USER: root

DB_PASSWORD: secret

### 2. 引用宿主环境变量
yaml

services:

app:

image: my-app

environment:

SPRING_PROFILES_ACTIVE=${SPRING_PROFILE:-dev}   # 默认值 dev

DB_PASSWORD=${DB_PASSWORD}

启动时：
bash

export DB_PASSWORD=realsecret

docker compose up

### 3. 使用 `.env` 文件
在 `docker-compose.yml` 同级目录创建 `.env` 文件：
env

SPRING_PROFILE=prod

DB_PASSWORD=supersecret

然后在 `docker-compose.yml` 中直接使用变量名：
yaml

environment:

SPRING_PROFILES_ACTIVE=${SPRING_PROFILE}

DB_PASSWORD=${DB_PASSWORD}

### 4. 使用 `env_file`
yaml

services:

app:

image: my-app

env_file:

./app.env

`app.env` 文件内容：
env

SPRING_PROFILES_ACTIVE=prod

DB_URL=jdbc:mysql://db:3306/mydb

---

## 二、变量替换与默认值

| 语法 | 说明 | 示例 |
|------|------|------|
| `${VAR}` | 直接引用，未定义时报错 | `image: ${IMAGE_NAME}` |
| `${VAR:-default}` | 未定义时使用默认值 | `image: ${IMAGE_NAME:-nginx}` |
| `${VAR:?error}` | 未定义时输出错误信息 | `image: ${IMAGE_NAME:?IMAGE_NAME is required}` |

---

## 三、使用扩展字段（YAML Anchors）

避免重复配置：
yaml

x-logging: &default-logging

driver: json-file

options:

max-size: "10m"

max-file: "3"

services:

app:

image: my-app

logging: *default-logging

db:

image: mysql

logging: *default-logging

---

## 四、使用 `extends`（已弃用，不推荐）

Compose V2 不再推荐 `extends`，建议使用 YAML anchors 或 include。

---

## 五、多环境配置（Profile）

通过 `--profile` 参数启动特定服务：
yaml

services:

app:

image: my-app

profiles:

production

staging

debug-tools:

image: busybox

profiles:

debug

启动：
bash

只启动 app（production/staging 都匹配）
docker compose --profile production up

启动 app + debug-tools
docker compose --profile debug up

---

## 六、使用 `include`（Compose V2.20+）
yaml

include:

path: ./base/compose.yaml

path: ./monitoring/prometheus.yaml

services:

app:

image: my-app

depends_on:

prometheus   # 从 include 的服务中引用

---

## 七、综合示例：Spring Boot + MySQL + Redis 带环境变量
yaml

version: '3.8'

services:

redis:

image: redis:7-alpine

restart: unless-stopped

mysql:

image: mysql:8.0

env_file: ./mysql.env

volumes:

mysql-data:/var/lib/mysql

restart: unless-stopped

app:

build: .

ports:

"${APP_PORT:-8080}:8080"

environment:

SPRING_PROFILES_ACTIVE: ${SPRING_PROFILE:-dev}

DB_HOST: mysql

DB_PORT: 3306

DB_NAME: ${DB_NAME:-mydb}

DB_USER: ${DB_USER:-root}

DB_PASSWORD: ${DB_PASSWORD}

REDIS_HOST: redis

depends_on:

mysql

redis

restart: unless-stopped

volumes:

mysql-data:

对应的 `.env` 文件：
env

SPRING_PROFILE=prod

APP_PORT=8080

DB_NAME=shop

DB_USER=root

DB_PASSWORD=verysecret

---

## 小结

- 环境变量可通过 `environment`、`env_file`、`.env` 文件、宿主变量四种方式传递。
- 使用 `${VAR:-default}` 设置默认值，避免未定义报错。
- YAML anchors 可以复用配置段，减少重复。
- `profiles` 和 `include` 支持更复杂的多环境和多文件编排。
