# Spring Integration 🌱🔍

> Spring Boot integration with Elasticsearch for backend engineers (3–5 years experience).  
> Spring Boot 集成 Elasticsearch 核心知识，面试高频考点。

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-2.7%2B-green)](https://spring.io/projects/spring-boot)
[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers integrating Elasticsearch with Spring Boot using Spring Data Elasticsearch. You'll learn how to configure the client, define repositories, use ElasticsearchTemplate, perform complex queries, and handle pagination. This is the most common way Java backend engineers interact with ES in enterprise applications.

本章介绍如何使用 Spring Data Elasticsearch 将 Elasticsearch 集成到 Spring Boot 应用中。你将学习如何配置客户端、定义 Repository、使用 ElasticsearchTemplate、执行复杂查询和处理分页。这是 Java 后端工程师在企业应用中与 ES 交互的最常见方式。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Project Setup · 项目配置
xml

<parent>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-parent</artifactId>

<version>2.7.18</version>

</parent>

<dependencies>

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-data-elasticsearch</artifactId>

</dependency>

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-web</artifactId>

</dependency>

</dependencies>

yaml

application.yml
spring:

elasticsearch:

uris: http://localhost:9200

connection-timeout: 5s

socket-timeout: 60s

# 如果使用安全认证

# username: elastic

# password: changeme

---

### 2️⃣ Entity Definition · 实体定义
java

import org.springframework.data.annotation.Id;

import org.springframework.data.elasticsearch.annotations.Document;

import org.springframework.data.elasticsearch.annotations.Field;

import org.springframework.data.elasticsearch.annotations.FieldType;

import org.springframework.data.elasticsearch.annotations.Setting;

import java.time.LocalDateTime;

import java.util.List;

@Document(indexName = "products")           // 索引名称

@Setting(shards = 3, replicas = 1)          // 分片和副本设置

public class Product {

@Id
private String id;

@Field(type = FieldType.Text, analyzer = "ik_max_word")  // 中文分词
private String name;

@Field(type = FieldType.Text, analyzer = "standard")
private String description;

@Field(type = FieldType.Double)
private Double price;

@Field(type = FieldType.Keyword)        // 不分词，用于精确匹配和聚合
private String category;

@Field(type = FieldType.Keyword)
private List<String> tags;

@Field(type = FieldType.Integer)
private Integer stock;

@Field(type = FieldType.Date, format = {}, pattern = "yyyy-MM-dd HH:mm:ss")
private LocalDateTime createdAt;

@Field(type = FieldType.Date)
private LocalDateTime updatedAt;

// getters and setters
}

**注意事项**：
- `@Document` 注解标识这是一个 ES 文档实体。
- `@Field` 用于自定义字段映射，如果不指定则使用 Spring Data 的自动推断。
- 使用 `@Setting` 可以在创建索引时指定分片数等设置。

---

### 3️⃣ Repository · 数据访问层
java

import org.springframework.data.elasticsearch.repository.ElasticsearchRepository;

import org.springframework.stereotype.Repository;

import java.util.List;

@Repository

public interface ProductRepository extends ElasticsearchRepository<Product, String> {

// 派生查询：根据名称精确匹配（keyword 字段）
List<Product> findByName(String name);

// 派生查询：价格区间
List<Product> findByPriceBetween(Double min, Double max);

// 派生查询：类别和库存大于
List<Product> findByCategoryAndStockGreaterThan(String category, Integer stock);

// 派生查询：名称包含（text 字段会自动使用 match 查询）
List<Product> findByNameContaining(String keyword);

// 分页查询
org.springframework.data.domain.Page<Product> findByCategory(
String category, org.springframework.data.domain.Pageable pageable);

// 自定义查询（使用 JSON 查询字符串）
@Query("{\"match\": {\"tags\": \"?0\"}}")
List<Product> findByTag(String tag);

// 自定义查询（bool 查询）
@Query("{\"bool\": {\"must\": [{\"match\": {\"name\": \"?0\"}}, {\"term\": {\"category\": \"?1\"}}]}}")
List<Product> findByNameAndCategory(String name, String category);
}

**派生查询关键词**：

| Keyword | Example | Generated Query |
|---------|---------|-----------------|
| `And` | `findByNameAndPrice` | bool must [term name, term price] |
| `Or` | `findByNameOrCategory` | bool should [term name, term category] |
| `Between` | `findByPriceBetween` | range query |
| `LessThan` | `findByStockLessThan` | range lt |
| `GreaterThan` | `findByPriceGreaterThan` | range gt |
| `Like` / `Containing` | `findByNameContaining` | match query |
| `StartingWith` | `findByNameStartingWith` | prefix query |
| `OrderBy` | `findByCategoryOrderByPriceDesc` | sort |

---

### 4️⃣ Service Layer · 服务层
java

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.domain.Page;

import org.springframework.data.domain.PageRequest;

import org.springframework.data.domain.Sort;

import org.springframework.stereotype.Service;

import java.util.List;

import java.util.Optional;

@Service

public class ProductService {

@Autowired
private ProductRepository repository;

public Product save(Product product) {
return repository.save(product);
}

public Optional<Product> findById(String id) {
return repository.findById(id);
}

public List<Product> searchByName(String name) {
return repository.findByNameContaining(name);
}

public Page<Product> searchByCategory(String category, int page, int size) {
PageRequest pageRequest = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "price"));
return repository.findByCategory(category, pageRequest);
}

public void deleteById(String id) {
repository.deleteById(id);
}

public List<Product> bulkSave(List<Product> products) {
return (List<Product>) repository.saveAll(products);
}
}

