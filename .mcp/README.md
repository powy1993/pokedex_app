# Flutter Pokedex MCP 集成

本项目已集成 MCP (Model Context Protocol) 支持，让 AI 助手能够更好地理解和优化项目代码。

## 功能特性

### 1. 工具 (Tools)
MCP 提供以下代码分析和优化工具：

- **analyze_project**: 分析项目结构、依赖关系和代码复杂度
- **analyze_widget**: 分析特定 Widget 文件，提供性能优化建议
- **suggest_optimizations**: 为指定文件提供代码优化建议
- **find_unused_code**: 查找项目中可能未使用的代码和依赖
- **check_best_practices**: 检查代码是否遵循 Flutter 最佳实践
- **generate_documentation**: 为指定文件或类生成文档注释

### 2. 资源 (Resources)
访问项目的关键文件和信息：

- `file://pubspec.yaml`: 项目配置文件
- `file://analysis_options.yaml`: Lint 配置
- `file://lib/`: 源代码目录
- `project://structure`: 项目完整目录结构
- `project://widgets`: 所有 Widget 列表
- `project://models`: 数据模型列表

### 3. 提示词 (Prompts)
预定义的 AI 提示词模板：

- **optimize_widget**: 优化指定 Widget 的性能和代码质量
- **refactor_code**: 重构代码以提高可维护性
- **implement_feature**: 实现新功能的指导
- **fix_issue**: 修复代码问题的建议
- **improve_architecture**: 改进项目架构的建议

## 快速开始

### 1. 安装依赖

```bash
fvm flutter pub get
```

### 2. 启动 MCP 服务器

**macOS/Linux:**
```bash
chmod +x scripts/start_mcp_server.sh
./scripts/start_mcp_server.sh
```

**Windows:**
```cmd
scripts\start_mcp_server.bat
```

### 3. 配置 CodeBuddy

**好消息！** CodeBuddy 会自动识别项目中的 MCP 服务器，无需手动配置！

CodeBuddy 会自动扫描：
- 项目根目录下的 `.mcp` 文件夹
- `mcp_server/` 配置文件
- MCP 启动脚本

只要这些文件存在，CodeBuddy 就能自动加载 MCP 功能。

### 4. 开始使用

直接在 CodeBuddy 中输入命令即可，无需重启！

## 使用示例

### 分析项目
```
请使用 MCP 工具分析当前项目结构
```

### 优化 Widget
```
使用 MCP 分析 screens/detail_screen.dart 并提供优化建议
```

### 检查最佳实践
```
检查项目是否遵循 Flutter 最佳实践
```

### 重构代码
```
使用 refactor_code 提示词重构 services/poke_service.dart
```

## 工具详细说明

### analyze_project
分析整个项目，包括：
- 项目结构和文件组织
- 文件和代码行数统计
- 依赖分析
- 代码复杂度评估

参数：
- `include_dependencies` (boolean): 是否包含依赖分析，默认 true

### analyze_widget
深入分析 Widget 文件：
- 统计 StatefulWidget 和 StatelessWidget 数量
- 分析 build 方法复杂度
- 检查状态管理方式
- 提供性能优化建议

参数：
- `file_path` (string, 必需): Widget 文件的相对路径

### suggest_optimizations
提供代码优化建议：
- 性能优化（const 使用、列表优化等）
- 可读性改进
- 可维护性提升

参数：
- `file_path` (string, 必需): 要优化的文件路径
- `focus_area` (string): 优化重点，可选值：performance, readability, maintainability, all

## 最佳实践

1. **定期运行分析**: 在开发过程中定期使用 `analyze_project` 了解项目状态
2. **代码审查**: 在提交代码前使用 `check_best_practices` 检查代码质量
3. **性能优化**: 使用 `analyze_widget` 找出性能瓶颈
4. **重构指导**: 使用相关提示词获取重构建议

## 故障排除

### MCP 服务器无法启动
1. 确保已安装 Flutter 和 FVM
2. 运行 `fvm flutter pub get` 安装依赖
3. 检查脚本权限（macOS/Linux 需要执行权限）

### CodeBuddy 无法识别 MCP 服务器
1. 确认 `.mcp` 文件夹存在
2. 确认 `mcp_server/mcp_config.json` 存在
3. 运行测试脚本验证服务器功能
4. 查看 CodeBuddy 的 MCP 日志

### 工具调用失败
1. 确认文件路径格式正确（相对于项目根目录）
2. 检查文件是否存在
3. 查看错误消息获取详细信息

## 开发和扩展

你可以通过以下方式扩展 MCP 功能：

### 添加新工具
编辑 `lib/mcp/mcp_tools.dart`，在 `listTools()` 和 `callTool()` 中添加新工具。

### 添加新资源
编辑 `lib/mcp/mcp_resources.dart`，在 `listResources()` 和 `readResource()` 中添加新资源。

### 添加新提示词
编辑 `lib/mcp/mcp_prompts.dart`，在 `listPrompts()` 和 `getPrompt()` 中添加新提示词。

## 技术架构

```
lib/mcp/
├── mcp_server.dart      # MCP 服务器主程序
├── mcp_tools.dart       # 工具定义和实现
├── mcp_resources.dart   # 资源管理
└── mcp_prompts.dart     # 提示词模板

scripts/
├── start_mcp_server.sh  # macOS/Linux 启动脚本
└── start_mcp_server.bat # Windows 启动脚本

mcp_server/
└── mcp_config.json      # MCP 配置示例
```

## 相关链接

- [MCP 协议规范](https://modelcontextprotocol.io)
- [Flutter 最佳实践](https://flutter.dev/docs/development/ui/layout)
- [Dart 代码风格指南](https://dart.dev/guides/language/effective-dart)

## 反馈和贡献

如果你有任何问题或建议，欢迎提出 Issue 或 Pull Request。
