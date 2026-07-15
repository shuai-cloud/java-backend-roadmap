一、先把四个概念拆开（很多人混着用）

组件



角色



解决什么



不解决什么




主从复制​



地基



数据冗余 + 读写分离



不 HA，主挂了要手动切




Sentinel（哨兵）​



主从的"自动切换器"



监控 + 自动故障转移 + 通知客户端新主



不分片，写还是单主瓶颈




Cluster​



官方分布式方案



分片（16384 槽）+ 每个分片自带主从 HA



运维复杂，跨槽多 key 受限




代理（Twemproxy / Codis / Predixy）​



客户端和 Redis 中间层



分片 + 故障转移，客户端无感



多了一次跳转，Twemproxy/Codis 基本淘汰，Predixy 还能打但小众

关系：主从复制是所有 HA 的地基，Sentinel 是主从的"外挂 HA"，Cluster 是"分片 + HA 内置"，代理是早期为了兼容老客户端搞的过渡方案。

二、现在生产用哪个多？什么情况用哪个？
1. 数据量 ≤ 单机内存 + 写不炸 → Sentinel（主流）

适合：

数据量 < 20~50GB，单机内存装得下

写 QPS 不爆炸（单主够扛，一般 < 10 万）

读多写少，可以从节点分担读

业务强依赖 Lua / MULTI / 跨 key 操作（Cluster 跨槽不支持）

典型：会话缓存、配置中心、中小业务缓存层。苍穹外卖这种体量，Sentinel 就够了，没必要上 Cluster。

💡 云厂商（阿里云、腾讯云）的 Redis "标准版"就是 Sentinel 模式，现在还在卖。

2. 数据超单机 or 写要水平扩展 → Cluster（官方主力）

适合：

数据 > 50GB，单机内存扛不住

写 QPS 要线性扩展（多主并行）

业务能接受 Hash Tag 约束（{user:1001}:cart这种写法）

代价：客户端要支持 Cluster 协议（JedisCluster / Lettuce），跨槽 MGET/MSET/Lua 受限，运维（槽迁移、reshard）复杂。

📌 云厂商的"集群版"就是 Cluster 模式，新项目如果预期会涨，直接 Cluster 避免后面重构。

3. 代理 → 基本淘汰，只剩"老系统改不动客户端"才用

Twemproxy：Twitter 出品，早已不活跃，不支持在线扩缩容、不支持故障转移（要配 Sentinel），新项目没人上了。

Codis：豌豆荚出品，功能全但 2019 起停止维护，国内一堆遗留系统在用，新项目别选。

Predixy：新一点的代理，同时支持 Sentinel 和 Cluster 后端，性能比 Twemproxy 好，但社区小，用的人不多。

唯一合理场景：老 Java/PHP 项目，客户端库不支持 Sentinel/Cluster 协议，又不想改代码，加个代理做兼容。

三、决策树（背这个面试能答）
纯文本
数据量能装进单机内存？
├─ 否 → Cluster
└─ 是 → 写 QPS 单主扛得住？
├─ 否 → Cluster
└─ 是 → 客户端能改吗？（支持 Cluster 协议）
├─ 不能 → 代理过渡
└─ 能 → Sentinel（95% 场景够用）

行业共识：Sentinel 覆盖 95% 的部署，Cluster 是数据/写要突破单机时才上。

四、3-5 年 Java 面试会怎么问（重点）

3 年以内可能只背概念，3-5 年一定会追问场景 + 坑，下面这些是近两年的高频追问点：

🎯 Sentinel 方向

Sentinel 最少几个？为什么是 3 个？

最少 3 个，quorum一般设 2。2 个哨兵的话挂 1 个就达不到 quorum，故障转移卡死。

主观下线 vs 客观下线？

单个 Sentinel 认为主节点挂了 = SDOWN；≥ quorum 个 Sentinel 都认为挂了 = ODOWN，才开始选主。

Sentinel 的故障转移流程？

监控 → SDOWN → ODOWN → 选举 Leader（Raft-like）→ 选最优从节点（优先级 + 复制偏移量最新）→ SLAVEOF NO ONE→ 通知其他从切主 → 通知客户端。

脑裂会不会发生？怎么防？

会。网络分区时旧主没死、Sentinel 另选了新主，出现双主。防：min-replicas-to-write 1+ min-replicas-max-lag 10，主节点发现从节点不够就不接受写。

🎯 Cluster 方向

16384 个槽怎么分的？客户端怎么路由？

CRC16(key) % 16384。客户端缓存 slot→node 映射，key 不在当前节点返回 MOVED，客户端更新缓存；迁移中返回 ASK，客户端这次先发 ASKING再发请求（不更新缓存）。

Hash Tag 是什么？为什么要用？

{user:1001}:cart和 {user:1001}:order花括号内相同 → 同一槽 → 能跨 key 操作（MGET、Lua、事务）。

Cluster 需要配 Sentinel 吗？

不需要。Cluster 节点间 Gossip 互监，每个主的分片自带从，故障自动升主。这是常见误区。

🎯 分布式锁方向（这两年八股更新了，必问）

RedLock 为什么被废弃？

Martin Kleppmann（《DDIA》作者）怼过 Antirez，三个硬伤：

时钟漂移：RedLock 依赖多节点系统时钟，NTP 跳变可能让锁提前释放

GC 停顿：客户端 Full GC 醒来锁已过期，两客户端同时持锁

网络分区脑裂：不像 Raft/Paxos 有严谨一致性

结果：Redis 官方文档已移除 RedLock 推荐，Redisson 里 RedissonRedLock已标 @Deprecated。

那现在分布式锁怎么写？

允许偶尔冲突 → 单 Redis 节点锁（SET key uuid NX PX，看门狗续期，Lua 释放），Redisson 的 RLock就是这套

强一致要求 → ZooKeeper / etcd（基于 Raft 租约）

🎯 代理方向

Twemproxy / Codis 和 Cluster 怎么选？

新项目直接 Cluster；老系统客户端改不动才用代理过渡。Codis 已停更，Twemproxy 不活跃。

quorum是 法定人数，在 Redis Sentinel 里指"至少要有多少个 Sentinel 达成一致，才能判定主节点客观下线（ODOWN），进而触发故障转移"。