#!/bin/bash
#
# demo.sh - 日志分析命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh
#

set -euo pipefail

echo "============================================"
echo "  Log Analysis Demo"
echo "  场景：日志搜索、统计、提取、实时监控"
echo "============================================"

# ---------- 1. 生成模拟日志文件 ----------
WORKDIR="/tmp/log_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo -e "\n[1] 生成模拟应用日志"
cat > app.log <<'EOF'
2025-03-15 10:00:01 INFO  Application started successfully
2025-03-15 10:00:02 DEBUG Loading configuration from /etc/app/config.yml
2025-03-15 10:00:03 WARN  Connection pool exhausted, retrying in 1s
2025-03-15 10:00:04 ERROR Timeout connecting to database after 30000ms
2025-03-15 10:00:05 INFO  Retry attempt 1
2025-03-15 10:00:06 ERROR Database connection failed: Connection refused
2025-03-15 10:00:07 FATAL Application crashed due to DB error
2025-03-15 10:01:01 INFO  Application restarted
2025-03-15 10:01:02 INFO  Health check passed
2025-03-15 10:01:03 WARN  Memory usage above 85%
2025-03-15 10:01:04 ERROR NullPointerException at com.example.service.OrderService.getOrder(OrderService.java:45)
2025-03-15 10:01:05 ERROR Order processing failed for orderId=12345
2025-03-15 10:02:01 INFO  Scheduled task completed
EOF
echo "  已生成 app.log（14行）"

# ---------- 2. 生成模拟访问日志 ----------
cat > access.log <<'EOF'
192.168.1.1 - - [15/Mar/2025:10:00:01 +0800] "GET /api/users HTTP/1.1" 200 1024
10.0.0.2 - - [15/Mar/2025:10:00:02 +0800] "POST /api/order HTTP/1.1" 201 256
192.168.1.1 - - [15/Mar/2025:10:00:03 +0800] "GET /api/products HTTP/1.1" 200 2048
10.0.0.3 - - [15/Mar/2025:10:00:04 +0800] "GET /api/users HTTP/1.1" 200 512
192.168.1.1 - - [15/Mar/2025:10:01:01 +0800] "POST /api/login HTTP/1.1" 401 128
10.0.0.2 - - [15/Mar/2025:10:01:02 +0800] "GET /api/orders HTTP/1.1" 200 4096
EOF
echo "  已生成 access.log（6行）"

# ---------- 3. 基本搜索 ----------
echo -e "\n[2] 使用 grep 搜索 ERROR"
grep "ERROR" app.log

# ---------- 4. 计数 ----------
echo -e "\n[3] 统计各日志级别数量"
awk '{count[$3]++} END {for(k in count) print k, count[k]}' app.log

# ---------- 5. 显示上下文 ----------
echo -e "\n[4] 显示 NullPointerException 的前后2行"
grep -B 2 -A 2 "NullPointerException" app.log

# ---------- 6. 提取字段 ----------
echo -e "\n[5] 提取访问日志中的 IP 和 URL"
awk '{print $1, $7}' access.log

# ---------- 7. 统计 IP 访问次数 ----------
echo -e "\n[6] 统计 IP 访问次数（降序）"
awk '{print $1}' access.log | sort | uniq -c | sort -rn

# ---------- 8. 实时监控模拟 ----------
echo -e "\n[7] 模拟 tail -f 并过滤 ERROR（显示2秒后自动停止）"
timeout 2 tail -f app.log | grep --color=always "ERROR" || true

# ---------- 9. 使用 sed 脱敏 ----------
echo -e "\n[8] 使用 sed 脱敏 orderId"
sed 's/orderId=[0-9]*/orderId=****/g' app.log | grep "orderId"

# ---------- 10. 统计每小时错误数 ----------
echo -e "\n[9] 统计每小时的 ERROR 数量"
awk '/ERROR/ {hour=substr($2,1,2); count[hour]++} END {for(h in count) print h":00", count[h]}' app.log

# ---------- 11. 清理 ----------
echo -e "\n[10] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"