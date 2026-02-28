#!/bin/bash
# 备份状态API - 显示备份相关信息

echo "{"
echo "  \"backups\": ["

# 检查常见备份目录
declare -a BACKUP_DIRS=(
    "/root/.openclaw/backup:OpenClaw备份"
    "/backup:通用备份"
    "/mnt/backup:挂载备份"
    "/home/backup:用户备份"
)

first=1
for item in "${BACKUP_DIRS[@]}"; do
    IFS=':' read -r dir desc <<< "$item"
    
    if [ -d "$dir" ]; then
        # 获取备份目录信息
        count=$(find "$dir" -type f 2>/dev/null | wc -l)
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        last=$(find "$dir" -type f -mmin -60 2>/dev/null | wc -l)
        
        if [ $first -eq 0 ]; then
            echo ","
        fi
        echo -n "    {\"name\":\"$desc\",\"path\":\"$dir\",\"files\":$count,\"size\":\"$size\",\"recentBackup\":$last}"
        first=0
    fi
done

echo ""
echo "  ],"

# 检查最近的备份文件
echo "  \"recentFiles\": ["

# 查找最近修改的备份文件
find /root -name "*.tar*" -o -name "*.gz" -o -name "*.zip" -o -name "*backup*" 2>/dev/null | head -10 | while read f; do
    if [ -f "$f" ]; then
        size=$(du -h "$f" 2>/dev/null | cut -f1)
        mtime=$(stat -c %y "$f" 2>/dev/null | cut -d' ' -f1,2 | cut -c1-16)
        name=$(basename "$f")
        echo "    {\"name\":\"$name\",\"size\":\"$size\",\"modified\":\"$mtime\"},"
    fi
done | sed 's/,$//'

echo ""
echo "  ],"

# 备份统计
echo "  \"stats\": {"
echo "    \"openclawBackups\": $(find /root/.openclaw -name "*.tar*" -o -name "*.gz" 2>/dev/null | wc -l),"
echo "    \"configBackups\": $(find /root/.openclaw/config -name "*.bak*" 2>/dev/null | wc -l)"
echo "  },"

echo "  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
echo "}"
