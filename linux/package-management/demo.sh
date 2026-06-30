#!/bin/bash
#
# demo.sh - 包管理命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Package Management Demo"
echo "  场景：安装、查询、卸载、源管理"
echo "============================================"

# 检测系统类型
if command -v apt &>/dev/null; then
    PKG_MGR="apt"
    echo "  检测到 Debian/Ubuntu 系统 (APT)"
elif command -v yum &>/dev/null; then
    PKG_MGR="yum"
    echo "  检测到 CentOS/RHEL 系统 (YUM)"
elif command -v dnf &>/dev/null; then
    PKG_MGR="dnf"
    echo "  检测到 Fedora/RHEL 8+ 系统 (DNF)"
else
    echo "  未知包管理器，部分演示可能不可用"
    PKG_MGR="unknown"
fi

# ---------- 1. 更新包索引（模拟 dry-run） ----------
echo -e "\n[1] 更新包索引（仅模拟，不实际执行）"
case $PKG_MGR in
    apt) echo "  命令: sudo apt update (跳过)" ;;
    yum) echo "  命令: sudo yum check-update (跳过)" ;;
    dnf) echo "  命令: sudo dnf check-update (跳过)" ;;
esac

# ---------- 2. 搜索软件包 ----------
echo -e "\n[2] 搜索 curl 包"
case $PKG_MGR in
    apt)
        apt search curl 2>/dev/null | head -5 || echo "  搜索失败"
        ;;
    yum)
        yum search curl 2>/dev/null | head -5 || echo "  搜索失败"
        ;;
    dnf)
        dnf search curl 2>/dev/null | head -5 || echo "  搜索失败"
        ;;
esac

# ---------- 3. 查看已安装的包 ----------
echo -e "\n[3] 查看已安装的 openssh 相关包"
case $PKG_MGR in
    apt)
        dpkg -l | grep -i openssh 2>/dev/null | head -5 || echo "  未找到 openssh 包"
        ;;
    yum|dnf)
        rpm -qa | grep -i openssh 2>/dev/null | head -5 || echo "  未找到 openssh 包"
        ;;
esac

# ---------- 4. 查看文件属于哪个包 ----------
echo -e "\n[4] 查看 /bin/ls 属于哪个包"
case $PKG_MGR in
    apt)
        dpkg -S /bin/ls 2>/dev/null || echo "  dpkg 查询失败"
        ;;
    yum|dnf)
        rpm -qf /bin/ls 2>/dev/null || echo "  rpm 查询失败"
        ;;
esac

# ---------- 5. 查看包详细信息 ----------
echo -e "\n[5] 查看 bash 包的信息"
case $PKG_MGR in
    apt)
        apt show bash 2>/dev/null | head -8 || echo "  apt show 失败"
        ;;
    yum)
        yum info bash 2>/dev/null | head -8 || echo "  yum info 失败"
        ;;
    dnf)
        dnf info bash 2>/dev/null | head -8 || echo "  dnf info 失败"
        ;;
esac

# ---------- 6. 查看包的文件列表 ----------
echo -e "\n[6] 查看 tar 包安装的文件列表（仅前5行）"
case $PKG_MGR in
    apt)
        dpkg -L tar 2>/dev/null | head -5 || echo "  dpkg -L 失败"
        ;;
    yum|dnf)
        rpm -ql tar 2>/dev/null | head -5 || echo "  rpm -ql 失败"
        ;;
esac

# ---------- 7. 模拟安装一个包（dry-run） ----------
echo -e "\n[7] 模拟安装 tree 包（dry-run）"
case $PKG_MGR in
    apt)
        apt install --dry-run tree 2>/dev/null | head -3 || echo "  dry-run 失败"
        ;;
    yum)
        yum install --dry-run tree 2>/dev/null | head -3 || echo "  dry-run 失败"
        ;;
    dnf)
        dnf install --dry-run tree 2>/dev/null | head -3 || echo "  dry-run 失败"
        ;;
esac

# ---------- 8. 查看软件源列表 ----------
echo -e "\n[8] 查看软件源配置"
case $PKG_MGR in
    apt)
        if [ -f /etc/apt/sources.list ]; then
            head -5 /etc/apt/sources.list 2>/dev/null || echo "  文件不存在"
        else
            echo "  sources.list 不存在"
        fi
        ;;
    yum|dnf)
        ls /etc/yum.repos.d/ 2>/dev/null | head -5 || echo "  yum.repos.d 目录不存在"
        ;;
esac

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"