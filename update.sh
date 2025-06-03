#!/bin/sh

# 设置 compose 文件的下载地址
COMPOSE_URL="https://github.com/xiaoyuan0011/futrtalk/main/docker-compose-update.yml"  # ✅ 请替换为实际链接
COMPOSE_FILE="docker-compose-update.yml"

# 当前目录
SCRIPT_DIR=$(cd "$(dirname "$0")"; pwd)
cd "$SCRIPT_DIR"

echo "📥 正在下载最新 docker-compose-update.yml ..."
wget -q -O "$COMPOSE_FILE" "$COMPOSE_URL"
if [ $? -ne 0 ]; then
  echo "❌ 下载 docker-compose.yml 失败，请检查链接：$COMPOSE_URL"
  exit 1
fi
echo "✅ docker-compose.yml 已更新"

echo "⬇️ 拉取最新镜像中..."
docker compose -f "$COMPOSE_FILE" pull

echo "🛑 停止旧容器..."
docker compose -f "$COMPOSE_FILE" down

echo "🚀 启动新容器..."
docker compose -f "$COMPOSE_FILE" up -d

echo "🧹 清理无用镜像..."
docker image prune -f

echo "🎉 Docker 容器更新完成！"
