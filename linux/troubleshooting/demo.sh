#!/bin/bash
#
# demo.sh - 线上问题排查场景模拟演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Troubleshooting Demo"
echo "  场景模拟：CPU 飙高、磁盘满、端口冲突"
echo "============================================"

WORKDIR="/tmp/troubleshoot_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ---------- 场景1：模拟 CPU 飙高 ----------
echo -e "\n[场景1] 模拟 CPU 飙高排查"
echo "  创建一个消耗 CPU 的进程..."
dd if=/dev/zero of=/dev/null bs=1M count=5000 2>/dev/null &
LOAD_PID=$!
sleep 1

echo "  步骤1: 使用 top 查看 CPU 最高的进程"
top -b -n1 -p $LOAD_PID 2>/dev/null | tail -2

echo "  步骤2: 查看该进程的线程 CPU 使用"
top -b -H -n1 -p $LOAD_PID 2>/dev/null | tail -2

echo "  步骤3: 使用 strace 查看系统调用（采样3秒）"
timeout 3 strace -p $LOAD_PID -c 2>&1 || echo "  strace 不可用"

kill $LOAD_PID 2>/dev/null || true
echo "  场景1 结束"

# ---------- 场景2：模拟磁盘满 ----------
echo -e "\n[场景2] 模拟磁盘满排查"
echo "  创建一个 20MB 的大文件..."
dd if=/dev/zero of=largefile.bin bs=1M count=20 2>/dev/null

echo "  步骤1: 使用 df -h 查看磁盘使用"
df -h "$WORKDIR" | tail -1

echo "  步骤2: 使用 du -sh 查看目录大小"
du -sh "$WORKDIR"

echo "  步骤3: 使用 find 查找大文件"
find "$WORKDIR" -type f -size +10M -exec ls -lh {} \;

rm -f largefile.bin
echo "  场景2 结束"

# ---------- 场景3：模拟端口冲突 ----------
echo -e "\n[场景3] 模拟端口冲突排查"
echo "  启动一个临时监听 9999 端口的进程..."
nc -l -p 9999 -w 30 &
NC_PID=$!
sleep 1

echo "  步骤1: 使用 ss -tlnp 查看端口监听"
ss -tlnp | grep :9999 || echo "  端口 9999 未被监听"

echo "  步骤2: 使用 lsof -i :9999 查看占用进程"
lsof -i :9999 2>/dev/null | head -3 || echo "  lsof 不可用"

kill $NC_PID 2>/dev/null || true
echo "  场景3 结束"

# ---------- 场景4：模拟 OOM（仅演示命令） ----------
echo -e "\n[场景4] OOM 排查命令演示（不实际触发 OOM）"
echo "  步骤1: free -h 查看内存"
free -h

echo "  步骤2: 查看 /proc/meminfo 关键字段"
grep -E "MemTotal|MemAvailable|SwapTotal" /proc/meminfo

echo "  步骤3: 如果有 Java 进程，可以使用 jmap -heap"
echo "  命令示例: jmap -heap <PID>"

# ---------- 清理 ----------
echo -e "\n[清理] 删除临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"