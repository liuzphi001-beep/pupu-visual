#!/bin/bash
# GitHub项目状态API

REPO="liuzphi001-beep/pupu-visual"
cd /root/.openclaw/workspace/project/pupu-visual

# 获取git状态
IS_DIRTY=$(git status --porcelain 2>/dev/null | wc -l)
LAST_COMMIT=$(git log -1 --format='%h %s' 2>/dev/null || echo "none")
LAST_PUSH=$(git log -1 --format='%ci' origin/main 2>/dev/null || echo "unknown")

# 获取远程仓库信息
BRANCH=$(git branch --show-current 2>/dev/null || echo "main")
COMMITS_AHEAD=$(git rev-list HEAD --not origin/main --count 2>/dev/null || echo 0)

echo "{"
echo "  \"repo\": \"$REPO\","
echo "  \"branch\": \"$BRANCH\","
echo "  \"dirty\": $IS_DIRTY,"
echo "  \"ahead\": $COMMITS_AHEAD,"
echo "  \"lastCommit\": \"$LAST_COMMIT\","
echo "  \"lastPush\": \"$LAST_PUSH\","
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"
