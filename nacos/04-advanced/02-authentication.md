# Nacos 鉴权与安全

## 一、开启鉴权

Nacos 默认不开启鉴权，任何人访问控制台即可管理配置和服务。生产环境必须开启。

### 修改 application.properties
properties

开启鉴权
nacos.core.auth.enabled=true

配置密钥（自定义，至少 32 位）
nacos.core.auth.plugin.nacos.token.secret.key=YourSecretKey012345678901234567890123456789

开启服务端身份识别（防止伪造请求）
nacos.core.auth.server.identity.key=serverIdentity

nacos.core.auth.server.identity.value=security

### 重启 Nacos 后，访问控制台需要登录。

---

## 二、用户管理

Nacos 内置用户表，可通过控制台或 API 管理用户。

### 默认用户
- 用户名：`nacos`
- 密码：`nacos`

### 创建新用户（API）
bash

curl -X POST 'http://localhost:8848/nacos/v1/auth/users?username=admin&password=admin123'

### 角色管理
Nacos 支持 RBAC 权限模型，可为用户分配角色，角色关联权限。

---

## 三、配置加密传输

Nacos 2.0+ 支持 gRPC 协议，默认使用 TLS 加密。配置方式：
properties

开启 TLS
nacos.remote.server.grpc.tls.enable=true

nacos.remote.server.grpc.tls.cert-chain-file=/path/to/cert.pem

nacos.remote.server.grpc.tls.key-file=/path/to/key.pem

---

## 四、安全最佳实践

1. **修改默认密码**：部署后立即修改 `nacos` 用户的密码。
2. **使用 HTTPS**：Nginx 反向代理时配置 SSL 证书。
3. **网络隔离**：Nacos 服务不应暴露公网，仅内网访问。
4. **最小权限原则**：为不同团队创建独立命名空间，分配不同权限。
5. **审计日志**：开启操作审计，记录配置变更和服务注册日志。

---

## 小结

- 生产环境必须开启鉴权和身份识别。
- 使用 RBAC 管理用户权限。
- 结合网络安全策略保障 Nacos 安全。
