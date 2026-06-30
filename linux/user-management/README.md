# User Management 👤

> Linux user and group management for Java backend engineers.  
> Java 后端工程师必备的用户与组管理知识。

---

## 📖 Overview · 概览

This section covers Linux user and group management commands. You'll learn how to create/modify/delete users and groups, manage passwords, configure sudo privileges, and understand the underlying configuration files. These skills are essential for securing your servers and managing access control.

本章涵盖 Linux 用户和组管理命令。你将学习如何创建/修改/删除用户和组、管理密码、配置 sudo 权限以及理解底层的配置文件。这些技能对于保护服务器安全和管理访问控制至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ User Management · 用户管理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `useradd` | Create a new user · 创建新用户 | `-m` 创建家目录；`-s /bin/bash` 指定 shell；`-G group1,group2` 附加组；`-u UID` 指定 UID；`-r` 创建系统用户 |
| `usermod` | Modify a user account · 修改用户账户 | `-aG group` 追加到附加组；`-l newname` 改名；`-L` 锁定账号；`-U` 解锁；`-d /home/newdir` 修改家目录 |
| `userdel` | Delete a user · 删除用户 | `-r` 同时删除家目录和邮件池 |
| `passwd` | Change user password · 修改用户密码 | `-l` 锁定；`-u` 解锁；`-S` 显示状态；`-d` 删除密码（变为空密码） |
| `chage` | Change user password expiry info · 修改密码过期信息 | `-l` 列出当前过期信息；`-M 90` 设置最大天数；`-E 2025-12-31` 设置账号过期日期 |

**注意事项**：
- 创建系统服务账号时建议使用 `useradd -r -s /sbin/nologin`（不登录、无家目录）。
- 使用 `passwd -l` 锁定账号比删除更安全，可以保留用户数据。
- `chage` 常用于管理服务账号的密码策略。

---

### 2️⃣ Group Management · 组管理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `groupadd` | Create a new group · 创建新组 | `-g GID` 指定 GID；`-r` 创建系统组 |
| `groupmod` | Modify a group · 修改组 | `-n newname` 改名；`-g GID` 修改 GID |
| `groupdel` | Delete a group · 删除组 | 无常用参数 |
| `gpasswd` | Administer /etc/group and /etc/gshadow · 管理组成员和密码 | `-a user` 添加用户到组；`-d user` 从组中移除用户；`-A user` 设置组管理员 |

**注意事项**：
- 删除组前确保没有用户以该组为主要组。
- `gpasswd -a` 是添加用户到组的快捷方式，效果等同 `usermod -aG`。

---

### 3️⃣ User Information · 用户信息查看

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `id` | Display user identity · 显示用户身份 | `id username`；`-u` 只显示 UID；`-g` 只显示 GID；`-G` 显示所有组 ID |
| `who` | Show who is logged in · 显示当前登录用户 | `-b` 显示系统启动时间；`-q` 只显示用户名和数量 |
| `w` | Show who is logged in and what they are doing · 显示登录用户及其活动 | 无常用参数 |
| `whoami` | Print effective user name · 显示当前有效用户名 | 无常用参数 |
| `finger` | User information lookup · 查询用户信息（需安装） | `-l` 长格式；`-s` 短格式 |
| `last` | Show listing of last logged in users · 显示最近登录记录 | `-n 5` 显示最近5条；`-f /var/log/wtmp` 指定日志文件 |
| `lastlog` | Reports the most recent login of all users · 显示所有用户最近登录时间 | `-u username` 指定用户；`-t 30` 显示最近30天未登录的用户 |

**注意事项**：
- `w` 比 `who` 更详细，能看到用户当前执行的命令。
- `last` 和 `lastlog` 用于审计登录历史。

---

### 4️⃣ User Switching & Privilege Escalation · 用户切换与提权

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `su` | Switch user · 切换用户 | `su - username` 切换到目标用户并加载其环境变量；`su` 不加用户名默认切换到 root |
| `sudo` | Execute command as another user · 以其他用户身份执行命令 | `sudo command`；`-u username` 指定用户；`-i` 登录式 shell；`-l` 列出当前用户可执行的 sudo 命令；`-k` 清除缓存的凭证 |
| `visudo` | Edit sudoers file safely · 安全编辑 sudo 配置文件 | 直接执行 `visudo`，语法检查后保存 |

**注意事项**：
- `sudo` 需要用户在 `/etc/sudoers` 中有相应配置。
- 常用 sudo 配置：`username ALL=(ALL) ALL` 或 `%group ALL=(ALL) NOPASSWD: ALL`。
- `visudo` 会自动检查语法，避免锁死 sudo。

---

### 5️⃣ Configuration Files · 配置文件

| File | Description · 说明 | Format |
|------|--------------------|--------|
| `/etc/passwd` | User account information · 用户账户信息 | `username:x:UID:GID:comment:home:shell` |
| `/etc/shadow` | Encrypted passwords and expiry · 加密密码和过期信息 | `username:$hash:lastchange:min:max:warn:inactive:expire` |
| `/etc/group` | Group definitions · 组定义 | `groupname:x:GID:member1,member2` |
| `/etc/gshadow` | Group shadow passwords · 组密码影子文件 | `groupname:encrypted_password:admins:members` |
| `/etc/sudoers` | Sudo privileges · sudo 权限配置 | 使用 `visudo` 编辑 |

**注意事项**：
- 永远不要直接编辑 `/etc/shadow` 或 `/etc/sudoers`，使用 `vipw` 或 `visudo`。
- `/etc/passwd` 中的 `x` 表示密码存储在 `/etc/shadow` 中。

---

## 🚀 Quick Reference · 速查示例

bash

创建新用户并加入 docker 组

sudo useradd -m -s /bin/bash -G docker jenkins

修改用户密码

sudo passwd jenkins

将用户加入 sudo 组（Ubuntu）

sudo usermod -aG sudo jenkins

查看当前用户信息

id

groups

查看所有最近登录

last -n 10

以 www-data 身份执行命令

sudo -u www-data php artisan migrate

查看当前用户可执行的 sudo 命令

sudo -l

锁定用户账号

sudo passwd -l jenkins

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 用户和组管理相关的命令，涵盖用户创建/修改/删除、组管理、信息查看、切换提权以及配置文件解读。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在测试环境中练习用户管理操作，熟悉后再应用到生产环境。

---

*Users are the gateways to your system. Manage them wisely.* 🚪