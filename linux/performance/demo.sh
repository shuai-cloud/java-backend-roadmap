#!/bin/bash
#
# demo.sh - Linux 性能监控命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Performance Monitoring Demo"
echo "  场景：CPU、内存、磁盘 I/O、网络、负载"
echo "============================================"

# ---------- 1. CPU 性能 ----------
echo -e "\n[1] 使用 top 获取一次快照（仅显示前5行）"
top -b -n1 2>/dev/null | head -6 || echo "  top 不可用"

echo -e "\n[2] 使用 mpstat 查看 CPU 核心统计（如果可用）"
if command -v mpstat &>/dev/null; then
    mpstat -P ALL 1 1 2>/dev/null | tail -6
else
    echo "  mpstat 未安装（属于 sysstat 包）"
fi

# ---------- 2. 内存性能 ----------
echo -e "\n[3] 使用 free -h 查看内存使用"
free -h

echo -e "\n[4] 使用 vmstat 查看虚拟内存统计（采样1次）"
vmstat 1 2 2>/dev/null | tail -2 || echo "  vmstat 不可用"

# ---------- 3. 磁盘 I/O ----------
echo -e "\n[5] 使用 iostat 查看磁盘 I/O（如果可用）"
if command -v iostat &>/dev/null; then
    iostat -x 1 1 2>/dev/null | tail -10
else
    echo "  iostat 未安装（属于 sysstat 包）"
fi

# ---------- 4. 网络性能 ----------
echo -e "\n[6] 使用 sar 查看网络接口统计（如果可用）"
if command -v sar &>/dev/null; then
    sar -n DEV 1 1 2>/dev/null | tail -6
else
    echo "  sar 未安装（属于 sysstat 包）"
fi

# ---------- 5. 系统负载 ----------
echo -e "\n[7] 使用 uptime 查看系统负载"
uptime

echo -e "\n[8] 使用 dmesg 查看最近的内核消息（仅显示最后3行）"
dmesg -T 2>/dev/null | tail -3 || echo "  dmesg 不可用"

# ---------- 6. 综合分析 ----------
echo -e "\n[9] 尝试使用 dstat（如果可用）"
if command -v dstat &>/dev/null; then
    dstat -tcyrdn 1 2 2>/dev/null || echo "  dstat 执行失败"
else
    echo "  dstat 未安装"
fi

# ---------- 7. 生成 CPU 负载模拟 ----------
echo -e "\n[10] 模拟 CPU 负载（运行3秒）"
dd if=/dev/zero of=/dev/null bs=1M count=1000 2>/dev/null &
LOAD_PID=$!
sleep 1
echo "  模拟进程 PID: $LOAD_PID"
echo "  使用 top 查看该进程的 CPU 使用:"
top -b -n1 -p $LOAD_PID 2>/dev/null | tail -2
kill $LOAD_PID 2>/dev/null || true
echo "  模拟结束"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"