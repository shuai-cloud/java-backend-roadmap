#!/bin/bash
#
# demo.sh - Linux 文件系统命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh
#

set -euo pipefail

echo "============================================"
echo "  Linux Filesystem Commands Demo"
echo "  场景：磁盘空间查看、文件系统信息、挂载管理"
echo "============================================"

# ---------- 1. 创建临时工作目录和文件 ----------
WORKDIR="/tmp/filesystem_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo -e "\n[1] 创建测试文件"
dd if=/dev/zero of=testfile bs=1M count=50 2>/dev/null
echo "  已创建 50MB 的测试文件 testfile"

# ---------- 2. 使用 df 查看磁盘空间 ----------
echo -e "\n[2] 使用 df -h 查看文件系统磁盘使用情况（仅显示 / 和 /tmp）"
df -h / /tmp 2>/dev/null || df -h /

# ---------- 3. 使用 du 查看目录大小 ----------
echo -e "\n[3] 使用 du -sh 查看当前目录总大小"
du -sh "$WORKDIR"

# ---------- 4. 使用 lsblk 查看块设备 ----------
echo -e "\n[4] 使用 lsblk -f 查看块设备（仅显示前5行）"
lsblk -f 2>/dev/null | head -6 || echo "  lsblk 不可用"

# ---------- 5. 使用 blkid 查看 UUID（需要 root 或特定权限） ----------
echo -e "\n[5] 尝试查看根分区的 UUID"
blkid -s UUID "$(df / --output=source | tail -1)" 2>/dev/null || echo "  权限不足或 blkid 不可用"

# ---------- 6. 使用 stat 查看文件 inode ----------
echo -e "\n[6] 使用 stat 查看 testfile 的 inode 信息"
stat testfile | head -10

# ---------- 7. 使用 file 判断文件类型 ----------
echo -e "\n[7] 使用 file 判断 testfile 类型"
file testfile

# ---------- 8. 使用 df -i 查看 inode 使用 ----------
echo -e "\n[8] 使用 df -i 查看根分区的 inode 使用情况"
df -i / | tail -1

# ---------- 9. 模拟磁盘满场景 ----------
echo -e "\n[9] 模拟磁盘满：创建一个大文件填满 /tmp（如果空间允许）"
AVAIL=$(df /tmp --output=avail | tail -1)
if [ "$AVAIL" -gt 200000 ]; then
    dd if=/dev/zero of=bigfile bs=1M count=150 2>/dev/null && echo "  已创建 bigfile，现在 /tmp 使用率上升"
else
    echo "  /tmp 可用空间不足 200MB，跳过此步骤"
fi

# ---------- 10. 清理 ----------
echo -e "\n[10] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"