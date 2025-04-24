#!/bin/bash
set -eo pipefail

# 工作目录定义
WORKSPACE="_temp_workspace"
TARGET_DIR="iStore"

# 清理旧工作区
echo "🧹 初始化工作环境..."
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

# 克隆源仓库函数
clone_repo() {
  repo_url=$1
  target_dir=$2
  
  echo "⬇️ 正在克隆 $repo_url..."
  git clone --depth 1 "$repo_url" "$WORKSPACE/$target_dir"
  rm -rf "$WORKSPACE/$target_dir/.git"
}

# 克隆并处理istore
clone_repo https://github.com/linkease/istore.git istore

# 克隆并处理small-package
clone_repo https://github.com/kenzok8/small-package.git small-package

# 过滤small-package目录
echo "🔍 过滤small-package内容..."
KEEP_FOLDERS=(
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

cd "$WORKSPACE/small-package"
mkdir -p "../filtered"
for folder in "${KEEP_FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    echo "📦 保留: $folder"
    cp -rf "$folder" "../filtered/"
  fi
done
cd ..

# 合并内容到目标目录
echo "🔄 合并仓库内容..."
mkdir -p "$TARGET_DIR"
cp -rf istore/* "$TARGET_DIR/"
cp -rf filtered/* "$TARGET_DIR/"

# 保留空目录结构
echo "📁 维护目录结构..."
find "$TARGET_DIR" -type d -empty -exec touch {}/.keep \;

# 同步到仓库根目录
echo "🚚 准备发布内容..."
cd ..
rm -rf !(".git"|".github"|"diy.sh")
cp -rf "$WORKSPACE/$TARGET_DIR"/* .

# 最终清理
echo "🧽 清理临时文件..."
rm -rf "$WORKSPACE"
