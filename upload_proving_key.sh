#!/bin/bash

echo "========================================="
echo "上传 proving.key 到 GitHub"
echo "========================================="
echo ""

# 检查文件是否存在
if [ ! -f "zokrates/proving.key" ]; then
    echo "❌ ERROR: proving.key 不存在"
    echo "请先运行: ./test_all.sh"
    exit 1
fi

# 创建submission文件夹
mkdir -p submission

# 复制文件
echo "复制 proving.key..."
cp zokrates/proving.key submission/proving.key
cp zokrates/VerifyPwdAddr.zok submission/VerifyPwdAddr.zok
cp deployment_info.txt submission/ 2>/dev/null || echo "Warning: deployment_info.txt not found"

echo "✓ 文件已复制到 submission/ 文件夹"
echo ""

# 强制添加proving.key（忽略.gitignore）
echo "添加文件到 git（忽略 .gitignore）..."
git add -f submission/proving.key
git add submission/VerifyPwdAddr.zok
git add submission/deployment_info.txt 2>/dev/null || true

echo "✓ 文件已添加"
echo ""

# 提交
echo "提交到仓库..."
git commit -m "Add submission files (temporary - for download)"

echo "✓ 已提交"
echo ""

# 推送
echo "推送到 GitHub..."
git push

echo ""
echo "========================================="
echo "✅ 完成！"
echo "========================================="
echo ""
echo "现在可以从 GitHub 下载文件："
echo "https://github.com/FBI-openup/Mock_ethereum/tree/main/submission"
echo ""
echo "或者直接下载："
echo "https://raw.githubusercontent.com/FBI-openup/Mock_ethereum/main/submission/proving.key"
echo "https://raw.githubusercontent.com/FBI-openup/Mock_ethereum/main/submission/VerifyPwdAddr.zok"
echo ""
