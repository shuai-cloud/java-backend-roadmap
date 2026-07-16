# 配置管理（进阶）

## 一、配置的持久化

Nacos 将配置存储在数据库中（Derby/MySQL），表结构如下：

| 表名 | 说明 |
|------|------|
| `config_info` | 配置基本信息（Data ID、Group、内容、MD5） |
| `config_history` | 配置历史版本 |
| `config_tags_relation` | 配置与标签的关联 |
| `his_config_info` | 配置变更历史 |

### 配置 MD5 校验
- Nacos 为每个配置计算 MD5，客户端拉取时比对 MD5，如果相同则不更新。
- 配置变更时 MD5 变化，客户端通过长轮询或 gRPC 流实时感知。

---

## 二、配置的导入导出

Nacos 控制台支持批量导入/导出配置，便于环境迁移。

- 导出：选中配置 → 导出 → 生成 ZIP 文件。
- 导入：上传 ZIP 文件 → 选择覆盖策略（跳过/覆盖/终止）。

---

## 三、配置的灰度发布（Beta）

Nacos 支持配置的灰度发布，先让部分实例生效，验证无误后再全量发布。

### 操作步骤
1. 在 Nacos 控制台编辑配置，点击「发布 Beta」。
2. 输入 Beta 版本的 IP 列表（如 `192.168.1.100`）。
3. 只有指定 IP 的实例会收到新配置。
4. 验证通过后，点击「发布」全量生效。

---

## 四、监听配置变更

### 通过 Spring Cloud
java

@RefreshScope

@Component

public class DynamicConfig {

@Value("${timeout:5000}")

private int timeout;

@PostConstruct
public void init() {
System.out.println("当前超时时间：" + timeout);
}
}

### 通过 Nacos 原生 API
java

ConfigService configService = NacosFactory.createConfigService("localhost:8848");

configService.addListener("order-service-dev.yaml", "DEFAULT_GROUP", new Listener() {

@Override

public Executor getExecutor() {

return null; // 同步回调

}

@Override

public void receiveConfigInfo(String configInfo) {

System.out.println("配置变更：" + configInfo);

}

});

---

## 五、配置加密

Nacos 原生不提供配置加密，但可以通过以下方式实现：

1. **客户端解密**：配置中存储密文，应用启动时解密。
2. **插件扩展**：Nacos 支持 `ConfigFilter` 插件，可自定义加解密逻辑。
3. **外部密钥管理**：使用 KMS（如阿里云 KMS）管理密钥。

---

## 六、配置管理的注意事项

- **不要将密码等敏感信息明文存储在配置中心**，应使用环境变量或密钥管理服务。
- **配置变更应有审批流程**，避免误操作导致线上故障。
- **配置的命名规范**：`${appName}-${profile}.${format}`，如 `order-service-prod.yaml`。

---

## 小结

- Nacos 配置中心支持持久化、版本管理、导入导出、灰度发布。
- 通过 `@RefreshScope` 实现动态刷新。
- 敏感配置需加密存储。