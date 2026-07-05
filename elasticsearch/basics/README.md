# Elasticsearch Basics 📄

> Elasticsearch fundamentals for backend engineers (3–5 years experience).  
> Elasticsearch 基础概念，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers the core concepts of Elasticsearch: documents, indices, shards, replicas, inverted index, and basic CRUD operations. Understanding these fundamentals is essential for designing efficient search architectures and troubleshooting performance issues.

本章涵盖 Elasticsearch 的核心概念：文档、索引、分片、副本、倒排索引和基本 CRUD 操作。理解这些基础知识对于设计高效的搜索架构和排查性能问题至关重要。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Documents & Indices · 文档与索引
json

// 文档（Document）：ES 中的基本数据单元，以 JSON 格式存储

{

"_index": "products",

"_id": "1",

"_source": {

"name": "Laptop",

"price": 1500.00,

"tags": ["electronics", "computers"],

"description": "High-performance laptop"

}

}

// 索引（Index）：具有相似特征的文档集合，类似数据库中的表

// 索引名称必须是小写字母，不能包含特殊字符

**注意事项**：
- 每个文档都有一个唯一的 `_id`，可以手动指定或由 ES 自动生成。
- 索引是逻辑命名空间，实际数据分布在多个分片上。

---

### 2️⃣ Shards & Replicas · 分片与副本
json

// 创建索引时指定分片和副本数

PUT /my_index

{

"settings": {

"number_of_shards": 3,    // 主分片数（创建后不可修改）

"number_of_replicas": 1   // 副本分片数（可动态调整）

}

}

**分片（Shard）**：
- 每个索引由一个或多个主分片组成，每个分片是一个 Lucene 实例。
- 主分片数量在创建索引时确定，之后不可更改。
- 数据根据文档 ID 的哈希值分配到不同的主分片。

**副本（Replica）**：
- 每个主分片可以有零个或多个副本分片，用于容错和提高读取性能。
- 副本分片可以动态调整：`PUT /my_index/_settings { "number_of_replicas": 2 }`。
- 主分片宕机时，副本会被提升为新的主分片。

**注意事项**：
- 主分片数一旦设定不能修改，因此需要提前规划（通常根据数据量和节点数预估）。
- 副本数越多，读取性能越好，但写入性能下降（需要同步到更多副本）。

---

### 3️⃣ Inverted Index · 倒排索引

倒排索引是 ES 实现全文搜索的核心数据结构。它将文档中的词语映射到包含该词语的文档列表。
原始文档：

Doc1: "I love elasticsearch"

Doc2: "I love java"

Doc3: "elasticsearch is powerful"

倒排索引（简化）：

"love"        -> Doc1, Doc2

"elasticsearch" -> Doc1, Doc3

"java"        -> Doc2

"powerful"    -> Doc3

**搜索过程**：
1. 用户输入查询词 "love elasticsearch"。
2. ES 将查询词分词为 ["love", "elasticsearch"]。
3. 在倒排索引中查找这两个词，得到包含它们的文档集合。
4. 计算相关性评分（TF-IDF 或 BM25），返回排序后的结果。

**注意事项**：
- 倒排索引是 ES 搜索速度快的原因（避免了全表扫描）。
- 分词器（Analyzer）决定了如何将文本分割成词语。

---

### 4️⃣ Basic CRUD Operations · 基本增删改查
json

// 1. 创建/更新文档（PUT 指定 ID）

PUT /products/_doc/1

{

"name": "Laptop",

"price": 1200,

"stock": 50

}

// 2. 创建文档（POST 自动生成 ID）

POST /products/_doc

{

"name": "Mouse",

"price": 25,

"stock": 200

}

// 3. 获取文档

GET /products/_doc/1

// 4. 更新文档（局部更新）

POST /products/_update/1

{

"doc": {

"price": 1100

}

}

// 5. 删除文档

DELETE /products/_doc/1

// 6. 批量操作

POST /_bulk

{"index": {"index": "products", "id": "2"}}

{"name": "Keyboard", "price": 80, "stock": 100}

{"delete": {"index": "products", "id": "1"}}

**注意事项**：
- PUT 创建文档时如果 ID 已存在，会覆盖整个文档（版本号递增）。
- 更新操作实际上是先获取文档、修改、再索引的过程（内部使用乐观锁）。
- 批量操作可以减少网络往返，提高写入性能。

---

### 5️⃣ Analyzer · 分词器
json

