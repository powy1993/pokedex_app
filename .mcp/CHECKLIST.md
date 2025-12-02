# MCP 安装验证清单

使用此清单确保 MCP 功能正确安装和配置。

## ✅ 安装验证

### 第 1 步: 文件检查
- [x] `lib/mcp/mcp_server.dart` - MCP 服务器主程序
- [x] `lib/mcp/mcp_tools.dart` - 代码分析工具
- [x] `lib/mcp/mcp_resources.dart` - 资源管理
- [x] `lib/mcp/mcp_prompts.dart` - AI 提示词
- [x] `scripts/start_mcp_server.sh` - 启动脚本（macOS/Linux）
- [x] `scripts/start_mcp_server.bat` - 启动脚本（Windows）
- [x] `scripts/test_mcp.dart` - 测试脚本
- [x] `mcp_server/mcp_config.json` - MCP 配置示例
- [x] `mcp_server/claude_config.json` - Claude 配置（自动生成）

### 第 2 步: 依赖检查
- [x] `path` 包已添加到 pubspec.yaml
- [x] 运行 `fvm flutter pub get` 成功

### 第 3 步: 权限检查（仅 macOS/Linux）
- [x] `start_mcp_server.sh` 具有执行权限

### 第 4 步: 测试验证
运行测试脚本：
```bash
fvm dart run scripts/test_mcp.dart
```

预期输出：
```
=== Flutter Pokedex MCP 测试 ===

--- 测试 1: 检查文件结构 ---
✓ lib/mcp/mcp_server.dart
✓ lib/mcp/mcp_tools.dart
✓ lib/mcp/mcp_resources.dart
✓ lib/mcp/mcp_prompts.dart
✓ scripts/start_mcp_server.sh
✓ mcp_server/mcp_config.json

--- 测试 2: 检查依赖 ---
✓ path 包

--- 测试 3: 测试工具列表 ---
✓ MCP 服务器文件完整
✓ 可以使用以下工具:
  - analyze_project
  - analyze_widget
  - suggest_optimizations
  - find_unused_code
  - check_best_practices
  - generate_documentation

--- 测试 4: 检查脚本权限 ---
✓ start_mcp_server.sh 可执行

--- 测试 5: 生成配置文件 ---
✓ 配置文件已生成

=== 测试完成 ===
```

## 📋 配置 Claude Desktop

### macOS 配置
- [ ] 打开配置文件：`~/Library/Application Support/Claude/claude_desktop_config.json`
- [ ] 复制 `mcp_server/claude_config.json` 的内容
- [ ] 确认使用绝对路径
- [ ] 保存文件
- [ ] 重启 Claude Desktop

### Windows 配置
- [ ] 打开配置文件：`%APPDATA%\Claude\claude_desktop_config.json`
- [ ] 修改路径为 Windows 格式
- [ ] 确认使用绝对路径
- [ ] 保存文件
- [ ] 重启 Claude Desktop

## 🧪 功能测试

在 Claude Desktop 中测试以下功能：

### 测试 1: 列出工具
输入：
```
请列出 pokedex-flutter MCP 服务器提供的所有工具
```

预期：显示 6 个工具列表

### 测试 2: 分析项目
输入：
```
使用 analyze_project 工具分析项目
```

预期：返回项目结构、文件统计等信息

### 测试 3: 读取资源
输入：
```
读取资源 project://structure
```

预期：返回项目目录树结构

### 测试 4: 使用提示词
输入：
```
使用 optimize_widget 提示词，widget_path 设为 'screens/home_screen.dart'
```

预期：返回详细的优化建议

## 🔧 故障排除

### 如果工具列表为空
- [ ] 检查 Claude Desktop 配置文件路径是否正确
- [ ] 确认使用绝对路径而非相对路径
- [ ] 检查路径中是否有空格或特殊字符
- [ ] 完全退出并重启 Claude Desktop
- [ ] 查看 Claude Desktop 的开发者工具（如果有）

### 如果服务器启动失败
- [ ] 运行 `fvm flutter --version` 确认 Flutter 已安装
- [ ] 运行 `fvm flutter pub get` 重新安装依赖
- [ ] 手动运行 `./scripts/start_mcp_server.sh` 查看错误信息
- [ ] 检查项目路径是否正确

### 如果工具调用出错
- [ ] 确认文件路径格式正确（相对于 lib/ 目录）
- [ ] 检查文件是否存在
- [ ] 查看错误消息了解具体问题
- [ ] 参考 `.mcp/examples.md` 中的示例

## ✨ 完成！

当所有项目都打勾时，MCP 功能就完全可用了！

## 📚 下一步

- [ ] 阅读 `.mcp/QUICKSTART.md` 快速入门
- [ ] 查看 `.mcp/examples.md` 学习使用示例
- [ ] 参考 `.mcp/README.md` 了解完整功能
- [ ] 开始使用 AI 优化你的代码！

---

**提示**: 保存此清单，每次在新环境中配置时使用。
