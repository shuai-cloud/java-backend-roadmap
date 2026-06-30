#!/bin/bash
#
# demo.sh - Linux 权限管理命令使用场景演示
# 适用人群：Java 后端工程师
# 使用方法：bash demo.sh（部分命令可能需要 sudo）
#

set -euo pipefail

echo "============================================"
echo "  Linux Permission Commands Demo"
echo "  场景：文件权限、用户管理、sudo 配置"
echo "============================================"

# ---------- 1. 创建临时工作目录和文件 ----------
WORKDIR="/tmp/permission_demo"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo -e "\n[1] 创建测试文件和目录"
touch testfile.txt
mkdir testdir
echo "  已创建 testfile.txt 和 testdir"

# ---------- 2. 查看默认权限 ----------
echo -e "\n[2] 查看当前 umask 和文件默认权限"
echo "  当前 umask: $(umask)"
echo "  默认文件权限: $(umask -S)"
ls -l testfile.txt

# ---------- 3. 修改文件权限 ----------
echo -e "\n[3] 使用 chmod 修改权限"
chmod 644 testfile.txt
echo "  chmod 644 后: $(ls -l testfile.txt)"
chmod u+x testfile.txt
echo "  chmod u+x 后: $(ls -l testfile.txt)"

# ---------- 4. 修改文件所有者（需要 sudo） ----------
echo -e "\n[4] 尝试修改文件所有者为 nobody（需要 sudo）"
if sudo -n true 2>/dev/null; then
    sudo chown nobody:nogroup testfile.txt 2>/dev/null || echo "  无 nogroup 组，改用 root"
    sudo chown root:root testfile.txt 2>/dev/null
    echo "  修改后: $(ls -l testfile.txt)"
    # 恢复
    sudo chown $(whoami):$(id -gn) testfile.txt
else
    echo "  无 sudo 权限，跳过 chown 演示"
fi

# ---------- 5. 特殊权限位演示 ----------
echo -e "\n[5] 设置 SUID、SGID、Sticky Bit"
touch suid_test sgid_test sticky_dir
chmod u+s suid_test
chmod g+s sgid_test
chmod o+t sticky_dir
ls -l suid_test sgid_test -d sticky_dir

# ---------- 6. ACL 演示 ----------
echo -e "\n[6] 设置 ACL（为当前用户添加额外权限）"
setfacl -m u:$(whoami):rwx testfile.txt
echo "  设置 ACL 后: "
getfacl testfile.txt | head -5
echo "  ls -l 显示权限后有 '+' 号: $(ls -l testfile.txt)"

# ---------- 7. 用户信息查询 ----------
echo -e "\n[7] 查看当前用户信息"
id
groups

# ---------- 8. 创建临时用户（需要 sudo） ----------
echo -e "\n[8] 尝试创建临时用户 demouser（需要 sudo）"
if sudo -n true 2>/dev/null; then
    sudo useradd -m -s /bin/bash demouser 2>/dev/null || echo "  用户 demouser 已存在"
    echo "  已创建用户 demouser"
    id demouser
    # 清理
    sudo userdel -r demouser 2>/dev/null || true
    echo "  已删除用户 demouser"
else
    echo "  无 sudo 权限，跳过用户创建演示"
fi

# ---------- 9. sudo 权限查看 ----------
echo -e "\n[9] 查看当前用户的 sudo 权限"
sudo -l 2>/dev/null || echo "  当前用户无 sudo 权限或 sudo 未配置"

# ---------- 10. 清理 ----------
echo -e "\n[10] 清理临时文件"
rm -rf "$WORKDIR"
echo "  已删除 $WORKDIR"

echo -e "\n============================================"
echo "  演示完成！更多详情请参考 README.md"
echo "============================================"