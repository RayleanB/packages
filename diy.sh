#!/bin/bash
set -eo pipefail

# 工作区定义（使用临时目录）
TEMP_DIR="$(mktemp -d)"
WORKSPACE="${TEMP_DIR}/_temp_sync"
FILTER_DIR="${WORKSPACE}/filtered"

# 清理旧数据
echo "🧹 初始化工作区..."
rm -rf "${WORKSPACE}"
mkdir -p "${WORKSPACE}" "${FILTER_DIR}"

# 克隆源仓库
echo "⬇️ 克隆istore仓库..."
git clone --depth 1 https://github.com/linkease/istore.git "${WORKSPACE}/istore"
rm -rf "${WORKSPACE}/istore/.git"

echo "⬇️ 克隆small-package仓库..."
git clone --depth 1 https://github.com/kenzok8/small-package.git "${WORKSPACE}/small-package"
rm -rf "${WORKSPACE}/small-package/.git"

# 过滤small-package
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

echo "🔍 过滤内容..."
cd "${WORKSPACE}/small-package"
for folder in "${keep_folders[@]}"; do
  if [ -d "${folder}" ]; then
    echo "📦 复制: ${folder}"
    mkdir -p "${FILTER_DIR}"
    cp -rf "${folder}" "${FILTER_DIR}/"
  fi
done
cd -

# 合并内容
echo "🔄 合并文件..."
mv -f "${WORKSPACE}/istore"/* "${WORKSPACE}/" 2>/dev/null || true
mv -f "${FILTER_DIR}"/* "${WORKSPACE}/" 2>/dev/null || true

# 最终处理
echo "📁 准备发布内容..."
mkdir -p "${TEMP_DIR}/final_output"
mv -f "${WORKSPACE}"/* "${TEMP_DIR}/final_output/"

# 移动到工作区可见目录
echo "🚚 转移文件..."
mv -f "${TEMP_DIR}/final_output" "${GITHUB_WORKSPACE}/_temp_sync"

# 清理所有临时文件
echo "🧽 清理临时目录..."
rm -rf "${TEMP_DIR}"

echo "✅ 同步完成！"
