# Network 🌐

> Linux networking commands for Java backend engineers.  
> Java 后端工程师必备的网络排查与管理知识。

---

## 📖 Overview · 概览

This section covers Linux networking commands you'll use daily: checking network interfaces, inspecting connections, testing connectivity, resolving DNS, tracing routes, and capturing packets. These skills are essential for diagnosing connection issues, port conflicts, DNS failures, and firewall problems.

本章涵盖日常工作中常用的 Linux 网络命令：查看网络接口、检查连接、测试连通性、解析 DNS、路由跟踪和抓包分析。这些技能对于排查连接问题、端口冲突、DNS 故障和防火墙配置至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Network Interface Configuration · 网络接口配置

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ip` | Show/manipulate routing, devices, tunnels · 显示和管理路由、设备、隧道（现代替代 ifconfig） | `addr` 查看 IP 地址；`link` 查看/修改接口状态；`route` 查看路由表；`-s` 显示统计信息；`-c` 彩色输出 |
| `ifconfig` | Configure network interface (legacy) · 配置网络接口（传统命令，逐渐淘汰） | `-a` 显示所有接口（包括未激活的）；`interface up/down` 启用/禁用接口 |
| `nmcli` | NetworkManager command-line tool · NetworkManager 的命令行工具 | `device status` 查看设备状态；`connection show` 查看连接配置；`device wifi list` 列出 WiFi |

**注意事项**：
- 现代 Linux 发行版推荐使用 `ip` 命令代替 `ifconfig`。
- `ip addr` 等同于 `ifconfig -a`，`ip link set eth0 up` 等同于 `ifconfig eth0 up`。

---

### 2️⃣ Network Connections & Ports · 网络连接与端口

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ss` | Socket statistics · Socket 统计（现代替代 netstat） | `-t` TCP 连接；`-u` UDP 连接；`-l` 仅显示监听中的 socket；`-n` 不解析服务名（显示端口号）；`-p` 显示进程信息；`-a` 所有 socket |
| `netstat` | Network statistics (legacy) · 网络统计（传统命令） | `-tlnp` 显示 TCP 监听端口及进程；`-ulnp` UDP 监听；`-an` 所有连接；`-r` 路由表 |

**注意事项**：
- `ss -tlnp` 是最常用的命令，用于查看哪些端口在监听以及对应的进程。
- 排查端口冲突时：`ss -tlnp | grep :8080`。

---

