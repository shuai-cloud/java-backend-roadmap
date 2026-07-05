# Java Client ☕🔍

> Elasticsearch Java client for backend engineers (3–5 years experience).  
> Elasticsearch Java 客户端核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)
[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://openjdk.org/)

---

## 📖 Overview · 概览

This section covers the Elasticsearch Java client: connecting to a cluster, performing CRUD operations, building queries, handling bulk operations, and integrating with Spring Data Elasticsearch. The modern Java client (since ES 7.x) replaces the deprecated RestHighLevelClient. Each topic includes code examples with Chinese comments and common interview questions with answers.

本章涵盖 Elasticsearch Java 客户端：连接集群、执行 CRUD 操作、构建查询、处理批量操作以及与 Spring Data Elasticsearch 集成。现代 Java 客户端（ES 7.x 起）替代了已弃用的 RestHighLevelClient。每个主题都包含带中文注释的代码示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Client Setup · 客户端配置
xml

<dependency>

<groupId>co.elastic.clients</groupId>

<artifactId>elasticsearch-java</artifactId>

<version>7.17.18</version>

</dependency>

<dependency>

<groupId>com.fasterxml.jackson.core</groupId>

<artifactId>jackson-databind</artifactId>

<version>2.15.2</version>

</dependency>

java

// 创建客户端（使用 Jackson 序列化）

ElasticsearchClient client = new ElasticsearchClient(

new RestClientTransport(

RestClient.builder(HttpHost.create("http://localhost:9200")).build(),

new JacksonJsonpMapper()

)

);

// 使用连接池和超时设置

RestClient restClient = RestClient.builder(

HttpHost.create("http://node1:9200"),

HttpHost.create("http://node2:9200"),

HttpHost.create("http://node3:9200")

)

.setRequestConfigCallback(builder -> builder

.setConnectTimeout(5000)

.setSocketTimeout(60000))

.build();

ElasticsearchClient esClient = new ElasticsearchClient(

new RestClientTransport(restClient, new JacksonJsonpMapper())

);

**注意事项**：
- 不要为每个请求创建新的客户端，应该使用单例。
- 生产环境建议连接多个节点以实现故障转移。

---

### 2️⃣ Index Operations · 索引操作
java

// 创建索引

CreateIndexResponse createResponse = esClient.indices().create(

req -> req.index("products")

.settings(s -> s.numberOfShards("3").numberOfReplicas("1"))

.mappings(m -> m.properties("name", p -> p.text(t -> t))

.properties("price", p -> p.double_(d -> d))

.properties("tags", p -> p.keyword(k -> k)))

);

// 检查索引是否存在

boolean exists = esClient.indices().exists(req -> req.index("products")).value();

// 删除索引

DeleteIndexResponse deleteResponse = esClient.indices().delete(req -> req.index("temp_index"));

// 获取索引映射

GetMappingResponse mapping = esClient.indices().getMapping(req -> req.index("products"));

---

### 3️⃣ Document CRUD · 文档增删改查
java

// 实体类

public class Product {

private String id;

private String name;

private double price;

private List<String> tags;

// getters, setters, constructors

}

// 索引文档（自动生成 ID）

IndexResponse response = esClient.index(req -> req

.index("products")

.document(new Product(null, "Laptop", 1200.0, List.of("electronics", "computers")))

);

String generatedId = response.id();

// 索引文档（指定 ID）

Product product = new Product("p001", "Phone", 800.0, List.of("electronics"));

IndexResponse response2 = esClient.index(req -> req

.index("products")

.id(product.getId())

.document(product)

);

// 根据 ID 获取文档

GetResponse<Product> getResponse = esClient.get(req -> req

.index("products")

.id("p001"),

Product.class

);

if (getResponse.found()) {

Product p = getResponse.source();

}

// 更新文档

UpdateResponse<Product> updateResponse = esClient.update(req -> req

.index("products")

.id("p001")

.doc(new Product("p001", "Phone Pro", 899.0, List.of("electronics"))),

Product.class

);

// 删除文档

DeleteResponse deleteResponse = esClient.delete(req -> req

.index("products")

.id("p001")

);

---

### 4️⃣ Searching · 搜索
java

// 简单搜索

SearchResponse<Product> searchResponse = esClient.search(req -> req

.index("products")

.query(q -> q.match(m -> m.field("name").query("laptop"))),

Product.class

);

List<Product> products = searchResponse.hits().hits().stream()

.map(hit -> hit.source())

.collect(Collectors.toList());

// Bool 查询

SearchResponse<Product> boolSearch = esClient.search(req -> req

.index("products")

.query(q -> q.bool(b -> b

.must(m -> m.match(t -> t.field("name").query("phone")))

.filter(f -> f.range(r -> r.field("price").gte(JsonData.of(500)).lte(JsonData.of(1500))))

.mustNot(mn -> mn.term(t -> t.field("tags").value("refurbished")))

)),

Product.class

);

// 高亮

SearchResponse<Product> highlightSearch = esClient.search(req -> req

.index("products")

.query(q -> q.match(m -> m.field("name").query("laptop")))

.highlight(h -> h.fields("name", f -> f.preTags("").postTags(""))),

Product.class

);

// 获取高亮片段

highlightSearch.hits().hits().forEach(hit -> {

List<String> highlights = hit.highlight().get("name");

System.out.println(highlights);

});

---

### 5️⃣ Bulk Operations · 批量操作
java

// 批量索引

BulkRequest.Builder bulkReq = new BulkRequest.Builder();

List<Product> products = fetchProducts(); // 假设有大量数据

for (Product p : products) {

bulkReq.operations(op -> op.index(idx -> idx

.index("products")

.id(p.getId())

.document(p)

));

}

BulkResponse bulkResponse = esClient.bulk(bulkReq.build());

if (bulkResponse.errors()) {

bulkResponse.items().forEach(item -> {

if (item.error() != null) {

System.err.println("Failed to index " + item.id() + ": " + item.error().reason());

}

});

}

// 批量更新

BulkRequest.Builder updateBulk = new BulkRequest.Builder();

updateBulk.operations(op -> op.update(u -> u

.index("products")

.id("p001")

.action(a -> a.doc(new Product("p001", "Updated Phone", 850.0, null)))

));

esClient.bulk(updateBulk.build());

**注意事项**：
- 批量操作比逐条索引快得多，建议大批量数据时使用。
- 批量请求体不宜过大，建议每批 5-10MB 或 1000-5000 条。

---

### 6️⃣ Aggregations · 聚合
java

// 聚合查询

SearchResponse<Void> aggResponse = esClient.search(req -> req

.index("orders")

.size(0)

.aggregations("by_category", agg -> agg

.terms(t -> t.field("category").size(10))

.aggregations("avg_amount", subAgg -> subAgg

.avg(a -> a.field("total_amount"))

)

),

Void.class

);

// 解析聚合结果

Aggregate aggregate = aggResponse.aggregations().get("by_category");

StringTerms terms = aggregate.sterms();

for (StringTermsBucket bucket : terms.buckets().array()) {

String category = bucket.key().stringValue();

long count = bucket.docCount();

double avgAmount = bucket.aggregations().get("avg_amount").avg().value();

System.out.println(category + ": " + count + " orders, avg " + avgAmount);

}

---

### 7️⃣ Spring Data Elasticsearch · Spring Data 集成
xml

<dependency>

<groupId>org.springframework.boot</groupId>

<artifactId>spring-boot-starter-data-elasticsearch</artifactId>

</dependency>

yaml

application.yml
spring:

elasticsearch:

uris: http://localhost:9200

connection-timeout: 5s

socket-timeout: 60s

java

// 实体类

@Document(indexName = "products")

public class Product {

@Id

private String id;

@Field(type = FieldType.Text, analyzer = "ik_max_word")

private String name;

@Field(type = FieldType.Double)

private Double price;

@Field(type = FieldType.Keyword)

private List<String> tags;

// getters, setters

}

// Repository

public interface ProductRepository extends ElasticsearchRepository<Product, String> {

List<Product> findByName(String name);

List<Product> findByPriceBetween(Double min, Double max);

@Query("{"match": {"tags": "?0"}}")

List<Product> findByTag(String tag);

}

// 使用

@Service

public class ProductService {

@Autowired

private ProductRepository repository;

public List<Product> searchByName(String name) {
return repository.findByName(name);
}
}

---

### 8️⃣ Error Handling · 错误处理
java

try {

GetResponse<Product> response = esClient.get(g -> g.index("products").id("unknown"), Product.class);

} catch (ElasticsearchException e) {

if (e.status() == 404) {

System.out.println("Document not found");

} else {

System.err.println("Elasticsearch error: " + e.getMessage());

}

} catch (IOException e) {

System.err.println("Network error: " + e.getMessage());

}

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `ClientSetup.java` | 创建客户端、连接池配置 |
| `IndexCRUD.java` | 创建索引、CRUD 文档 |
| `SearchQueries.java` | 各种查询示例 |
| `BulkOperations.java` | 批量索引和更新 |
| `AggregationExample.java` | 聚合查询 |
| `SpringDataExample.java` | Spring Data Elasticsearch 集成 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 客户端
1. **RestHighLevelClient 和新的 Elasticsearch Java Client 有什么区别？**
    - **答**：RestHighLevelClient 在 ES 7.x 中已废弃，将在 ES 8.x 中移除。新的 Java Client 使用 Elasticsearch 官方提供的 JSON 映射器（Jackson），API 更加流畅（Fluent API），并且支持所有新特性。

2. **如何配置连接池和超时？**
    - **答**：通过 `RestClient.builder()` 的 `setRequestConfigCallback` 设置 connectTimeout 和 socketTimeout，通过 `setHttpClientConfigCallback` 配置连接池大小。

### CRUD
3. **索引文档时如何指定 ID？不指定 ID 会怎样？**
    - **答**：在 index 请求中通过 `id()` 指定 ID；不指定时 ES 自动生成 UUID。如果指定 ID，后续相同 ID 的索引请求会覆盖原有文档（upsert）。

4. **更新文档和重新索引文档有什么区别？**
    - **答**：更新文档只发送变化的部分，网络开销小；重新索引文档是覆盖整个文档。更新内部是先获取再合并再索引，如果文档很大但只改一个小字段，更新更高效。

### 搜索
5. **如何构建一个复杂的 bool 查询？**
    - **答**：使用 `query.q().bool(b -> b.must(...).filter(...).should(...).mustNot(...))`，其中 must 贡献评分，filter 不贡献评分且可缓存。

6. **高亮查询如何实现？**
    - **答**：在 search 请求中添加 `highlight(h -> h.fields("fieldName", f -> f.preTags("<em>").postTags("</em>")))`，结果中通过 `hit.highlight().get("fieldName")` 获取高亮片段。

### 批量
7. **批量操作的最佳实践？**
    - **答**：每批 1000-5000 条或 5-10MB，使用 `BulkRequest.Builder` 添加操作，检查 `BulkResponse.errors()` 处理失败项。注意不要在一个批次中混合不同类型操作导致性能下降。

### Spring Data
8. **Spring Data Elasticsearch 和原生客户端的优缺点？**
    - **答**：Spring Data 提供声明式 Repository，开发效率高，但灵活性受限（复杂查询需要 @Query 注解）；原生客户端功能完整，适合复杂查询和聚合。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch Java 客户端的核心知识，包括客户端配置、CRUD、搜索、批量操作、聚合和 Spring Data 集成。每个主题都配有带中文注释的代码示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接运行。

---

*The client is your bridge to the cluster.* ☕🔍