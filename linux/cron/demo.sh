#!/bin/bash
#
# demo.sh - 定时任务命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Cron Demo"
echo "  场景：crontab 操作、时间表达式、任务管理"
echo "============================================"

# ---------- 1. 查看当前用户的 crontab ----------
echo -e "\n[1] 查看当前用户的 crontab（如果存在）"
if crontab -l 2>/dev/null; then
    echo "  当前用户有 crontab"
else
    echo "  当前用户没有 crontab"
fi

# ---------- 2. 创建一个临时 crontab 文件 ----------
echo -e "\n[2] 创建一个示例 crontab 文件"
WORKDIR="/tmp/cron_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

cat > mycron <<'EOF'
# 示例 crontab 文件
# 环境变量
PATH=/usr/local/bin:/usr/bin:/bin
MAILTO=""

# 每5分钟执行健康检查
*/5 * * * * /opt/scripts/healthcheck.sh > /var/log/healthcheck.log 2>&1

# 每天凌晨2点备份
0 2 * * * /opt/scripts/backup.sh > /var/log/backup.log 2>&1

# 每周日凌晨3点重启服务
0 3 * * 0 systemctl restart myapp

# 每月1号清理旧日志
0 4 1 * * find /var/log/myapp -name "*.log" -mtime +30 -delete

# 系统启动时运行
@reboot /opt/scripts/startup.sh
EOF
echo "  示例 crontab 已创建:"
cat mycron

# ---------- 3. 验证 crontab 语法 ----------
echo -e "\n[3] 验证 crontab 语法（使用临时文件）"
if crontab mycron 2>/dev/null; then
    echo "  语法正确，已安装临时 crontab"
    echo "  当前 crontab 内容:"
    crontab -l
else
    echo "  语法错误"
fi

# ---------- 4. 列出当前 crontab ----------
echo -e "\n[4] 再次列出 crontab"
crontab -l

# ---------- 5. 删除临时 crontab ----------
echo -e "\n[5] 删除临时 crontab"
crontab -r
echo "  crontab 已删除"

# ---------- 6. 查看系统级 cron 任务 ----------
echo -e "\n[6] 查看系统级 cron 任务（/etc/crontab）"
if [ -f /etc/crontab ]; then
    cat /etc/crontab | grep -v "^#" | grep -v "^$" | head -10
else
    echo "  /etc/crontab 不存在"
fi

# ---------- 7. 查看 cron 目录 ----------
echo -e "\n[7] 查看 cron 目录内容"
ls -la /etc/cron.d/ 2>/dev/null || echo "  /etc/cron.d 不存在"
ls -la /etc/cron.hourly/ 2>/dev/null || echo "  /etc/cron.hourly 不存在"
ls -la /etc/cron.daily/ 2>/dev/null || echo "  /etc/cron.daily 不存在"
ls -la /etc/cron.weekly/ 2>/dev/null || echo "  /etc/cron.weekly 不存在"
ls -la /etc/cron.monthly/ 2>/dev/null || echo "  /etc/cron.monthly 不存在"

# ---------- 8. 查看 cron 服务状态 ----------
echo -e "\n[8] 查看 cron 服务状态"
if systemctl is-active cron &>/dev/null; then
    systemctl status cron --no-pager | head -5
elif systemctl is-active crond &>/dev/null; then
    systemctl status crond --no-pager | head -5
else
    echo "  cron/crond 服务未运行"
fi

# ---------- 9. 清理 ----------
echo -e "\n[9] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"