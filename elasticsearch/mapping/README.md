# Mapping 🗺️

> Elasticsearch mapping for backend engineers (3–5 years experience).  
> Elasticsearch 映射核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers Elasticsearch mapping: defining field types, dynamic vs explicit mapping, analyzers, multi-fields, and mapping updates. Proper mapping is critical for search relevance, storage efficiency, and query performance. Each topic includes JSON examples with Chinese comments and common interview questions with answers.

本章涵盖 Elasticsearch 映射：定义字段类型、动态映射 vs 显式映射、分析器、多字段和映射更新。合理的映射对于搜索相关性、存储效率和查询性能至关重要。每个主题都包含带中文注释的 JSON 示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ What is Mapping? · 什么是映射？

Mapping defines how documents and their fields are stored and indexed. It's analogous to a schema definition in a relational database.

映射定义了文档及其字段如何存储和索引，类似于关系数据库的表结构定义。

json

// 创建索引时指定映射

PUT /users

{

"mappings": {

"properties": {

"name":    { "type": "text" },

"age":     { "type": "integer" },

"email":   { "type": "keyword" },

"bio":     { "type": "text", "analyzer": "standard" },

"created": { "type": "date", "format": "yyyy-MM-dd" }

}

}

}

---

### 2️⃣ Dynamic Mapping · 动态映射

When you index a document with a new field, ES automatically detects its type based on the value.

当你索引一个包含新字段的文档时，ES 会根据值自动推断字段类型。

json

// 动态映射示例：索引一个文档，ES 自动创建映射

POST /users/_doc/1

{

"name": "Alice",

"age": 30,

"email": "alice@example.com"

}

// 查看自动生成的映射

GET /users/_mapping

**动态映射类型推断规则**：

| JSON Value | Detected Field Type |
|------------|---------------------|
| String (text-like) | `text` + `keyword` (multi-field) |
| Integer | `long` |
| Floating point | `float` |
| Boolean | `boolean` |
| Object | `object` |
| Array | Based on first non-null element |

**注意事项**：
- 动态映射很方便，但在生产环境中可能导致意外的类型映射（如数字被映射为 `long` 而非 `integer`）。
- 建议在正式环境使用显式映射，或通过 `dynamic: "strict"` 禁止动态映射。

---

### 3️⃣ Explicit Mapping · 显式映射

You define the mapping explicitly before indexing data. This gives you full control over field types, analyzers, and formats.

你在索引数据之前明确定义映射，这样可以完全控制字段类型、分析器和格式。

json

PUT /products

{

"mappings": {

"dynamic": "strict",  // 严格模式：未知字段会报错

"properties": {

"product_id": { "type": "keyword" },

"name": {

"type": "text",

"fields": {                   // multi-field

"keyword": { "type": "keyword" }

}

},

"description": {

"type": "text",

"analyzer": "english"         // 英语分析器（词干提取）

},

"price": { "type": "float" },

"tags": { "type": "keyword" },

"stock": { "type": "integer" },

"published_date": {

"type": "date",

"format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd"

},

"location": { "type": "geo_point" },  // 地理位置

"attributes": { "type": "nested" }    // 嵌套对象

}

}

}

---

### 4️⃣ Field Data Types · 字段数据类型

| Category | Types · 类型 | Usage · 用途 |
|----------|--------------|--------------|
| Core | `text`, `keyword`, `long`, `integer`, `short`, `byte`, `double`, `float`, `half_float`, `scaled_float`, `boolean`, `date`, `binary` | 基本数据类型 |
| Complex | `object`, `nested`, `flattened` | 对象和嵌套结构 |
| Geo | `geo_point`, `geo_shape` | 地理位置 |
| Specialized | `ip`, `version`, `murmur3`, `token_count` | 专用类型 |
| Search-as-you-type | `completion`, `search_as_you_type` | 自动补全 |
| Ranking | `rank_feature`, `rank_features` | 排名特征 |

**text vs keyword 的选择**：

| Feature | `text` | `keyword` |
|---------|--------|-----------|
| Analyzed | 是（分词） | 否（原值存储） |
| 全文搜索 | 支持（match, match_phrase） | 不支持 |
| 精确匹配 | 不支持（需用 keyword 子字段） | 支持（term, terms） |
| 聚合 | 不支持（需用 keyword 子字段） | 支持 |
| 排序 | 不支持 | 支持 |

**最佳实践**：
- 需要全文搜索的字段用 `text`，并添加 `.keyword` 多字段用于精确匹配和聚合。
- 不需要分词的字段（如 ID、枚举值、标签）直接用 `keyword`。

---

### 5️⃣ Analyzers · 分析器

An analyzer consists of three components: character filters, tokenizer, and token filters.

分析器由三个组件组成：字符过滤器、分词器和令牌过滤器。

json

// 自定义分析器

PUT /my_index

{

"settings": {

"analysis": {

"analyzer": {

"my_custom_analyzer": {

"type": "custom",

"char_filter": ["html_strip"],           // 去除 HTML 标签

"tokenizer": "standard",                 // 标准分词器

"filter": ["lowercase", "stop", "snowball"] // 小写、停用词、词干提取

}

}

}

},

"mappings": {

"properties": {

"content": {

"type": "text",

"analyzer": "my_custom_analyzer"

}

}

}

}

