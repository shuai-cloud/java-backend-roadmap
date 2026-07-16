# 多阶段构建

## 一、为什么需要多阶段构建？

- **减小镜像体积**：构建阶段需要编译工具、依赖包，运行阶段只需要产物。多阶段构建可以只保留最终产物。
- **安全性**：构建工具和源码不会留在最终镜像中。
- **加速 CI/CD**：构建阶段可以缓存，运行阶段镜像更小，推送和拉取更快。

## 二、基本语法
dockerfile

第一阶段：构建
FROM maven:3.8-openjdk-17 AS builder

WORKDIR /build

COPY pom.xml .

RUN mvn dependency:go-offline

COPY src ./src

RUN mvn package -DskipTests

第二阶段：运行
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=builder /build/target/app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

- `AS builder`：给第一阶段起别名。
- `COPY --from=builder`：从第一阶段复制文件。

## 三、多阶段构建示例：Spring Boot + Maven
dockerfile

Build stage
FROM maven:3.8-openjdk-17 AS build

WORKDIR /workspace

COPY pom.xml .

COPY src ./src

RUN mvn clean package -DskipTests

Run stage
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

构建：
bash

docker build -t my-spring-app:latest .

## 四、多阶段构建示例：前端 + 后端
dockerfile

前端构建
FROM node:18 AS frontend

WORKDIR /app

COPY frontend/package*.json ./

RUN npm ci

COPY frontend/ .

RUN npm run build

后端构建
FROM maven:3.8-openjdk-17 AS backend

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline

COPY src ./src

RUN mvn package -DskipTests

运行
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY --from=backend /app/target/*.jar app.jar

COPY --from=frontend /app/dist /static

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

## 五、优化技巧

- **利用构建缓存**：将变化不频繁的指令放在前面（如 `COPY pom.xml`），变化频繁的放在后面（如 `COPY src`）。
- **使用更小的基础镜像**：如 `alpine`、`slim` 版本。
- **只复制需要的文件**：避免复制整个目录。
- **使用 `.dockerignore`** 排除不需要的文件。

## 六、查看镜像大小对比
bash

不使用多阶段构建：可能 500MB+
docker images my-app:without-multi

使用多阶段构建：可能 200MB-
docker images my-app:with-multi

---

## 小结

- 多阶段构建是减小镜像体积的标准做法。
- 通过 `AS` 命名阶段，`COPY --from` 跨阶段复制。
- 结合缓存优化构建速度。
