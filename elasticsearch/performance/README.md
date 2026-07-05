# Performance ⚡

> Elasticsearch performance tuning for backend engineers (3–5 years experience).  
> Elasticsearch 性能优化核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers Elasticsearch performance tuning: indexing optimization, query optimization, shard strategy, caching, and hardware considerations. Performance tuning is critical for maintaining low latency and high throughput in production. Each topic includes practical tips and common interview questions with answers.

本章涵盖 Elasticsearch 性能优化：索引优化、查询优化、分片策略、缓存和硬件考量。性能优化对于在生产环境中保持低延迟和高吞吐量至关重要。每个主题都包含实用技巧和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Indexing Performance · 索引性能优化

| Technique | Description · 说明 |
|-----------|--------------------|
| 批量写入 | 使用 bulk API，每批 1000-5000 条或 5-15MB |
| 增加 refresh interval | `index.refresh_interval: -1`（禁用自动刷新）或 `30s`，写完后手动 refresh |
| 禁用副本 | 初始导入时设置 `number_of_replicas: 0`，导入完成后恢复 |
| 使用 SSD | 磁盘 I/O 是主要瓶颈，SSD 显著提升索引速度 |
| 合理映射 | 不需要搜索的字段设 `index: false`，不需要聚合的设 `doc_values: false` |
| 使用 ingest pipeline | 预处理数据，减少写入时的计算开销 |
| 增加 translog flush 间隔 | `index.translog.durability: async`，`index.translog.sync_interval: 5s` |
json

// 批量导入优化配置

PUT /my_index/_settings

{

"index": {

"refresh_interval": "-1",

"number_of_replicas": 0,

"translog.durability": "async",

"translog.sync_interval": "5s"

}

}

// 导入完成后恢复

PUT /my_index/_settings

{

"index": {

"refresh_interval": "30s",

"number_of_replicas": 1

}

}

POST /my_index/_refresh

---

### 2️⃣ Shard Strategy · 分片策略

| Aspect | Recommendation · 建议 |
|--------|----------------------|
| 分片大小 | 每个分片 10GB-50GB（日志场景可到 100GB） |
| 分片数量 | `number_of_shards = (数据总量 / 目标分片大小) × (1 + 增长系数)` |
| 最大分片 | 每个节点不超过 20-25 个分片（包括副本） |
| 主分片 | 创建索引后不可修改，提前规划 |
| 副本分片 | 至少 1 个副本保证高可用，最多不超过节点数-1 |

**分片过多的危害**：
- 增加集群管理开销（分片元数据、master 节点压力）。
- 增加搜索的 fan-out（每个分片都要处理请求）。
- 增加 GC 压力。

**分片过少的危害**：
- 单个分片过大，影响恢复时间。
- 无法充分利用多节点并行能力。

---

### 3️⃣ Query Performance · 查询性能优化

| Technique | Description · 说明 |
|-----------|--------------------|
| 使用 filter 代替 query | filter 不计算评分，可缓存 |
| 避免 script 查询 | script 查询无法缓存，性能差 |
| 使用 keyword 字段做精确匹配 | 避免对 text 字段做 term 查询 |
| 限制返回字段 | 使用 `_source_includes` 只返回需要的字段 |
| 使用 scroll / search_after | 深度分页避免 from + size 的开销 |
| 避免通配符前缀查询 | `wildcard` 和 `prefix` 性能较差 |
| 使用 completion suggester | 自动补全场景专用 |
| 预热文件系统缓存 | 确保热门数据在内存中 |
json

// 优化后的查询

GET /products/_search

{

"_source": ["name", "price"],

"query": {

"bool": {

"filter": [

{ "term": { "status": "active" } },

{ "range": { "price": { "gte": 100, "lte": 500 } } }

],

"must": [

{ "match": { "name": "laptop" } }

]

}

}

}

---

### 4️⃣ Caching · 缓存

| Cache Type | Description · 说明 | Eviction |
|------------|--------------------|----------|
| Request Cache | 缓存 filter 查询的结果 | LRU，基于分片 |
| Query Cache | 缓存查询的评分结果 | LRU，基于节点 |
| Field Data Cache | 用于 text 字段的聚合和排序 | LRU，基于字段 |
| Shard Request Cache | 缓存分片级别的请求结果 | 索引刷新时失效 |
json

// 查看缓存统计

GET /_nodes/stats/indices/request_cache,query_cache,fielddata

// 清除缓存

POST /my_index/_cache/clear

