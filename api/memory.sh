#!/bin/bash
# 记忆系统状态API

WORKSPACE="/root/.openclaw/workspace"

# 获取各记忆文件状态
MEMORY_FILES=0
if [ -f "$WORKSPACE/MEMORY.md" ]; then
    MEMORY_FILES=$((MEMORY_FILES + 1))
fi

# 每日日记数量
DAILY_FILES=0
if [ -d "$WORKSPACE/memory" ]; then
    DAILY_FILES=$(ls "$WORKSPACE/memory"/*.md 2>/dev/null | wc -l)
fi

# 错题本
SELF_REVIEW=0
if [ -f "$WORKSPACE/self-review.md" ]; then
    SELF_REVIEW=1
fi

# 核心文件
CORE_FILES=0
if [ -d "$WORKSPACE/core-memory" ]; then
    CORE_FILES=$(ls "$WORKSPACE/core-memory"/*.md 2>/dev/null | wc -l)
fi

# TOOLS配置
TOOLS_FILE=0
if [ -f "$WORKSPACE/TOOLS.md" ]; then
    TOOLS_FILE=1
fi

# 总计
TOTAL=$((MEMORY_FILES + DAILY_FILES + SELF_REVIEW + CORE_FILES + TOOLS_FILE))

echo "{"
echo "  \"memory\": $MEMORY_FILES,"
echo "  \"daily\": $DAILY_FILES,"
echo "  \"selfReview\": $SELF_REVIEW,"
echo "  \"coreFiles\": $CORE_FILES,"
echo "  \"tools\": $TOOLS_FILE,"
echo "  \"total\": $TOTAL,"
echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"
