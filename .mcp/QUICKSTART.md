# 快速开始指南

按照以下步骤在 5 分钟内启用 MCP 功能。

## 第 1 步: 安装依赖

```bash
cd /Users/wangyuxing/Desktop/pokedex/pokedex_app
fvm flutter pub get
```

## 第 2 步: 测试 MCP 服务器

运行测试脚本确保一切正常：

```bash
fvm dart run scripts/test_mcp.dart
```

## 第 3 步: 配置 CodeBuddy

CodeBuddy 会自动识别项目根目录下的 `.mcp` 文件夹和 MCP 服务器配置，无需手动配置！

### 自动配置（推荐）

CodeBuddy 已经自动检测到 MCP 服务器，你可以直接开始使用。

### 手动配置（可选）

如果需要手动配置，可以在 CodeBuddy 的 MCP 设置中添加：

```json
{
  "name": "pokedex-flutter",
  "command": "bash",
  "args": ["/Users/wangyuxing/Desktop/pokedex/pokedex_app/scripts/start_mcp_server.sh"],
  "env": {
    "PROJECT_ROOT": "/Users/wangyuxing/Desktop/pokedex/pokedex_app"
  }
}
```

**注意**: CodeBuddy 通常会自动使用当前项目的工作目录，所以大多数情况下不需要手动配置！

## 第 4 步: 验证 MCP 功能

在 CodeBuddy 中直接输入：

```
请列出当前项目的 MCP 工具
```

或者：

```
使用 analyze_project 工具分析项目
```

如果看到工具列表或分析结果，说明配置成功！

## 开始使用

尝试以下命令：

### 分析项目
```
使用 analyze_project 工具分析我的项目结构
```

### 优化 Widget
```
使用 analyze_widget 工具分析 screens/detail_screen.dart
```

### 获取优化建议
```
使用 suggest_optimizations 为 lib/screens/home_screen.dart 提供性能优化建议
```

## 故障排除

### 工具列表显示为空

1. CodeBuddy 会自动扫描项目中的 MCP 服务器
2. 确保 `.mcp` 文件夹存在
3. 尝试手动运行测试脚本验证服务器功能

### 服务器启动失败

1. 运行测试脚本检查问题：
```bash
fvm dart run scripts/test_mcp.dart
```

2. 确保已安装依赖：
```bash
fvm flutter pub get
```

3. 检查 Flutter 版本：
```bash
fvm flutter --version
```

### 工具调用出错

1. 检查文件路径格式（使用相对路径，相对于 lib/ 目录）
2. 确认文件存在
3. 在 CodeBuddy 中查看 MCP 日志获取详细错误信息

## 下一步

- 查看 [README.md](.mcp/README.md) 了解完整功能
- 查看 [examples.md](.mcp/examples.md) 学习使用示例
- 开始使用 MCP 优化你的代码！

## 需要帮助？

如果遇到问题，请：
1. 查看完整文档：`.mcp/README.md`
2. 运行测试脚本：`fvm dart run scripts/test_mcp.dart`
3. 检查 MCP 服务器日志
