# Package Management 📦

> Linux package management for Java backend engineers.  
> Java 后端工程师必备的包管理知识。

---

## 📖 Overview · 概览

This section covers package management on major Linux distributions. You'll learn how to install, update, remove software, manage repositories, and troubleshoot dependency issues. These skills are essential for setting up development environments, deploying applications, and maintaining servers.

本章介绍主流 Linux 发行版的包管理知识。你将学习如何安装、更新、卸载软件，管理软件源，以及排查依赖问题。这些技能对于搭建开发环境、部署应用和维护服务器至关重要。

---

## 🗂️ Commands · 命令速查

### 1️⃣ APT (Debian/Ubuntu) · Debian 系列包管理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `apt update` | Update package index · 更新软件包索引 | `apt update` |
| `apt upgrade` | Upgrade all upgradable packages · 升级所有可升级的包 | `apt upgrade`；`--dry-run` 模拟运行 |
| `apt install` | Install package(s) · 安装软件包 | `apt install nginx`；`-y` 自动确认 |
| `apt remove` | Remove package · 卸载软件包 | `apt remove nginx`；`--purge` 同时删除配置文件 |
| `apt autoremove` | Remove unused dependencies · 删除不再需要的依赖 | `apt autoremove` |
| `apt search` | Search for packages · 搜索软件包 | `apt search keyword` |
| `apt show` | Show package details · 显示软件包详细信息 | `apt show nginx` |
| `apt list` | List packages · 列出软件包 | `--installed` 已安装的；`--upgradable` 可升级的 |
| `apt-cache` | Query package cache · 查询包缓存（旧命令） | `apt-cache search`；`apt-cache show` |
| `apt-get` | Older APT interface · 旧版 APT 接口 | 基本同上，但更底层 |

**注意事项**：
- `apt` 是 `apt-get` 和 `apt-cache` 的现代化整合，日常使用 `apt` 即可。
- 首次使用前务必执行 `apt update` 更新索引。
- 生产环境升级前建议先在测试环境验证。

---

### 2️⃣ DPKG (Debian/Ubuntu) · 底层包工具

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `dpkg -i` | Install a .deb package · 安装 .deb 包 | `dpkg -i package.deb` |
| `dpkg -r` | Remove a package · 卸载包 | `dpkg -r packagename` |
| `dpkg -l` | List installed packages · 列出已安装的包 | `dpkg -l \| grep nginx` |
| `dpkg -L` | List files owned by package · 列出包拥有的文件 | `dpkg -L nginx` |
| `dpkg -S` | Find which package owns a file · 查找文件属于哪个包 | `dpkg -S /etc/nginx/nginx.conf` |
| `dpkg --configure` | Reconfigure an unpacked package · 重新配置未完成的包 | `dpkg --configure -a` |

**注意事项**：
- `dpkg` 不自动处理依赖，通常配合 `apt` 使用。
- 如果 `dpkg -i` 报依赖错误，执行 `apt install -f` 修复。

---

### 3️⃣ YUM/DNF (Red Hat/CentOS/Fedora) · Red Hat 系列包管理

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `yum install` | Install package · 安装软件包 | `yum install nginx`；`-y` 自动确认 |
| `yum update` | Update all packages · 更新所有包 | `yum update` |
| `yum remove` | Remove package · 卸载软件包 | `yum remove nginx` |
| `yum search` | Search packages · 搜索软件包 | `yum search keyword` |
| `yum info` | Show package info · 显示包信息 | `yum info nginx` |
| `yum list` | List packages · 列出包 | `yum list installed`；`yum list available` |
| `yum provides` | Find which package provides a file · 查找文件由哪个包提供 | `yum provides */nginx.conf` |
| `dnf` | Next-generation YUM (Fedora/RHEL 8+) · YUM 的下一代 | 用法与 yum 基本相同 |

