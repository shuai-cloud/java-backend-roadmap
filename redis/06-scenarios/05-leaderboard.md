# 排行榜

Redis 的 ZSet（有序集合）是实现排行榜的理想数据结构，天然支持按分数排序和范围查询。

---

## 一、排行榜的常见类型

| 类型 | 特点 | 示例 |
|------|------|------|
| 实时排行榜 | 分数实时更新，按总分排序 | 游戏积分榜 |
| 周榜/月榜 | 按周期重置 | 销售额周榜 |
| 多维排行榜 | 按多个维度排序（如销量+好评率） | 综合评分榜 |

---

## 二、基础排行榜实现

### 1. 添加/更新分数

java

// 玩家得分 100

redisTemplate.opsForZSet().add("leaderboard", "player1", 100);

// 增加分数（增量更新）

redisTemplate.opsForZSet().incrementScore("leaderboard", "player1", 50);

### 2. 获取 Top N

java

// 获取前三名（降序）

Set<String> top3 = redisTemplate.opsForZSet()

.reverseRange("leaderboard", 0, 2);

// 获取前三名及其分数

Set<ZSetOperations.TypedTuple<String>> top3WithScores = redisTemplate.opsForZSet()

.reverseRangeWithScores("leaderboard", 0, 2);

### 3. 获取某个玩家的排名

java

// 升序排名（从 0 开始）

Long rank = redisTemplate.opsForZSet().rank("leaderboard", "player1");

// 降序排名

Long reverseRank = redisTemplate.opsForZSet().reverseRank("leaderboard", "player1");

### 4. 获取某个玩家的分数

java

Double score = redisTemplate.opsForZSet().score("leaderboard", "player1");

### 5. 获取排行榜总人数

java

Long size = redisTemplate.opsForZSet().zCard("leaderboard");

---

## 三、周榜/月榜实现

### 方案：按周期创建不同 key

java

// 周榜 key 包含周数

String weekKey = "leaderboard:week:" + getWeekOfYear();

// 月榜 key 包含月份

String monthKey = "leaderboard:month:" + getMonthOfYear();

// 添加分数时写入对应的周期 key

redisTemplate.opsForZSet().incrementScore(weekKey, playerId, score);

redisTemplate.opsForZSet().incrementScore(monthKey, playerId, score);

### 自动过期

java

// 周榜设置 8 天过期（多一天缓冲）

redisTemplate.expire(weekKey, 8, TimeUnit.DAYS);

// 月榜设置 32 天过期

redisTemplate.expire(monthKey, 32, TimeUnit.DAYS);

---

## 四、多维排行榜

有时需要按多个维度排序（如销量 * 0.6 + 好评率 * 0.4）。可以在应用层计算综合分数后写入 ZSet。

java

public void updateComprehensiveScore(String productId, double sales, double rating) {

double score = sales * 0.6 + rating * 0.4;

redisTemplate.opsForZSet().add("product:rank", productId, score);

}

---

## 五、排行榜的分页查询

java

public List<String> getRankingPage(int page, int size) {

long start = (long) (page - 1) * size;

long end = start + size - 1;

Set<String> set = redisTemplate.opsForZSet()

.reverseRange("leaderboard", start, end);

return new ArrayList<>(set);

}

---

## 六、性能优化

- **ZSet 的 skiplist 编码**：当元素较多时，插入和查询都是 O(log N)。
- **避免全量查询**：使用 `reverseRange` 限制返回数量。
- **冷热数据分离**：对于百万级排行榜，可以只缓存前 1000 名，其余从数据库查询。
- **使用 Pipeline**：批量更新分数时使用 Pipeline 提升性能。

---

## 七、在苍穹外卖中的应用

- **菜品销量排行**：统计一段时间内销量最高的菜品，用于“热销榜”展示。
- **商家销售排行**：管理端查看各商家的销售额排名。

---

## 小结

- ZSet 是实现排行榜的最佳选择，支持排序、范围查询、排名获取。
- 注意周榜/月榜的 key 设计和过期策略。
- 对于大规模排行榜，考虑只缓存头部数据。