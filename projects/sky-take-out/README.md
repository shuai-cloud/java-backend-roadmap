# Sky Takeout 🛵

> A full-featured food ordering platform for restaurants, built with Spring Boot + MyBatis + Redis + WebSocket.  
> 苍穹外卖：专为餐饮企业定制的外卖管理系统，包含管理后台与微信小程序端。

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7-green)](https://spring.io/projects/spring-boot)
[![MyBatis](https://img.shields.io/badge/MyBatis-3.5-blue)](https://mybatis.org/mybatis-3/)
[![Redis](https://img.shields.io/badge/Redis-7-red)](https://redis.io/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](LICENSE)

---

## 📖 Overview · 项目简介

Sky Takeout is a cloud-based restaurant management system designed for catering enterprises. It consists of two parts:

- **Admin Dashboard** – Used by restaurant staff to manage employees, categories, dishes, set meals, orders, and view business statistics.
- **Mini Program (WeChat)** – Used by customers to browse menus, add items to cart, place orders, make payments, and track deliveries.

This project demonstrates industry-standard practices in **microservice architecture, caching strategies, real-time communication, scheduled tasks, third-party integrations**, and more.

---

## 🎯 Features · 功能模块

### Admin Side · 管理端

| Module | Description |
|--------|-------------|
| Employee Management | CRUD, enable/disable accounts |
| Category Management | Add/edit/delete categories (dishes & set meals) |
| Dish Management | Add/edit/delete dishes with flavors, enable/disable sales |
| Set Meal Management | Combine dishes into set meals, batch operations |
| Order Management | View/search orders, confirm, reject, deliver, complete |
| Data Statistics | Turnover, user growth, order trends, top-selling items |
| Workspace | Daily overview: orders, revenue, users |
| Export Reports | Download Excel reports of business data (POI) |

### User Side · 用户端 (WeChat Mini Program)

| Module | Description |
|--------|-------------|
| WeChat Login | Auto-login via WeChat authorization |
| Menu Browsing | Browse categories, dishes, and set meals |
| Shopping Cart | Add/remove items, clear cart |
| Place Order | Submit orders with address validation |
| Payment | WeChat Pay integration |
| Order History | View past orders, re-order, cancel |
| Address Management | CRUD delivery addresses |
| Reminder | Send reminder to restaurant (WebSocket) |

---

## 🛠️ Tech Stack · 技术栈

### Backend · 后端

| Technology | Purpose |
|------------|---------|
| **Spring Boot 2.7** | Rapid application framework |
| **MyBatis** | ORM for MySQL |
| **MySQL** | Relational database |
| **Redis** | Caching (dishes, set meals, shop status) |
| **Spring Cache** | Declarative caching |
| **Spring Task** | Scheduled tasks (auto-cancel unpaid orders) |
| **WebSocket** | Real-time order alerts & reminders |
| **HttpClient** | Third-party API calls (WeChat, Baidu Maps) |
| **POI** | Excel report generation |
| **Swagger / Knife4j** | API documentation & testing |
| **JWT** | Token-based authentication |
| **Aliyun OSS** | Image storage |
| **Baidu Maps API** | Delivery range validation |

### Frontend · 前端

| Technology | Purpose |
|------------|---------|
| **Vue 3 + Element Plus** | Admin dashboard UI |
| **WeChat Mini Program** | Customer-facing app |
| **Apache ECharts** | Charts & data visualization |
| **Nginx** | Static resource serving, reverse proxy, load balancing |

### Tools · 工具

| Tool | Purpose |
|------|---------|
| **Maven** | Build & dependency management |
| **Git** | Version control |
| **Apifox / Postman** | API testing |
| **YApi** | API documentation management |

---

## ✨ Highlights · 项目亮点

1. **Redis Caching** – Reduced database load by caching hot dish/setmeal data with Spring Cache. Cache invalidation handled on updates.
2. **AOP for Auto Fill** – Used custom annotation `@AutoFill` + Aspect to automatically populate `createTime`, `updateTime`, `createUser`, `updateUser` fields.
3. **Real-time Notifications** – WebSocket pushes order alerts and customer reminders to the admin dashboard.
4. **Scheduled Tasks** – Spring Task cancels unpaid orders after 15 minutes and auto-completes “delivering” orders at midnight.
5. **Third-party Integrations** – WeChat login & payment, Aliyun OSS for image upload, Baidu Maps for delivery distance calculation.
6. **Complex Business Logic** – Shopping cart management, order submission with transaction control (`@Transactional`), refund processing.
7. **Data Export** – POI generates Excel reports with formatted tables and charts.
8. **Scalable Architecture** – Multi-module Maven project (`sky-common`, `sky-pojo`, `sky-server`) following separation of concerns.

---

## 🚀 Quick Start · 快速开始

### Prerequisites

- JDK 17+
- Maven 3.8+
- MySQL 8.0+
- Redis 7+
- Node.js 16+ (for frontend)
- WeChat Developer Tools (for mini program)

### Step 1: Clone & Import

bash

git clone https://github.com/your-username/sky-take-out.git

cd sky-take-out

Open the project in IntelliJ IDEA as a Maven project.

### Step 2: Database Setup

Execute `sky.sql` (located in `docs/`) to create all tables and initial data.

bash

mysql -u root -p < docs/sky.sql

### Step 3: Configure `application.yml`

Edit `sky-server/src/main/resources/application.yml`:

yaml

spring:

datasource:

url: jdbc:mysql://localhost:3306/sky_take_out?useSSL=false&serverTimezone=Asia/Shanghai

username: root

password: your_password

redis:

host: localhost

port: 6379

sky:

jwt:

admin-secret-key: your_admin_secret

user-secret-key: your_user_secret

aliyun:

oss:

endpoint: oss-cn-beijing.aliyuncs.com

access-key-id: your_oss_key

access-key-secret: your_oss_secret

bucket-name: your_bucket

wechat:

appid: your_appid

secret: your_secret

mchid: your_mchid

baidu:

ak: your_baidu_map_ak

### Step 4: Run Backend

bash

cd sky-server

mvn spring-boot:run

The admin API will be available at `http://localhost:8080/doc.html` (Swagger UI).

### Step 5: Run Frontend (Admin Dashboard)

bash

cd frontend/admin

npm install

npm run dev

### Step 6: Run Mini Program

Open `frontend/miniprogram` in WeChat Developer Tools, fill in your AppID, and run.

---

## 📁 Project Structure · 项目结构

sky-take-out/

├── sky-common/                  # Shared constants, exceptions, utils

├── sky-pojo/                    # Entity, DTO, VO

├── sky-server/                  # Main application module

│   ├── src/main/java/com/sky/

│   │   ├── config/              # Config classes

│   │   ├── controller/          # REST controllers

│   │   │   ├── admin/           # Admin endpoints

│   │   │   └── user/            # User endpoints

│   │   ├── service/             # Business logic

│   │   │   └── impl/            # Service implementations

│   │   ├── mapper/              # MyBatis mappers

│   │   ├── interceptor/         # JWT interceptors

│   │   ├── aspect/              # AOP aspects

│   │   ├── annotation/          # Custom annotations

│   │   └── task/                # Scheduled tasks

│   └── src/main/resources/

│       ├── mapper/              # XML mappers

│       ├── template/            # Excel templates

│       └── application.yml

├── docs/                        # Documentation & SQL scripts

├── frontend/                    # Frontend projects

│   ├── admin/                   # Vue3 admin dashboard

│   └── miniprogram/             # WeChat mini program

└── README.md

---

## 📜 License

This project is for learning and demonstration purposes only. Feel free to use it as a reference for your own projects.

---

*Built with ❤️ for better food ordering experience.*