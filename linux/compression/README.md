# Compression 📦

> Linux compression and archiving for Java backend engineers.  
> Java 后端工程师必备的压缩归档知识。

---

## 📖 Overview · 概览

This section covers Linux compression and archiving tools: creating and extracting archives, choosing the right compression algorithm, and transferring compressed data. These skills are essential for packaging deployments, archiving logs, and transferring files efficiently.

本章涵盖 Linux 压缩和归档工具：创建和解压归档文件、选择合适的压缩算法以及传输压缩数据。这些技能对于打包部署、归档日志和高效传输文件至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Tar · 归档工具

Tar 是 Linux 最常用的归档工具，通常与压缩算法配合使用。

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `tar -cvf archive.tar /path` | Create archive · 创建归档 | `-c` 创建；`-v` 显示详情；`-f` 指定文件名 |
| `tar -xvf archive.tar` | Extract archive · 解压归档 | `-x` 解压；`-v` 显示详情；`-f` 指定文件名 |
| `tar -tvf archive.tar` | List contents · 列出内容 | `-t` 列出；`-v` 显示详情；`-f` 指定文件名 |
| `tar -zcvf archive.tar.gz /path` | Create gzip-compressed archive · 创建 gzip 压缩归档 | `-z` 通过 gzip 过滤 |
| `tar -zxvf archive.tar.gz` | Extract gzip-compressed archive · 解压 gzip 压缩归档 | `-z` 通过 gzip 过滤 |
| `tar -jcvf archive.tar.bz2 /path` | Create bzip2-compressed archive · 创建 bzip2 压缩归档 | `-j` 通过 bzip2 过滤 |
| `tar -Jcvf archive.tar.xz /path` | Create xz-compressed archive · 创建 xz 压缩归档 | `-J` 通过 xz 过滤 |

**注意事项**：
- 压缩率：xz > bzip2 > gzip，但速度相反。
- 解压时 tar 会自动检测压缩格式（`tar -xf` 即可，无需指定 `-z`/`-j`/`-J`）。
- 常用组合：`tar -czf`（快速，兼容性好），`tar -cjf`（中等压缩），`tar -cJf`（高压缩）。

---

### 2️⃣ Gzip · 压缩工具

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `gzip file` | Compress file (replaces with .gz) · 压缩文件（替换为 .gz） | `-k` 保留原文件；`-r` 递归压缩目录；`-1` 最快压缩；`-9` 最高压缩 |
| `gunzip file.gz` | Decompress .gz file · 解压 .gz 文件 | `-k` 保留原文件；`-r` 递归 |
| `zcat file.gz` | View compressed file content · 查看压缩文件内容 | 相当于 `gunzip -c` |

**注意事项**：
- `gzip` 只能压缩单个文件，不能打包目录，通常与 `tar` 配合使用。
- 压缩级别 `-1` 到 `-9`，默认 `-6`。

---

### 3️⃣ Bzip2 · 压缩工具

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `bzip2 file` | Compress file (replaces with .bz2) · 压缩文件（替换为 .bz2） | `-k` 保留原文件；`-1` 最快；`-9` 最高压缩 |
| `bunzip2 file.bz2` | Decompress .bz2 file · 解压 .bz2 文件 | `-k` 保留原文件 |
| `bzcat file.bz2` | View compressed file content · 查看压缩文件内容 | 相当于 `bunzip2 -c` |

---

### 4️⃣ Xz · 压缩工具

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `xz file` | Compress file (replaces with .xz) · 压缩文件（替换为 .xz） | `-k` 保留原文件；`-1` 最快；`-9` 最高压缩；`-T 0` 使用所有 CPU 核心 |
| `unxz file.xz` | Decompress .xz file · 解压 .xz 文件 | `-k` 保留原文件 |
| `xzcat file.xz` | View compressed file content · 查看压缩文件内容 | 相当于 `unxz -c` |

---

### 5️⃣ Zip/Unzip · 跨平台压缩

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `zip archive.zip file1 file2` | Create zip archive · 创建 zip 压缩包 | `-r` 递归压缩目录；`-q` 安静模式；`-9` 最高压缩 |
| `unzip archive.zip` | Extract zip archive · 解压 zip 压缩包 | `-l` 列出内容不解压；`-d /path` 指定解压目录；`-o` 覆盖不提示 |

**注意事项**：
- Zip 是跨平台兼容性最好的格式，Windows 和 macOS 原生支持。
- 但 zip 的压缩率通常不如 tar+gzip。

---

### 6️⃣ Rsync · 远程同步（带压缩）

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `rsync -avz src/ user@host:/dest/` | Sync with compression · 带压缩的同步 | `-a` 归档模式（保留权限、时间等）；`-v` 详细；`-z` 传输时压缩；`--progress` 显示进度；`--delete` 删除目标端多余文件 |

**注意事项**：
- `rsync` 在传输过程中压缩数据，节省带宽，适合远程部署和备份。
- 使用 `-z` 选项在网络传输时压缩，但本地同步不需要。

---

## 🚀 Quick Reference · 速查示例

bash

创建 tar.gz 归档

tar -czf app-backup-20250315.tar.gz /opt/myapp/

解压 tar.gz

tar -xzf app-backup-20250315.tar.gz -C /tmp/restore/

查看归档内容

tar -tzf app-backup-20250315.tar.gz

压缩单个文件

gzip -k large-log.log

创建 zip 归档

zip -r deploy.zip /opt/myapp/

解压 zip

unzip deploy.zip -d /tmp/deploy/

远程同步并压缩

rsync -avz /opt/myapp/ user@backup-server:/backup/myapp/

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 压缩归档相关的命令，涵盖 tar、gzip、bzip2、xz、zip/unzip 和 rsync。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在部署脚本和日志归档中熟练使用 tar + gzip 的组合。

---

*Compress to save space, archive to stay organized.* 🗜️