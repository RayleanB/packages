#!/bin/bash
set -euo pipefail

# ===================== 用户配置区 =====================
SOURCE_REPO="https://github.com/kenzok8/small-package.git"
TARGET_USER="lein134"  
TARGET_REPO_NAME="packages"
MAX_RETRY=3  # 最大重试次数

# ===================== 增强版同步函数 =====================
robust_rsync() {
    local retry=0
    until [ $retry -ge $MAX_RETRY ]
    do
        # 添加rsync容错参数
        rsync -av --ignore-missing-args --delay-updates --delete \
              --exclude='.git' --filter=':- .gitignore' \
              ./ target_repo/ && return 0
        
        echo "⚠️ 第 $((retry+1)) 次同步失败，60秒后重试..."
        sleep 60
        ((retry++))
    done
    echo "❌ 达到最大重试次数 $MAX_RETRY"
    return 1
}

# ===================== 主逻辑 =====================
main() {
    # 初始化变量
    TARGET_REPO="https://${TARGET_PAT}@github.com/${TARGET_USER}/${TARGET_REPO_NAME}.git"
    WORK_DIR="sync_temp"
    
    # 清理工作区
    rm -rf $WORK_DIR && mkdir -p $WORK_DIR
    cd $WORK_DIR

    # 克隆源仓库
    git_sparse_clone main "$SOURCE_REPO" "source_repo" "${CLONE_FOLDERS[@]}"
    
    # 克隆目标仓库
    git clone --quiet --depth 1 $TARGET_REPO target_repo
    
    # 增强同步
    if ! robust_rsync; then
        echo "::warning::部分文件同步失败，但继续提交"
    fi

    # 提交变更
    cd target_repo
    git config --local core.autocrlf false
    git add --all --verbose
    
    # 智能提交
    if ! git commit -m "Sync: $(date +'%Y-%m-%d %H:%M:%S')"; then
        echo "🟢 无变更需要提交"
        exit 0  # 正常退出
    fi
    
    # 重试推送
    git push --verbose origin main || {
        echo "🔴 推送失败，尝试强制推送"
        git push --force origin main
    }
}

# ===================== 执行入口 =====================
trap "echo '❌ 脚本被中断！'; exit 130" INT TERM
main || exit $?
trap - EXIT
echo "✅ 同步成功完成"
