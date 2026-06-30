#!/bin/bash
#
# demo.sh - Linux 进程管理命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh
#

set -euo pipefail

echo "============================================"
echo "  Linux Process Commands Demo"
echo "  场景：进程查看、控制、后台作业、资源分析"
echo "============================================"

# ---------- 1. 创建临时工作目录 ----------
WORKDIR="/tmp/process_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ---------- 2. 使用 ps 查看进程 ----------
echo -e "\n[1] 使用 ps aux 查看当前所有进程（仅显示前5行）"
ps aux | head -6

# ---------- 3. 使用 pgrep 查找进程 ----------
echo -e "\n[2] 使用 pgrep 查找 sshd 进程"
pgrep -l sshd 2>/dev/null || echo "  sshd 进程未运行"

# ---------- 4. 使用 pstree 查看进程树 ----------
echo -e "\n[3] 使用 pstree 查看进程树（仅显示前10行）"
pstree -p 2>/dev/null | head -10 || echo "  pstree 不可用"

# ---------- 5. 启动一个后台进程模拟 ----------
echo -e "\n[4] 启动一个后台 sleep 进程模拟长时间运行的任务"
sleep 120 &
BG_PID=$!
echo "  后台进程 PID: $BG_PID"

# ---------- 6. 使用 jobs 查看后台作业 ----------
echo -e "\n[5] 使用 jobs 查看后台作业"
jobs -l

# ---------- 7. 使用 top 查看进程（非交互，快照模式） ----------
echo -e "\n[6] 使用 top -b -n1 获取一次快照（仅显示前5行）"
top -b -n1 -p $BG_PID 2>/dev/null | head -7 || echo "  top 不可用"

# ---------- 8. 使用 kill 发送信号 ----------
echo -e "\n[7] 使用 kill -15 优雅终止后台进程"
kill -15 $BG_PID 2>/dev/null || true
sleep 1
# 检查进程是否还在
if ps -p $BG_PID > /dev/null 2>&1; then
    echo "  进程仍在运行，使用 kill -9 强制终止"
    kill -9 $BG_PID 2>/dev/null || true
else
    echo "  进程已优雅终止"
fi

# ---------- 9. 使用 lsof 查看端口占用 ----------
echo -e "\n[8] 使用 lsof 查看 22 端口（SSH）占用情况"
lsof -i :22 2>/dev/null | head -3 || echo "  权限不足或无 lsof"

# ---------- 10. 使用 nohup 模拟后台运行 ----------
echo -e "\n[9] 使用 nohup 启动一个后台任务"
nohup sleep 60 > /dev/null 2>&1 &
NOHUP_PID=$!
echo "  nohup 进程 PID: $NOHUP_PID"
# 立即终止
kill $NOHUP_PID 2>/dev/null || true

# ---------- 11. 使用 pidstat 查看进程统计（如果可用） ----------
echo -e "\n[10] 尝试使用 pidstat 查看当前 shell 的进程统计"
if command -v pidstat &>/dev/null; then
    pidstat -u -r -p $$ 1 1 2>/dev/null || echo "  pidstat 执行失败"
else
    echo "  pidstat 未安装（属于 sysstat 包）"
fi

# ---------- 12. 清理 ----------
echo -e "\n[11] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"