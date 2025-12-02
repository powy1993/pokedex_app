#!/bin/bash

# Flutter Pokedex MCP Server 启动脚本

# 设置项目根目录
export PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "启动 Flutter Pokedex MCP Server..."
echo "项目路径: $PROJECT_ROOT"

# 确保使用 fvm flutter
cd "$PROJECT_ROOT"

# 运行 MCP 服务器
fvm dart run lib/mcp/mcp_server.dart

echo "MCP Server 已停止"
