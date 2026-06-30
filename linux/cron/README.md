# Cron ⏰

> Linux cron jobs for Java backend engineers.  
> Java 后端工程师必备的定时任务知识。

---

## 📖 Overview · 概览

This section covers cron, the standard job scheduler on Linux. You'll learn how to create, view, and manage scheduled tasks for automating routine operations like log rotation, backups, health checks, and data synchronization.

本章介绍 cron——Linux 标准的任务调度器。你将学习如何创建、查看和管理定时任务，用于自动化日常运维操作，如日志轮转、备份、健康检查和数据同步。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Crontab Basics · 基本操作

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `crontab -e` | Edit current user's crontab · 编辑当前用户的定时任务 | 默认使用 vi 编辑器；可通过 `EDITOR=nano crontab -e` 指定编辑器 |
| `crontab -l` | List current user's crontab · 列出当前用户的定时任务 | 无常用参数 |
| `crontab -r` | Remove current user's crontab · 删除当前用户的定时任务 | 无常用参数 |
| `crontab -u` | Manage another user's crontab (root only) · 管理其他用户的定时任务（仅 root） | `crontab -u username -l` |

**注意事项**：
- 每个用户都有自己的 crontab 文件，存放在 `/var/spool/cron/crontabs/` 目录下。
- 使用 `crontab -e` 编辑时会自动检查语法，错误的格式不会被保存。

---

### 2️⃣ Time Expression · 时间表达式

Cron 时间格式由五个字段组成，用空格分隔：

.....command_to_execute

┬ ┬ ┬ ┬ ┬

│ │ │ │ └──── Day of week (0-7, Sunday=0 or 7)

│ │ │ └────── Month (1-12)

│ │ └──────── Day of month (1-31)

│ └────────── Hour (0-23)

└──────────── Minute (0-59)

**常用特殊字符**：

| Character | Meaning · 含义 | Example |
|-----------|----------------|---------|
| `*` | Any value · 任意值 | `* * * * *` 每分钟 |
| `,` | Multiple values · 多个值 | `0,30 * * * *` 每小时的第0和30分钟 |
| `-` | Range · 范围 | `9-17 * * * *` 9点到17点之间 |
| `/` | Step · 步长 | `*/5 * * * *` 每5分钟 |

**常见示例**：

| Expression | Meaning · 含义 |
|------------|----------------|
| `*/5 * * * *` | Every 5 minutes · 每5分钟 |
| `0 * * * *` | Every hour at minute 0 · 每小时整点 |
| `0 2 * * *` | Daily at 2:00 AM · 每天凌晨2点 |
| `0 2 * * 1` | Every Monday at 2:00 AM · 每周一凌晨2点 |
| `0 2 1 * *` | First day of every month at 2:00 AM · 每月1日凌晨2点 |
| `*/30 9-17 * * 1-5` | Every 30 min, 9AM-5PM, Mon-Fri · 工作日每半小时 |

---

### 3️⃣ Special Strings · 特殊字符串

| String | Equivalent To · 等价于 | Meaning · 含义 |
|--------|------------------------|----------------|
| `@reboot` | (none) | Run once at startup · 系统启动时运行一次 |
| `@yearly` | `0 0 1 1 *` | Run once a year · 每年1月1日 |
| `@monthly` | `0 0 1 * *` | Run once a month · 每月1日 |
| `@weekly` | `0 0 * * 0` | Run once a week · 每周日 |
| `@daily` | `0 0 * * *` | Run once a day · 每天午夜 |
| `@hourly` | `0 * * * *` | Run once an hour · 每小时整点 |

---

### 4️⃣ Environment & Logging · 环境变量与日志

在 crontab 文件中，可以在任务前设置环境变量：
bash

设置 PATH，确保命令能找到
PATH=/usr/local/bin:/usr/bin:/bin

设置 MAILTO，将输出发送到邮箱（留空则不发送）
MAILTO=admin@example.com

设置 SHELL
SHELL=/bin/bash

任务示例
0 2 * * * /opt/scripts/backup.sh > /var/log/backup.log 2>&1

**注意事项**：
- Cron 默认使用有限的 PATH（`/usr/bin:/bin`），所以建议在 crontab 开头设置 PATH。
- 如果不重定向输出，cron 会将输出通过邮件发送给用户（如果 MAILTO 未设置）。
- 建议始终将输出重定向到日志文件：`>> /var/log/myjob.log 2>&1`。

---

### 5️⃣ Common Task Examples · 常见任务示例
bash

1. 每天凌晨3点清理日志（保留最近7天）
   0 3 * * * find /var/log/myapp -name "*.log" -mtime +7 -delete

2. 每5分钟检查应用健康状态
   */5 * * * * curl -s http://localhost:8080/health> /dev/null || echo "App down" | mail -s "Alert" admin@example.com

3. 每天凌晨2点备份数据库
   0 2 * * * mysqldump -u root mydb > /backup/db_$(date +%Y%m%d).sql

4. 每小时同步数据到远程服务器
   0 * * * * rsync -avz /data/ user@remote:/data/

5. 每周日凌晨3点重启服务
   0 3 * * 0 systemctl restart myapp

**注意事项**：
- 在 crontab 中使用 `%` 需要转义为 `\%`，否则会被解释为换行符。
- 复杂的脚本建议写成独立的 `.sh` 文件，然后在 crontab 中调用。

---

### 6️⃣ Systemd Timer vs Cron · 对比

| Feature | Cron | Systemd Timer |
|---------|------|---------------|
| Precision | Minute-level · 分钟级 | Second-level · 秒级 |
| Dependency | None | Can depend on other units · 可依赖其他单元 |
| Logging | Via mail or redirect | Integrated with journald · 集成 journald |
| Random delay | Not built-in | `RandomizedDelaySec` option |
| Persistence | Missed jobs skipped | `Persistent=true` catches missed jobs |
| Complexity | Simple | More complex setup |

**何时使用 systemd timer**：
- 需要秒级精度。
- 需要依赖其他服务（如网络就绪后才执行）。
- 需要持久化错过的时间（如机器关机期间的任务）。

---

## 🚀 Quick Reference · 速查示例
bash

编辑当前用户的 crontab
crontab -e

查看当前用户的 crontab
crontab -l

查看其他用户的 crontab（需要 root）
sudo crontab -u www-data -l

每5分钟执行一次健康检查
*/5 * * * * /opt/scripts/healthcheck.sh

每天凌晨2点备份
0 2 * * * /opt/scripts/backup.sh > /var/log/backup.log 2>&1

系统启动时执行
@reboot /opt/scripts/startup.sh

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 定时任务相关的命令和概念，涵盖 crontab 基本操作、时间表达式、特殊字符串、环境变量配置、常见任务示例以及与 systemd timer 的对比。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在测试环境中练习创建和管理定时任务，注意日志重定向和 PATH 设置。

---

*Let cron handle the routine while you focus on the important.* ⏲️