---

### 5️⃣ ElasticsearchRestTemplate · 高级操作

For complex queries that cannot be expressed via derived methods or `@Query`, use `ElasticsearchRestTemplate`.
java

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.elasticsearch.core.ElasticsearchRestTemplate;

import org.springframework.data.elasticsearch.core.SearchHits;

import org.springframework.data.elasticsearch.core.query.NativeSearchQuery;

import org.springframework.data.elasticsearch.core.query.NativeSearchQueryBuilder;

import org.springframework.stereotype.Service;

import static org.elasticsearch.index.query.QueryBuilders.*;

import static org.elasticsearch.search.aggregations.AggregationBuilders.*;

@Service

public class AdvancedSearchService {

@Autowired
private ElasticsearchRestTemplate template;

public SearchHits<Product> boolSearch(String name, Double minPrice, Double maxPrice, List<String> tags) {
NativeSearchQuery query = new NativeSearchQueryBuilder()
.withQuery(boolQuery()
.must(matchQuery("name", name))
.filter(rangeQuery("price").gte(minPrice).lte(maxPrice))
.filter(termsQuery("tags", tags))
)
.withPageable(PageRequest.of(0, 10))
.withSort(Sort.by(Sort.Direction.DESC, "price"))
.build();

    return template.search(query, Product.class);
}

public SearchHits<Product> fuzzySearch(String name) {
NativeSearchQuery query = new NativeSearchQueryBuilder()
.withQuery(fuzzyQuery("name", name).fuzziness(Fuzziness.AUTO))
.build();
return template.search(query, Product.class);
}

public SearchHits<Product> highlightSearch(String keyword) {
NativeSearchQuery query = new NativeSearchQueryBuilder()
.withQuery(matchQuery("name", keyword))
.withHighlightBuilder(new HighlightBuilder()
.field("name")
.preTags("<em>")
.postTags("</em>"))
.build();
return template.search(query, Product.class);
}
}

---

### 6️⃣ Controller · 控制器
java

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.domain.Page;

import org.springframework.http.ResponseEntity;

import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController

@RequestMapping("/api/products")

public class ProductController {

@Autowired
private ProductService productService;

@PostMapping
public ResponseEntity<Product> create(@RequestBody Product product) {
return ResponseEntity.ok(productService.save(product));
}

@GetMapping("/{id}")
public ResponseEntity<Product> getById(@PathVariable String id) {
return productService.findById(id)
.map(ResponseEntity::ok)
.orElse(ResponseEntity.notFound().build());
}

@GetMapping("/search")
public ResponseEntity<List<Product>> search(@RequestParam String q) {
return ResponseEntity.ok(productService.searchByName(q));
}

@GetMapping("/category/{category}")
public ResponseEntity<Page<Product>> searchByCategory(
@PathVariable String category,
@RequestParam(defaultValue = "0") int page,
@RequestParam(defaultValue = "10") int size) {
return ResponseEntity.ok(productService.searchByCategory(category, page, size));
}

@DeleteMapping("/{id}")
public ResponseEntity<Void> delete(@PathVariable String id) {
productService.deleteById(id);
return ResponseEntity.noContent().build();
}
}

