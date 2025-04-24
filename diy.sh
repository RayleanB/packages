#!/bin/bash
set -eo pipefail

WORKSPACE="_temp_sync"
FILTER_DIR="${WORKSPACE}/filtered"

# 清理旧数据
rm -rf "${WORKSPACE}"
mkdir -p "${WORKSPACE}"

# 克隆并处理istore
echo "→ Cloning istore..."
git clone --depth 1 https://github.com/linkease/istore.git "${WORKSPACE}/istore"
rm -rf "${WORKSPACE}/istore/.git"

# 克隆并处理small-package
echo "→ Cloning small-package..."
git clone --depth 1 https://github.com/kenzok8/small-package.git "${WORKSPACE}/small-package"
rm -rf "${WORKSPACE}/small-package/.git"

# 创建过滤目录（强制创建父级目录）
mkdir -p "${FILTER_DIR}"

# 筛选目录列表
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

echo "→ Filtering small-package..."
cd "${WORKSPACE}/small-package"
for folder in "${keep_folders[@]}"; do
  if [ -d "${folder}" ]; then
    echo "Copying ${folder}..."
    cp -rf "${folder}" "${FILTER_DIR}/" || true
  fi
done
cd ..

# 合并内容（使用rsync更可靠）
echo "→ Merging contents..."
rsync -a istore/ "${WORKSPACE}/"
rsync -a filtered/ "${WORKSPACE}/"

# 清理中间目录
rm -rf istore small-package filtered

# 确保空目录
find "${WORKSPACE}" -type d -empty -exec touch {}/.keep \;

echo "✅ Sync completed"
