# 服务注册与发现

## 一、服务注册

### 1. 通过 Open API 注册
bash

curl -X POST "http://localhost:8848/nacos/v1/ns/instance" \

-d "serviceName=nacos.test.service&ip=127.0.0.1&port=8080"

### 2. 通过 Spring Cloud 集成

#### 引入依赖
xml

<dependency>

<groupId>com.alibaba.cloud</groupId>

<artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>

</dependency>

#### 配置 application.yml
yaml

spring:

application:

name: order-service

cloud:

nacos:

discovery:

server-addr: localhost:8848

namespace: dev

group: DEFAULT_GROUP

#### 启动类
java

@SpringBootApplication

@EnableDiscoveryClient

public class OrderApplication {

public static void main(String[] args) {

SpringApplication.run(OrderApplication.class, args);

}

}

启动后，在 Nacos 控制台的「服务管理」中可以看到 `order-service` 已注册。

---

## 二、服务发现

### 1. 使用 RestTemplate + @LoadBalanced
java

@Configuration

public class BeanConfig {

@Bean

@LoadBalanced

public RestTemplate restTemplate() {

return new RestTemplate();

}

}

// 调用

@Autowired

private RestTemplate restTemplate;

public String callOrder() {

return restTemplate.getForObject("http://order-service/api/order/1", String.class);

}

### 2. 使用 FeignClient（推荐）
java

@FeignClient(name = "order-service")

public interface OrderClient {

@GetMapping("/api/order/{id}")

String getOrder(@PathVariable("id") Long id);

}

---

## 三、健康检查

- Nacos 客户端默认每 5 秒向服务端发送心跳。
- 如果 15 秒未收到心跳，实例标记为不健康。
- 如果 30 秒未收到心跳，实例被剔除。

---

## 四、服务管理

在 Nacos 控制台可以：
- 查看服务列表和实例详情。
- 手动上下线实例。
- 设置权重（权重越高，被分配的流量越多）。
- 设置保护阈值（当健康实例比例低于阈值时，返回所有实例包括不健康的）。

---

## 小结

- 服务注册通过 `@EnableDiscoveryClient` + 配置即可。
- 服务发现通过 Feign 或 RestTemplate + LoadBalancer。
- Nacos 控制台提供可视化的服务管理能力。
