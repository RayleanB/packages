#!/bin/bash

# 用户自定义配置区（修改以下变量）
SOURCE_REPO="https://github.com/kenzok8/small-package.git"  # 源仓库地址
TARGET_DIR="my-packages"                                    # 目标目录名称
CLONE_FOLDERS="luci-app-argon-config luci-theme-argon"       # 要克隆的文件夹列表（空格分隔）

# 稀疏克隆函数
function git_sparse_clone() {
  branch="$1" rurl="$2" localdir="$3" && shift 3
  git clone -b $branch --depth 1 --filter=blob:none --sparse $rurl $localdir
  cd $localdir
  git sparse-checkout init --cone
  git sparse-checkout set $@
  mv -n $@ ../
  cd ..
  rm -rf $localdir
}

# 主克隆流程
rm -rf $TARGET_DIR && mkdir $TARGET_DIR
git_sparse_clone main "$SOURCE_REPO" "$TARGET_DIR" $CLONE_FOLDERS

# 清理.git文件
find $TARGET_DIR -name ".git*" -exec rm -rf {} \;

# 自动提交
git add .
git commit -m "Sync: $(date +'%Y-%m-%d %H:%M:%S')"
git push
