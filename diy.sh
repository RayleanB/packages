#!/bin/bash
set -eo pipefail

# 工作区定义
WORKSPACE="_temp_sync"
FILTER_DIR="${WORKSPACE}/filtered"

# 清理旧数据
echo "🧹 清理工作区..."
rm -rf "${WORKSPACE}"
mkdir -p "${WORKSPACE}" "${FILTER_DIR}"

# 克隆istore
echo "⬇️ 克隆istore仓库..."
git clone --depth 1 https://github.com/linkease/istore.git "${WORKSPACE}/istore"
rm -rf "${WORKSPACE}/istore/.git"

# 克隆small-package
echo "⬇️ 克隆small-package仓库..."
git clone --depth 1 https://github.com/kenzok8/small-package.git "${WORKSPACE}/small-package"
rm -rf "${WORKSPACE}/small-package/.git"

# 筛选目录
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
for folder in "${keep_folders[@]}"; do
  if [ -d "${folder}" ]; then
    echo "📦 复制: ${folder}"
    cp -rf "${folder}" "${FILTER_DIR}/"
  fi
done
cd -

# 合并内容
echo "🔄 合并仓库内容..."
mv -f "${WORKSPACE}/istore"/* "${WORKSPACE}/"
mv -f "${FILTER_DIR}"/* "${WORKSPACE}/"

# 清理中间目录
echo "🧽 清理临时文件..."
rm -rf "${WORKSPACE}/"{istore,small-package,filtered}

# 保留空目录
echo "📁 保留目录结构..."
find "${WORKSPACE}" -type d -empty -exec touch {}/.keep \;

echo "✅ 同步完成！"
