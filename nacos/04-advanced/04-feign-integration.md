# Feign：声明式 HTTP 客户端

Feign 是 Spring Cloud 中的声明式 HTTP 客户端，让你用接口和注解定义远程调用，无需手写 HTTP 请求代码。它整合了 Ribbon（负载均衡）和 Hystrix/Sentinel（熔断），与 Nacos 注册中心无缝集成。

---

## 一、Feign 是什么？

- 声明式：写一个 Java 接口，加上 `@FeignClient` 注解，Spring 自动生成实现。
- 集成负载均衡：默认整合 Ribbon（或 Spring Cloud LoadBalancer），通过服务名调用。
- 集成熔断：可配合 Sentinel 或 Hystrix 实现降级。

### 对比传统 RestTemplate
java

// RestTemplate 方式

@Autowired

private RestTemplate restTemplate;

public String getOrder(Long id) {

return restTemplate.getForObject("http://order-service/order/" + id, String.class);

}

// Feign 方式

@FeignClient(name = "order-service")

public interface OrderClient {

@GetMapping("/order/{id}")

String getOrder(@PathVariable("id") Long id);

}

---

## 二、与 Nacos 集成

### 1. 引入依赖
xml

<dependency>

<groupId>com.alibaba.cloud</groupId>

<artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>

</dependency>

<dependency>

<groupId>org.springframework.cloud</groupId>

<artifactId>spring-cloud-starter-openfeign</artifactId>

</dependency>

### 2. 配置 application.yml
yaml

spring:

application:

name: user-service

cloud:

nacos:

discovery:

server-addr: localhost:8848

### 3. 启动类开启 Feign
java

@SpringBootApplication

@EnableFeignClients

public class UserApplication {

public static void main(String[] args) {

SpringApplication.run(UserApplication.class, args);

}

}

### 4. 编写 Feign 接口
java

@FeignClient(name = "order-service", path = "/api/order")

public interface OrderClient {

@GetMapping("/{id}")

Order getOrder(@PathVariable("id") Long id);

@PostMapping("/create")
Long createOrder(@RequestBody OrderCreateDTO dto);
}

### 5. 调用
java

@RestController

public class UserController {

@Autowired

private OrderClient orderClient;

@GetMapping("/user/order/{id}")
public Order getOrder(@PathVariable Long id) {
return orderClient.getOrder(id);
}
}

---

## 三、核心配置

### 1. 超时设置
yaml

feign:

client:

config:

default:

connectTimeout: 5000

readTimeout: 5000

order-service:          # 针对特定服务

connectTimeout: 3000

readTimeout: 10000

### 2. 日志级别
yaml

logging:

level:

com.example.client.OrderClient: DEBUG

Feign 日志级别：NONE、BASIC、HEADERS、FULL。

### 3. 熔断降级（配合 Sentinel）
yaml

feign:

sentinel:

enabled: true

java

@FeignClient(name = "order-service", fallbackFactory = OrderFallbackFactory.class)

public interface OrderClient { ... }

@Component

public class OrderFallbackFactory implements FallbackFactory<OrderClient> {

@Override

public OrderClient create(Throwable cause) {

return id -> {

log.error("调用订单服务失败", cause);

return new Order(); // 返回默认空对象

};

}

}

### 4. 请求/响应压缩
yaml

feign:

compression:

request:

enabled: true

mime-types: text/xml,application/json

min-request-size: 2048

response:

enabled: true

---

## 四、Feign 原理简述

1. Spring 启动时扫描 `@FeignClient` 接口。
2. 为每个接口生成动态代理对象（JDK 动态代理）。
3. 代理内部通过 `MethodHandler` 处理每个方法调用。
4. `MethodHandler` 解析方法上的 Spring MVC 注解（`@GetMapping` 等），构建 HTTP 请求。
5. 使用 Ribbon/LoadBalancer 从 Nacos 获取服务实例列表，负载均衡选出一个实例。
6. 发送 HTTP 请求，解析响应，返回结果。

---

## 五、面试常见问题

### Q1：Feign 和 OpenFeign 有什么区别？
> Feign 是 Netflix 开源的，OpenFeign 是 Spring Cloud 在 Feign 基础上封装的，支持 Spring MVC 注解（`@RequestMapping` 等）。现在用的基本都是 OpenFeign。

### Q2：Feign 怎么实现负载均衡？
> Feign 默认整合 Spring Cloud LoadBalancer（旧版是 Ribbon），通过服务名从注册中心获取实例列表，然后用轮询/随机等策略选择一个实例发起请求。

### Q3：Feign 调用超时怎么处理？
> 配置 `feign.client.config.default.readTimeout` 和 `connectTimeout`。超时后会触发熔断（如果开启了 Sentinel/Hystrix），执行降级逻辑。

### Q4：Feign 和 Dubbo 有什么区别？
> Feign 是基于 HTTP 的 REST 调用，Dubbo 是基于 TCP 的 RPC 调用。Feign 更简单、跨语言，Dubbo 性能更高、支持更多治理特性。微服务架构中两者可以并存。

---

## 小结

- Feign 是 Spring Cloud 中声明式 HTTP 客户端，与 Nacos 配合实现服务间调用。
- 核心配置：超时、日志、熔断、压缩。
- 原理：动态代理 + 负载均衡 + HTTP 请求。
- 面试重点：Feign vs OpenFeign、负载均衡实现、超时熔断配置。