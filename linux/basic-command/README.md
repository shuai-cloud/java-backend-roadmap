# Basic Commands 📁

> Everyday Linux commands for Java backend developers.  
> Java 后端工程师日常最常用的 Linux 命令速查。

---

## 📖 Overview · 概览

This section covers the most frequently used Linux commands in daily development, troubleshooting, and automation. Each command is listed with its purpose and common options explained in both English and Chinese.

本章收录日常开发、排障和自动化中最常用的 Linux 命令。每条命令都附有 **中英文用途说明** 和 **常用选项的中文解释**，方便快速查阅。

> **Note**: Commands related to specific topics (process, network, permissions, compression, etc.) are covered in their respective directories. This page focuses on cross-cutting basics.

---

## 🗂️ Categories · 分类速查

### 1️⃣ File & Directory Operations · 文件与目录操作

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ls` | List directory contents · 列出目录内容 | `-l` 长格式显示（权限、大小、日期）；`-a` 显示隐藏文件；`-h` 人类可读大小；`-t` 按时间排序；`-r` 逆序；`-R` 递归子目录 |
| `cd` | Change directory · 切换目录 | `cd ~` 回家目录；`cd -` 回到上次目录；`cd ..` 上级目录 |
| `pwd` | Print working directory · 显示当前路径 | 无常用参数 |
| `cp` | Copy files/directories · 复制文件或目录 | `-r` 递归复制目录；`-i` 覆盖前提示；`-v` 显示详情；`-p` 保留属性 |
| `mv` | Move/rename files · 移动或重命名文件 | `-i` 覆盖前提示；`-v` 显示详情；`-u` 只移动更新的文件 |
| `rm` | Remove files/directories · 删除文件或目录 | `-r` 递归删除目录；`-f` 强制删除不提示；`-i` 逐个确认 |
| `mkdir` | Create directories · 创建目录 | `-p` 递归创建父目录 |
| `touch` | Create empty file or update timestamp · 创建空文件或更新时间戳 | 无常用参数 |
| `ln` | Create links · 创建链接 | `-s` 创建软链接（符号链接）；不加 `-s` 创建硬链接 |

**注意事项**：
- `rm -rf` 极其危险，务必确认路径。
- 软链接可以跨文件系统，硬链接不能跨分区。
- `cp -r` 复制目录时，源目录末尾有无 `/` 行为不同（有 `/` 则复制目录内容，无则复制目录本身）。

---

### 2️⃣ File Viewing & Browsing · 文件查看

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `cat` | Concatenate and display file · 连接并显示文件内容 | `-n` 显示行号；`-b` 仅对非空行编号；`-T` 显示制表符为 ^I |
| `less` | Page through file (supports scroll) · 分页浏览文件（支持上下滚动） | `-N` 显示行号；`-S` 单行显示（不换行，←→滚动）；`/pattern` 搜索；`q` 退出 |
| `head` | Display first lines · 显示文件头部 | `-n 10` 显示前10行（默认10）；`-c 100` 显示前100字节 |
| `tail` | Display last lines · 显示文件尾部 | `-n 20` 显示最后20行；`-f` 实时追加（跟踪日志）；`-F` 跟踪并处理文件轮转 |
| `nl` | Number lines · 给文件加行号 | `-ba` 对所有行编号（包括空行） |

**注意事项**：
- 查看大日志文件优先用 `less` 而不是 `cat`，避免刷屏。
- `tail -f` 是排查线上问题的利器，常配合 `grep` 过滤。

---

### 3️⃣ Text Processing · 文本处理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `grep` | Search text with patterns · 搜索文本（支持正则） | `-i` 忽略大小写；`-v` 反向匹配；`-c` 计数；`-n` 显示行号；`-r` 递归搜索；`-l` 只显示文件名；`-E` 扩展正则；`--color` 高亮 |
| `sed` | Stream editor for filtering/transforming · 流式编辑文本 | `s/old/new/g` 全局替换；`-i` 直接修改文件；`-n p` 打印指定行；`/pattern/d` 删除匹配行 |
| `awk` | Pattern scanning and processing language · 文本分析和处理语言 | `'{print $1,$NF}'` 打印第一列和最后一列；`-F,` 指定分隔符为逗号；`NR==5` 处理第5行；`{sum+=$1}END{print sum}` 求和 |
| `cut` | Cut out selected fields · 截取字段 | `-d:` 指定分隔符；`-f1,3` 取第1和第3字段；`-c1-5` 取字符范围 |
| `sort` | Sort lines · 排序 | `-n` 按数字排序；`-r` 降序；`-k2` 按第二列排序；`-t:` 指定分隔符 |
| `uniq` | Report or omit repeated lines · 报告或去除重复行 | `-c` 统计重复次数；`-d` 只显示重复行；`-u` 只显示唯一行 |
| `wc` | Word/line/character count · 统计字数、行数、字符数 | `-l` 行数；`-w` 单词数；`-c` 字节数；`-m` 字符数 |
| `tr` | Translate or delete characters · 替换或删除字符 | `'a-z' 'A-Z'` 小写转大写；`-d ':'` 删除冒号；`-s` 压缩连续重复字符 |
| `diff` | Compare files line by line · 逐行比较文件差异 | `-u` 统一格式（常用）；`-i` 忽略大小写；`-r` 递归比较目录 |

**注意事项**：
- `grep -E` 等价于 `egrep`，支持扩展正则。
- `sed -i` 直接修改原文件，建议先备份。
- `awk` 默认以空白分割，可用 `-F` 指定分隔符。
- `uniq` 只能去除连续的重复行，常与 `sort` 配合使用。

---

### 4️⃣ Finding Files & Commands · 查找

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `find` | Search for files in directory hierarchy · 在目录树中查找文件 | `-name "*.log"` 按名称；`-type f/d` 文件/目录；`-size +100M` 大于100MB；`-mtime -7` 7天内修改；`-exec {} \;` 对结果执行命令 |
| `locate` | Fast file search (uses database) · 快速查找文件（基于数据库） | `-i` 忽略大小写；`-c` 只计数 |
| `which` | Locate a command's executable path · 查找命令的可执行路径 | 无常用参数 |
| `whereis` | Locate binary, source, and manual pages · 查找二进制、源码和手册 | `-b` 只查二进制；`-m` 只查手册 |

**注意事项**：
- `find` 功能强大但速度较慢；`locate` 快但依赖数据库（需 `updatedb` 更新）。
- `which` 只返回 PATH 中的第一个匹配。

---

### 5️⃣ Redirection & Pipe · 重定向与管道

| Symbol | Description · 说明 |
|--------|--------------------|
| `>` | Redirect stdout to file (overwrite) · 标准输出重定向到文件（覆盖） |
| `>>` | Redirect stdout to file (append) · 标准输出重定向到文件（追加） |
| `<` | Read stdin from file · 从文件读取标准输入 |
| `2>` | Redirect stderr · 标准错误重定向 |
| `2>&1` | Merge stderr into stdout · 标准错误合并到标准输出 |
| `\|` | Pipe: output of left command becomes input of right · 管道：左侧命令的输出作为右侧命令的输入 |
| `tee` | Output to screen and file simultaneously · 同时输出到屏幕和文件（`tee file.txt`） |

**注意事项**：
- `nohup command > out.log 2>&1 &` 是后台运行 Java 程序的经典写法。
- `tee -a` 追加模式。

---

### 6️⃣ Variables & Aliases · 变量与别名

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `export` | Set environment variable · 设置环境变量 | `export JAVA_HOME=/usr/lib/jvm/java-17` |
| `source` | Execute script in current shell · 在当前 shell 中执行脚本 | `source ~/.bashrc` 重新加载配置 |
| `alias` | Create command shortcut · 创建命令别名 | `alias ll='ls -lh'`；`unalias ll` 取消别名 |

**注意事项**：
- 别名只在当前 shell 生效，永久生效需写入 `~/.bashrc` 或 `~/.zshrc`。
- `export` 设置的变量对子进程可见。

---

### 7️⃣ Help & System Info · 帮助与系统信息

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `man` | Display manual page · 显示命令手册 | `man ls`；`-k keyword` 搜索手册 |
| `whatis` | One-line description of command · 显示命令的一行描述 | `whatis ls` |
| `help` | Show built-in shell help · 显示 shell 内置命令帮助 | `help cd` |
| `uname` | Print system information · 打印系统信息 | `-a` 全部信息；`-r` 内核版本 |
| `hostname` | Print/set hostname · 显示或设置主机名 | 无常用参数 |
| `date` | Print/set date · 显示或设置日期 | `+%Y-%m-%d %H:%M:%S` 自定义格式 |
| `uptime` | How long system has been running · 系统运行时长 | 无常用参数 |
| `whoami` | Print current user name · 显示当前用户名 | 无常用参数 |

**注意事项**：
- `man` 是学习命令最好的老师，遇到不懂的先 `man`。
- `date` 格式化常用于日志文件名：`date +%Y%m%d_%H%M%S`。

---

## 🚀 Quick Reference · 速查示例
bash

查看日志最后100行并实时跟踪
tail -n 100 -f app.log

统计日志中 ERROR 的数量
grep -c "ERROR" app.log

查找所有超过500MB的日志文件
find /var/log -name "*.log" -size +500M

把进程ID为1234的线程栈导出
jstack 1234 > /tmp/threaddump.txt

查看磁盘使用情况
df -h

查看内存使用
free -h

后台运行jar包
nohup java -jar app.jar > app.log 2>&1 &

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录收录了 Java 后端工程师每天都会用到的 Linux 基础命令。每个命令都提供了 **中英文用途说明** 和 **常用选项的中文解释**，方便快速理解和记忆。  
建议结合实际场景反复练习，熟练掌握这些命令能大幅提高工作效率。

---

*Practice makes perfect. Happy hacking!* 🐧