**注意事项**：
- CentOS 7 使用 `yum`，CentOS 8+/RHEL 8+ 使用 `dnf`。
- `yum` 和 `dnf` 会自动处理依赖关系。

---

### 4️⃣ RPM (Red Hat 系列) · 底层包工具

| Command | Description · 说明 | Common Options (中文) |
|---------|--------------------|-----------------------|
| `rpm -ivh` | Install a .rpm package · 安装 .rpm 包 | `rpm -ivh package.rpm` |
| `rpm -e` | Erase (remove) a package · 卸载包 | `rpm -e nginx` |
| `rpm -qa` | Query all installed packages · 查询所有已安装的包 | `rpm -qa \| grep nginx` |
| `rpm -ql` | List files in package · 列出包中的文件 | `rpm -ql nginx` |
| `rpm -qf` | Find which package owns a file · 查找文件属于哪个包 | `rpm -qf /etc/nginx/nginx.conf` |
| `rpm -V` | Verify package integrity · 验证包的完整性 | `rpm -V nginx` |

**注意事项**：
- `rpm` 不处理依赖，通常配合 `yum`/`dnf` 使用。
- 使用 `rpm -ivh --nodeps` 可跳过依赖检查（不推荐）。

---

### 5️⃣ Repository Management · 软件源管理

| Distribution | Configuration File · 配置文件 | Key Commands |
|--------------|-------------------------------|--------------|
| Debian/Ubuntu | `/etc/apt/sources.list` 和 `/etc/apt/sources.list.d/` | `add-apt-repository ppa:xxx`；`apt-add-repository` |
| CentOS/RHEL | `/etc/yum.repos.d/` 目录下的 `.repo` 文件 | `yum-config-manager --add-repo URL` |

**常用操作**：

bash

Ubuntu: 添加第三方源

sudo add-apt-repository ppa:openjdk-r/ppa

sudo apt update

CentOS: 添加 EPEL 源

sudo yum install epel-release

查看当前启用的源
Ubuntu

apt-cache policy

CentOS

yum repolist

---

### 6️⃣ Common Scenarios · 常见场景

bash

1. 安装 Java
   Ubuntu

sudo apt install openjdk-17-jdk

CentOS

sudo yum install java-17-openjdk-devel

2. 安装 Nginx

sudo apt install nginx   # Ubuntu

sudo yum install nginx   # CentOS

3. 查找某个命令由哪个包提供
   Ubuntu

apt search /usr/bin/curl

CentOS

yum provides */curl

4. 查看已安装包的版本

dpkg -l | grep nginx    # Ubuntu

rpm -qa | grep nginx    # CentOS

5. 清理缓存释放空间

sudo apt clean          # Ubuntu

sudo yum clean all      # CentOS

---

## 🚀 Quick Reference · 速查示例

bash

Ubuntu: 更新索引并安装 nginx

sudo apt update && sudo apt install -y nginx

CentOS: 安装 EPEL 源并安装 htop

sudo yum install -y epel-release

sudo yum install -y htop

查找文件属于哪个包

dpkg -S /etc/hosts          # Ubuntu

rpm -qf /etc/hosts          # CentOS

查看已安装的所有 Java 相关包

dpkg -l | grep -i jdk       # Ubuntu

rpm -qa | grep -i jdk       # CentOS

卸载包并清除配置

sudo apt purge nginx        # Ubuntu

sudo yum remove nginx       # CentOS
---

## 📜 Script Demo · 示例脚本

See [`demo.sh`](./demo.sh) for a runnable script demonstrating these commands in action.

---

## 🇨🇳 中文说明

本目录整理了 Linux 包管理相关的命令，涵盖 APT、DPKG、YUM、DNF、RPM 以及软件源管理。每个命令都提供了中英文用途说明和常用选项的中文解释。  
建议在虚拟机中分别练习 Debian 系和 Red Hat 系的包管理命令，熟悉两者的异同。

---

*Package managers: your gateway to the Linux ecosystem.* 📦