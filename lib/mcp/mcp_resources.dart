import 'dart:io';
import 'package:path/path.dart' as path;

/// MCP 资源管理 - 提供项目文件和配置的访问
class McpResources {
  final String projectRoot;

  McpResources(this.projectRoot);

  /// 列出所有可用资源
  List<Map<String, dynamic>> listResources() {
    return [
      {
        'uri': 'file://pubspec.yaml',
        'name': '项目配置',
        'description': 'Flutter 项目的依赖和配置文件',
        'mimeType': 'text/yaml',
      },
      {
        'uri': 'file://analysis_options.yaml',
        'name': 'Lint 配置',
        'description': 'Dart/Flutter 代码分析配置',
        'mimeType': 'text/yaml',
      },
      {
        'uri': 'file://lib/',
        'name': '源代码目录',
        'description': '项目的主要源代码',
        'mimeType': 'text/plain',
      },
      {
        'uri': 'project://structure',
        'name': '项目结构',
        'description': '项目的完整目录结构',
        'mimeType': 'application/json',
      },
      {
        'uri': 'project://widgets',
        'name': 'Widget 列表',
        'description': '项目中所有的 Widget',
        'mimeType': 'application/json',
      },
      {
        'uri': 'project://models',
        'name': '数据模型',
        'description': '项目中的数据模型定义',
        'mimeType': 'application/json',
      },
    ];
  }

  /// 读取指定资源
  Future<Map<String, dynamic>> readResource(String uri) async {
    if (uri.startsWith('file://')) {
      return await _readFile(uri.substring(7));
    } else if (uri.startsWith('project://')) {
      return await _readProjectResource(uri.substring(10));
    } else {
      throw Exception('Unsupported URI scheme: $uri');
    }
  }

  /// 读取文件资源
  Future<Map<String, dynamic>> _readFile(String relativePath) async {
    final fullPath = path.join(projectRoot, relativePath);
    final file = File(fullPath);

    if (!await file.exists()) {
      throw Exception('File not found: $relativePath');
    }

    final content = await file.readAsString();
    final mimeType = _getMimeType(relativePath);

    return {
      'uri': 'file://$relativePath',
      'mimeType': mimeType,
      'text': content,
    };
  }

  /// 读取项目级资源
  Future<Map<String, dynamic>> _readProjectResource(String resourceType) async {
    switch (resourceType) {
      case 'structure':
        return {
          'uri': 'project://structure',
          'mimeType': 'application/json',
          'text': await _getProjectStructure(),
        };
      
      case 'widgets':
        return {
          'uri': 'project://widgets',
          'mimeType': 'application/json',
          'text': await _getWidgetsList(),
        };
      
      case 'models':
        return {
          'uri': 'project://models',
          'mimeType': 'application/json',
          'text': await _getModelsList(),
        };
      
      default:
        throw Exception('Unknown project resource: $resourceType');
    }
  }

  /// 获取项目结构
  Future<String> _getProjectStructure() async {
    final structure = <String, dynamic>{};
    final libDir = Directory(path.join(projectRoot, 'lib'));

    if (await libDir.exists()) {
      structure['lib'] = await _buildDirectoryTree(libDir);
    }

    return _formatJson(structure);
  }

  /// 构建目录树
  Future<Map<String, dynamic>> _buildDirectoryTree(Directory dir) async {
    final tree = <String, dynamic>{};
    
    await for (final entity in dir.list()) {
      final name = path.basename(entity.path);
      
      if (entity is Directory) {
        tree[name] = await _buildDirectoryTree(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        tree[name] = {
          'type': 'file',
          'size': await entity.length(),
        };
      }
    }

    return tree;
  }

  /// 获取所有 Widget
  Future<String> _getWidgetsList() async {
    final widgets = <Map<String, dynamic>>[];
    final libDir = Directory(path.join(projectRoot, 'lib'));

    if (await libDir.exists()) {
      await for (final entity in libDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final widgetPattern = RegExp(
            r'class\s+(\w+)\s+extends\s+(StatelessWidget|StatefulWidget)',
          );
          
          for (final match in widgetPattern.allMatches(content)) {
            widgets.add({
              'name': match.group(1),
              'type': match.group(2),
              'file': path.relative(entity.path, from: path.join(projectRoot, 'lib')),
            });
          }
        }
      }
    }

    return _formatJson({'widgets': widgets, 'count': widgets.length});
  }

  /// 获取所有数据模型
  Future<String> _getModelsList() async {
    final models = <Map<String, dynamic>>[];
    final modelsDir = Directory(path.join(projectRoot, 'lib', 'models'));

    if (await modelsDir.exists()) {
      await for (final entity in modelsDir.list()) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final classPattern = RegExp(r'class\s+(\w+)\s*{');
          
          for (final match in classPattern.allMatches(content)) {
            models.add({
              'name': match.group(1),
              'file': path.basename(entity.path),
            });
          }
        }
      }
    }

    return _formatJson({'models': models, 'count': models.length});
  }

  /// 获取 MIME 类型
  String _getMimeType(String filePath) {
    if (filePath.endsWith('.dart')) return 'text/x-dart';
    if (filePath.endsWith('.yaml') || filePath.endsWith('.yml')) return 'text/yaml';
    if (filePath.endsWith('.json')) return 'application/json';
    if (filePath.endsWith('.md')) return 'text/markdown';
    return 'text/plain';
  }

  /// 格式化 JSON
  String _formatJson(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

/// JSON 编码器
class JsonEncoder {
  final String indent;

  const JsonEncoder.withIndent(this.indent);

  String convert(dynamic object) {
    return _encode(object, 0);
  }

  String _encode(dynamic object, int level) {
    if (object == null) return 'null';
    if (object is String) return '"${_escape(object)}"';
    if (object is num || object is bool) return object.toString();
    
    if (object is List) {
      if (object.isEmpty) return '[]';
      final items = object.map((e) => _encode(e, level + 1)).join(',\n${indent * (level + 1)}');
      return '[\n${indent * (level + 1)}$items\n${indent * level}]';
    }
    
    if (object is Map) {
      if (object.isEmpty) return '{}';
      final items = object.entries
          .map((e) => '"${e.key}": ${_encode(e.value, level + 1)}')
          .join(',\n${indent * (level + 1)}');
      return '{\n${indent * (level + 1)}$items\n${indent * level}}';
    }
    
    return object.toString();
  }

  String _escape(String str) {
    return str
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
