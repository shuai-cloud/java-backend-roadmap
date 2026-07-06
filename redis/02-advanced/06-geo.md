# Redis GEO：地理位置功能

Redis GEO 是 Redis 3.2 引入的特性，用于存储地理位置信息，并支持距离计算、范围查询等操作。底层基于 ZSet 数据结构实现。

---

## 一、核心命令

| 命令 | 作用 |
|------|------|
| `GEOADD key longitude latitude member [longitude latitude member...]` | 添加地理坐标 |
| `GEOPOS key member [member...]` | 获取一个或多个成员的坐标 |
| `GEODIST key member1 member2 [unit]` | 计算两个成员之间的距离 |
| `GEORADIUS key longitude latitude radius unit [WITHCOORD] [WITHDIST] [WITHHASH] [COUNT count] [ASC\|DESC]` | 查找给定经纬度半径内的成员 |
| `GEORADIUSBYMEMBER key member radius unit [...]` | 以某个成员为中心查找半径内的成员 |
| `GEOHASH key member [member...]` | 获取成员的 Geohash 字符串 |
| `ZREM key member` | 删除地理位置（底层是 ZSet） |

**unit 可选值**：m（米）、km（千米）、mi（英里）、ft（英尺）。

---

## 二、基本使用示例

### 添加位置

bash

添加北京和上海的位置

127.0.0.1:6379> GEOADD cities 116.397 39.908 "Beijing" 121.473 31.230 "Shanghai"

(integer) 2

### 获取坐标

bash

127.0.0.1:6379> GEOPOS cities Beijing Shanghai

"116.39700257778168"

"39.90800048828125"

"121.47300106287003"

"31.229999542236328"

### 计算距离

bash

北京到上海的距离（公里）

127.0.0.1:6379> GEODIST cities Beijing Shanghai km

"1067.5579"

### 查找附近的人

bash

以北京为中心，半径 1100 公里内的城市，返回距离和坐标

127.0.0.1:6379> GEORADIUS cities 116.397 39.908 1100 km WITHDIST WITHCOORD ASC

"Beijing"

"0.3705"

"116.39700257778168"

"39.90800048828125"

"Shanghai"

"1067.1874"

"121.47300106287003"

"31.229999542236328"

### 以成员为中心查找

bash

以上海为中心，半径 500 公里内的城市

GEORADIUSBYMEMBER cities Shanghai 500 km

---

## 三、GEO 的实现原理

GEO 使用 **Geohash** 算法将二维经纬度编码为一维字符串，然后存储在 ZSet 中（score 是 Geohash 的整数值）。因此：
- ZSet 的 score 就是 Geohash 编码，可以按距离排序。
- 可以直接使用 ZSet 命令操作 GEO 数据（如 ZREM 删除、ZRANGE 遍历）。

**注意**：`GEORADIUS` 的精度受 Geohash 编码长度影响，默认使用 52 位编码，误差约 0.3 米。

---

## 四、应用场景

### 1. 附近的人 / 附近的商家

java

// 用户上传自己的位置

jedis.geoadd("users:location", lng, lat, userId);

// 查找附近 1 公里内的用户

List<GeoRadiusResponse> nearby = jedis.georadius("users:location", lng, lat, 1, GeoUnit.KM);

### 2. 外卖配送范围校验
苍穹外卖中使用百度地图 API 计算配送距离，也可以直接用 Redis GEO 实现：

java

// 商家位置添加到 GEO

jedis.geoadd("shops", shopLng, shopLat, shopId);

// 判断用户地址是否在商家配送范围内

double dist = jedis.geodist("shops", shopId, userAddressId, GeoUnit.KM);

if (dist <= deliveryRadius) {

// 可以配送

}

### 3. 打车/出行
乘客叫车时，查找附近 3 公里内的司机。

### 4. 打卡签到
公司考勤机位置预先录入，员工打卡时判断是否在范围内。

---

## 五、性能与限制

- **性能**：GEO 底层是 ZSet，范围查询时间复杂度 O(log(N)+M)，N 为元素总数，M 为结果数。
- **精度**：默认 52 位 Geohash，误差约 0.3 米，满足大部分业务需求。
- **数据量**：单个 ZSet 最多 2^32 - 1 个元素，实际受内存限制。
- **无法直接计算多边形区域**：GEO 只支持圆形范围查询。如果需要多边形区域（如不规则配送范围），需要使用其他方案（如百度地图 API）。

---

## 六、Java 集成示例（Jedis）

java

Jedis jedis = new Jedis("localhost", 6379);

// 添加位置

Map<String, GeoCoordinate> memberCoordMap = new HashMap<>();

memberCoordMap.put("Beijing", new GeoCoordinate(116.397, 39.908));

memberCoordMap.put("Shanghai", new GeoCoordinate(121.473, 31.230));

jedis.geoadd("cities", memberCoordMap);

// 计算距离

Double dist = jedis.geodist("cities", "Beijing", "Shanghai", GeoUnit.KM);

System.out.println("Distance: " + dist + " km");

// 查找附近

List<GeoRadiusResponse> radiusResponses = jedis.georadius(

"cities", 116.397, 39.908, 1100, GeoUnit.KM,

GeoRadiusParam.geoRadiusParam().withDist().withCoord().asc());

for (GeoRadiusResponse resp : radiusResponses) {

System.out.println(resp.getMemberByString() + ": " + resp.getDistance());

}

---

## 七、注意事项

1. **坐标精度**：经纬度通常保留 6 位小数（约 0.1 米精度）。
2. **删除成员**：使用 `ZREM key member` 而非专门的 GEO 命令。
3. **批量添加**：GEOADD 支持一次添加多个成员。
4. **与百度地图 API 的关系**：Redis GEO 适合简单的圆形范围查询，复杂的地理围栏（多边形、行政区域）仍需调用外部 API。

---

## 小结

- GEO 提供了便捷的地理位置存储和查询能力。
- 底层基于 ZSet，支持距离计算和圆形范围查询。
- 适用于“附近的人”、配送范围校验、位置打卡等场景。
- 在苍穹外卖中，可以用来替代部分百度地图 API 的调用，减少外部依赖和费用。