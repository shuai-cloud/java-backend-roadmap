# Nacos 安装与启动

## 一、环境要求

- JDK 1.8+
- Maven（可选，源码编译）
- 64 位 OS（Linux / Mac / Windows）

---

## 二、下载与安装

### 1. 下载 Release 包

bash

wget https://github.com/alibaba/nacos/releases/download/2.3.2/nacos-server-2.3.2.tar.gz

tar -zxvf nacos-server-2.3.2.tar.gz

cd nacos/bin

### 2. 启动（单机模式）

bash

Linux/Mac

sh startup.sh -m standalone

Windows

startup.cmd -m standalone

访问 http://localhost:8848/nacos，默认用户名/密码：`nacos/nacos`。

### 3. Docker 启动（推荐学习用）

bash

docker run --name nacos -d -p 8848:8848 -p 9848:9848 \

-e MODE=standalone \

nacos/nacos-server:2.3.2

---

## 三、配置数据库（生产环境）

Nacos 默认使用内嵌 Derby 数据库，生产环境建议切换到 MySQL。

### 1. 创建数据库

sql

CREATE DATABASE nacos_config DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

### 2. 初始化表

执行 `conf/mysql-schema.sql`（Nacos 安装目录下）。

### 3. 修改配置文件

编辑 `conf/application.properties`：

properties

spring.datasource.platform=mysql

db.url.0=jdbc:mysql://localhost:3306/nacos_config?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true

db.user=root

db.password=yourpassword

### 4. 重启 Nacos

bash

sh startup.sh -m standalone

---

## 四、验证

bash

curl -X GET "http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=10
"

返回空列表表示启动成功。

---

## 小结

- 学习环境用 Docker 单机模式最方便。
- 生产环境必须配置 MySQL 集群，并部署 Nacos 集群（至少 3 节点）。
- 默认端口 8848（客户端）、9848（gRPC）。