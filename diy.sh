#!/bin/bash
set -e

# 初始化目录
rm -rf _temp_sync
mkdir -p _temp_sync

# 克隆并处理istore
git clone --depth 1 https://github.com/linkease/istore.git _temp_sync/istore
rm -rf _temp_sync/istore/.git

# 克隆并处理small-package
git clone --depth 1 https://github.com/kenzok8/small-package.git _temp_sync/small-package
cd _temp_sync/small-package

# 需要保留的目录列表
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

# 筛选目录
mkdir -p ../filtered
for folder in "${keep_folders[@]}"; do
  if [ -d "$folder" ]; then
    cp -rf "$folder" ../filtered/
  fi
done

# 合并内容到根目录
cd ../..
mv -f _temp_sync/istore/* _temp_sync/
mv -f _temp_sync/filtered/* _temp_sync/
rm -rf _temp_sync/{istore,small-package,filtered}

# 确保空目录保留
find _temp_sync -type d -empty -exec touch {}/.keep \;
