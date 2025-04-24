#!/bin/bash
set -eo pipefail

# 临时工作区定义
WORKSPACE="_temp_sync"
mkdir -p "$WORKSPACE"

# 克隆istore
echo "⬇️ 克隆istore仓库..."
git clone --depth 1 https://github.com/linkease/istore.git "${WORKSPACE}/istore"
rm -rf "${WORKSPACE}/istore/.git"

# 克隆并处理small-package
echo "⬇️ 克隆small-package仓库..."
git clone --depth 1 https://github.com/kenzok8/small-package.git "${WORKSPACE}/small-package"
rm -rf "${WORKSPACE}/small-package/.git"

# 筛选small-package目录
keep_folders=(
  istoreenhance
  luci-app-istoredup
  luci-app-istoreenhance
  luci-app-istorego
  luci-app-istorepanel
  luci-app-istorex
  luci-app-quickstart
  quickstart
  vmease
)

echo "🔍 过滤small-package内容..."
cd "${WORKSPACE}/small-package"
mkdir -p "../filtered"
for folder in "${keep_folders[@]}"; do
  if [ -d "$folder" ]; then
    echo "📦 保留: $folder"
    cp -rf "$folder" "../filtered/"
  fi
done
cd ..

# 合并内容到根目录
echo "🔄 合并仓库内容..."
mv -f istore/* . 2>/dev/null || true
mv -f filtered/* . 2>/dev/null || true

# 清理中间文件
echo "🧹 清理临时文件..."
rm -rf istore small-package filtered

# 保留空目录结构
echo "📁 维护目录结构..."
find . -type d -empty -exec touch {}/.keep \;

echo "✅ 同步完成！"
