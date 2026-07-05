# Cluster 🏢

> Elasticsearch cluster management for backend engineers (3–5 years experience).  
> Elasticsearch 集群管理核心知识，面试高频考点。

[![Elasticsearch](https://img.shields.io/badge/Elasticsearch-7.x+-green)](https://www.elastic.co/)

---

## 📖 Overview · 概览

This section covers Elasticsearch cluster architecture: node roles, discovery, fault tolerance, scaling, monitoring, and common operational tasks. Understanding cluster management is essential for running ES in production. Each topic includes practical commands with Chinese comments and common interview questions with answers.

本章涵盖 Elasticsearch 集群架构：节点角色、发现、容错、扩缩容、监控和常见运维操作。理解集群管理对于在生产环境中运行 ES 至关重要。每个主题都包含带中文注释的实用命令和带答案的常见面试题。

---

## 🗂️ Topics · 主题速查

### 1️⃣ Cluster Architecture · 集群架构

An Elasticsearch cluster consists of one or more nodes. Each node can serve multiple roles.

Elasticsearch 集群由一个或多个节点组成。每个节点可以承担多个角色。
┌─────────────────────────────────────────────┐

│            Elasticsearch Cluster            │

│                                             │

│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │

│  │ Node 1   │  │ Node 2   │  │ Node 3   │  │

│  │ master   │  │ data     │  │ data     │  │

│  │ data     │  │ ingest   │  │ ml       │  │

│  │ coord    │  │ coord    │  │ coord    │  │

│  └──────────┘  └──────────┘  └──────────┘  │

│                                             │

│  Shards distributed across nodes            │

└─────────────────────────────────────────────┘

**Node Roles · 节点角色**：

| Role | Setting | Description · 说明 |
|------|---------|--------------------|
| Master | `node.master: true` | Manages cluster state, coordinates metadata changes |
| Data | `node.data: true` | Stores data, performs CRUD, search, aggregations |
| Ingest | `node.ingest: true` | Preprocesses documents before indexing |
| ML | `node.ml: true` | Runs machine learning jobs |
| Coordinating | (default) | Routes requests, aggregates results |
| Voting-only | `node.voting_only: true` | Participates in master election but never becomes master |

**Best Practices · 最佳实践**：
- Small clusters (< 3 nodes): each node acts as master + data + ingest.
- Medium clusters (3-10 nodes): dedicated master-eligible nodes (3 minimum).
- Large clusters (10+ nodes): separate master, data, ingest, coordinating roles.

---

### 2️⃣ Discovery & Election · 发现与选举

Nodes discover each other and elect a master node to coordinate cluster state.

节点相互发现并选举一个主节点来协调集群状态。
yaml

elasticsearch.yml 配置
discovery.seed_hosts:

10.0.0.1:9300

10.0.0.2:9300

10.0.0.3:9300

cluster.initial_master_nodes:

node-1

node-2

node-3

**Zen Discovery (7.x)**：
- Nodes ping each other on port 9300 (transport layer).
- Master election uses a quorum-based algorithm.
- Minimum master nodes: `discovery.zen.minimum_master_nodes: (N/2)+1` (prevent split-brain).

**Split-brain Problem · 脑裂问题**：
- Occurs when two nodes both think they are master.
- Prevention: set `minimum_master_nodes` to majority of master-eligible nodes.
- In 7.x+, the cluster automatically manages this with `cluster.initial_master_nodes`.

---

### 3️⃣ Cluster Health · 集群健康
json

// 查看集群健康状态

GET /_cluster/health

// 响应示例

{

"cluster_name": "my_cluster",

"status": "yellow",          // green, yellow, red

"timed_out": false,

"number_of_nodes": 3,

"number_of_data_nodes": 3,

"active_primary_shards": 150,

"active_shards": 290,

"relocating_shards": 0,

"initializing_shards": 0,

"unassigned_shards": 5,

"delayed_unassigned_shards": 0,

"number_of_pending_tasks": 0

}

**Health Status**：

| Status | Meaning · 含义 |
|--------|----------------|
| Green | All primary and replica shards are active |
| Yellow | All primary shards are active, but some replicas are unassigned |
| Red | Some primary shards are unassigned (data unavailable) |

**Common Causes of Yellow/Red**：
- Yellow: insufficient nodes to allocate replicas (e.g., 1 node cluster).
- Red: node failure, disk full, corrupted index.

---

### 4️⃣ Shard Allocation · 分片分配
json

// 查看分片分配情况

GET /_cat/shards?v

// 手动分配分片

POST /_cluster/reroute

{

"commands": [

{

"allocate_replica": {

"index": "my_index",

"shard": 0,

"node": "node-3"

}

}

]

}

// 查看分片分配解释（诊断未分配的原因）

GET /_cluster/allocation/explain

{

"index": "my_index",

"shard": 0,

"primary": true

}

**Shard Allocation Settings**：

| Setting | Description · 说明 |
|---------|--------------------|
| `cluster.routing.allocation.enable` | Enable/disable allocation (`all`, `primaries`, `new_primaries`, `none`) |
| `cluster.routing.allocation.node_concurrent_recoveries` | Max concurrent recoveries per node (default 2) |
| `cluster.routing.allocation.cluster_concurrent_rebalance` | Max concurrent rebalances cluster-wide (default 2) |
| `index.routing.allocation.require._name` | Pin index to specific nodes |
| `index.routing.allocation.total_shards_per_node` | Max shards per node for an index |

---

### 5️⃣ Scaling · 扩缩容

**Horizontal Scaling (Add Nodes)**：
json

// 加入新节点后，自动重新平衡分片

// 无需手动操作，ES 会自动迁移分片到新节点

// 查看重新平衡进度

GET /_cat/recovery?v

**Vertical Scaling (Upgrade Hardware)**：
- Increase RAM (recommended: 50% heap, 50% OS cache).
- Use SSDs for data paths.
- Increase CPU cores for compute-heavy workloads.

**Rolling Restart**：
json

// 1. 禁用分片分配

PUT /_cluster/settings

{

"persistent": {

"cluster.routing.allocation.enable": "none"

}

}

// 2. 重启节点（逐个）

// 3. 重新启用分片分配

PUT /_cluster/settings

{

"persistent": {

"cluster.routing.allocation.enable": "all"

}

}

---

### 6️⃣ Monitoring · 监控
json

// 节点信息

GET /_nodes/stats

GET /_nodes/node-1/stats

// 集群统计

GET /_cluster/stats

// 索引统计

GET /all/stats

GET /my_index/_stats

// 热点线程（诊断 CPU 高）

GET /_nodes/hot_threads

// 任务管理

GET /_tasks?detailed=true

GET /_tasks/action:search

// 慢查询日志配置

PUT /my_index/_settings

{

"index.search.slowlog.threshold.query.warn": "5s",

"index.search.slowlog.threshold.fetch.warn": "2s",

"index.indexing.slowlog.threshold.index.warn": "5s"

}

**Key Metrics to Monitor**：
- Cluster health status (green/yellow/red).
- JVM heap usage (>75% warning, >90% critical).
- Search and indexing throughput.
- Search latency (p50, p90, p99).
- Merge rate and merge time.
- Disk usage (warning at 80%, critical at 90%).

---

### 7️⃣ Backup & Restore · 备份与恢复
json

// 注册快照仓库

PUT /_snapshot/my_backup

{

"type": "fs",

"settings": {

"location": "/mnt/backups/es_snapshots"

}

}

// 创建快照

PUT /_snapshot/my_backup/snapshot_20250706

{

"indices": "my_index,another_index",

"ignore_unavailable": true,

"include_global_state": false

}

// 查看快照状态

GET /snapshot/my_backup/snapshot_20250706/status

// 恢复快照

POST /snapshot/my_backup/snapshot_20250706/restore

{

"indices": "my_index",

"rename_pattern": "(.+)",

"rename_replacement": "restored_$1"

}

// 删除快照

DELETE /_snapshot/my_backup/snapshot_20250706

---

### 8️⃣ Security · 安全
json

// 创建用户

POST /_security/user/kibana_admin

{

"password": "password123",

"roles": ["kibana_admin"],

"full_name": "Kibana Administrator"

}

// 创建角色

POST /_security/role/logs_writer

{

"indices": [

{

"names": ["logs-*"],

"privileges": ["write", "create_index"]

}

]

}

// TLS 配置（elasticsearch.yml）

xpack.security.transport.ssl.enabled: true

xpack.security.http.ssl.enabled: true

---

## 📂 Code Examples · 代码示例

All runnable code examples are located in the [`src/`](./src/) directory:

| File | Description |
|------|-------------|
| `cluster_health.json` | 查看集群健康、节点信息、分片分配 |
| `rolling_restart.json` | 滚动重启步骤 |
| `backup_restore.json` | 快照创建和恢复 |
| `monitoring.json` | 监控指标和慢查询日志 |
| `security.json` | 用户和角色管理 |

---

## ❓ Interview Questions with Answers · 面试题（附答案）

### 集群架构
1. **Elasticsearch 集群中节点的角色有哪些？如何配置专用节点？**
    - **答**：Master、Data、Ingest、ML、Coordinating、Voting-only。在 `elasticsearch.yml` 中设置 `node.master: true/false`、`node.data: true/false` 等。大型集群建议分离角色。

2. **什么是脑裂（split-brain）？如何预防？**
    - **答**：脑裂是集群中两个节点同时认为自己是主节点，导致状态不一致。预防：设置 `discovery.zen.minimum_master_nodes` 为 `(master-eligible nodes / 2) + 1`。7.x+ 使用 `cluster.initial_master_nodes` 自动管理。

### 发现与选举
3. **Elasticsearch 如何发现节点和选举主节点？**
    - **答**：节点通过 `discovery.seed_hosts` 指定的种子节点进行发现。主节点选举使用 Zen Discovery（7.x）或基于投票的算法，获得多数票的节点成为主节点。

### 集群健康
4. **集群状态 yellow 和 red 分别代表什么？如何排查？**
    - **答**：Yellow：主分片正常，副本分片未分配（常见于单节点集群或节点不足）。Red：主分片未分配，数据不可用。排查：`GET /_cluster/allocation/explain` 查看原因，检查磁盘空间、节点状态、分片分配设置。

### 分片分配
5. **如何将分片分配到特定节点？**
    - **答**：使用 `index.routing.allocation.require._name: "node-name"` 或 `_ip`、`_host`。也可以使用 `_cluster/reroute` 手动移动分片。

### 扩缩容
6. **如何在不中断服务的情况下扩容集群？**
    - **答**：添加新节点，ES 会自动重新平衡分片。建议先禁用分片分配（`cluster.routing.allocation.enable: none`），加入节点后再启用。

### 备份
7. **Elasticsearch 如何备份和恢复数据？**
    - **答**：使用快照（Snapshot）API。注册快照仓库（文件系统、S3、HDFS 等），创建快照，需要时恢复。快照是增量备份，只保存变化的部分。

### 监控
8. **如何监控 Elasticsearch 集群的健康状况？**
    - **答**：使用 `_cluster/health`、`_nodes/stats`、`_cat` API。关注堆内存使用、磁盘使用、搜索延迟、合并速率。可以使用 Elasticsearch Monitoring（X-Pack）或 Prometheus + Grafana。

---

## 🇨🇳 中文说明

本目录覆盖了 Elasticsearch 集群管理的核心知识，包括节点角色、发现选举、集群健康、分片分配、扩缩容、监控、备份和安全。每个主题都配有实用命令和带答案的面试题。代码示例在 `src/` 目录下，可以直接在 Kibana Dev Tools 中运行。

---

*A healthy cluster is a happy cluster.* 🏢