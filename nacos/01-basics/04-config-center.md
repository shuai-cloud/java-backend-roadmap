# 配置中心

## 一、为什么需要配置中心？

- 传统配置写在 `application.yml` 中，修改配置需要重启应用。
- 微服务数量多，配置分散，难以统一管理。
- 配置中心实现配置集中存储、动态刷新、版本管理。

---

## 二、Nacos 配置中心的基本概念

| 概念 | 说明 | 示例 |
|------|------|------|
| **Data ID** | 配置的唯一标识 | `order-service-dev.yaml` |
| **Group** | 配置分组 | `DEFAULT_GROUP` |
| **Namespace** | 环境隔离 | `dev`、`test`、`prod` |
| **配置格式** | 支持 YAML、Properties、JSON、XML 等 | `.yaml` |

---

## 三、Spring Cloud 集成

### 1. 引入依赖

xml

<dependency>

<groupId>com.alibaba.cloud</groupId>

<artifactId>spring-cloud-starter-alibaba-nacos-config</artifactId>

</dependency>

### 2. 配置 bootstrap.yml

yaml

spring:

application:

name: order-service

cloud:

nacos:

config:

server-addr: localhost:8848

file-extension: yaml

namespace: dev

group: DEFAULT_GROUP

### 3. 在 Nacos 中创建配置

- Data ID：`order-service-dev.yaml`
- Group：`DEFAULT_GROUP`
- 配置内容：

yaml

server:

port: 8080

spring:

datasource:

url: jdbc:mysql://localhost:3306/order_db

username: root

password: 123456

### 4. 动态刷新

在需要动态刷新的类上加 `@RefreshScope`：

java

@RestController

@RefreshScope

public class ConfigController {

@Value("${server.port}")

private String port;

@GetMapping("/port")
public String getPort() {
return port;
}

}

修改 Nacos 中的配置后，应用无需重启即可生效。

---

## 四、配置的优先级

bootstrap.yml < Nacos 配置 < application.yml < 命令行参数

实际加载顺序：
1. `bootstrap.yml`（Nacos 地址等基础配置）
2. Nacos 中的远程配置
3. `application.yml`（本地配置）
4. 命令行参数（最高优先级）

---

## 五、多环境管理

### 方案1：通过 Namespace 隔离

- 创建 `dev`、`test`、`prod` 三个命名空间。
- 每个命名空间下有独立的配置。
- 应用通过 `spring.cloud.nacos.config.namespace` 指定。

### 方案2：通过 Data ID 的 profile 后缀

- `order-service-dev.yaml`（开发）
- `order-service-test.yaml`（测试）
- `order-service-prod.yaml`（生产）

yaml

spring:

profiles:

active: dev

---

## 六、配置的版本管理

- Nacos 控制台支持配置的历史版本管理，可回滚到任意历史版本。
- 每次修改都会生成一个新版本号。

---

## 小结

- Nacos 配置中心实现配置集中管理和动态刷新。
- 核心概念：Data ID、Group、Namespace。
- 通过 `@RefreshScope` 实现动态刷新。
- 多环境通过 Namespace 或 Profile 隔离。