# Spring Boot 应用容器化

## 一、准备工作

假设你有一个标准的 Spring Boot 项目，使用 Maven 构建，打包为 fat JAR。

## 二、编写 Dockerfile

### 基础版
dockerfile

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/app.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

### 带多阶段构建
dockerfile

FROM maven:3.8-openjdk-17 AS build

WORKDIR /workspace

COPY pom.xml .

RUN mvn dependency:go-offline

COPY src ./src

RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim

RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \

CMD curl -f http://localhost:8080/actuator/health|| exit 1

USER appuser

ENTRYPOINT ["java", "-jar", "app.jar"]

### 带 JVM 参数和环境变量
dockerfile

FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/app.jar app.jar

ENV SPRING_PROFILES_ACTIVE=prod

ENV JAVA_OPTS="-Xms256m -Xmx512m"

EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

## 三、构建镜像
bash

在项目根目录执行
docker build -t my-app:latest .

指定 Dockerfile 路径
docker build -f docker/Dockerfile -t my-app:latest .

带构建参数
docker build --build-arg JAR_FILE=target/app.jar -t my-app:latest .

## 四、运行容器
bash

基本运行
docker run -d --name my-app -p 8080:8080 my-app:latest

带环境变量
docker run -d --name my-app -p 8080:8080 \

-e SPRING_PROFILES_ACTIVE=prod \

-e DB_URL=jdbc:mysql://host.docker.internal:3306/db\

my-app:latest

挂载配置文件
docker run -d --name my-app -p 8080:8080 \

-v /path/to/config:/app/config \

my-app:latest

限制资源
docker run -d --name my-app -p 8080:8080 \

--memory=512m --cpus=1 \

my-app:latest

## 五、使用 Docker Compose 编排
yaml

version: '3.8'

services:

app:

build: .

ports:

"8080:8080"

environment:

SPRING_PROFILES_ACTIVE=prod

DB_URL=jdbc:mysql://db:3306/shop

depends_on:

db

restart: unless-stopped

db:

image: mysql:8.0

environment:

MYSQL_ROOT_PASSWORD=root

MYSQL_DATABASE=shop

volumes:

mysql-data:/var/lib/mysql

ports:

"3306:3306"

volumes:

mysql-data:

## 六、优化 Spring Boot 镜像的技巧

1. **分离依赖层**：利用 Spring Boot 2.3+ 的分层 JAR 功能，将依赖和业务代码分开，利用 Docker 缓存。
   dockerfile

COPY --from=build /workspace/target/app.jar app.jar

RUN java -Djarmode=layertools -jar app.jar extract

COPY --from=build /workspace/target/dependencies/ ./

COPY --from=build /workspace/target/spring-boot-loader/ ./

COPY --from=build /workspace/target/snapshot-dependencies/ ./

COPY --from=build /workspace/target/application/ ./

2. **使用 `spring-boot-maven-plugin` 配置分层**：
   xml

<plugin>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-maven-plugin</artifactId>

<configuration>

<layers>

<enabled>true</enabled>

</layers>

</configuration>

</plugin>

3. **健康检查端点**：确保引入了 `spring-boot-starter-actuator`，并使用 `/actuator/health` 作为健康检查路径。

---

## 小结

- Spring Boot 应用容器化非常简单，核心是 `FROM openjdk + COPY jar + ENTRYPOINT`。
- 多阶段构建和分层 JAR 可以优化构建速度和镜像大小。
- 使用 Docker Compose 编排 Spring Boot + MySQL 等依赖服务。
- 注意资源限制、环境变量和健康检查。