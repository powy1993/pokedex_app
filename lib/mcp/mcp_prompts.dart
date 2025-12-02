import 'dart:io';
import 'package:path/path.dart' as path;

/// MCP 提示词管理 - 提供预定义的 AI 提示词模板
class McpPrompts {
  final String projectRoot;

  McpPrompts(this.projectRoot);

  /// 列出所有可用提示词
  List<Map<String, dynamic>> listPrompts() {
    return [
      {
        'name': 'optimize_widget',
        'description': '优化指定 Widget 的性能和代码质量',
        'arguments': [
          {
            'name': 'widget_path',
            'description': 'Widget 文件路径',
            'required': true,
          },
        ],
      },
      {
        'name': 'refactor_code',
        'description': '重构代码以提高可维护性',
        'arguments': [
          {
            'name': 'file_path',
            'description': '要重构的文件路径',
            'required': true,
          },
          {
            'name': 'refactor_type',
            'description': '重构类型：extract_widget, extract_method, simplify',
            'required': false,
          },
        ],
      },
      {
        'name': 'implement_feature',
        'description': '实现新功能的指导',
        'arguments': [
          {
            'name': 'feature_description',
            'description': '功能描述',
            'required': true,
          },
        ],
      },
      {
        'name': 'fix_issue',
        'description': '修复代码问题的建议',
        'arguments': [
          {
            'name': 'issue_description',
            'description': '问题描述',
            'required': true,
          },
          {
            'name': 'file_path',
            'description': '相关文件路径',
            'required': false,
          },
        ],
      },
      {
        'name': 'improve_architecture',
        'description': '改进项目架构的建议',
        'arguments': [],
      },
    ];
  }

  /// 获取指定提示词
  Future<Map<String, dynamic>> getPrompt(String promptName, Map<String, dynamic> arguments) async {
    switch (promptName) {
      case 'optimize_widget':
        return await _getOptimizeWidgetPrompt(arguments);
      case 'refactor_code':
        return await _getRefactorCodePrompt(arguments);
      case 'implement_feature':
        return await _getImplementFeaturePrompt(arguments);
      case 'fix_issue':
        return await _getFixIssuePrompt(arguments);
      case 'improve_architecture':
        return await _getImproveArchitecturePrompt(arguments);
      default:
        throw Exception('Unknown prompt: $promptName');
    }
  }

  /// 优化 Widget 提示词
  Future<Map<String, dynamic>> _getOptimizeWidgetPrompt(Map<String, dynamic> args) async {
    final widgetPath = args['widget_path'] as String;
    final fullPath = path.join(projectRoot, 'lib', widgetPath);

    String widgetContent = '';
    if (await File(fullPath).exists()) {
      widgetContent = await File(fullPath).readAsString();
    }

    final prompt = '''
作为 Flutter 专家，请分析并优化以下 Widget：

文件路径: $widgetPath

当前代码:
```dart
$widgetContent
```

请提供以下方面的优化建议：

1. **性能优化**
   - 是否正确使用了 const 构造函数
   - 是否存在不必要的重建
   - 是否可以使用 ListView.builder 等优化列表渲染
   - 是否需要使用 RepaintBoundary

2. **代码质量**
   - Widget 是否过于复杂，需要拆分
   - 状态管理是否合理
   - 是否遵循 Flutter 最佳实践

3. **可维护性**
   - 代码可读性
   - 是否有足够的注释
   - 命名是否清晰

4. **具体改进代码**
   - 提供优化后的代码示例

请给出详细的分析和改进方案。
''';

    return {
      'description': '优化 Widget: $widgetPath',
      'messages': [
        {
          'role': 'user',
          'content': {
            'type': 'text',
            'text': prompt,
          },
        },
      ],
    };
  }

  /// 重构代码提示词
  Future<Map<String, dynamic>> _getRefactorCodePrompt(Map<String, dynamic> args) async {
    final filePath = args['file_path'] as String;
    final refactorType = args['refactor_type'] as String? ?? 'general';
    final fullPath = path.join(projectRoot, filePath);

    String fileContent = '';
    if (await File(fullPath).exists()) {
      fileContent = await File(fullPath).readAsString();
    }

    final typeInstructions = {
      'extract_widget': '将复杂的 build 方法拆分为多个独立的 Widget',
      'extract_method': '提取重复的代码为独立的方法',
      'simplify': '简化复杂的逻辑和嵌套',
      'general': '全面重构以提高代码质量',
    };

    final prompt = '''
请对以下代码进行重构：

文件路径: $filePath
重构类型: ${typeInstructions[refactorType]}

当前代码:
```dart
$fileContent
```

重构要求：
1. 保持功能不变
2. 提高代码可读性和可维护性
3. 遵循 SOLID 原则
4. 符合 Flutter 最佳实践
5. 添加必要的注释

请提供：
1. 重构方案说明
2. 重构后的完整代码
3. 重构前后的对比分析
''';

    return {
      'description': '重构代码: $filePath',
      'messages': [
        {
          'role': 'user',
          'content': {
            'type': 'text',
            'text': prompt,
          },
        },
      ],
    };
  }

