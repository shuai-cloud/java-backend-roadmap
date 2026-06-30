# Linux 🐧

> Essential Linux skills for Java backend engineers (3–5 years experience).  
> Java 后端工程师必备的 Linux 技能体系。

[![Linux](https://img.shields.io/badge/Linux-CentOS%20%7C%20Ubuntu-yellow)]()
[![Shell](https://img.shields.io/badge/Shell-Bash-green)]()

---

## 📖 Overview · 概览

This section covers the Linux knowledge required for daily development, troubleshooting, and production environment maintenance. Mastering these topics will help you:

- Efficiently navigate and operate servers.
- Diagnose and resolve common issues (high CPU, memory leak, slow network).
- Automate repetitive tasks with shell scripts.
- Understand how your Java application interacts with the OS.

本部分涵盖日常开发、故障排查和生产环境维护所需的 Linux 知识。掌握这些内容可以帮助你高效操作服务器、诊断常见问题、编写自动化脚本，并理解 Java 应用与操作系统的交互。

---

## 🗂️ Directory Structure · 目录结构

linux/

├── basic-command/          # 常用命令 (ls, cd, grep, awk, sed, find, xargs)

├── filesystem/             # 文件系统结构、inode、软硬链接、挂载

├── permission/             # 权限管理 (chmod, chown, umask, ACL)

├── user-management/        # 用户/组管理 (useradd, usermod, sudo)

├── process/                # 进程管理 (ps, top, htop, kill, nohup)

├── network/                # 网络配置与诊断 (ip, ss, netstat, curl, tcpdump)

├── disk/                   # 磁盘管理 (fdisk, df, du, LVM, mount)

├── package-management/     # 包管理 (apt, yum, dnf, dpkg, rpm)

├── cron/                   # 定时任务 (crontab, systemd timer)

├── vim/                    # Vim 编辑器 (模式、快捷键、配置)

├── shell/                  # Shell 脚本编程 (变量、循环、函数、正则)

├── service/                # 服务管理 (systemctl, journalctl, supervisor)

├── security/               # 安全加固 (firewalld, iptables, SELinux, SSH)

├── compression/            # 压缩归档 (tar, gzip, zip, rsync)

├── log-analysis/           # 日志分析 (tail, less, awk, journalctl, logrotate)

├── performance/            # 性能监控 (top, vmstat, iostat, sar, perf)

└── troubleshooting/        # 故障排查综合案例 (CPU 100%、OOM、端口冲突)

Each subdirectory contains:
- A `README.md` with key concepts and command summaries.
- Practical examples and scripts.
- Common interview questions and scenarios.

每个子目录都包含概念总结、实用示例和常见面试题。

---

## 🎯 Learning Goals · 学习目标

By completing this section, you should be able to:

| Topic | Goal |
|-------|------|
| Basic Commands | Navigate, search, filter text fluently without GUI |
| File System | Understand Linux directory hierarchy, manage disks |
| Permission & Users | Configure secure access control |
| Process Management | Monitor and control running processes |
| Network | Diagnose connectivity issues, inspect ports |
| Shell Scripting | Automate routine tasks (backup, deploy, monitor) |
| Service Management | Start/stop services, view logs with systemd |
| Performance | Identify bottlenecks (CPU, memory, I/O) |
| Troubleshooting | Solve real problems step by step |

---

## 🚦 How to Use · 如何使用

1. Start from `basic-command/` if you are new to Linux.
2. Practice each command on your local VM or cloud server.
3. For each topic, try to answer: *How does this relate to my Java app?*  
   (e.g., JVM memory → `top`/`free`, thread dump → `jstack` + `ps`)
4. Use the `troubleshooting/` section as a final exam – simulate real incidents.

---

## 📚 Recommended Resources · 推荐资源

- [鸟哥的 Linux 私房菜](http://linux.vbird.org/) – 中文经典
- [The Linux Command Line](https://linuxcommand.org/) – 免费英文书
- [TLDR pages](https://tldr.sh/) – 快速查命令用法
- [ExplainShell](https://explainshell.com/) – 解析复杂命令

---

## 🇨🇳 中文说明

本目录专为 Java 后端工程师整理，覆盖从日常命令到生产环境排障的全部 Linux 技能。  
每个子目录都配有详细笔记和可执行的示例脚本，建议边学边练。  
面试前重点复习 **process**、**performance**、**troubleshooting** 三个目录。

---

*Keep calm and `sudo` on.* 🐧