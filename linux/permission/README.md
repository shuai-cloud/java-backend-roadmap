# Permission 🔒

> Linux permission and user management for Java backend engineers.  
> Java 后端工程师必备的 Linux 权限与用户管理知识。

---

## 📖 Overview · 概览

This section covers Linux file permissions, ownership, special bits, ACLs, user/group management, and privilege escalation. These skills are essential for deploying applications securely, troubleshooting permission denied errors, and configuring sudo access.

本章涵盖 Linux 文件权限、所有者、特殊权限位、ACL、用户/组管理以及提权操作。这些技能对于安全部署应用、排查权限拒绝错误、配置 sudo 访问至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ File Permissions · 文件权限

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `ls -l` | List files with permissions · 列出文件并显示权限 | `-l` 长格式（权限、硬链接数、所有者、组、大小、日期、文件名） |
| `chmod` | Change file mode bits · 修改文件权限 | 数字法：`chmod 755 file`；符号法：`chmod u+x,g-w,o=r file`；`-R` 递归修改目录 |
| `chown` | Change file owner and group · 修改文件所有者和组 | `chown user:group file`；`-R` 递归；`--from=current:current` 仅当匹配时才改 |
| `chgrp` | Change group ownership · 修改文件所属组 | `chgrp group file`；`-R` 递归 |

**注意事项**：
- 权限三位一组：owner（所有者）、group（所属组）、others（其他人）。
- 数字权限：r=4, w=2, x=1，相加得到三位数（如 755 = rwxr-xr-x）。
- 符号法：`u` 所有者，`g` 组，`o` 其他人，`a` 所有人。
- 修改目录权限时常用 `chmod -R`，但要注意可执行权限对目录的意义（能否进入目录）。

---

### 2️⃣ Default Permissions · 默认权限

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `umask` | Set default file creation mask · 设置默认文件创建掩码 | `umask 022` 设置掩码；`umask -S` 以符号形式显示当前掩码 |

**注意事项**：
- 最终权限 = 最大权限（文件666，目录777）减去 umask 值。
- 常见 umask：022（文件644，目录755），002（文件664，目录775）。

---

### 3️⃣ Special Permission Bits · 特殊权限位

| Bit | Symbol | Description · 说明 |
|-----|--------|--------------------|
| SUID | `s` in owner's execute position | 运行时以文件所有者的身份执行（如 `passwd`）· 临时获得所有者权限 |
| SGID | `s` in group's execute position | 运行时以文件所属组的身份执行；对目录生效时，新建文件继承目录的组 |
| Sticky Bit | `t` in others' execute position | 仅文件所有者或 root 可删除自己的文件（如 `/tmp`）· 防止误删他人文件 |

**查看与设置**：

bash

设置 SUID

chmod u+s file

设置 SGID

chmod g+s dir

设置 Sticky Bit

chmod o+t dir

数字法：chmod 4755 file (SUID), 2755 dir (SGID), 1777 dir (Sticky)

**注意事项**：
- SUID 对脚本无效，仅对二进制可执行文件有效。
- 设置 SUID/SGID 有安全风险，谨慎使用。

---

### 4️⃣ Access Control Lists (ACL) · 访问控制列表

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `getfacl` | Get file ACL · 获取文件 ACL | `-R` 递归；`-d` 显示默认 ACL |
| `setfacl` | Set file ACL · 设置文件 ACL | `-m u:username:rwx` 为用户添加权限；`-m g:group:rx` 为组添加；`-x u:username` 删除用户 ACL；`-b` 移除所有扩展 ACL；`-R` 递归；`-d` 设置默认 ACL（目录） |

**注意事项**：
- 使用 `ls -l` 时，如果权限位后有一个 `+` 号，表示该文件设置了 ACL。
- ACL 优先级：所有者 > 命名的用户 > 所属组 > 命名的组 > 其他人。

---

### 5️⃣ User & Group Management · 用户与组管理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `useradd` | Create a new user · 创建新用户 | `-m` 创建家目录；`-s /bin/bash` 指定 shell；`-G group1,group2` 附加组；`-u UID` 指定 UID |
| `usermod` | Modify a user account · 修改用户账户 | `-aG group` 追加到附加组（与 `-G` 配合）；`-l newname` 改名；`-L` 锁定账号；`-U` 解锁 |
| `userdel` | Delete a user · 删除用户 | `-r` 同时删除家目录和邮件池 |
| `groupadd` | Create a new group · 创建新组 | `-g GID` 指定 GID |
| `groupdel` | Delete a group · 删除组 | 无常用参数 |
| `passwd` | Change user password · 修改用户密码 | `passwd username` 修改指定用户密码（root 可免旧密码）；`-l` 锁定；`-u` 解锁；`-S` 显示状态 |
| `id` | Display user identity · 显示用户身份信息 | `id username`；`-u` 只显示 UID；`-g` 只显示 GID；`-G` 显示所有组 ID |
| `groups` | Show group memberships · 显示用户所属组 | `groups username` |

**注意事项**：
- 创建系统服务账号时建议使用 `useradd -r -s /sbin/nologin`（不登录、无家目录）。
- 修改用户组时，用户需重新登录才能生效。

---

### 6️⃣ Switching Users & Privilege Escalation · 切换用户与提权

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `su` | Switch user · 切换用户 | `su - username` 切换到目标用户并加载其环境变量；`su` 不加用户名默认切换到 root |
| `sudo` | Execute command as another user · 以其他用户身份执行命令 | `sudo command`；`-u username` 指定用户；`-i` 登录式 shell；`-l` 列出当前用户可执行的 sudo 命令 |
| `visudo` | Edit sudoers file safely · 安全编辑 sudo 配置文件 | 直接执行 `visudo`，语法检查后保存 |

**注意事项**：
- `sudo` 需要用户在 `/etc/sudoers` 中有相应配置。
- 常用 sudo 配置：`username ALL=(ALL) ALL` 或 `%group ALL=(ALL) NOPASSWD: ALL`。
- `visudo` 会自动检查语法，避免锁死 sudo。

---

## 🚀 Quick Reference · 速查示例

bash

查看文件权限

ls -l /etc/passwd

修改文件权限为 644

chmod 644 config.properties

修改文件所有者为 appuser:appgroup

sudo chown appuser:appgroup /opt/app/config.yml

设置 umask 为 027（文件640，目录750）

umask 027

查看文件 ACL

getfacl /var/log/app.log

为用户 deploy 添加读写权限

setfacl -m u:deploy:rw /var/log/app.log

创建新用户并加入 docker 组

sudo useradd -m -s /bin/bash -G docker jenkins

修改用户密码

sudo passwd jenkins

以 www-data 身份执行命令

sudo -u www-data php artisan migrate

查看当前用户可执行的 sudo 命令

sudo -l

---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 权限管理相关的常用命令，涵盖文件权限、特殊权限位、ACL、用户/组管理和 sudo 提权。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在测试环境或虚拟机中实际操作，加深理解。

部分命令需要 sudo 权限，脚本做了容错处理，无 sudo 时会跳过。
---

*With great power comes great responsibility. Use sudo wisely.* 🔐