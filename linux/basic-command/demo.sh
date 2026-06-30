#!/bin/bash
#
# demo.sh - 日常 Linux 基础命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh
#

set -euo pipefail   # 安全模式：出错即停、未定义变量报错、管道检测失败

echo "============================================"
echo "  Linux Basic Commands Demo"
echo "  场景：Java 后端日常开发与排障"
echo "============================================"

# ---------- 1. 创建临时工作目录 ----------
WORKDIR="/tmp/java_backend_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"
echo -e "\n[1] 工作目录: $(pwd)"

# ---------- 2. 模拟生成应用日志 ----------
LOG_FILE="app.log"
cat > "$LOG_FILE" <<EOF
2025-03-15 10:00:01 INFO  Starting application...
2025-03-15 10:00:02 DEBUG Loading configuration
2025-03-15 10:00:03 WARN  Connection pool exhausted, retrying...
2025-03-15 10:00:04 ERROR Timeout connecting to database
2025-03-15 10:00:05 INFO  Retry attempt 1
2025-03-15 10:00:06 ERROR Database connection failed
2025-03-15 10:00:07 FATAL Application crashed due to DB error
EOF
echo -e "\n[2] 生成示例日志文件: $LOG_FILE"
cat "$LOG_FILE"

# ---------- 3. 使用 grep 统计错误级别 ----------
echo -e "\n[3] 统计日志中各等级出现次数:"
grep -oE '\b(INFO|DEBUG|WARN|ERROR|FATAL)\b' "$LOG_FILE" | sort | uniq -c

# ---------- 4. 使用 awk 提取时间戳和消息 ----------
echo -e "\n[4] 提取时间和消息（前3行）:"
awk '{print $1, $2, $NF}' "$LOG_FILE" | head -3

# ---------- 5. 使用 sed 替换敏感信息 ----------
echo -e "\n[5] 将日志中的 'database' 替换为 '[REDACTED]':"
sed -i 's/database/[REDACTED]/gi' "$LOG_FILE"
cat "$LOG_FILE"

# ---------- 6. 使用 find 查找大文件 ----------
echo -e "\n[6] 查找 /var/log 下最近7天修改过的 .log 文件（最多5个）:"
find /var/log -name "*.log" -type f -mtime -7 2>/dev/null | head -5 || echo "  未找到符合条件的文件"

# ---------- 7. 使用 tail -f 模拟实时监控（只运行2秒） ----------
echo -e "\n[7] 模拟 tail -f 实时监控日志（2秒后自动停止）:"
timeout 2 tail -f "$LOG_FILE" || true

# ---------- 8. 使用 sort 和 uniq 分析 IP 访问 ----------
ACCESS_LOG="access.log"
cat > "$ACCESS_LOG" <<EOF
192.168.1.1 GET /api/users
10.0.0.2 POST /api/order
192.168.1.1 GET /api/products
10.0.0.3 GET /api/users
192.168.1.1 POST /api/login
EOF
echo -e "\n[8] 统计 IP 访问次数（降序）:"
awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -rn

# ---------- 9. 使用 cut 提取 URL 路径 ----------
echo -e "\n[9] 提取所有请求路径:"
cut -d' ' -f2 "$ACCESS_LOG"

# ---------- 10. 使用 tee 同时输出到文件和屏幕 ----------
echo -e "\n[10] 使用 tee 保存命令输出:"
echo "Current user: $(whoami)" | tee system_info.txt
echo "Hostname: $(hostname)" | tee -a system_info.txt
echo "Uptime: $(uptime -p)" | tee -a system_info.txt

# ---------- 11. 使用 alias 简化命令 ----------
echo -e "\n[11] 临时创建别名并测试:"
alias ll='ls -lh'
ll "$WORKDIR"

# ---------- 12. 使用 ln 创建软链接 ----------
echo -e "\n[12] 创建日志文件的软链接:"
ln -sf "$WORKDIR/$LOG_FILE" /tmp/latest_app.log
ls -la /tmp/latest_app.log

# ---------- 13. 清理临时文件 ----------
echo -e "\n[13] 清理临时文件..."
rm -rf "$WORKDIR" /tmp/latest_app.log

echo -e "\n============================================"
echo "  演示完成！所有命令均已成功运行。"
echo "  更多详情请参考 README.md 和各子目录。"
echo "============================================"