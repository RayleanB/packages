#!/bin/bash
set -e

# 初始化临时目录
WORKSPACE="_temp_sync"
rm -rf $WORKSPACE
mkdir -p $WORKSPACE

# 克隆istore仓库
git clone --depth 1 https://github.com/linkease/istore.git $WORKSPACE/istore
rm -rf $WORKSPACE/istore/.git

# 克隆small-package仓库
git clone --depth 1 https://github.com/kenzok8/small-package.git $WORKSPACE/small-package
rm -rf $WORKSPACE/small-package/.git

# 筛选small-package目录
FILTER_DIR="$WORKSPACE/filtered"
mkdir -p $FILTER_DIR

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

cd $WORKSPACE/small-package
for folder in "${keep_folders[@]}"; do
  if [ -d "$folder" ]; then
    cp -rf "$folder" $FILTER_DIR/
  fi
done
cd ..

# 合并内容到根目录
mv istore/* .
mv filtered/* .

# 清理中间目录
rm -rf istore small-package filtered

# 保留空目录
find . -type d -empty -exec touch {}/.keep \;

# 返回项目根目录
cd ..
