# Security 🔒

> Linux security hardening for Java backend engineers.  
> Java 后端工程师必备的 Linux 安全加固知识。

---

## 📖 Overview · 概览

This section covers essential Linux security practices: firewall management, SSH hardening, file integrity verification, audit logging, and mandatory access control. These skills are critical for protecting production servers from unauthorized access and attacks.

本章涵盖 Linux 安全加固的核心实践：防火墙管理、SSH 加固、文件完整性验证、审计日志和强制访问控制。这些技能对于保护生产服务器免受未经授权的访问和攻击至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ Firewall Management · 防火墙管理

#### iptables (Legacy, works on all distributions)

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `iptables -L` | List rules · 列出规则 | `-n` 数字格式（不解析主机名）；`-v` 详细输出；`--line-numbers` 显示行号 |
| `iptables -A` | Append rule · 添加规则 | `-A INPUT -p tcp --dport 80 -j ACCEPT` 允许 80 端口 |
| `iptables -D` | Delete rule · 删除规则 | `-D INPUT 3` 删除 INPUT 链第3条规则 |
| `iptables -P` | Set default policy · 设置默认策略 | `-P INPUT DROP` 默认丢弃入站流量 |

#### firewalld (CentOS/RHEL 7+, Fedora)

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `firewall-cmd --state` | Check if firewalld is running · 检查 firewalld 是否运行 | 无常用参数 |
| `firewall-cmd --list-all` | List all rules · 列出所有规则 | 无常用参数 |
| `firewall-cmd --add-port=8080/tcp` | Open a port · 开放端口 | `--permanent` 永久生效；`--zone=public` 指定区域 |
| `firewall-cmd --remove-port=8080/tcp` | Close a port · 关闭端口 | `--permanent` 永久生效 |
| `firewall-cmd --reload` | Reload firewall rules · 重新加载规则 | 无常用参数 |

