# Query DSL 🔎

> Elasticsearch Query DSL for backend engineers (3–5 years experience).  
> Elasticsearch 查询 DSL 核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers Elasticsearch Query DSL: leaf queries (match, term, range), compound queries (bool, boosting), joining queries (nested, has_child), and geospatial queries. Mastering Query DSL is essential for building powerful search experiences. Each topic includes JSON examples with Chinese comments and common interview questions with answers.

本章涵盖 Elasticsearch 查询 DSL：叶子查询（match, term, range）、复合查询（bool, boosting）、关联查询（nested, has_child）和地理空间查询。掌握 Query DSL 对于构建强大的搜索体验至关重要。每个主题都包含带中文注释的 JSON 示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Query Context vs Filter Context · 查询上下文与过滤上下文

| Context | Scoring | Caching | Usage |
|---------|---------|---------|-------|
| Query context | 计算 _score，影响相关性排序 | 不缓存 | `must`, `should` |
| Filter context | 不计算 _score，只过滤 | 自动缓存 | `filter`, `must_not` |

json

// bool 查询中同时使用 query 和 filter

POST /products/_search

{

"query": {

"bool": {

"must": [

{ "match": { "name": "laptop" } }    // query context，计算分数

],

"filter": [

{ "range": { "price": { "gte": 1000 } } }  // filter context，不计算分数，可缓存

]

}

}

}

**注意事项**：
- 尽可能使用 filter context 来加速查询，特别是对于范围、精确匹配等不需要评分的条件。
- filter 的结果会被缓存，相同 filter 在不同查询中重复使用效率更高。

---

### 2️⃣ Leaf Queries · 叶子查询

#### Match Query（全文搜索）

json

// 基本 match

POST /articles/_search

{

"query": {

"match": {

"title": "elasticsearch tutorial"

}

}

}

// match_phrase（短语匹配）

POST /articles/_search

{

"query": {

"match_phrase": {

"title": "elasticsearch tutorial"

}

}

}

// multi_match（多字段搜索）

POST /articles/_search

{

"query": {

"multi_match": {

"query": "elasticsearch",

"fields": ["title^3", "content"]  // title 权重为 3

}

}

}

#### Term Query（精确匹配）

json

// term 查询（适用于 keyword 或数值类型）

POST /products/_search

{

"query": {

"term": {

"status": "active"

}

}

}

// terms 查询（多值匹配）

POST /products/_search

{

"query": {

"terms": {

"tags": ["electronics", "computer"]

}

}

}

**注意事项**：
- `term` 查询不会对搜索词进行分析，适用于 `keyword` 字段。
- 对 `text` 字段使用 `term` 通常不会匹配到文档，因为 `text` 字段经过了分词。

#### Range Query（范围查询）

json

POST /products/_search

{

"query": {

"range": {

"price": {

"gte": 100,

"lte": 500,

"boost": 2.0  // 提升权重

}

}

}

}

**Range 参数**：`gt`（大于）、`gte`（大于等于）、`lt`（小于）、`lte`（小于等于）、`boost`（权重）、`format`（日期格式）、`time_zone`（时区）。

#### Exists Query（存在查询）

json

// 查找 description 字段存在的文档

POST /products/_search

{

"query": {

"exists": {

"field": "description"

}

}

}

#### Wildcard / Fuzzy / Prefix Query

json

// wildcard（通配符）

POST /products/_search

{

"query": {

"wildcard": {

"name": "lap*"

}

}

}

// fuzzy（模糊匹配，编辑距离）

POST /products/_search

{

"query": {

"fuzzy": {

"name": {

"value": "laptoop",

"fuzziness": "AUTO"

}

}

}

}

// prefix（前缀匹配）

POST /products/_search

{

"query": {

"prefix": {

"name": "lap"

}

}

}

---

### 3️⃣ Compound Queries · 复合查询

#### Bool Query（最常用）

json

POST /products/_search

{

"query": {

"bool": {

"must": [

{ "match": { "name": "laptop" } }        // 必须匹配，贡献分数

],

"should": [

{ "match": { "brand": "dell" } },         // 可选匹配，提高分数

{ "match": { "brand": "lenovo" } }

],

"filter": [

{ "range": { "price": { "gte": 800 } } }, // 必须匹配，不计分，可缓存

{ "term": { "status": "active" } }

],

"must_not": [

{ "term": { "condition": "refurbished" } } // 必须不匹配

],

"minimum_should_match": 1  // should 至少满足 1 个

}

}

}

#### Boosting Query（降权）

json

// 降低包含 "used" 的文档的分数

POST /products/_search

