# Docker 学习笔记

> 本专题是 `java-backend-roadmap` 的独立组件，帮助你系统掌握 Docker 的核心概念、常用操作、编排部署以及面试高频问题。

---

## 🎯 学习目标

- ✅ 理解 Docker 的架构和核心概念（镜像、容器、仓库、守护进程）
- ✅ 掌握常用 Docker 命令（镜像管理、容器生命周期、网络、数据卷）
- ✅ 能够编写 Dockerfile 构建自定义镜像
- ✅ 熟练使用 Docker Compose 编排多容器应用
- ✅ 理解 Docker 网络和数据卷的原理与使用
- ✅ 能够将 Spring Boot 应用容器化并部署
- ✅ 应对面试中 90% 以上的 Docker 相关问题

---

## 📖 前置知识

- Linux 基本命令
- （可选）了解虚拟化概念

---

## 📂 目录说明

| 目录 | 内容 | 难度 |
|------|------|------|
| `01-basics/` | Docker 简介、安装、架构、核心概念、常用命令 | ⭐ 入门 |
| `02-images-containers/` | 镜像管理、容器生命周期、资源限制、日志 | ⭐⭐ 进阶 |
| `03-dockerfile/` | Dockerfile 指令、最佳实践、多阶段构建 | ⭐⭐ 进阶 |
| `04-compose/` | Docker Compose 编排、环境变量、网络、卷 | ⭐⭐ 进阶 |
| `05-network-storage/` | 网络模式、数据卷、Volume 与 Bind Mount | ⭐⭐ 进阶 |
| `06-interview/` | 常见面试题与真实案例分析 | ⭐⭐⭐ 冲刺 |

---

## 🚀 学习路线建议

### 第一阶段：基础入门（1~2 天）
1. 阅读 `01-basics/`，理解 Docker 架构和核心概念。
2. 安装 Docker Desktop 或 Docker Engine。
3. 运行 `hello-world` 和 `nginx` 容器，熟悉常用命令。

### 第二阶段：镜像与容器（2~3 天）
1. 学习镜像拉取、推送、导出导入。
2. 掌握容器创建、启动、停止、删除、日志查看。
3. 理解资源限制（CPU、内存）和环境变量。

### 第三阶段：Dockerfile（2~3 天）
1. 学习编写 Dockerfile，构建自定义镜像。
2. 实践多阶段构建优化镜像体积。
3. 将 Spring Boot 应用容器化。

### 第四阶段：Docker Compose（2~3 天）
1. 学习编写 docker-compose.yml 编排多容器应用。
2. 部署 Nacos + MySQL + 你的 Spring Boot 应用。
3. 理解网络和卷的配置。

### 第五阶段：面试准备（1~2 天）
1. 复习 `06-interview/` 中的常见问题。
2. 重点准备：Docker 与虚拟机区别、镜像分层、网络模式、数据持久化。

---

## 🔗 关联内容

- [Redis 专题](../redis/README.md) — 可容器化部署
- [Kafka 专题](../kafka/README.md) — 可容器化部署
- [Nacos 专题](../nacos/README.md) — 可容器化部署

---

## 📚 推荐资源

- [Docker 官方文档](https://docs.docker.com/)
- 《Docker 从入门到实践》（yeasy）
- 《深入浅出 Docker》（Nigel Poulton）

---

*Happy Containerizing! 🐳*