#### ufw (Ubuntu)

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ufw enable` | Enable firewall · 启用防火墙 | 无常用参数 |
| `ufw disable` | Disable firewall · 禁用防火墙 | 无常用参数 |
| `ufw status` | Show firewall status · 显示防火墙状态 | `verbose` 详细输出 |
| `ufw allow 22/tcp` | Allow port 22 · 允许 22 端口 | `ufw allow from 192.168.1.0/24 to any port 22` 限制来源 |
| `ufw deny 8080` | Deny port 8080 · 拒绝 8080 端口 | 无常用参数 |

**注意事项**：
- 配置防火墙时务必保留 SSH 端口（22）的访问权限，以免把自己锁在外面。
- 修改 iptables 规则后，规则立即生效但重启后丢失，需要使用 `iptables-save` 保存。

---

### 2️⃣ SSH Hardening · SSH 加固

**关键配置文件**：`/etc/ssh/sshd_config`

| Setting | Recommended Value | Description · 说明 |
|---------|-------------------|--------------------|
| `Port` | 2222 (non-default) | Change default port to reduce automated attacks · 修改默认端口减少自动攻击 |
| `PermitRootLogin` | no | Disable direct root login · 禁止 root 直接登录 |
| `PasswordAuthentication` | no | Use key-based authentication only · 仅使用密钥认证 |
| `PubkeyAuthentication` | yes | Enable public key authentication · 启用公钥认证 |
| `AllowUsers` | user1 user2 | Limit which users can SSH · 限制可 SSH 的用户 |
| `MaxAuthTries` | 3 | Limit authentication attempts · 限制认证尝试次数 |
| `ClientAliveInterval` | 300 | Drop idle connections after 5 minutes · 5分钟无活动断开 |
| `Protocol` | 2 | Use SSH protocol version 2 only · 仅使用 SSHv2 |

**常用命令**：

| Command | Description · 说明 |
|---------|--------------------|
| `ssh-keygen -t ed25519` | Generate Ed25519 key pair (most secure) · 生成 Ed25519 密钥对 |
| `ssh-copy-id user@host` | Copy public key to remote server · 复制公钥到远程服务器 |
| `ssh -p 2222 user@host` | Connect with non-default port · 使用非默认端口连接 |
| `systemctl restart sshd` | Apply SSH config changes · 应用 SSH 配置更改 |

**注意事项**：
- 修改 SSH 配置后，先在一个窗口中保持现有连接，另一个窗口测试新连接，确认无误后再关闭。
- 建议使用 Ed25519 算法而非 RSA，安全性更高且性能更好。

---

### 3️⃣ File Integrity Verification · 文件完整性验证

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `sha256sum` | Compute SHA-256 hash · 计算 SHA-256 哈希 | `sha256sum file`；`-c checksum.txt` 校验 |
| `md5sum` | Compute MD5 hash (less secure) · 计算 MD5 哈希 | 同上 |
| `rpm -V` | Verify installed RPM packages · 验证已安装的 RPM 包 | `rpm -Va` 验证所有包；`rpm -V package_name` 验证特定包 |
| `aide` | Advanced Intrusion Detection Environment · 高级入侵检测环境 | `aide --init` 初始化数据库；`aide --check` 检查变化 |

**注意事项**：
- 下载重要文件后，建议验证其 SHA-256 校验和是否与官方一致。
- `rpm -Va` 可以检查系统文件是否被篡改（仅限 RPM 系发行版）。

---

### 4️⃣ Audit Logging · 审计日志

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `auditctl` | Control audit system · 控制审计系统 | `-l` 列出规则；`-a always,exit -S open -F key=file_open` 添加规则 |
| `ausearch` | Search audit logs · 搜索审计日志 | `-m USER_LOGIN` 搜索用户登录事件；`-ui username` 按用户 ID 搜索；`-ts today` 按时间搜索 |
| `aureport` | Generate audit reports · 生成审计报告 | `-l` 登录报告；`-m` 账户修改报告；`-f` 文件访问报告 |

**常用审计日志文件**：

| File | Description · 说明 |
|------|--------------------|
| `/var/log/secure` | Authentication and authorization logs (RHEL/CentOS) · 认证和授权日志 |
| `/var/log/auth.log` | Authentication logs (Debian/Ubuntu) · 认证日志 |
| `/var/log/audit/audit.log` | Audit daemon logs · 审计守护进程日志 |

---

### 5️⃣ SELinux & AppArmor · 强制访问控制

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `getenforce` | Check SELinux mode · 检查 SELinux 模式 | 返回 Enforcing/Permissive/Disabled |
| `setenforce` | Change SELinux mode temporarily · 临时修改 SELinux 模式 | `setenforce 0` 设为 Permissive；`setenforce 1` 设为 Enforcing |
| `sestatus` | Show SELinux status · 显示 SELinux 状态 | 无常用参数 |
| `aa-status` | Show AppArmor status · 显示 AppArmor 状态 | 无常用参数 |
| `aa-enforce` | Set profile to enforce mode · 设置配置文件为强制模式 | `aa-enforce /path/to/profile` |

**注意事项**：
- 生产环境不建议关闭 SELinux/AppArmor，应学会配置正确的上下文/配置文件。
- 排查权限问题时，可以先 `setenforce 0` 临时关闭 SELinux 验证是否为 SELinux 导致的问题。

---

## 🚀 Quick Reference · 速查示例
bash

查看防火墙状态
Ubuntu
ufw status

CentOS
firewall-cmd --state

开放 8080 端口
sudo firewall-cmd --add-port=8080/tcp --permanent

sudo firewall-cmd --reload

生成 SSH 密钥对
ssh-keygen -t ed25519 -C "your_email@example.com"

复制公钥到远程服务器
ssh-copy-id user@remote-server

查看 SSH 登录失败记录
sudo journalctl -u sshd -p err --since "1 day ago"

检查文件完整性
sha256sum important_file.tar.gz

查看审计登录报告
sudo aureport -l

纯文本
---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 安全加固相关的命令和概念，涵盖防火墙管理、SSH 加固、文件完整性验证、审计日志和强制访问控制。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在测试环境练习安全配置，熟悉后再应用到生产服务器。

---

*Security is not a product, but a process.* 🛡️