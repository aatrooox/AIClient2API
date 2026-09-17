#!/bin/bash
set -e

# 设置输出颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}   AIClient2API 上游代码同步工具   ${NC}"
echo -e "${YELLOW}========================================${NC}"

# 1. 确保在 Git 仓库根目录
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# 2. 检查是否有未提交的修改
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}[提示] 检测到工作区有未提交的代码，正在自动执行 git stash 保存...${NC}"
    STASHED=1
    git stash push -m "Auto stash before sync upstream at $(date +'%Y-%m-%d %H:%M:%S')"
else
    STASHED=0
fi

CURRENT_BRANCH=$(git branch --show-current)
echo -e "[信息] 当前工作分支: ${GREEN}${CURRENT_BRANCH}${NC}"

# 3. 检查 upstream remote
if ! git remote | grep -q "^upstream$"; then
    echo -e "[提示] 未检测到 upstream remote，正在自动添加..."
    git remote add upstream https://github.com/justlovemaki/AIClient2API.git
fi

echo -e "[更新] 正在从上游 (upstream) 拉取最新分支与代码..."
git fetch upstream

echo -e "[同步] 切换到 main 分支同步上游主分支..."
git checkout main
git merge --ff-only upstream/main
echo -e "[推送] 同步最新 main 到个人 Fork (origin)..."
git push origin main

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo -e "[合并] 切换回 ${GREEN}${CURRENT_BRANCH}${NC} 分支并将最新 main 合入..."
    git checkout "$CURRENT_BRANCH"
    if git merge main -m "chore: sync upstream main into ${CURRENT_BRANCH}"; then
        echo -e "${GREEN}[成功] 最新上游代码已平滑合入 ${CURRENT_BRANCH} 分支！${NC}"
    else
        echo -e "${RED}[警告] 合并时发生冲突，请手动解决冲突后执行 git commit。${NC}"
        exit 1
    fi
fi

# 恢复暂存的修改
if [ $STASHED -eq 1 ]; then
    echo -e "[恢复] 正在恢复之前暂存的工作区修改..."
    git stash pop
fi

# 检查依赖是否有更新并安装
echo -e "[依赖] 检查并更新项目依赖..."
pnpm install

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}   同步完成！代码已是最新状态。   ${NC}"
echo -e "${GREEN}========================================${NC}"
