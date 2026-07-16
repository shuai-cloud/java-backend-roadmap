# Nacos vs Eureka vs Consul vs Zookeeper

## 一、功能对比

| 特性 | Nacos | Eureka | Consul | Zookeeper |
|------|-------|--------|--------|-----------|
| **注册中心** | ✅ | ✅ | ✅ | ✅ |
| **配置中心** | ✅ | ❌ | ❌ | ❌ |
| **健康检查** | 心跳 + 主动探测 | 心跳 | 多种（TCP/HTTP/脚本） | 心跳（Session） |
| **CAP 模型** | AP/CP 可切换 | AP | CP | CP |
| **一致性协议** | Distro / Raft | 自研 | Raft | ZAB |
| **多数据中心** | 支持 | 不支持 | 支持 | 不支持 |
| **K8s 集成** | 支持 | 支持 | 支持 | 支持 |
| **管理界面** | 完善 | 简单 | 完善 | 无（需第三方） |
| **社区活跃度** | 高（国内） | 维护状态 | 中等 | 高（大数据生态） |

---

## 二、为什么 Nacos 更适合微服务？

### 1. 功能二合一
Eureka 只有注册中心，Consul 有注册 + KV Store（非配置中心），Zookeeper 只有注册。Nacos 同时提供注册中心和配置中心，减少组件数量。

### 2. AP 模式优先
微服务注册中心应该优先保证可用性（AP），Nacos 默认 AP 模式，Eureka 也是 AP，但 Consul 和 ZK 是 CP。CP 模式下，Leader 选举期间服务不可用，对微服务是致命打击。

### 3. 健康检查更灵活
Nacos 支持临时实例的心跳和持久化实例的主动探测，适应不同场景。

### 4. 运维更简单
Nacos 集群部署简单，依赖 MySQL（运维同学熟悉），而 Consul 依赖 Raft 集群，ZK 需要独立运维。

---

## 三、各组件的最佳使用场景

| 组件 | 最佳场景 |
|------|----------|
| **Nacos** | Spring Cloud Alibaba 微服务体系，需要注册+配置中心 |
| **Eureka** | Spring Cloud Netflix 老项目，已维护状态，不建议新项目 |
| **Consul** | 多数据中心、需要健康检查和服务网格（Envoy） |
| **Zookeeper** | Hadoop、Kafka、Dubbo 老版本，大数据生态 |

---

## 小结

- 国内微服务新项目首选 Nacos。
- 理解 CAP 模型和一致性协议有助于面试和选型。
- 没有最好的组件，只有最适合业务场景的选择。