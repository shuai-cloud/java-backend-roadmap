#!/bin/bash
#
# demo.sh - 磁盘管理命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Disk Management Demo"
echo "  场景：磁盘查看、分区、挂载、LVM、健康检查"
echo "============================================"

# ---------- 1. 查看块设备 ----------
echo -e "\n[1] 使用 lsblk 查看所有块设备"
lsblk -f 2>/dev/null | head -15 || echo "  lsblk 不可用"

# ---------- 2. 查看磁盘使用情况 ----------
echo -e "\n[2] 使用 df -h 查看磁盘使用"
df -h | head -10

# ---------- 3. 查看磁盘 UUID ----------
echo -e "\n[3] 使用 blkid 查看磁盘 UUID（仅显示前3行）"
blkid 2>/dev/null | head -3 || echo "  blkid 不可用或权限不足"

# ---------- 4. 查看 /etc/fstab ----------
echo -e "\n[4] 查看 /etc/fstab 挂载配置"
cat /etc/fstab 2>/dev/null | grep -v "^#" | grep -v "^$" | head -10 || echo "  无法读取"

# ---------- 5. 查看磁盘分区表 ----------
echo -e "\n[5] 使用 fdisk -l 查看分区表（仅显示前10行）"
sudo fdisk -l 2>/dev/null | head -10 || echo "  fdisk 不可用或权限不足"

# ---------- 6. 查看 LVM 状态（如果存在） ----------
echo -e "\n[6] 查看 LVM 状态"
if command -v lvs &>/dev/null; then
    echo "  物理卷:"
    sudo pvs 2>/dev/null || echo "  无物理卷"
    echo "  卷组:"
    sudo vgs 2>/dev/null || echo "  无卷组"
    echo "  逻辑卷:"
    sudo lvs 2>/dev/null || echo "  无逻辑卷"
else
    echo "  LVM 未安装"
fi

# ---------- 7. 查看磁盘健康状态 ----------
echo -e "\n[7] 使用 smartctl 检查磁盘健康（仅第一个磁盘）"
FIRST_DISK=$(lsblk -ndo NAME 2>/dev/null | head -1)
if [ -n "$FIRST_DISK" ]; then
    sudo smartctl -H "/dev/$FIRST_DISK" 2>/dev/null | grep -E "SMART overall-health|SMART Health Status" || echo "  smartctl 不可用或不支持"
else
    echo "  未找到磁盘"
fi

# ---------- 8. 查看磁盘性能（iostat） ----------
echo -e "\n[8] 使用 iostat 查看磁盘性能（采样1次）"
if command -v iostat &>/dev/null; then
    iostat -x 1 1 2>/dev/null | tail -10
else
    echo "  iostat 未安装（属于 sysstat 包）"
fi

# ---------- 9. 模拟创建测试文件系统（不实际执行） ----------
echo -e "\n[9] 模拟磁盘操作（不实际执行）"
echo "  创建分区: sudo fdisk /dev/sdb"
echo "  格式化: sudo mkfs.ext4 /dev/sdb1"
echo "  挂载: sudo mount /dev/sdb1 /mnt/data"
echo "  设置开机挂载: 编辑 /etc/fstab 添加 UUID=... /mnt/data ext4 defaults 0 2"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"