---

### 7️⃣ Index Management · 索引管理
java

import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.data.elasticsearch.core.ElasticsearchRestTemplate;

import org.springframework.data.elasticsearch.core.IndexOperations;

import org.springframework.stereotype.Service;

@Service

public class IndexManagementService {

@Autowired
private ElasticsearchRestTemplate template;

public boolean createIndex() {
IndexOperations ops = template.indexOps(Product.class);
if (!ops.exists()) {
ops.create();          // 创建索引（使用 @Setting 和 @Mapping）
ops.putMapping();      // 写入映射
return true;
}
return false;
}

public boolean deleteIndex() {
return template.indexOps(Product.class).delete();
}

public boolean refreshIndex() {
template.indexOps(Product.class).refresh();
return true;
}
}

---

### 8️⃣ Configuration · 高级配置
java

import org.springframework.context.annotation.Configuration;

import org.springframework.data.elasticsearch.client.ClientConfiguration;

import org.springframework.data.elasticsearch.client.elc.ElasticsearchConfiguration;

@Configuration

public class ElasticsearchConfig extends ElasticsearchConfiguration {

@Override
public ClientConfiguration clientConfiguration() {
return ClientConfiguration.builder()
.connectedTo("localhost:9200", "node2:9200")
.withConnectTimeout(Duration.ofSeconds(5))
.withSocketTimeout(Duration.ofSeconds(60))
.withBasicAuth("elastic", "changeme")  // 安全认证
.build();
}
}

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `Product.java` | Entity definition |
| `ProductRepository.java` | Repository interface |
| `ProductService.java` | Service layer |
| `AdvancedSearchService.java` | ElasticsearchRestTemplate usage |
| `ProductController.java` | REST controller |
| `IndexManagementService.java` | Index lifecycle management |
| `ElasticsearchConfig.java` | Client configuration |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 基础
1. **Spring Data Elasticsearch 和原生 Java Client 的区别？**
    - **答**：Spring Data 提供了声明式 Repository，开发效率高，适合标准 CRUD 和简单查询；原生客户端功能更全面，适合复杂查询、聚合、批量操作。Spring Data 底层也使用原生客户端。

2. **`@Field` 注解中的 `FieldType.Text` 和 `FieldType.Keyword` 有什么区别？**
    - **答**：Text 会分词，用于全文搜索；Keyword 不分词，用于精确匹配、排序和聚合。通常在需要全文搜索的字段上用 Text，并添加一个 Keyword 子字段用于精确匹配。

### Repository
3. **派生查询方法的工作原理？**
    - **答**：Spring Data 解析方法名，根据关键词（如 And、Or、Between、Containing）自动生成 Elasticsearch 查询。例如 `findByNameAndPrice` 生成 bool 查询包含两个 term 条件。

4. **`@Query` 注解如何工作？**
    - **答**：`@Query` 允许直接编写 JSON 查询字符串，`?0`、`?1` 等占位符对应方法参数。适用于派生方法无法表达的复杂查询。

### Template
5. **ElasticsearchRestTemplate 和 Repository 的关系？**
    - **答**：Repository 底层使用 ElasticsearchRestTemplate 执行操作。Template 提供了更底层的 API，适合构建 NativeSearchQuery 实现复杂查询、聚合、高亮等功能。

### 性能
6. **如何优化 Spring Data Elasticsearch 的批量操作？**
    - **答**：使用 `saveAll()` 方法进行批量保存，底层会使用 bulk API。避免在循环中逐条 save()。批量大小建议 1000-5000 条。

### 索引
7. **如何在不重启应用的情况下更新索引映射？**
    - **答**：ES 不允许修改已有字段类型。需要创建新索引 → 使用 reindex API 迁移数据 → 删除旧索引 → 创建别名指向新索引。Spring Data 可以通过 `IndexOperations` 管理索引生命周期。

---

## 🇨🇳 中文说明

本目录覆盖了 Spring Boot 集成 Elasticsearch 的核心知识，包括项目配置、实体定义、Repository、服务层、ElasticsearchRestTemplate 高级查询、控制器和索引管理。每个主题都配有带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接运行。

---

*Spring + Elasticsearch = Enterprise search made easy.* 🌱🔍