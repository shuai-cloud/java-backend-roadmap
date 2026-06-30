# Service 🛠️

> Linux service management for Java backend engineers.  
> Java 后端工程师必备的服务管理知识。

---

## 📖 Overview · 概览

This section covers Linux service management using systemd – the standard init system on modern Linux distributions. You'll learn how to start/stop services, view logs, create custom service units, and automate tasks with timers. These skills are essential for deploying and maintaining Java applications in production.

本章介绍使用 systemd 管理 Linux 服务的知识——这是现代 Linux 发行版的标准初始化系统。你将学习如何启停服务、查看日志、创建自定义服务单元以及使用定时器自动化任务。这些技能对于在生产环境中部署和维护 Java 应用至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Service Lifecycle · 服务生命周期

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `systemctl start` | Start a service · 启动服务 | `systemctl start nginx` |
| `systemctl stop` | Stop a service · 停止服务 | `systemctl stop nginx` |
| `systemctl restart` | Restart a service · 重启服务 | `systemctl restart nginx` |
| `systemctl reload` | Reload configuration without stopping · 重新加载配置（不停机） | `systemctl reload nginx` |
| `systemctl enable` | Enable service to start at boot · 设置开机自启 | `systemctl enable nginx` |
| `systemctl disable` | Disable service from starting at boot · 取消开机自启 | `systemctl disable nginx` |
| `systemctl status` | Show service status · 显示服务状态 | `-l` 显示完整输出；`--no-pager` 不分页 |
| `systemctl is-active` | Check if service is active · 检查服务是否运行 | `systemctl is-active nginx` |
| `systemctl is-enabled` | Check if service is enabled · 检查服务是否开机自启 | `systemctl is-enabled nginx` |

**注意事项**：
- `reload` 要求服务支持 SIGHUP 信号，并非所有服务都支持。
- 修改 `.service` 文件后需执行 `systemctl daemon-reload` 重新加载。

---

### 2️⃣ Viewing Logs · 查看日志

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `journalctl` | Query the systemd journal · 查询 systemd 日志 | `-u nginx` 查看特定服务的日志；`-f` 实时跟踪；`-n 50` 显示最后50行；`--since "1 hour ago"` 按时间过滤；`-p err` 按优先级过滤（emerg, alert, crit, err, warning, notice, info, debug）；`-o json` JSON 格式输出 |
| `journalctl -xe` | Show recent logs with explanations · 显示最近的日志并附带解释 | 常用于排查错误 |

**注意事项**：
- `journalctl` 默认使用分页器（less），可用 `--no-pager` 禁用。
- 日志持久化需要配置 `/etc/systemd/journald.conf` 中的 `Storage=persistent`。

---

### 3️⃣ Custom Service Units · 自定义服务单元

一个典型的 Java 应用 `.service` 文件示例（保存在 `/etc/systemd/system/myapp.service`）：

ini

[Unit]

Description=My Java Application

After=network.target

[Service]

Type=simple

User=appuser

WorkingDirectory=/opt/myapp

ExecStart=/usr/bin/java -jar /opt/myapp/app.jar

ExecStop=/bin/kill -15 $MAINPID

Restart=on-failure

RestartSec=10

Environment=JAVA_HOME=/usr/lib/jvm/java-17

Environment=SPRING_PROFILES_ACTIVE=prod

[Install]

WantedBy=multi-user.target

**关键字段说明**：

| Field | Description · 说明 |
|-------|--------------------|
| `Description` | 服务描述 |
| `After` | 在哪些服务之后启动（依赖关系） |
| `Type` | 启动类型：`simple`（主进程）、`forking`（派生）、`oneshot`（一次性） |
| `User` | 运行服务的用户（安全考虑，不要用 root） |
| `WorkingDirectory` | 工作目录 |
| `ExecStart` | 启动命令 |
| `ExecStop` | 停止命令（可选，默认发送 SIGTERM） |
| `Restart` | 重启策略：`always`、`on-failure`、`no` |
| `RestartSec` | 重启前的等待秒数 |
| `Environment` | 环境变量 |
| `WantedBy` | 目标运行级别（通常为 `multi-user.target`） |

**注意事项**：
- 修改 unit 文件后执行 `sudo systemctl daemon-reload`。
- 使用 `systemctl cat myapp` 查看当前生效的 unit 配置。

---

### 4️⃣ Systemd Timers · 定时任务

Systemd timer 是 cron 的现代替代方案，更灵活、可审计。

**示例**：每天凌晨 2 点执行备份脚本

`/etc/systemd/system/backup.service`：

ini

[Unit]

Description=Daily Backup

[Service]

Type=oneshot

ExecStart=/opt/scripts/backup.sh

`/etc/systemd/system/backup.timer`：

ini

[Unit]

Description=Run backup daily at 2am

[Timer]

OnCalendar=daily

Persistent=true

[Install]

WantedBy=timers.target

**启用 timer**：

bash

sudo systemctl daemon-reload

sudo systemctl enable backup.timer

sudo systemctl start backup.timer

**常用命令**：

| Command | Description · 说明 |
|---------|--------------------|
| `systemctl list-timers` | 列出所有定时器 |
| `systemctl start backup.timer` | 启动定时器 |
| `systemctl enable backup.timer` | 启用定时器（开机自启） |
| `systemctl status backup.timer` | 查看定时器状态 |

---

### 5️⃣ Supervisor · 进程管理工具

Supervisor 是 Python 编写的进程管理工具，常用于管理非 systemd 环境的进程（如 Docker 容器内）。

**安装**：`pip install supervisor` 或 `apt install supervisor`

**配置文件示例**（`/etc/supervisor/conf.d/myapp.conf`）：

ini

[program:myapp]

command=java -jar /opt/myapp/app.jar

directory=/opt/myapp

user=appuser

autostart=true

autorestart=true

startretries=3

stderr_logfile=/var/log/myapp.err.log

stdout_logfile=/var/log/myapp.out.log

**常用命令**：

| Command | Description · 说明 |
|---------|--------------------|
| `supervisorctl status` | 查看所有进程状态 |
| `supervisorctl start myapp` | 启动进程 |
| `supervisorctl stop myapp` | 停止进程 |
| `supervisorctl restart myapp` | 重启进程 |
| `supervisorctl reread` | 重新加载配置文件 |
| `supervisorctl update` | 应用配置变更 |

---

## 🚀 Quick Reference · 速查示例

bash

查看 nginx 服务状态

systemctl status nginx

重启 Java 应用

sudo systemctl restart myapp

查看 myapp 最近 50 条日志

journalctl -u myapp -n 50 --no-pager

实时跟踪 myapp 日志

journalctl -u myapp -f

创建并启用自定义服务

sudo vim /etc/systemd/system/myapp.service

sudo systemctl daemon-reload

sudo systemctl enable myapp

sudo systemctl start myapp

查看所有定时器

systemctl list-timers

使用 supervisor 管理进程

sudo supervisorctl status

sudo supervisorctl restart myapp

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 服务管理相关的命令和概念，涵盖 systemd 的基本操作、日志查看、自定义服务单元、定时任务以及 supervisor。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在测试环境中练习创建和管理自己的 Java 应用服务。

---

*Services are the building blocks of production systems.* 🏗️