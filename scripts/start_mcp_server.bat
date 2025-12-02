@echo off
REM Flutter Pokedex MCP Server 启动脚本 (Windows)

REM 设置项目根目录
set PROJECT_ROOT=%~dp0..

echo 启动 Flutter Pokedex MCP Server...
echo 项目路径: %PROJECT_ROOT%

REM 切换到项目目录
cd /d "%PROJECT_ROOT%"

REM 运行 MCP 服务器
fvm dart run lib/mcp/mcp_server.dart

echo MCP Server 已停止
pause
