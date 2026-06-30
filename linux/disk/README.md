# Disk 💾

> Linux disk management for Java backend engineers.  
> Java 后端工程师必备的磁盘管理知识。

---

## 📖 Overview · 概览

This section covers Linux disk management: partitioning, formatting, mounting, LVM, and troubleshooting. Understanding disk management is crucial for adding storage, resizing volumes, diagnosing disk failures, and optimizing I/O performance.

本章涵盖 Linux 磁盘管理：分区、格式化、挂载、LVM 和故障排查。理解磁盘管理对于添加存储、扩容卷、诊断磁盘故障和优化 I/O 性能至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Disk Partitioning · 磁盘分区

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `fdisk` | Manipulate disk partition table (MBR) · 管理 MBR 分区表 | `-l` 列出分区表；`/dev/sda` 进入交互模式（`n`新建，`d`删除，`w`保存） |
| `parted` | Advanced partition tool (supports GPT) · 高级分区工具（支持 GPT） | `-l` 列出设备；`mklabel gpt` 创建 GPT 标签；`mkpart primary ext4 1MiB 100%` 创建分区 |
| `lsblk` | List block devices · 列出块设备 | `-f` 显示文件系统信息；`-o NAME,SIZE,TYPE,MOUNTPOINT` 自定义输出列 |
| `blkid` | Locate/print block device attributes · 查看块设备的 UUID 和文件系统类型 | `-s UUID` 只显示 UUID；`-o value` 只输出值 |

**注意事项**：
- `fdisk` 适用于 MBR 分区表（最大支持 2TB 磁盘），`parted` 适用于 GPT（支持更大磁盘）。
- 分区操作前务必使用 `lsblk` 确认设备名称，避免误操作。

---

### 2️⃣ Creating File Systems · 创建文件系统

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `mkfs.ext4` | Create ext4 file system · 创建 ext4 文件系统 | `-L label` 设置卷标；`-m 1` 预留块百分比（默认5%） |
| `mkfs.xfs` | Create XFS file system · 创建 XFS 文件系统 | `-L label` 设置卷标；`-f` 强制覆盖已有文件系统 |
| `mkfs` | Generic file system creation · 通用文件系统创建 | `-t ext4` 指定类型 |

**注意事项**：
- ext4 适合通用场景，XFS 适合大文件和高并发场景。
- 创建文件系统会清空分区上的所有数据，务必确认。

---

### 3️⃣ Mounting & Unmounting · 挂载与卸载

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `mount` | Mount a file system · 挂载文件系统 | `-t ext4` 指定类型；`-o ro` 只读；`-o remount,rw` 重新挂载为读写；`-a` 挂载 `/etc/fstab` 中所有条目 |
| `umount` | Unmount a file system · 卸载文件系统 | `-l` 懒惰卸载；`-f` 强制卸载 |
| `findmnt` | Find mounted file systems · 查找已挂载的文件系统 | `-t ext4` 按类型过滤；`-l` 列表格式 |

**`/etc/fstab` 文件格式**：

UUID=xxxx  /mount/point  ext4  defaults  0  2

设备UUID    挂载点       类型   选项       dump  fsck顺序

**注意事项**：
- 修改 `/etc/fstab` 后执行 `mount -a` 测试是否正确，避免重启后无法挂载。
- 卸载时若提示 `device is busy`，使用 `lsof /mount/point` 找出占用进程。

---

### 4️⃣ LVM (Logical Volume Manager) · 逻辑卷管理

LVM 提供了灵活的磁盘管理能力，允许在线扩容、快照等。

| Component | Description · 说明 | Commands |
|-----------|--------------------|----------|
| Physical Volume (PV) | 物理卷（磁盘或分区） | `pvcreate /dev/sdb1`；`pvs` 查看；`pvdisplay` 详细信息 |
| Volume Group (VG) | 卷组（多个 PV 组成） | `vgcreate vg_data /dev/sdb1 /dev/sdc1`；`vgs` 查看；`vgdisplay` |
| Logical Volume (LV) | 逻辑卷（从 VG 分配） | `lvcreate -L 10G -n lv_data vg_data`；`lvs` 查看；`lvdisplay` |

**常用操作**：

bash

创建 LVM

pvcreate /dev/sdb1

vgcreate vg_data /dev/sdb1

lvcreate -L 10G -n lv_data vg_data

mkfs.ext4 /dev/vg_data/lv_data

mount /dev/vg_data/lv_data /mnt/data

扩容逻辑卷（在线）

lvextend -L +5G /dev/vg_data/lv_data

resize2fs /dev/vg_data/lv_data    # ext4

xfs_growfs /mnt/data              # XFS

缩小逻辑卷（需先卸载，ext4 支持）

umount /mnt/data

e2fsck -f /dev/vg_data/lv_data

resize2fs /dev/vg_data/lv_data 10G

lvreduce -L 10G /dev/vg_data/lv_data

mount /dev/vg_data/lv_data /mnt/data

**注意事项**：
- XFS 文件系统不支持缩小，只能扩容。
- 扩容后必须执行 `resize2fs` 或 `xfs_growfs` 使文件系统识别新空间。

---

### 5️⃣ Disk Performance · 磁盘性能

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `iostat` | CPU and I/O statistics · CPU 和 I/O 统计 | `-x` 扩展显示（await, svctm, %util）；`-d` 只显示磁盘；`1 5` 每秒采样 |
| `iotop` | Per-process I/O usage · 每个进程的 I/O 使用 | `-o` 只显示有 I/O 的进程；`-P` 只显示进程 |
| `hdparm` | Get/set hard disk parameters · 获取/设置硬盘参数 | `-t` 测试读取速度；`-T` 测试缓存速度；`-I` 显示硬盘信息 |

---

### 6️⃣ Disk Failure Diagnosis · 磁盘故障排查

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `smartctl` | SMART monitoring tool · SMART 监控工具 | `-a /dev/sda` 显示所有 SMART 信息；`-H` 快速健康检查；`-t short` 执行短测试 |
| `badblocks` | Search for bad blocks · 扫描坏道 | `-s` 显示进度；`-v` 详细输出；`-w` 破坏性写入测试 |
| `dmesg` | Kernel ring buffer · 内核环形缓冲区 | `-T` 人类可读时间；`grep -i "error\|fail\|bad"` 过滤错误 |

**SMART 关键指标**：
- `Reallocated_Sector_Ct`：已重映射的扇区数（大于0表示磁盘可能有坏道）。
- `Pending_Sector_Ct`：待重映射的扇区数。
- `UDMA_CRC_Error_Ct`：数据传输错误计数（可能表示线缆问题）。

---

## 🚀 Quick Reference · 速查示例

bash

查看所有磁盘和分区

lsblk -f

查看磁盘使用情况

df -h

查看磁盘 UUID

blkid

创建分区并格式化

sudo fdisk /dev/sdb    # 创建分区

sudo mkfs.ext4 /dev/sdb1

挂载分区

sudo mount /dev/sdb1 /mnt/data

设置开机自动挂载（编辑 /etc/fstab）

echo "UUID=$(blkid -s UUID -o value /dev/sdb1) /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab

查看磁盘健康状态

sudo smartctl -H /dev/sda

查看磁盘性能

iostat -x 1 5

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 磁盘管理相关的命令，涵盖分区、格式化、挂载、LVM、性能监控和故障排查。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在虚拟机中添加虚拟磁盘进行练习，熟悉 LVM 的扩容操作。

---

*Disk is where your data lives. Manage it wisely.* 💿