  /// 实现功能提示词
  Future<Map<String, dynamic>> _getImplementFeaturePrompt(Map<String, dynamic> args) async {
    final featureDescription = args['feature_description'] as String;

    final projectInfo = await _getProjectInfo();

    final prompt = '''
在 Flutter Pokedex 项目中实现以下新功能：

功能描述: $featureDescription

项目信息:
$projectInfo

实现要求：
1. 遵循项目现有的架构和代码风格
2. 使用项目已有的依赖（Provider、http 等）
3. 保证代码质量和性能
4. 添加必要的错误处理
5. 编写清晰的注释

请提供：
1. 实现方案设计
2. 需要创建/修改的文件列表
3. 完整的实现代码
4. 使用说明
''';

    return {
      'description': '实现功能: $featureDescription',
      'messages': [
        {
          'role': 'user',
          'content': {
            'type': 'text',
            'text': prompt,
          },
        },
      ],
    };
  }

  /// 修复问题提示词
  Future<Map<String, dynamic>> _getFixIssuePrompt(Map<String, dynamic> args) async {
    final issueDescription = args['issue_description'] as String;
    final filePath = args['file_path'] as String?;

    String fileContent = '';
    if (filePath != null) {
      final fullPath = path.join(projectRoot, filePath);
      if (await File(fullPath).exists()) {
        fileContent = await File(fullPath).readAsString();
      }
    }

    final fileInfo = filePath != null ? '''
相关文件: $filePath
```dart
$fileContent
```
''' : '';

    final prompt = '''
请帮助修复以下问题：

问题描述: $issueDescription

$fileInfo

请提供：
1. 问题原因分析
2. 解决方案
3. 修复后的代码
4. 如何避免类似问题的建议
''';

    return {
      'description': '修复问题: $issueDescription',
      'messages': [
        {
          'role': 'user',
          'content': {
            'type': 'text',
            'text': prompt,
          },
        },
      ],
    };
  }

  /// 改进架构提示词
  Future<Map<String, dynamic>> _getImproveArchitecturePrompt(Map<String, dynamic> args) async {
    final projectInfo = await _getProjectInfo();
    final structure = await _getProjectStructure();

    final prompt = '''
请分析并改进 Flutter Pokedex 项目的架构：

项目信息:
$projectInfo

当前项目结构:
$structure

请从以下方面提供建议：

1. **目录结构**
   - 当前结构是否合理
   - 是否需要调整或新增目录

2. **代码组织**
   - 关注点分离是否清晰
   - 是否需要引入新的分层（如 repository、use case）

3. **状态管理**
   - 当前使用 Provider，是否合适
   - 是否需要改进状态管理方案

4. **依赖管理**
   - 当前依赖是否合理
   - 是否有更好的替代方案

5. **可扩展性**
   - 如何提高项目的可扩展性
   - 如何方便添加新功能

6. **测试**
   - 如何组织测试代码
   - 建议的测试策略

请提供详细的改进方案和示例代码。
''';

    return {
      'description': '改进项目架构',
      'messages': [
        {
          'role': 'user',
          'content': {
            'type': 'text',
            'text': prompt,
          },
        },
      ],
    };
  }

  // ========== 辅助方法 ==========

  Future<String> _getProjectInfo() async {
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      return '无法读取项目信息';
    }

    final content = await pubspecFile.readAsString();
    final lines = content.split('\n');
    
    String name = '';
    String description = '';
    final dependencies = <String>[];

    for (final line in lines) {
      if (line.startsWith('name:')) {
        name = line.split(':')[1].trim();
      } else if (line.startsWith('description:')) {
        description = line.substring(12).trim().replaceAll('"', '');
      } else if (line.trim().startsWith('http:') || 
                 line.trim().startsWith('provider:') ||
                 line.trim().startsWith('cached_network_image:')) {
        dependencies.add(line.trim().split(':')[0]);
      }
    }

    return '''
项目名称: $name
项目描述: $description
主要依赖: ${dependencies.join(', ')}
''';
  }

  Future<String> _getProjectStructure() async {
    final libDir = Directory(path.join(projectRoot, 'lib'));
    if (!await libDir.exists()) {
      return '无法读取项目结构';
    }

    final structure = StringBuffer();
    structure.writeln('lib/');
    
    await for (final entity in libDir.list()) {
      if (entity is Directory) {
        final dirName = path.basename(entity.path);
        structure.writeln('  $dirName/');
        
        await for (final file in entity.list()) {
          if (file is File && file.path.endsWith('.dart')) {
            structure.writeln('    ${path.basename(file.path)}');
          }
        }
      } else if (entity is File && entity.path.endsWith('.dart')) {
        structure.writeln('  ${path.basename(entity.path)}');
      }
    }

    return structure.toString();
  }
}
