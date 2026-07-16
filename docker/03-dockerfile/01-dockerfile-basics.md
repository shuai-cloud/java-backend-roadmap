# Dockerfile 基础指令

## 一、什么是 Dockerfile？

Dockerfile 是一个文本文件，包含一系列指令，用于自动化构建 Docker 镜像。每一条指令对应镜像的一层（Layer）。

## 二、常用指令速查

| 指令 | 作用 | 示例 |
|------|------|------|
| `FROM` | 指定基础镜像 | `FROM openjdk:17-jdk-slim` |
| `WORKDIR` | 设置工作目录 | `WORKDIR /app` |
| `COPY` | 复制文件到镜像 | `COPY target/app.jar app.jar` |
| `ADD` | 复制文件（支持自动解压、URL） | `ADD app.tar.gz /app/` |
| `RUN` | 执行命令（构建时） | `RUN apt-get update && apt-get install -y curl` |
| `CMD` | 容器启动时的默认命令（可被覆盖） | `CMD ["java", "-jar", "app.jar"]` |
| `ENTRYPOINT` | 容器启动时的入口命令（不可被覆盖） | `ENTRYPOINT ["java", "-jar", "app.jar"]` |
| `EXPOSE` | 声明容器监听的端口（文档作用） | `EXPOSE 8080` |
| `ENV` | 设置环境变量 | `ENV SPRING_PROFILES_ACTIVE=prod` |
| `ARG` | 构建时变量 | `ARG JAR_FILE=target/*.jar` |
| `VOLUME` | 声明匿名卷 | `VOLUME /tmp` |
| `LABEL` | 添加元数据 | `LABEL maintainer="me@example.com"` |
| `HEALTHCHECK` | 健康检查 | `HEALTHCHECK CMD curl -f http://localhost:8080/health` |
| `USER` | 指定运行用户 | `USER appuser` |

## 三、指令详解

### FROM

dockerfile

FROM openjdk:17-jdk-slim

- 必须是第一条非注释指令。
- 可以多次使用实现多阶段构建。

### WORKDIR

dockerfile

WORKDIR /app

- 设置工作目录，后续的 COPY、RUN、CMD 等指令都在此目录下执行。
- 如果目录不存在，会自动创建。

### COPY vs ADD

dockerfile

COPY target/app.jar app.jar

ADD app.tar.gz /app/

- `COPY`：单纯复制文件或目录。
- `ADD`：支持自动解压 tar 包，支持 URL 下载（不推荐，因为不缓存且不安全）。
- 建议：尽量用 `COPY`，只有需要自动解压时才用 `ADD`。

### RUN

dockerfile

RUN apt-get update && apt-get install -y curl

- 在构建镜像时执行命令，会创建新层。
- 建议合并多个命令，减少层数。

### CMD vs ENTRYPOINT

dockerfile

CMD ["java", "-jar", "app.jar"]

ENTRYPOINT ["java", "-jar", "app.jar"]

- `CMD`：提供默认命令，可以被 `docker run` 后面的参数覆盖。
- `ENTRYPOINT`：容器的主命令，不容易被覆盖（除非使用 `--entrypoint`）。
- 常用组合：`ENTRYPOINT` 固定可执行文件，`CMD` 提供默认参数。

### EXPOSE

dockerfile

EXPOSE 8080

- 仅作文档声明，不实际暴露端口。实际端口映射需要在 `docker run -p` 时指定。

### ENV vs ARG

dockerfile

ENV SPRING_PROFILES_ACTIVE=prod

ARG JAR_FILE=target/*.jar

- `ENV`：设置环境变量，在容器运行时生效。
- `ARG`：构建时变量，只在 `docker build` 过程中有效，不会留在镜像中。

## 四、一个简单的 Dockerfile 示例

dockerfile

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

构建：

bash

docker build -t my-app:latest .

---

## 小结

- 掌握 FROM、WORKDIR、COPY、RUN、CMD、ENTRYPOINT 等核心指令。
- 理解 CMD 和 ENTRYPOINT 的区别。
- 注意减少层数，合并 RUN 命令。