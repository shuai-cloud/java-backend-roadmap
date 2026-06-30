#!/bin/bash
#
# demo.sh - 安全相关命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Security Demo"
echo "  场景：防火墙、SSH、文件完整性、审计"
echo "============================================"

# ---------- 1. 防火墙状态 ----------
echo -e "\n[1] 查看防火墙状态"
if command -v ufw &>/dev/null; then
    ufw status 2>/dev/null || echo "  ufw 未启用"
elif command -v firewall-cmd &>/dev/null; then
    firewall-cmd --state 2>/dev/null || echo "  firewalld 未运行"
elif command -v iptables &>/dev/null; then
    sudo iptables -L -n --line-numbers 2>/dev/null | head -10 || echo "  iptables 不可用"
else
    echo "  未检测到防火墙工具"
fi

# ---------- 2. SSH 配置检查 ----------
echo -e "\n[2] 查看 SSH 关键配置"
if [ -f /etc/ssh/sshd_config ]; then
    echo "  SSH 端口: $(grep -E "^Port " /etc/ssh/sshd_config 2>/dev/null || echo '默认22')"
    echo "  PermitRootLogin: $(grep -E "^PermitRootLogin" /etc/ssh/sshd_config 2>/dev/null || echo '未设置')"
    echo "  PasswordAuthentication: $(grep -E "^PasswordAuthentication" /etc/ssh/sshd_config 2>/dev/null || echo '未设置')"
else
    echo "  /etc/ssh/sshd_config 不存在"
fi

# ---------- 3. SSH 密钥生成演示 ----------
echo -e "\n[3] SSH 密钥生成演示（不实际创建）"
echo "  命令: ssh-keygen -t ed25519 -C \"your_email@example.com\""
echo "  这将生成 ~/.ssh/id_ed25519 和 ~/.ssh/id_ed25519.pub"

# ---------- 4. 文件完整性验证 ----------
echo -e "\n[4] 文件完整性验证"
WORKDIR="/tmp/security_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "hello world" > testfile.txt
sha256sum testfile.txt > checksum.txt
echo "  文件内容: hello world"
echo "  SHA-256 校验和: $(cat checksum.txt)"

# 验证
echo "  验证校验和:"
sha256sum -c checksum.txt

# 模拟文件被篡改
echo "modified content" > testfile.txt
echo "  文件被修改后验证:"
sha256sum -c checksum.txt 2>&1 || echo "  校验和不匹配（预期行为）"

# ---------- 5. 查看认证日志 ----------
echo -e "\n[5] 查看最近认证日志（仅显示最后3行）"
if [ -f /var/log/auth.log ]; then
    tail -3 /var/log/auth.log
elif [ -f /var/log/secure ]; then
    sudo tail -3 /var/log/secure 2>/dev/null || echo "  权限不足"
else
    echo "  未找到认证日志文件"
fi

# ---------- 6. SELinux 状态 ----------
echo -e "\n[6] 查看 SELinux 状态"
if command -v getenforce &>/dev/null; then
    echo "  SELinux 模式: $(getenforce)"
    sestatus 2>/dev/null | head -3 || echo "  sestatus 不可用"
else
    echo "  SELinux 未安装或不可用"
fi

# ---------- 7. 查看审计服务状态 ----------
echo -e "\n[7] 查看 auditd 服务状态"
if systemctl is-active auditd &>/dev/null; then
    systemctl status auditd --no-pager | head -5
    echo "  审计规则数量: $(sudo auditctl -l 2>/dev/null | wc -l)"
else
    echo "  auditd 未运行"
fi

# ---------- 8. 清理 ----------
echo -e "\n[8] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"