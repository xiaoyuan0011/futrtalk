#!/bin/bash
# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null
then
    echo "Docker 没有安装，开始下载并安装最新版本的 Docker..."

    # 更新系统包
    sudo apt update -y

    # 安装依赖包
    sudo apt install -y ca-certificates curl gnupg lsb-release

    # 添加 Docker 官方 GPG 密钥
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # 设置 Docker 软件仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 更新系统包并安装 Docker
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动 Docker 服务
    sudo systemctl start docker

    # 设置 Docker 开机启动
    sudo systemctl enable docker

    # 显示 Docker 版本确认安装成功
    docker --version

    echo "Docker 安装完成！"
else
    echo "Docker 已安装，版本如下："
    docker --version
fi

# 检查 Docker Compose v2 是否已安装
if ! docker compose version &> /dev/null
then
    echo "Docker Compose v2 没有安装，开始安装最新版本的 Docker Compose v2..."

    # 使用 apt 安装 Docker Compose 插件（v2 已集成到 Docker 中）
    sudo apt install -y docker-compose-plugin

    # 显示 Docker Compose v2 版本确认安装成功
    docker compose version

    echo "Docker Compose v2 安装完成！"
else
    echo "Docker Compose v2 已安装，版本如下："
    docker compose version
fi
