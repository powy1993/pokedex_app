# MCP 使用示例

本文档提供了在 AI 助手中使用 MCP 工具的实际示例。

## 场景 1: 项目健康检查

**目标**: 全面了解项目状态

**步骤**:
1. 分析项目结构
```
使用 analyze_project 工具分析项目
```

2. 检查最佳实践
```
使用 check_best_practices 检查整个项目
```

3. 查找未使用的代码
```
使用 find_unused_code 工具，scope 设为 'all'
```

## 场景 2: Widget 性能优化

**目标**: 优化 DetailScreen Widget 的性能

**步骤**:
1. 分析 Widget
```
使用 analyze_widget 工具分析 screens/detail_screen.dart
```

2. 获取优化建议
```
使用 suggest_optimizations 工具优化 lib/screens/detail_screen.dart，focus_area 设为 'performance'
```

3. 使用提示词进行重构
```
使用 optimize_widget 提示词，widget_path 设为 'screens/detail_screen.dart'
```

## 场景 3: 代码重构

**目标**: 重构 PokemonProvider

**步骤**:
1. 读取当前代码
```
读取资源 file://lib/services/pokemon_provider.dart
```

2. 使用重构提示词
```
使用 refactor_code 提示词，file_path 设为 'lib/services/pokemon_provider.dart'，refactor_type 设为 'general'
```

3. 获取优化建议
```
使用 suggest_optimizations，file_path 设为 'lib/services/pokemon_provider.dart'，focus_area 设为 'maintainability'
```

## 场景 4: 新功能开发

**目标**: 添加宝可梦收藏功能

**步骤**:
1. 查看项目结构
```
读取资源 project://structure
```

2. 查看现有数据模型
```
读取资源 project://models
```

3. 使用实现功能提示词
```
使用 implement_feature 提示词，feature_description 设为 '添加宝可梦收藏功能，用户可以收藏喜欢的宝可梦并在单独页面查看'
```

## 场景 5: Bug 修复

**目标**: 修复网络请求错误

**步骤**:
1. 分析相关文件
```
使用 analyze_widget 分析 services/poke_service.dart
```

2. 使用修复提示词
```
使用 fix_issue 提示词，
issue_description 设为 '网络请求有时会超时，需要添加重试机制'，
file_path 设为 'lib/services/poke_service.dart'
```

## 场景 6: 架构改进

**目标**: 改进整体项目架构

**步骤**:
1. 分析项目结构
```
使用 analyze_project 工具，include_dependencies 设为 true
```

2. 获取架构建议
```
使用 improve_architecture 提示词
```

## 场景 7: 文档生成

**目标**: 为代码添加文档注释

**步骤**:
1. 为特定类生成文档
```
使用 generate_documentation 工具，
file_path 设为 'lib/models/pokemon.dart'，
class_name 设为 'Pokemon'
```

2. 检查可读性
```
使用 suggest_optimizations，
file_path 设为 'lib/models/pokemon.dart'，
focus_area 设为 'readability'
```

## 高级用法

### 组合多个工具

**示例**: 全面优化某个 Widget

```
1. 使用 analyze_widget 分析 screens/home_screen.dart
2. 使用 check_best_practices 检查 lib/screens/home_screen.dart
3. 使用 suggest_optimizations 获取优化建议，focus_area 设为 'all'
4. 使用 optimize_widget 提示词获取详细优化方案
```

### 持续改进流程

```
每周任务:
1. 运行 analyze_project 了解项目整体状态
2. 运行 find_unused_code 清理无用代码
3. 运行 check_best_practices 确保代码质量

每次提交前:
1. 对修改的文件运行 check_best_practices
2. 对修改的文件运行 suggest_optimizations
3. 确保遵循所有建议
```

## 提示词参数示例

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
  "refactor_type": "extract_method"
}
```

### implement_feature
```json
{
  "feature_description": "添加深色模式切换功能，可以在设置页面切换主题"
}
```

### fix_issue
```json
{
  "issue_description": "图片加载失败时应该显示占位图",
  "file_path": "lib/screens/detail_screen.dart"
}
```

## 常见问题

**Q: 工具返回的文件路径应该如何指定？**
A: 大多数工具接受相对于 `lib/` 目录的路径，例如 `screens/home_screen.dart` 而不是 `lib/screens/home_screen.dart`。

**Q: 如何一次性分析多个文件？**
A: 可以多次调用工具，或者使用 `analyze_project` 分析整个项目。

**Q: 提示词和工具有什么区别？**
A: 工具返回结构化的分析数据，提示词返回格式化的指导文本，适合 AI 进行深度分析。

**Q: 如何自定义分析规则？**
A: 编辑 `lib/mcp/mcp_tools.dart` 文件，修改相应的分析方法。

## 最佳实践总结

1. **循序渐进**: 先用工具分析，再用提示词深入
2. **关注重点**: 根据需求选择合适的 focus_area
3. **定期检查**: 建立定期运行分析的习惯
4. **文档优先**: 优先为公共 API 生成文档
5. **性能优先**: 定期检查 Widget 性能
6. **持续改进**: 根据建议不断优化代码

## 下一步

尝试在你的 AI 助手中运行这些示例，体验 MCP 如何提升开发效率！
