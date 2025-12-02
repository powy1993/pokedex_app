# MCP 快速参考卡片

## 🎯 常用命令

### 项目分析
```
使用 analyze_project 工具分析项目
```

### Widget 优化
```
使用 analyze_widget 分析 screens/detail_screen.dart
使用 suggest_optimizations 优化 lib/screens/home_screen.dart，focus_area 设为 'performance'
```

### 代码检查
```
使用 check_best_practices 检查整个项目
使用 find_unused_code 工具，scope 设为 'all'
```

### 文档生成
```
使用 generate_documentation 为 lib/models/pokemon.dart 生成文档
```

### 资源访问
```
读取资源 project://structure
读取资源 project://widgets
读取资源 file://pubspec.yaml
```

### AI 提示词
```
使用 optimize_widget 提示词，widget_path 设为 'screens/detail_screen.dart'
使用 refactor_code 提示词，file_path 设为 'lib/services/poke_service.dart'
使用 implement_feature 提示词，feature_description 设为 '添加收藏功能'
```

## 📝 工具参数

### analyze_widget
```json
{
  "file_path": "screens/home_screen.dart"
}
```

### suggest_optimizations
```json
{
  "file_path": "lib/screens/detail_screen.dart",
  "focus_area": "performance"  // performance | readability | maintainability | all
}
```

### check_best_practices
```json
{
  "file_path": "lib/models/pokemon.dart"  // 可选，不提供则检查整个项目
}
```

### find_unused_code
```json
{
  "scope": "all"  // dependencies | widgets | utils | all
}
```

### generate_documentation
```json
{
  "file_path": "lib/models/pokemon.dart",
  "class_name": "Pokemon"  // 可选
}
```

## 🎨 提示词参数

### optimize_widget
```json
{
  "widget_path": "screens/detail_screen.dart"
}
```

### refactor_code
```json
{
  "file_path": "lib/services/poke_service.dart",
  "refactor_type": "extract_widget"  // extract_widget | extract_method | simplify | general
}
```

### implement_feature
```json
{
  "feature_description": "添加宝可梦收藏功能"
}
```

### fix_issue
```json
{
  "issue_description": "网络请求超时",
  "file_path": "lib/services/poke_service.dart"
}
```

## 🔧 故障排除

### 服务器无法启动
```bash
fvm flutter pub get
fvm dart run scripts/test_mcp.dart
```

### 工具调用失败
- 检查文件路径（使用相对路径，相对于 `lib/` 目录）
- 确认文件存在
- 查看错误消息

### 配置不生效
- 使用绝对路径
- 重启 Claude Desktop
- 检查 JSON 格式

## 📚 文档位置

- **快速开始**: `.mcp/QUICKSTART.md`
- **完整文档**: `.mcp/README.md`
- **使用示例**: `.mcp/examples.md`
- **验证清单**: `.mcp/CHECKLIST.md`
- **集成总结**: `MCP_INTEGRATION.md`

## 🎓 学习路径

1. 阅读 **QUICKSTART.md** (5 分钟)
2. 尝试所有工具 (30 分钟)
3. 查看 **examples.md** 学习场景
4. 集成到日常开发流程

## 💡 最佳实践

✅ 提交前运行 `check_best_practices`
✅ 使用 `focus_area` 针对性优化
✅ 定期运行 `analyze_project`
✅ 为公共 API 生成文档
✅ 结合工具和提示词使用

---

**打印此页作为参考！** 📄
