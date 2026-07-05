# Aggregation 📊

> Elasticsearch aggregations for backend engineers (3–5 years experience).  
> Elasticsearch 聚合核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers Elasticsearch aggregations: metric aggregations, bucket aggregations, pipeline aggregations, and how to combine them. Aggregations enable real-time analytics on your data — counts, averages, histograms, percentiles, and more. Each topic includes JSON examples with Chinese comments and common interview questions with answers.

本章涵盖 Elasticsearch 聚合：指标聚合、桶聚合、管道聚合以及如何组合使用。聚合让你能够对数据进行实时分析——计数、平均值、直方图、百分位数等。每个主题都包含带中文注释的 JSON 示例和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ What are Aggregations? · 什么是聚合？

Aggregations summarize your data as metrics, buckets, or pipelines. They are the equivalent of SQL's GROUP BY but much more powerful.

聚合将数据总结为指标、桶或管道。它们相当于 SQL 的 GROUP BY，但功能强大得多。

json

// 最简单的聚合：统计文档总数

GET /sales/_search

{

"size": 0,  // 不返回原始文档

"aggs": {

"total_sales": {

"value_count": { "field": "amount" }

}

}

}

---

### 2️⃣ Metric Aggregations · 指标聚合

Metric aggregations compute numeric values from field values.

指标聚合从字段值计算数值。

| Aggregation | Description · 说明 |
|-------------|--------------------|
| `avg` | Average · 平均值 |
| `sum` | Sum · 总和 |
| `min` / `max` | Minimum / Maximum · 最小值/最大值 |
| `stats` | All of the above · 以上全部 |
| `extended_stats` | Extended stats (variance, std_deviation) · 扩展统计（方差、标准差） |
| `value_count` | Count of non-null values · 非空值计数 |
| `cardinality` | Approximate distinct count · 近似去重计数（类似 COUNT DISTINCT） |
| `percentiles` | Percentile values · 百分位数 |
| `percentile_ranks` | Rank values at specific percentiles · 指定百分位的排名 |
| `geo_bounds` | Bounding box of geo points · 地理边界框 |
| `geo_centroid` | Centroid of geo points · 地理中心点 |

json

// 多种指标聚合示例

GET /orders/_search

{

"size": 0,

"aggs": {

"amount_stats": {

"stats": { "field": "total_amount" }

},

"distinct_customers": {

"cardinality": { "field": "customer_id" }

},

"price_percentiles": {

"percentiles": {

"field": "total_amount",

"percents": [50, 90, 99]

}

}

}

}

**注意事项**：
- `cardinality` 是近似值，精度可通过 `precision_threshold` 调节（默认 3000）。
- `percentiles` 也是近似值，基于 TDigest 算法。

---

### 3️⃣ Bucket Aggregations · 桶聚合

Bucket aggregations group documents into buckets (like SQL GROUP BY). Each bucket can have its own sub-aggregations.

桶聚合将文档分组到桶中（类似 SQL GROUP BY）。每个桶可以有子聚合。

| Aggregation | Description · 说明 |
|-------------|--------------------|
| `terms` | Group by field value · 按字段值分组 |
| `range` | Custom numeric ranges · 自定义数值范围 |
| `date_range` | Custom date ranges · 自定义日期范围 |
| `histogram` | Fixed-width numeric intervals · 固定宽度的数值区间 |
| `date_histogram` | Fixed-width date intervals · 固定宽度的日期区间 |
| `filter` / `filters` | Filter-based buckets · 基于过滤器的桶 |
| `missing` | Documents with missing field · 字段缺失的文档 |
| `geohash_grid` | Geo-grid aggregation · 地理网格聚合 |
| `nested` / `reverse_nested` | For nested objects · 用于嵌套对象 |

json

// terms 聚合：按类别分组统计销售额

GET /orders/_search

{

"size": 0,

"aggs": {

"by_category": {

"terms": {

"field": "category",

"size": 10,          // 返回前10个桶

"order": { "sales_sum": "desc" }

},

"aggs": {

"sales_sum": {

"sum": { "field": "total_amount" }

}

}

}

}

}

// date_histogram：按月统计订单数

GET /orders/_search

{

"size": 0,

"aggs": {

"orders_over_time": {

"date_histogram": {

"field": "order_date",

"calendar_interval": "month",

"format": "yyyy-MM"

}

}

}

}

**注意事项**：
- `terms` 聚合默认返回前 10 个桶，可通过 `size` 调整。
- `terms` 聚合的计数也是近似的（基于 `doc_count_error_upper_bound`）。
- `date_histogram` 支持 `fixed_interval`（固定间隔）和 `calendar_interval`（日历感知，如 `month` 自动处理不同月份天数）。

---

### 4️⃣ Pipeline Aggregations · 管道聚合

Pipeline aggregations take input from other aggregations and perform further calculations.

管道聚合从其他聚合获取输入并执行进一步计算。

| Aggregation | Description · 说明 |
|-------------|--------------------|
| `derivative` | Derivative (rate of change) · 导数（变化率） |
| `moving_avg` | Moving average · 移动平均 |
| `cumulative_sum` | Cumulative sum · 累积和 |
| `bucket_script` | Custom script across buckets · 跨桶的自定义脚本 |
| `bucket_selector` | Filter buckets based on script · 基于脚本过滤桶 |
| `stats_bucket` | Stats across sibling buckets · 兄弟桶的统计 |
| `percentiles_bucket` | Percentiles across sibling buckets · 兄弟桶的百分位数 |

json

// 管道聚合：计算每月销售额的移动平均

