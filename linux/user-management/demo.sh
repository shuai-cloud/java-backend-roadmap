#!/bin/bash
#
# demo.sh - 用户管理命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux User Management Demo"
echo "  场景：用户创建、组管理、信息查看、sudo"
echo "============================================"

# ---------- 1. 查看当前用户信息 ----------
echo -e "\n[1] 查看当前用户信息"
id
echo "  当前用户: $(whoami)"
echo "  所属组: $(groups)"

# ---------- 2. 查看系统用户 ----------
echo -e "\n[2] 查看最近登录的用户"
last -n 5 2>/dev/null || echo "  last 不可用"

# ---------- 3. 查看所有用户最近登录 ----------
echo -e "\n[3] 查看所有用户最近登录（仅显示前5行）"
lastlog 2>/dev/null | head -6 || echo "  lastlog 不可用"

# ---------- 4. 查看 /etc/passwd 文件结构 ----------
echo -e "\n[4] 查看 /etc/passwd 前5行"
head -5 /etc/passwd

# ---------- 5. 查看 /etc/group 文件结构 ----------
echo -e "\n[5] 查看 /etc/group 中包含当前用户的行"
grep "^$(whoami)" /etc/group || echo "  未找到"

# ---------- 6. 创建临时用户（需要 sudo） ----------
echo -e "\n[6] 尝试创建临时用户 demouser（需要 sudo）"
if sudo -n true 2>/dev/null; then
    # 创建用户
    sudo useradd -m -s /bin/bash demouser 2>/dev/null || echo "  用户 demouser 已存在"
    echo "  已创建用户 demouser"

    # 查看用户信息
    id demouser

    # 设置密码（设置为空密码演示，实际不应这样做）
    echo "demouser:password123" | sudo chpasswd 2>/dev/null || echo "  密码设置失败"
    echo "  密码已设置"

    # 查看用户密码状态
    sudo passwd -S demouser 2>/dev/null || echo "  passwd -S 失败"

    # 删除用户
    sudo userdel -r demouser 2>/dev/null || true
    echo "  已删除用户 demouser"
else
    echo "  无 sudo 权限，跳过用户创建演示"
fi

# ---------- 7. 查看 sudo 权限 ----------
echo -e "\n[7] 查看当前用户的 sudo 权限"
sudo -l 2>/dev/null || echo "  当前用户无 sudo 权限或 sudo 未配置"

# ---------- 8. 查看 /etc/sudoers 文件（安全方式） ----------
echo -e "\n[8] 安全查看 sudo 配置（仅显示有效行）"
sudo cat /etc/sudoers 2>/dev/null | grep -v "^#" | grep -v "^$" | head -10 || echo "  无法读取 sudoers"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"