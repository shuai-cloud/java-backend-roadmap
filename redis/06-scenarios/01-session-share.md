# Session 共享

在分布式系统中，用户的登录 Session 需要被多个应用实例共享。传统做法是将 Session 存储在 Redis 中，实现统一管理。

---

## 一、为什么需要 Session 共享？

- 用户登录后，后续请求可能被负载均衡到不同的服务器实例。
- 如果 Session 存储在本地内存，其他实例无法访问，导致用户需要重复登录。
- Redis 作为中央存储，所有实例都可以读写同一份 Session 数据。

---

## 二、实现方案

### 方案1：Spring Session + Redis（推荐）

Spring Session 提供了透明的 Session 共享方案，只需引入依赖并配置即可。

#### 1. 引入依赖

xml

<dependency>

<groupId>org.springframework.session</groupId>

<artifactId>spring-session-data-redis</artifactId>

</dependency>

#### 2. 配置

yaml

spring:

session:

store-type: redis

redis:

namespace: spring:session

flush-mode: on_save

redis:

host: localhost

port: 6379

#### 3. 使用

无需修改代码，原有的 `HttpSession` 用法不变：

java

@RestController

public class UserController {

@PostMapping("/login")

public String login(HttpSession session, @RequestParam String username) {

session.setAttribute("user", username);

return "logged in";

}

@GetMapping("/current")
public String current(HttpSession session) {
return (String) session.getAttribute("user");
}

}

Spring Session 会自动将 Session 数据存入 Redis，key 格式为 `spring:session:sessions:<session-id>`。

### 方案2：手动存储（不推荐）

java

@Autowired

private StringRedisTemplate redisTemplate;

public void saveSession(String token, User user) {

redisTemplate.opsForValue().set("session:" + token, JSON.toJSONString(user), 30, TimeUnit.MINUTES);

}

public User getSession(String token) {

String json = redisTemplate.opsForValue().get("session:" + token);

return JSON.parseObject(json, User.class);

}

这种方式需要手动管理 token 的生成和传递（通常放在 Cookie 或 Header 中）。

---

## 三、Session 过期与清理

- Spring Session 默认 30 分钟过期，可通过 `server.servlet.session.timeout` 配置。
- Redis 会自动删除过期 key，无需手动清理。
- 可以配置 `spring.session.redis.flush-mode=immediate` 让每次写入立即刷新（但性能较差）。

---

## 四、注意事项

1. **序列化**：Session 中的对象必须可序列化（实现 Serializable）。
2. **性能**：每次请求都读写 Redis，会增加延迟。可结合本地缓存优化（但需注意一致性）。
3. **安全**：Session ID 应使用 HTTPS 传输，防止被劫持。
4. **跨域**：如果前端域名不同，需要配置 Cookie 的 Domain 属性或使用 Token 方式。

---

## 五、在苍穹外卖中的应用

苍穹外卖的管理端和用户端都需要 Session 共享。管理端使用 JWT Token，用户端使用微信登录后的 Token。实际上苍穹外卖没有使用 Session，而是使用 JWT 实现无状态认证。但 Session 共享仍然是分布式系统中的经典场景。

---

## 小结

- Spring Session + Redis 是最简便的 Session 共享方案。
- 自动管理 Session 的生命周期，无需手动操作 Redis。
- 注意序列化和性能问题。