GET /sales/_search

{

"size": 0,

"aggs": {

"sales_per_month": {

"date_histogram": {

"field": "date",

"calendar_interval": "month"

},

"aggs": {

"monthly_total": {

"sum": { "field": "amount" }

},

"moving_avg": {

"moving_fn": {

"buckets_path": "monthly_total",

"window": 3,

"script": "MovingFunctions.unweightedAvg(values)"

}

}

}

}

}

}

---

### 5️⃣ Combining Aggregations · 组合聚合

You can nest aggregations arbitrarily deep to build complex analytics.

你可以任意深度嵌套聚合来构建复杂的分析。

json

// 多层嵌套：按年份 → 按类别 → 统计指标

GET /orders/_search

{

"size": 0,

"aggs": {

"by_year": {

"date_histogram": {

"field": "order_date",

"calendar_interval": "year"

},

"aggs": {

"by_category": {

"terms": {

"field": "category",

"size": 5

},

"aggs": {

"avg_amount": { "avg": { "field": "total_amount" } },

"total_revenue": { "sum": { "field": "total_amount" } },

"top_product": {

"terms": {

"field": "product_name",

"size": 1,

"order": { "_count": "desc" }

}

}

}

}

}

}

}

}

---

### 6️⃣ Filtering Before Aggregation · 聚合前过滤

Use `filter` or `post_filter` to scope which documents participate in aggregations.

使用 `filter` 或 `post_filter` 限定参与聚合的文档范围。

json

// 先过滤再聚合（推荐）

GET /orders/_search

{

"query": {

"bool": {

"filter": [

{ "range": { "order_date": { "gte": "2025-01-01" } } }

]

}

},

"size": 0,

"aggs": {

"by_category": {

"terms": { "field": "category" }

}

}

}

// 聚合内过滤：只对部分文档聚合

GET /orders/_search

{

"size": 0,

"aggs": {

"high_value_orders": {

"filter": { "range": { "total_amount": { "gte": 1000 } } },

"aggs": {

"by_category": {

"terms": { "field": "category" }

}

}

}

}

}

---

### 7️⃣ Aggregation Performance Tips · 聚合性能优化

| Tip | Description · 说明 |
|-----|--------------------|
| 开启 `doc_values` | 聚合依赖 doc_values，默认开启，不要关闭 |
| 使用 `size: 0` | 不需要原始文档时设置 `size: 0` 减少传输 |
| 限制 `terms` 的 `size` | 不需要返回所有桶，设置合理的 `size` |
| 使用 `filtered` 查询 | 先过滤减少聚合的数据量 |
| 避免深层嵌套 | 嵌套层级越多，性能越差 |
| 使用 `execution_hint: "map"` | 对低基数 terms 字段可优化（如性别） |
| 预热全局序号 | 对大索引的 keyword 字段预热 global ordinals |

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `metric_aggs.json` | avg, sum, stats, cardinality, percentiles |
| `bucket_aggs.json` | terms, date_histogram, range, histogram |
| `pipeline_aggs.json` | moving_avg, derivative, cumulative_sum |
| `nested_aggs.json` | Multi-level nesting |
| `filtered_aggs.json` | Filter + aggregation combination |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 基础
1. **Elasticsearch 的聚合和 SQL 的 GROUP BY 有什么区别？**
    - **答**：ES 聚合更灵活，支持嵌套、管道、多种指标类型。ES 聚合可以同时返回多个不同维度的结果，而 SQL GROUP BY 只能按一组字段分组。ES 聚合还支持近似算法（cardinality、percentiles），适合大规模数据。

2. **Metrics 聚合和 Bucket 聚合的区别？**
    - **答**：Metrics 聚合计算数值（如 sum, avg），不产生桶；Bucket 聚合将文档分组到桶中，每个桶可以包含子聚合。

### Terms 聚合
3. **Terms 聚合的计数为什么不准确？如何提高精度？**
    - **答**：Terms 聚合在每个分片上取 top N，然后合并，可能导致部分低频词被遗漏。提高精度：增大 `size` 值（如设为 2 倍期望桶数），或设置 `shard_size` 大于 `size`。

4. **Terms 聚合的 `order` 如何工作？**
    - **答**：默认按 `_count` 降序排列。可以改为按子聚合的结果排序，如 `order: { "avg_price": "asc" }`。

### Date Histogram
5. **`calendar_interval` 和 `fixed_interval` 的区别？**
    - **答**：`calendar_interval` 是日历感知的，如 `month` 会根据实际月份天数调整间隔；`fixed_interval` 是固定毫秒数，如 `720h` 永远是 30 天。建议时间序列分析使用 `calendar_interval`。

### 管道聚合
6. **什么是管道聚合？举例说明。**
    - **答**：管道聚合基于其他聚合的结果进行计算，如 `moving_avg`（移动平均）、`derivative`（导数）、`cumulative_sum`（累积和）。例如计算月度销售额的 3 个月移动平均。

### 性能
7. **如何优化聚合性能？**
    - **答**：① 确保 `doc_values` 开启；② 使用 `size: 0` 不返回文档；③ 先过滤再聚合；④ 限制 `terms` 的 `size`；⑤ 避免过深嵌套；⑥ 对高基数 fields 谨慎使用 terms 聚合。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch 聚合的核心知识，包括指标聚合、桶聚合、管道聚合、组合使用和性能优化。每个主题都配有 JSON 示例和带答案的面试题。代码示例在 `src/` 目录下，可以直接在 Kibana Dev Tools 中运行。

---

*Aggregations turn raw data into insights.* 📊