**内置分析器**：
- `standard`：标准分词，小写，停用词（默认）
- `simple`：非字母字符分割，小写
- `whitespace`：空白字符分割
- `stop`：类似 simple，但移除停用词
- `keyword`：不分词，视为一个整体
- `pattern`：正则表达式分割
- `language`：多语言分析器（如 `english`, `chinese`）

**注意事项**：
- 索引时使用的分析器（`analyzer`）和查询时使用的分析器（`search_analyzer`）可以不同。
- 中文推荐使用 IK 分词器（需安装插件）。

---

### 6️⃣ Multi-fields · 多字段

Allows a field to be indexed in multiple ways for different purposes.

允许一个字段以多种方式索引，以满足不同目的。

json

PUT /articles

{

"mappings": {

"properties": {

"title": {

"type": "text",

"fields": {

"keyword": { "type": "keyword" },          // 用于精确匹配和排序

"english": { "type": "text", "analyzer": "english" }, // 英语词干搜索

"ngram": { "type": "text", "analyzer": "ngram_analyzer" } // 模糊搜索

}

}

}

}

}

**使用场景**：
- `title` 用于全文搜索（match）。
- `title.keyword` 用于精确匹配（term）、排序、聚合。
- `title.english` 用于英语词干搜索。

---

### 7️⃣ Mapping Updates · 映射更新

Once a field mapping is created, you generally **cannot change its type**. However, you can add new fields.

一旦字段映射被创建，通常**不能更改其类型**。但你可以添加新字段。

json

// 添加新字段（允许）

PUT /users/_mapping

{

"properties": {

"phone": { "type": "keyword" }

}

}

// 更改字段类型（不允许，会报错）

PUT /users/_mapping

{

"properties": {

"age": { "type": "keyword" }  // 原本是 integer，改为 keyword 会失败

}

}

**如果需要更改字段类型，需要重建索引**：
1. 创建新索引，定义正确的映射。
2. 使用 reindex API 将数据从旧索引迁移到新索引。
3. 删除旧索引，创建别名指向新索引。

json

// reindex 示例

POST _reindex

{

"source": { "index": "old_users" },

"dest": { "index": "new_users" }

}

---

### 8️⃣ Mapping Parameters · 映射参数

| Parameter | Description · 说明 | Example |
|-----------|--------------------|---------|
| `index` | 是否被索引（可搜索） | `"index": false` |
| `store` | 是否独立存储（默认从 `_source` 获取） | `"store": true` |
| `doc_values` | 是否启用列存储（用于聚合、排序） | `"doc_values": false` |
| `norms` | 是否存储归一化因子（用于评分） | `"norms": false`（节省空间） |
| `coerce` | 是否自动转换类型（如 "5" → 5） | `"coerce": false` |
| `copy_to` | 复制到另一个字段 | `"copy_to": "full_name"` |
| `ignore_above` | 超过长度的字符串不被索引 | `"ignore_above": 256` |

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `create_mapping.json` | 创建索引并定义映射 |
| `dynamic_mapping.json` | 动态映射示例 |
| `multi_field.json` | 多字段映射 |
| `custom_analyzer.json` | 自定义分析器 |
| `update_mapping.json` | 添加新字段 |
| `reindex.json` | 重建索引 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 基础
1. **什么是 Elasticsearch 的映射？它与关系数据库的 schema 有何异同？**
    - **答**：映射定义字段类型和分析方式，类似于数据库 schema。不同点：ES 映射是 schema-less（动态映射），字段类型一经创建不可修改，支持嵌套和数组。

2. **text 和 keyword 的区别？什么时候用 keyword？**
    - **答**：text 会分词，用于全文搜索；keyword 不分词，用于精确匹配、排序、聚合。适合 ID、标签、状态码等不需要分词的字段。

### 动态映射
3. **动态映射的优缺点？如何控制动态映射？**
    - **答**：优点：快速上手，无需预定义 schema。缺点：可能导致意外的类型映射，占用不必要的存储。控制方式：设置 `dynamic: true`（默认）、`false`（忽略新字段）、`strict`（报错）。

### 分析器
4. **分析器的组成部分？如何自定义分析器？**
    - **答**：分析器由字符过滤器、分词器和令牌过滤器组成。自定义时在 settings 中定义 analyzer，指定 char_filter、tokenizer、filter。

### 映射更新
5. **为什么 ES 不允许修改字段类型？如何修改？**
    - **答**：因为 ES 使用 Lucene 倒排索引，字段类型决定了索引结构，修改后需要重建所有索引。修改方法：创建新索引 → reindex → 切换别名。

### 性能
6. **如何优化映射以减少存储空间？**
    - **答**：① 不需要搜索的字段设置 `"index": false`；② 不需要排序/聚合的字段设置 `"doc_values": false`；③ 不需要评分的字段设置 `"norms": false`；④ 使用 `keyword` 代替 `text`（如果不需要分词）；⑤ 合理设置 `ignore_above`。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch 映射的核心知识，包括字段类型、动态/显式映射、分析器、多字段、映射更新和参数优化。每个主题都配有 JSON 示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接在 Kibana Dev Tools 中运行。

---

*A good mapping is half the battle won.* 🗺️