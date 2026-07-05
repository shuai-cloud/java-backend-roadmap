# Elasticsearch 🔍

> Elasticsearch knowledge for backend engineers (3–5 years experience).  
> Elasticsearch 核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers Elasticsearch fundamentals: indexing, mapping, query DSL, aggregations, cluster management, and Java client integration. As a backend engineer, you'll often use ES for full-text search, log analytics, and real-time data analysis. Each topic includes practical examples and common interview questions.

本章涵盖 Elasticsearch 基础知识：索引、映射、查询 DSL、聚合、集群管理和 Java 客户端集成。作为后端工程师，你经常使用 ES 进行全文搜索、日志分析和实时数据分析。每个主题都包含实用示例和常见面试题。

---

## 🗂️ Directory Structure · 目录结构
es/

├── basics/                 # Documents, indices, shards, replicas, inverted index

├── mapping/                # Field types, dynamic mapping, explicit mapping, analyzers

├── query-dsl/              # Match, term, bool, range, fuzzy, wildcard, exists, geo

├── aggregation/            # Metric, bucket, pipeline aggregations

├── cluster/                # Node roles, health API, shard allocation, monitoring

├── java-client/            # RestHighLevelClient, Spring Data Elasticsearch

├── performance/            # Index optimization, query tuning, shard strategy, caching

└── interview-questions/    # High-frequency interview Q&A

Each subdirectory contains:
- A `README.md` with key concepts, examples, and interview tips.
- Code examples in `src/` (JSON queries or Java code).

---

## 🎯 Learning Goals · 学习目标

| Topic | Goal |
|-------|------|
| Basics | Understand document, index, shard, replica, inverted index |
| Mapping | Define explicit mappings, choose correct field types, configure analyzers |
| Query DSL | Write complex queries using bool, match, term, range, aggregations |
| Aggregations | Build metric, bucket, and pipeline aggregations for analytics |
| Cluster | Interpret cluster health, allocate shards, scale nodes |
| Java Client | Integrate ES with Spring Boot, perform CRUD and search |
| Performance | Optimize indexing speed, query latency, and disk usage |

---

## 📌 Key Interview Topics · 面试重点

1. **倒排索引原理**：如何实现全文搜索？
2. **分片和副本**：主分片数量为何不可变？副本的作用？
3. **Mapping 字段类型**：keyword vs text，date 格式，nested 对象。
4. **Query DSL**：bool 查询的 must / should / filter 区别，term vs match。
5. **聚合**：bucket 聚合（terms, date_histogram）、metric 聚合（avg, sum, cardinality）。
6. **集群管理**：节点角色（master, data, coordinating），脑裂问题，水平扩展。
7. **Java 客户端**：RestHighLevelClient 的使用，批量操作，异步查询。
8. **性能优化**：索引刷新间隔、段合并、分片大小、查询缓存。

---

## 🚀 Quick Reference · 速查示例
json

// 创建索引

PUT /products

{

"settings": {

"number_of_shards": 3,

"number_of_replicas": 1

},

"mappings": {

"properties": {

"name": { "type": "text" },

"price": { "type": "float" },

"tags": { "type": "keyword" },

"created_at": { "type": "date" }

}

}

}

// 查询

GET /products/_search

{

"query": {

"bool": {

"must": [{ "match": { "name": "laptop" } }],

"filter": [{ "range": { "price": { "gte": 1000 } } }]

}

},

"aggs": {

"by_tag": {

"terms": { "field": "tags" }

}

}

}

---

## 📅 Suggested Study Plan · 学习计划建议

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | Basics + Mapping | Create an index with proper mappings |
| 2 | Query DSL | Write 10 different queries |
| 3 | Aggregations | Build a dashboard-like aggregation report |
| 4 | Cluster + Java Client | Set up a 3-node cluster, connect via Java |
| 5 | Performance + Interview | Review performance tips, practice Q&A |

---

## 🇨🇳 中文说明

本目录为 Java 后端工程师整理了 Elasticsearch 的核心知识，从基础概念到集群管理、Java 客户端集成。每个子目录都配有中文注解和面试高频题，适合快速复习和查漏补缺。

---

*Search is not just a feature, it's a mindset.* 🔍