{

"query": {

"boosting": {

"positive": {

"match": { "name": "laptop" }

},

"negative": {

"match": { "condition": "used" }

},

"negative_boost": 0.5

}

}

}

#### Constant Score Query（恒定分数）

json

// 将 filter 中的文档分数设为固定值（默认 1.0）

POST /products/_search

{

"query": {

"constant_score": {

"filter": {

"term": { "status": "active" }

},

"boost": 1.2

}

}

}

---

### 4️⃣ Joining Queries · 关联查询

#### Nested Query（嵌套对象查询）

json

// 嵌套映射

PUT /orders

{

"mappings": {

"properties": {

"items": {

"type": "nested",

"properties": {

"product": { "type": "keyword" },

"quantity": { "type": "integer" },

"price": { "type": "float" }

}

}

}

}

}

// 嵌套查询

POST /orders/_search

{

"query": {

"nested": {

"path": "items",

"query": {

"bool": {

"must": [

{ "term": { "items.product": "laptop" } },

{ "range": { "items.price": { "gte": 1000 } } }

]

}

}

}

}

}

**注意事项**：
- 普通 `object` 类型在 Lucene 中是扁平化存储的，无法跨字段交叉匹配。
- `nested` 类型将每个嵌套对象作为独立的隐藏文档存储，支持跨字段匹配。

#### Has Child / Has Parent Query（父子文档）

json

// 查找有子文档的父文档

POST /parent_index/_search

{

"query": {

"has_child": {

"type": "child_type",

"query": {

"match": { "field": "value" }

}

}

}

}

---

### 5️⃣ Geospatial Queries · 地理空间查询

json

// geo_distance：查找指定距离内的地点

POST /restaurants/_search

{

"query": {

"bool": {

"filter": {

"geo_distance": {

"distance": "5km",

"location": {

"lat": 40.7128,

"lon": -74.0060

}

}

}

}

}

}

// geo_bounding_box：查找矩形区域内的地点

POST /restaurants/_search

{

"query": {

"geo_bounding_box": {

"location": {

"top_left": { "lat": 40.8, "lon": -74.1 },

"bottom_right": { "lat": 40.6, "lon": -73.9 }

}

}

}

}

---

### 6️⃣ Script Query · 脚本查询

json

// 使用 Painless 脚本进行复杂计算

POST /products/_search

{

"query": {

"script": {

"script": {

"source": "doc['price'].value * doc['discount'].value > 500",

"lang": "painless"

}

}

}

}

**注意事项**：
- 脚本查询性能较差，尽量避免在实时查询中使用。
- 可以将计算结果预先存储为字段，使用普通查询替代。

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `match_query.json` | match, match_phrase, multi_match |
| `term_query.json` | term, terms, exists |
| `range_query.json` | range with numeric and date |
| `bool_query.json` | bool with must, should, filter, must_not |
| `nested_query.json` | nested object query |
| `geo_query.json` | geo_distance, geo_bounding_box |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 基础
1. **Query context 和 Filter context 的区别？**
    - **答**：Query context 计算相关性分数（_score），影响排序；Filter context 不计算分数，只做过滤，结果可缓存。建议将不需要影响排名的条件放在 filter 中以提高性能。

2. **match 和 term 查询的区别？**
    - **答**：match 会对查询词进行分析（分词），适用于 text 字段的全文搜索；term 不对查询词进行分析，适用于 keyword 字段的精确匹配。

### Bool 查询
3. **bool 查询中 must、should、filter、must_not 的区别？**
    - **答**：must 必须匹配，贡献分数；should 可选匹配，提高分数（配合 minimum_should_match）；filter 必须匹配，不贡献分数，可缓存；must_not 必须不匹配，不贡献分数。

### 关联查询
4. **nested 和 object 的区别？为什么需要 nested？**
    - **答**：object 类型在 Lucene 中扁平化存储，无法独立查询嵌套对象中的字段关系；nested 将每个嵌套对象作为独立文档存储，支持跨字段匹配。例如查询订单中包含价格大于 1000 的笔记本电脑，使用 object 可能误匹配。

### 性能
5. **如何优化查询性能？**
    - **答**：① 使用 filter context 代替 query context（如果不需要评分）；② 避免使用 wildcard、regexp、script 等低效查询；③ 合理使用索引（如 keyword 字段代替 text）；④ 使用 search_after 代替深度分页；⑤ 控制返回字段数量（_source 过滤）。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch 查询 DSL 的核心知识，包括叶子查询、复合查询、关联查询和地理空间查询。每个主题都配有 JSON 示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接在 Kibana Dev Tools 中运行。

---

*Query DSL is the language of search.* 🔎