### 3️⃣ Connectivity Testing · 连通性测试

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ping` | Test reachability and measure RTT · 测试可达性并测量往返时间 | `-c 5` 发送 5 个包；`-i 0.5` 间隔 0.5 秒；`-W 3` 超时 3 秒；`-4/-6` IPv4/IPv6 |
| `telnet` | Connect to remote host via Telnet protocol · 通过 Telnet 连接到远程主机（测试端口） | `telnet host port` 测试端口是否开放 |
| `nc` (netcat) | Swiss army knife for TCP/UDP · 网络瑞士军刀 | `-zv host port` 扫描端口是否开放；`-l -p 9999` 监听端口；`-u` UDP 模式 |
| `curl` | Transfer data from/to server · 数据传输工具（HTTP/FTP 等） | `-v` 详细输出；`-I` 只显示响应头；`-o file` 下载到文件；`-X POST` 指定请求方法；`-H "Header: value"` 添加请求头 |
| `wget` | Non-interactive download utility · 非交互式下载工具 | `-O file` 指定输出文件名；`-q` 安静模式；`-c` 断点续传 |

**注意事项**：
- `telnet` 和 `nc` 常用于测试 TCP 端口是否可达（如数据库、Redis 端口）。
- `curl -v` 是调试 HTTP API 的首选命令。
- `ping` 不通不一定代表网络不通（可能被防火墙屏蔽 ICMP）。

---

### 4️⃣ DNS Resolution · DNS 解析

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `nslookup` | Query DNS records interactively · 交互式查询 DNS 记录 | `nslookup domain`；`nslookup domain 8.8.8.8` 指定 DNS 服务器 |
| `dig` | DNS lookup utility (more detailed) · DNS 查询工具（信息更详细） | `domain` 查询 A 记录；`+short` 简洁输出；`@8.8.8.8` 指定 DNS 服务器；`MX` 查询邮件交换记录；`ANY` 查询所有记录 |
| `host` | Simple DNS lookup · 简单 DNS 查询 | `host domain`；`host domain 8.8.8.8` |
| `getent` | Get entries from Name Service Switch libraries · 从系统名称服务中获取条目 | `getent hosts domain` 查询 hosts 文件或 DNS 中的 IP |

**注意事项**：
- `dig` 是最强大的 DNS 排查工具，`dig +short` 快速获取 IP。
- `getent hosts` 会按照 `/etc/nsswitch.conf` 的顺序查找（包括 `/etc/hosts`），比 `dig` 更贴近应用实际行为。

---

### 5️⃣ Route Tracing · 路由跟踪

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `traceroute` | Print route packets take to network host · 打印数据包到达目标主机的路径 | `-n` 不解析主机名（更快）；`-T` 使用 TCP SYN；`-p port` 指定端口 |
| `tracepath` | Similar to traceroute but simpler · 类似 traceroute，更简单 | 无需 root 权限；`-n` 不解析主机名 |
| `mtr` | Combines ping and traceroute (real-time) · 结合 ping 和 traceroute（实时） | `-r` 报告模式；`-c 10` 发送 10 个包；`-n` 不解析主机名 |

**注意事项**：
- `traceroute` 有时需要 root 权限才能使用 ICMP/UDP 探测。
- `mtr` 是排查网络延迟和丢包的最佳工具。

---

### 6️⃣ Packet Capture · 抓包分析

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `tcpdump` | Dump traffic on a network · 抓取网络流量 | `-i eth0` 指定网卡；`-c 10` 抓取 10 个包；`-nn` 不解析主机名和端口；`-X` 以十六进制和 ASCII 显示内容；`port 80` 过滤端口；`host 1.2.3.4` 过滤 IP；`-w file.pcap` 保存到文件 |
| `tshark` | Wireshark command-line version · Wireshark 命令行版本（需安装） | `-i eth0` 指定网卡；`-Y "http"` 显示过滤器；`-T fields -e ip.src -e ip.dst` 自定义输出字段 |

**注意事项**：
- `tcpdump` 通常需要 root 权限。
- 抓包文件可以用 Wireshark 图形界面分析。

---

### 7️⃣ Firewall Basics · 防火墙基础

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `iptables` | Administration tool for IPv4 packet filtering · IPv4 包过滤管理工具 | `-L` 列出规则；`-n` 数字格式；`-A INPUT -p tcp --dport 80 -j ACCEPT` 添加规则 |
| `firewalld` | Dynamic firewall manager (CentOS/RHEL 7+) · 动态防火墙管理器 | `--list-all` 列出所有规则；`--add-port=8080/tcp` 开放端口；`--remove-port=8080/tcp` 关闭端口；`--reload` 重新加载 |

**注意事项**：
- `iptables` 规则立即生效，但重启后丢失（除非保存）。
- `firewalld` 是 CentOS/RHEL 7+ 的默认防火墙，使用 zone 概念。

---

## 🚀 Quick Reference · 速查示例

bash

查看所有网络接口的 IP 地址

ip addr

查看哪些端口在监听

ss -tlnp

测试端口是否可达

nc -zv db.example.com 3306

测试 HTTP 接口

curl -v http://localhost:8080/api/health

DNS 查询

dig +short example.com

路由跟踪

traceroute -n google.com

抓取 80 端口的 5 个包

sudo tcpdump -i eth0 -c 5 port 80 -nn

开放防火墙端口

sudo firewall-cmd --add-port=8080/tcp --permanent

sudo firewall-cmd --reload

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 网络相关的常用命令，涵盖接口配置、连接查看、连通性测试、DNS 解析、路由跟踪和抓包分析。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议结合线上问题场景练习，例如用 `ss -tlnp` 排查端口冲突，用 `curl -v` 调试 API，用 `dig` 验证 DNS 解析。

---

*Network is the backbone. Master it.* 🌍