// 测试分词器

POST /_analyze

{

"analyzer": "standard",

"text": "I love Elasticsearch!"

}

// 结果：["i", "love", "elasticsearch"]

// 自定义分析器

PUT /my_index

{

"settings": {

"analysis": {

"analyzer": {

"my_custom_analyzer": {

"type": "custom",

"tokenizer": "standard",

"filter": ["lowercase", "stop", "snowball"]

}

}

}

}

}

**常见分词器**：
| Analyzer | Description · 说明 |
|----------|--------------------|
| standard | 按空格和标点分词，小写转换（默认） |
| simple | 按非字母字符分词，小写转换 |
| whitespace | 仅按空格分词 |
| keyword | 不分词，当作一个整体 |
| ik_smart | 中文分词（需安装 IK 插件） |

---

### 6️⃣ Mapping · 映射（基础）
json

// 查看映射

GET /products/_mapping

// 动态映射：ES 自动推断字段类型

// 例如插入 "age": 25 会被映射为 long 类型

// 显式映射（推荐）

PUT /products

{

"mappings": {

"properties": {

"name": { "type": "text" },

"price": { "type": "float" },

"tags": { "type": "keyword" },

"description": {

"type": "text",

"analyzer": "standard"

},

"created_at": { "type": "date" }

}

}

}

**注意事项**：
- `text` 类型会分词，用于全文搜索；`keyword` 类型不分词，用于精确匹配、排序和聚合。
- 映射一旦创建，已有的字段类型不能修改（除非重建索引）。

---

## 📂 Code Examples · 代码示例

All runnable examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `basic_crud.json` | CRUD 操作示例（可直接在 Kibana Dev Tools 中运行） |
| `analyzer_test.json` | 分词器测试 |
| `mapping_example.json` | 映射创建示例 |
| `shard_replica.json` | 分片和副本配置示例 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 基础概念
1. **什么是倒排索引？与传统数据库的 B-Tree 索引有什么区别？**
    - **答**：倒排索引将词语映射到包含该词的文档列表，适合全文搜索；B-Tree 索引将键值映射到行，适合精确匹配和范围查询。倒排索引在搜索时不需要全表扫描，效率更高。

2. **ES 中的索引（Index）和数据库中的表（Table）有什么异同？**
    - **答**：相似之处：都存储结构化数据。不同之处：ES 的索引是分布式的（分片），支持全文搜索，Schema 可以动态映射；数据库的表 Schema 严格，不支持全文搜索（除非使用 LIKE 或全文索引）。

### 分片与副本
3. **为什么主分片数创建后不能修改？**
    - **答**：因为文档根据 `_id` 的哈希值分配到主分片，如果改变主分片数，哈希结果会变化，需要重新索引所有数据。如果需要调整，只能创建新索引并 reindex。

4. **副本分片的作用？增加副本数对性能和容错的影响？**
    - **答**：副本用于容错（主分片宕机时提升为主）和提高读取性能（可以并行搜索）。增加副本会提高读取吞吐量，但会降低写入性能（需要同步到更多副本），同时增加磁盘使用。

### 文档操作
5. **ES 的更新操作是原地修改吗？**
    - **答**：不是。ES 的文档是不可变的，更新操作实际上是先标记旧文档为删除，然后索引一个新文档。删除的文档会在段合并时物理删除。

6. **批量操作（_bulk）的优势？**
    - **答**：减少网络往返次数，提高写入吞吐量。每个 bulk 请求可以包含多个操作（index/create/update/delete），ES 会并行处理。

### 分词器
7. **text 和 keyword 类型的区别？**
    - **答**：text 类型会经过分词器处理，用于全文搜索，支持模糊匹配、短语匹配等；keyword 类型不分词，用于精确匹配、排序和聚合。例如：商品名称用 text，商品标签用 keyword。

8. **如何实现中文分词？**
    - **答**：安装 IK 分词插件（elasticsearch-analysis-ik），配置 `analyzer: "ik_smart"` 或 `"ik_max_word"`。`ik_smart` 做最粗粒度的拆分，`ik_max_word` 做最细粒度的拆分。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch 的基础概念：文档、索引、分片、副本、倒排索引、CRUD 操作、分词器和映射。每个主题都配有 JSON 示例和带答案的面试题。示例代码在 `src/` 目录下，可以直接在 Kibana Dev Tools 中运行。

---

*Understand the foundation, master the search.* 📄