**注意事项**：
- Request Cache 只在 `size: 0` 的查询中生效。
- Field Data Cache 默认关闭，建议使用 `doc_values` 代替。

---

### 5️⃣ Hardware Considerations · 硬件考量

| Component | Recommendation · 建议 |
|-----------|----------------------|
| CPU | 高主频 > 多核心（搜索场景），多核心 > 高主频（索引场景） |
| 内存 | 堆内存不超过物理内存的 50%（留给 OS 文件缓存） |
| 磁盘 | SSD > HDD，RAID 0 提高吞吐 |
| 网络 | 万兆网卡，低延迟交换机 |

**内存分配公式**：
- 堆内存 ≤ 32GB（超过 32GB 指针压缩失效）。
- 堆内存 ≤ 物理内存的 50%。
- 剩余内存留给 OS 文件系统缓存。

---

### 6️⃣ Merge and Segments · 段合并
json

// 查看段信息

GET /my_index/_segments

// 强制合并（减少段数，提升查询性能，但会消耗 I/O）

POST /my_index/_forcemerge?max_num_segments=1

**注意事项**：
- 段合并是 I/O 密集型操作，建议在低峰期执行。
- 不要频繁强制合并，会增加写入放大。
- 对于日志场景，建议按时间滚动索引，不需要强制合并。

---

### 7️⃣ Monitoring · 监控
json

// 集群健康

GET _cluster/health

// 节点热点线程

GET _nodes/hot_threads

// 慢查询日志

PUT /my_index/_settings

{

"index.search.slowlog.threshold.query.warn": "10s",

"index.search.slowlog.threshold.query.info": "5s",

"index.indexing.slowlog.threshold.index.warn": "10s"

}

// 查看 pending tasks

GET _cluster/pending_tasks

// 查看任务队列

GET _cat/thread_pool?v

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `index_settings.json` | 索引优化配置 |
| `force_merge.json` | 强制合并示例 |
| `slow_log.json` | 慢查询日志配置 |
| `monitoring.json` | 监控 API 示例 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 索引优化
1. **如何提高索引速度？**
    - **答**：① 使用 bulk API 批量写入；② 增加 refresh_interval 或禁用自动刷新；③ 禁用副本（导入完成后恢复）；④ 使用 SSD；⑤ 合理设置 mapping（不需要的字段关闭 index/doc_values）；⑥ 使用 ingest pipeline 预处理。

2. **为什么批量导入时要禁用副本？**
    - **答**：每个副本都需要复制数据，禁用副本可以减少网络开销和磁盘写入，提高索引速度。导入完成后恢复副本，ES 会自动同步数据。

### 分片
3. **如何确定分片数量？**
    - **答**：根据数据量和节点数估算。公式：`分片数 = (数据总量 / 目标分片大小) × (1 + 增长系数)`。目标分片大小 10-50GB，每个节点不超过 20-25 个分片。

4. **主分片数量为什么不能修改？**
    - **答**：主分片数量决定了数据如何路由（`routing = hash(_id) % number_of_shards`），修改后会导致数据分布混乱。如需更改，只能重建索引。

### 查询优化
5. **filter 和 query 的区别？为什么 filter 更快？**
    - **答**：filter 不计算评分，结果可缓存（Request Cache），适合精确匹配和范围查询。query 计算相关性评分，结果不可缓存。filter 更快是因为跳过了评分计算和利用了缓存。

6. **深度分页为什么性能差？如何解决？**
    - **答**：`from + size` 需要协调节点从每个分片获取 `from + size` 条数据，然后排序截取，随着 from 增大，内存和时间开销剧增。解决：使用 `scroll`（快照式，适合导出）或 `search_after`（游标式，适合实时分页）。

### 缓存
7. **Request Cache 什么时候生效？**
    - **答**：当查询的 `size` 为 0 时，且使用了 filter 上下文（不涉及评分）。索引发生 refresh 后缓存会失效。

### 硬件
8. **ES 堆内存为什么建议不超过 32GB？**
    - **答**：超过 32GB 时 JVM 会关闭指针压缩（OOPs），对象引用从 4 字节变为 8 字节，导致内存占用增加约 50%。即使物理内存很大，堆内存也不建议超过 32GB，剩余内存留给 OS 文件缓存。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch 性能优化的核心知识，包括索引优化、分片策略、查询优化、缓存、硬件考量和监控。每个主题都配有实用技巧和带答案的面试题。代码示例在 `src/` 目录下，可以直接在 Kibana Dev Tools 中运行。

---

*Performance tuning is an ongoing process, not a one-time task.* ⚡