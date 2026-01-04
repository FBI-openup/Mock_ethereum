#!/bin/bash

echo "========================================="
echo "准备提交材料"
echo "========================================="
echo ""

# 创建提交文件夹
mkdir -p submission

# 1. 复制 VerifyPwdAddr.zok
echo "✓ 复制 VerifyPwdAddr.zok"
cp zokrates/VerifyPwdAddr.zok submission/

# 2. 复制 proving.key
if [ -f "zokrates/proving.key" ]; then
    echo "✓ 复制 proving.key"
    cp zokrates/proving.key submission/
else
    echo "❌ ERROR: proving.key 不存在！请先运行 test_all.sh"
    exit 1
fi

# 3. 读取部署信息
if [ -f "deployment_info.txt" ]; then
    echo "✓ 读取部署信息"
    cat deployment_info.txt
    cp deployment_info.txt submission/
else
    echo "❌ ERROR: deployment_info.txt 不存在！请先运行 test_all.sh"
    exit 1
fi

echo ""
echo "========================================="
echo "提交材料准备完成！"
echo "========================================="
echo ""
echo "文件位置: ./submission/"
ls -lh submission/
echo ""
echo "请通过以下方式下载到本地："
echo "1. 使用 scp 命令"
echo "2. 或者在文件管理器中通过 SSH 挂载"
echo ""
echo "邮件模板："
echo "---"
cat deployment_info.txt
echo "---"
echo ""
echo "收件人: daniel.augot@inria.fr"
echo "附件: submission/VerifyPwdAddr.zok, submission/proving.key"
