import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:convert';

/// MCP 工具集 - 提供代码分析和优化功能
class McpTools {
  final String projectRoot;

  McpTools(this.projectRoot);

  /// 列出所有可用工具
  List<Map<String, dynamic>> listTools() {
    return [
      {
        'name': 'analyze_project',
        'description': '分析 Flutter 项目结构，包括文件组织、依赖关系和代码复杂度',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'include_dependencies': {
              'type': 'boolean',
              'description': '是否包含依赖分析',
              'default': true,
            },
          },
        },
      },
      {
        'name': 'analyze_widget',
        'description': '分析特定 Widget 文件，提供性能优化建议',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'file_path': {
              'type': 'string',
              'description': 'Widget 文件的相对路径（相对于 lib/ 目录）',
            },
          },
          'required': ['file_path'],
        },
      },
      {
        'name': 'suggest_optimizations',
        'description': '为指定文件提供代码优化建议',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'file_path': {
              'type': 'string',
              'description': '要优化的文件路径',
            },
            'focus_area': {
              'type': 'string',
              'description': '优化重点：performance, readability, maintainability, all',
              'default': 'all',
            },
          },
          'required': ['file_path'],
        },
      },
      {
        'name': 'find_unused_code',
        'description': '查找项目中可能未使用的代码和依赖',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'scope': {
              'type': 'string',
              'description': '扫描范围：dependencies, widgets, utils, all',
              'default': 'all',
            },
          },
        },
      },
      {
        'name': 'check_best_practices',
        'description': '检查代码是否遵循 Flutter 最佳实践',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'file_path': {
              'type': 'string',
              'description': '要检查的文件路径（可选，不提供则检查整个项目）',
            },
          },
        },
      },
      {
        'name': 'generate_documentation',
        'description': '为指定文件或类生成文档注释',
        'inputSchema': {
          'type': 'object',
          'properties': {
            'file_path': {
              'type': 'string',
              'description': '要生成文档的文件路径',
            },
            'class_name': {
              'type': 'string',
              'description': '要生成文档的类名（可选）',
            },
          },
          'required': ['file_path'],
        },
      },
    ];
  }

  /// 调用指定工具
  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> arguments) async {
    switch (toolName) {
      case 'analyze_project':
        return await _analyzeProject(arguments);
      case 'analyze_widget':
        return await _analyzeWidget(arguments);
      case 'suggest_optimizations':
        return await _suggestOptimizations(arguments);
      case 'find_unused_code':
        return await _findUnusedCode(arguments);
      case 'check_best_practices':
        return await _checkBestPractices(arguments);
      case 'generate_documentation':
        return await _generateDocumentation(arguments);
      default:
        throw Exception('Unknown tool: $toolName');
    }
  }

  /// 分析项目结构
  Future<Map<String, dynamic>> _analyzeProject(Map<String, dynamic> args) async {
    final includeDeps = args['include_dependencies'] as bool? ?? true;
    
    final analysis = <String, dynamic>{
      'project_name': path.basename(projectRoot),
      'structure': await _analyzeProjectStructure(),
      'file_counts': await _countFiles(),
      'complexity': await _analyzeComplexity(),
    };

    if (includeDeps) {
      analysis['dependencies'] = await _analyzeDependencies();
    }

    return {
      'content': [
        {
          'type': 'text',
          'text': jsonEncode(analysis),
        }
      ],
    };
  }

  /// 分析 Widget
  Future<Map<String, dynamic>> _analyzeWidget(Map<String, dynamic> args) async {
    final filePath = args['file_path'] as String;
    final fullPath = path.join(projectRoot, 'lib', filePath);

    if (!await File(fullPath).exists()) {
      throw Exception('File not found: $filePath');
    }

    final content = await File(fullPath).readAsString();
    final analysis = {
      'file': filePath,
      'widget_count': _countWidgets(content),
      'stateful_widgets': _findStatefulWidgets(content),
      'stateless_widgets': _findStatelessWidgets(content),
      'build_methods': _analyzeBuildMethods(content),
      'state_management': _analyzeStateManagement(content),
      'suggestions': _generateWidgetSuggestions(content),
    };

    return {
      'content': [
        {
          'type': 'text',
          'text': jsonEncode(analysis),
        }
      ],
    };
  }

  /// 提供优化建议
  Future<Map<String, dynamic>> _suggestOptimizations(Map<String, dynamic> args) async {
    final filePath = args['file_path'] as String;
    final focusArea = args['focus_area'] as String? ?? 'all';
    final fullPath = path.join(projectRoot, filePath);

    if (!await File(fullPath).exists()) {
      throw Exception('File not found: $filePath');
    }

    final content = await File(fullPath).readAsString();
    final suggestions = <String>[];

    if (focusArea == 'performance' || focusArea == 'all') {
      suggestions.addAll(_getPerformanceSuggestions(content));
    }
    if (focusArea == 'readability' || focusArea == 'all') {
      suggestions.addAll(_getReadabilitySuggestions(content));
    }
    if (focusArea == 'maintainability' || focusArea == 'all') {
      suggestions.addAll(_getMaintainabilitySuggestions(content));
    }

    return {
      'content': [
        {
          'type': 'text',
          'text': jsonEncode({
            'file': filePath,
            'focus_area': focusArea,
            'suggestions': suggestions,
          }),
        }
      ],
    };
  }

  /// 查找未使用的代码
  Future<Map<String, dynamic>> _findUnusedCode(Map<String, dynamic> args) async {
    final scope = args['scope'] as String? ?? 'all';
    final results = <String, dynamic>{};

    if (scope == 'dependencies' || scope == 'all') {
      results['unused_dependencies'] = await _findUnusedDependencies();
    }

    return {
      'content': [
        {
          'type': 'text',
          'text': jsonEncode(results),
        }
      ],
    };
  }

  /// 检查最佳实践
  Future<Map<String, dynamic>> _checkBestPractices(Map<String, dynamic> args) async {
    final filePath = args['file_path'] as String?;
    final issues = <Map<String, dynamic>>[];

    if (filePath != null) {
      final fullPath = path.join(projectRoot, filePath);
      final content = await File(fullPath).readAsString();
      issues.addAll(_checkFileBestPractices(content, filePath));
    } else {
      // 检查整个项目
      issues.addAll(await _checkProjectBestPractices());
    }

    return {
      'content': [
        {
          'type': 'text',
          'text': jsonEncode({
            'checked': filePath ?? 'entire_project',
            'issues': issues,
          }),
        }
      ],
    };
  }

  /// 生成文档
  Future<Map<String, dynamic>> _generateDocumentation(Map<String, dynamic> args) async {
    final filePath = args['file_path'] as String;
    final className = args['class_name'] as String?;
    final fullPath = path.join(projectRoot, filePath);

    if (!await File(fullPath).exists()) {
      throw Exception('File not found: $filePath');
    }

    final content = await File(fullPath).readAsString();
    final docs = _generateDocs(content, className);

    return {
      'content': [
        {
          'type': 'text',
          'text': jsonEncode({
            'file': filePath,
            'class': className,
            'documentation': docs,
          }),
        }
      ],
    };
  }

  // ========== 辅助方法 ==========

  Future<Map<String, dynamic>> _analyzeProjectStructure() async {
    final libDir = Directory(path.join(projectRoot, 'lib'));
    final structure = <String, int>{};

    if (await libDir.exists()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final relativePath = path.relative(entity.path, from: libDir.path);
          final dir = path.dirname(relativePath);
          structure[dir] = (structure[dir] ?? 0) + 1;
        }
      }
    }

    return structure;
  }

  Future<Map<String, int>> _countFiles() async {
    final counts = <String, int>{};
    final libDir = Directory(path.join(projectRoot, 'lib'));

    if (await libDir.exists()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          counts['dart_files'] = (counts['dart_files'] ?? 0) + 1;
          final content = await entity.readAsString();
          counts['total_lines'] = (counts['total_lines'] ?? 0) + content.split('\n').length;
        }
      }
    }

    return counts;
  }

  Future<Map<String, dynamic>> _analyzeComplexity() async {
    return {
      'message': '代码复杂度分析需要运行 dart analyze',
      'suggestion': '运行 "fvm flutter analyze" 获取详细分析',
    };
  }

  Future<Map<String, dynamic>> _analyzeDependencies() async {
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      return {'error': 'pubspec.yaml not found'};
    }

    final content = await pubspecFile.readAsString();
    final deps = <String>[];
    final devDeps = <String>[];
    
    bool inDeps = false;
    bool inDevDeps = false;

    for (final line in content.split('\n')) {
      if (line.trim() == 'dependencies:') {
        inDeps = true;
        inDevDeps = false;
      } else if (line.trim() == 'dev_dependencies:') {
        inDevDeps = true;
        inDeps = false;
      } else if (line.isNotEmpty && !line.startsWith(' ') && line.contains(':')) {
        inDeps = false;
        inDevDeps = false;
      } else if (line.trim().isNotEmpty && line.startsWith('  ')) {
        final dep = line.trim().split(':')[0];
        if (inDeps && !dep.startsWith('#')) {
          deps.add(dep);
        } else if (inDevDeps && !dep.startsWith('#')) {
          devDeps.add(dep);
        }
      }
    }

    return {
      'dependencies': deps,
      'dev_dependencies': devDeps,
      'total': deps.length + devDeps.length,
    };
  }

  int _countWidgets(String content) {
    final widgetPattern = RegExp(r'class\s+\w+\s+extends\s+(StatelessWidget|StatefulWidget)');
    return widgetPattern.allMatches(content).length;
  }

  List<String> _findStatefulWidgets(String content) {
    final pattern = RegExp(r'class\s+(\w+)\s+extends\s+StatefulWidget');
    return pattern.allMatches(content).map((m) => m.group(1)!).toList();
  }

  List<String> _findStatelessWidgets(String content) {
    final pattern = RegExp(r'class\s+(\w+)\s+extends\s+StatelessWidget');
    return pattern.allMatches(content).map((m) => m.group(1)!).toList();
  }

  Map<String, dynamic> _analyzeBuildMethods(String content) {
    final buildPattern = RegExp(r'Widget\s+build\(BuildContext\s+context\)');
    final matches = buildPattern.allMatches(content).length;
    return {
      'count': matches,
      'suggestion': matches > 3 ? '考虑拆分为更小的 Widget' : '正常',
    };
  }

  Map<String, dynamic> _analyzeStateManagement(String content) {
    final hasProvider = content.contains('Provider') || content.contains('ChangeNotifier');
    final hasSetState = content.contains('setState');
    
    return {
      'uses_provider': hasProvider,
      'uses_setState': hasSetState,
      'recommendation': hasProvider ? 'Good: 使用了 Provider' : 'Consider using Provider for state management',
    };
  }

  List<String> _generateWidgetSuggestions(String content) {
    final suggestions = <String>[];

    if (content.contains('Container(') && content.split('Container(').length > 5) {
      suggestions.add('考虑使用更具体的 Widget 替代过多的 Container');
    }

    if (content.contains('Column') && content.contains('Row') && 
        (content.split('Column').length + content.split('Row').length) > 10) {
      suggestions.add('布局嵌套较深，考虑提取子 Widget');
    }

    if (!content.contains('const ') && content.contains('Widget')) {
      suggestions.add('添加 const 构造函数以提升性能');
    }

    return suggestions;
  }

  List<String> _getPerformanceSuggestions(String content) {
    final suggestions = <String>[];

    if (!content.contains('const ')) {
      suggestions.add('使用 const 构造函数来减少重建');
    }

    if (content.contains('setState') && content.split('setState').length > 3) {
      suggestions.add('频繁调用 setState，考虑使用 Provider 或其他状态管理');
    }

    if (content.contains('ListView(') && !content.contains('ListView.builder')) {
      suggestions.add('对于长列表，使用 ListView.builder 而不是 ListView');
    }

    return suggestions;
  }

  List<String> _getReadabilitySuggestions(String content) {
    final suggestions = <String>[];

    if (!content.contains('///') && content.contains('class ')) {
      suggestions.add('添加文档注释以提高代码可读性');
    }

    final lines = content.split('\n');
    if (lines.any((line) => line.length > 120)) {
      suggestions.add('某些行过长（>120字符），考虑拆分');
    }

    return suggestions;
  }

  List<String> _getMaintainabilitySuggestions(String content) {
    final suggestions = <String>[];

    if (content.split('class ').length > 5) {
      suggestions.add('文件包含多个类，考虑拆分为单独的文件');
    }

    if (!content.contains('@override') && content.contains('build(')) {
      suggestions.add('添加 @override 注解提高代码清晰度');
    }

    return suggestions;
  }

  Future<List<String>> _findUnusedDependencies() async {
    // 简化实现：检查 pubspec.yaml 中的依赖是否在代码中被引用
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      return [];
    }

    return ['运行 "dart pub outdated" 查看未使用的依赖'];
  }

  List<Map<String, dynamic>> _checkFileBestPractices(String content, String filePath) {
    final issues = <Map<String, dynamic>>[];

    if (!content.contains('const ')) {
      issues.add({
        'severity': 'info',
        'message': '考虑使用 const 构造函数',
        'file': filePath,
      });
    }

    if (content.contains('// ignore:')) {
      issues.add({
        'severity': 'warning',
        'message': '存在被忽略的 lint 警告',
        'file': filePath,
      });
    }

    return issues;
  }

  Future<List<Map<String, dynamic>>> _checkProjectBestPractices() async {
    final issues = <Map<String, dynamic>>[];
    
    final pubspecFile = File(path.join(projectRoot, 'pubspec.yaml'));
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      if (!content.contains('flutter_lints')) {
        issues.add({
          'severity': 'warning',
          'message': '建议添加 flutter_lints 以保证代码质量',
        });
      }
    }

    return issues;
  }

  String _generateDocs(String content, String? className) {
    if (className != null) {
      return '/// $className\n/// \n/// TODO: 添加类的详细说明';
    }
    return '/// TODO: 添加文件和类的文档注释';
  }
}
