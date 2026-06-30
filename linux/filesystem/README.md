# Filesystem 📂

> Linux file system management for Java backend engineers.  
> Java 后端工程师必备的文件系统管理知识。

---

## 📖 Overview · 概览

This section covers Linux file system concepts and commands you'll use daily: checking disk space, managing mounts, understanding inodes, and handling partitions. These skills are essential for diagnosing disk-full issues, mounting storage, and understanding how your application interacts with the underlying file system.

本章涵盖日常工作中常用的 Linux 文件系统概念和命令：检查磁盘空间、管理挂载、理解 inode、处理分区。这些技能对于排查磁盘满问题、挂载存储、理解应用与底层文件系统的交互至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Disk Space Usage · 磁盘空间查看

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `df` | Report file system disk space usage · 报告文件系统磁盘空间使用情况 | `-h` 人类可读（GB/MB）；`-T` 显示文件系统类型；`-i` 显示 inode 使用情况；`--total` 总计 |
| `du` | Estimate file/directory space usage · 估算文件或目录的磁盘使用量 | `-h` 人类可读；`-s` 只显示总计；`-c` 显示总和；`--max-depth=N` 限制目录深度；`-a` 显示所有文件 |

**注意事项**：
- `df -h` 是最常用的命令，用于快速查看各分区剩余空间。
- `du -sh *` 查看当前目录下每个子目录的大小，常用于找出大文件。
- `du` 扫描所有文件，对大目录耗时较长，可先用 `ncdu` 替代（需安装）。

---

### 2️⃣ File System Information · 文件系统信息

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `lsblk` | List block devices · 列出块设备（磁盘和分区） | `-f` 显示文件系统信息；`-o NAME,SIZE,TYPE,MOUNTPOINT` 自定义输出列；`-a` 显示空设备 |
| `blkid` | Locate/print block device attributes · 查看块设备的 UUID 和文件系统类型 | `-s UUID` 只显示 UUID；`-o value` 只输出值 |
| `file` | Determine file type · 判断文件类型 | `-s` 对特殊文件（如设备）也读取；`-b` 简洁输出 |

**注意事项**：
- `lsblk -f` 可以一次性看到磁盘分区、文件系统类型、UUID 和挂载点，非常实用。
- `blkid` 输出的 UUID 用于 `/etc/fstab` 挂载配置。

---

### 3️⃣ Mount Management · 挂载管理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `mount` | Mount a file system · 挂载文件系统 | `-t ext4` 指定文件系统类型；`-o ro` 只读挂载；`-o remount,rw` 重新挂载为读写；`-a` 挂载 `/etc/fstab` 中所有条目 |
| `umount` | Unmount a file system · 卸载文件系统 | `-l` 懒惰卸载（等待不再使用）；`-f` 强制卸载 |
| `findmnt` | Find mounted file systems · 查找已挂载的文件系统 | `-t ext4` 按类型过滤；`-l` 列表格式；`-D` 显示 df 风格 |

**注意事项**：
- `mount` 不带参数显示当前所有挂载点。
- 卸载时若提示 `device is busy`，可使用 `lsof /path` 找出占用进程。
- 修改 `/etc/fstab` 后执行 `mount -a` 测试是否正确。

---

### 4️⃣ Partition Management · 磁盘分区

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `fdisk` | Manipulate disk partition table · 管理磁盘分区表 | `-l` 列出分区表；`/dev/sda` 进入交互模式（`n`新建，`d`删除，`w`保存） |
| `parted` | Advanced partition tool · 高级分区工具 | `-l` 列出设备；`mklabel gpt` 创建 GPT 标签；`mkpart primary ext4 1MiB 100%` 创建分区 |
| `mkfs` | Build a file system on a device · 在设备上创建文件系统 | `mkfs.ext4 /dev/sdb1` 格式化为 ext4；`-L label` 设置卷标；`-n` 不真正执行 |

**注意事项**：
- 分区操作风险极高，务必确认设备正确（`lsblk` 先查看）。
- 生产环境中通常使用 LVM 或云盘动态扩容，较少手动分区。

---

### 5️⃣ File System Check · 文件系统检查

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `fsck` | Check and repair a file system · 检查和修复文件系统 | `-a` 自动修复；`-y` 对所有问题回答 yes；`-f` 强制检查（即使标记为干净）；`-t ext4` 指定类型 |
| `tune2fs` | Adjust tunable file system parameters · 调整 ext2/ext3/ext4 文件系统参数 | `-l` 显示超级块信息；`-c 30` 设置最大挂载次数；`-i 7d` 设置检查间隔 |

**注意事项**：
- `fsck` 必须在 **卸载** 状态下执行，否则可能损坏文件系统。
- 日常运维中很少手动执行 fsck，系统会在启动时自动检查。

---

### 6️⃣ Special File Systems · 特殊文件系统

| Path | Description · 说明 |
|------|--------------------|
| `/proc` | Virtual file system exposing kernel and process info · 虚拟文件系统，暴露内核和进程信息（如 `/proc/cpuinfo`、`/proc/meminfo`） |
| `/sys` | Virtual file system for hardware/device info · 硬件和设备信息（如 `/sys/block`） |
| `tmpfs` | Temporary file system stored in RAM · 存储在内存中的临时文件系统（如 `/tmp`、`/dev/shm`） |

**注意事项**：
- `/proc` 和 `/sys` 是伪文件系统，不占用磁盘空间。
- `tmpfs` 重启后数据丢失，不适合存放持久数据。

---

### 7️⃣ Inode & Links · inode 与链接

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `stat` | Display file or file system status · 显示文件或文件系统状态 | `-c '%i'` 只显示 inode 编号；`-f` 显示文件系统信息 |
| `ls -i` | List files with inode numbers · 列出文件并显示 inode 编号 | `-i` 显示 inode；`-l` 长格式 |
| `df -i` | Report inode usage · 报告 inode 使用情况 | 同 `df -i` |

**注意事项**：
- inode 耗尽也会导致无法创建新文件（即使磁盘有空闲），`df -i` 可查看。
- 硬链接共享同一个 inode，软链接有自己的 inode。

---

## 🚀 Quick Reference · 速查示例

bash

查看所有挂载点的磁盘使用情况（人类可读）

df -h

查看 inode 使用情况

df -i

查看当前目录下各子目录大小（只显示一级）

du -h --max-depth=1

列出块设备和文件系统类型

lsblk -f

查看 /data 目录所在分区的 UUID

blkid -s UUID $(df /data --output=source | tail -1)

挂载一个新磁盘到 /mnt/data

sudo mount /dev/sdb1 /mnt/data

卸载

sudo umount /mnt/data

查看文件类型

file /etc/passwd

查看文件的 inode 信息

stat /etc/hosts

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 文件系统相关的常用命令，涵盖磁盘空间查看、挂载管理、分区操作、inode 概念等。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议结合实际服务器操作练习，熟悉这些命令能帮助你快速定位磁盘问题和管理存储。

---

*Know your filesystem, know your server.* 🗄️