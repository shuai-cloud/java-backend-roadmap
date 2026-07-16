# Dockerfile 最佳实践

## 一、基础镜像选择

- **优先选择官方镜像**：如 `openjdk`、`nginx`、`node`。
- **选择精简版本**：`alpine`、`slim`、`buster-slim` 等。
- **固定版本标签**：避免使用 `latest`，使用具体版本如 `openjdk:17-jdk-slim`。
- **安全更新**：定期更新基础镜像，修复 CVE。

## 二、层优化

### 减少层数
dockerfile

不推荐：多条 RUN 命令
RUN apt-get update

RUN apt-get install -y curl vim

RUN rm -rf /var/lib/apt/lists/*

推荐：合并为一条
RUN apt-get update && apt-get install -y curl vim && rm -rf /var/lib/apt/lists/*

### 利用构建缓存
- 将变化不频繁的指令放在前面（如安装依赖）。
- 将变化频繁的指令放在后面（如复制源代码）。
  dockerfile

先复制 pom.xml（变化较少）
COPY pom.xml .

RUN mvn dependency:go-offline

再复制源代码（变化频繁）
COPY src ./src

RUN mvn package

## 三、安全最佳实践

- **不要以 root 用户运行**：创建专用用户。
  dockerfile

RUN groupadd -r appuser && useradd -r -g appuser appuser

USER appuser

- **不要存储敏感信息**：密码、密钥通过环境变量或挂载传入，不要写在 Dockerfile 中。
- **定期扫描镜像漏洞**：使用 Trivy、Snyk 等工具。
- **使用 `.dockerignore`**：排除敏感文件和目录（如 `.env`、`.git`）。

## 四、镜像体积优化

- 多阶段构建（见上一节）。
- 清理不必要的文件：
  dockerfile

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

- 使用 `--no-install-recommends` 避免安装额外包。
- 删除临时文件：`rm -rf /tmp/*`。

## 五、可维护性

- **添加 LABEL**：标注维护者、版本、描述。
  dockerfile

LABEL maintainer="team@example.com"

LABEL version="1.0.0"

LABEL description="Spring Boot application"

- **使用明确的 WORKDIR**：避免使用根目录。
- **EXPOSE 声明端口**：便于他人了解容器监听端口。
- **HEALTHCHECK**：定义健康检查，让 Docker 自动检测容器状态。

## 六、示例：一个遵循最佳实践的 Dockerfile
dockerfile

FROM openjdk:17-jdk-slim AS builder

WORKDIR /build

COPY pom.xml .

RUN mvn dependency:go-offline

COPY src ./src

RUN mvn package -DskipTests

FROM openjdk:17-jdk-slim

RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \

CMD curl -f http://localhost:8080/actuator/health|| exit 1

USER appuser

ENTRYPOINT ["java", "-jar", "app.jar"]

---

## 小结

- 选择合适的基础镜像，固定版本。
- 合并 RUN 命令，利用缓存。
- 非 root 运行，注意安全。
- 多阶段构建减小体积。
- 添加 LABEL 和 HEALTHCHECK 提高可维护性。