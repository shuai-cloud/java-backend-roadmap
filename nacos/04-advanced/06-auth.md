# Nacos 鉴权与安全

## 一、为什么需要鉴权？

- 防止未授权访问配置中心，泄露敏感信息（数据库密码、密钥等）。
- 防止恶意注册/注销服务，破坏服务发现。
- 多团队隔离，避免配置冲突。

---

## 二、开启鉴权

修改 `conf/application.properties`：
properties

开启鉴权
nacos.core.auth.enabled=true

密钥（自定义，至少 32 位）
nacos.core.auth.plugin.nacos.token.secret.key=VGhpc0lzTXlDdXN0b21TZWNyZXRLZXkxMjM0NTY=

服务端身份标识（用于集群间通信）
nacos.core.auth.server.identity.key=serverIdentity

nacos.core.auth.server.identity.value=security

重启 Nacos 后，访问控制台需要登录（默认用户名密码 `nacos/nacos`）。

---

## 三、使用 Token 访问 API
bash

登录获取 Token
curl -X POST "http://localhost:8848/nacos/v1/auth/login" \

-d "username=nacos&password=nacos"

返回 {"accessToken":"eyJhbGciOiJIUzI1NiJ9..."}
后续请求携带 Token
curl -X GET "http://localhost:8848/nacos/v1/ns/service/list" \

-H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9..."

### Spring Cloud 客户端配置
yaml

spring:

cloud:

nacos:

discovery:

username: nacos

password: nacos

config:

username: nacos

password: nacos

---

## 四、命名空间隔离

通过命名空间（Namespace）实现多环境或多团队隔离：
yaml

spring:

cloud:

nacos:

discovery:

namespace: dev    # 开发环境

config:

namespace: dev

每个命名空间有独立的服务和配置列表，互不干扰。

---

## 五、权限控制（RBAC）

Nacos 2.0+ 支持基于角色的权限控制：

- 用户管理：创建用户，分配角色。
- 角色管理：定义角色，关联权限。
- 权限管理：控制对命名空间、配置、服务的读写权限。

---

## 小结

- 生产环境必须开启鉴权，防止未授权访问。
- 使用 Token 或用户名密码访问 API。
- 通过命名空间实现环境隔离。
- RBAC 权限控制适合多团队协作。