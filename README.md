# 噗噗控制台 V5.1

本地部署版本 - 安全不公开

## 快速启动

### 方式1: Python (无需Docker)
```bash
cd /root/.openclaw/workspace/project/pupu-visual
python3 -m http.server 8080
# 访问 http://服务器IP:8080
```

### 方式2: Docker
```bash
docker build -t pupu-console .
docker run -d -p 8080:80 --name pupu-console pupu-console
# 访问 http://服务器IP:8080
```

### 方式3: Docker Compose
```bash
docker-compose up -d
```

## 安全码
- 默认安全码: pupu2026
- 可在index.html中修改

## 迭代
本地修改index.html后刷新即可见，无需推送
