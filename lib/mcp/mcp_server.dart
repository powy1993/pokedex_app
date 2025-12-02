import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'mcp_tools.dart';
import 'mcp_resources.dart';
import 'mcp_prompts.dart';

/// Flutter 项目的 MCP (Model Context Protocol) 服务器
/// 提供项目分析、代码优化建议和上下文信息
class FlutterMcpServer {
  final String projectRoot;
  final McpTools tools;
  final McpResources resources;
  final McpPrompts prompts;

  FlutterMcpServer(this.projectRoot)
      : tools = McpTools(projectRoot),
        resources = McpResources(projectRoot),
        prompts = McpPrompts(projectRoot);

  /// 启动 MCP 服务器
  Future<void> start() async {
    stderr.writeln('Flutter MCP Server starting...');
    stderr.writeln('Project root: $projectRoot');

    // 监听标准输入的 JSON-RPC 消息
    stdin
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_handleMessage, onError: (error) {
      stderr.writeln('Error reading stdin: $error');
    });

    stderr.writeln('Server ready and listening...');
  }

  /// 处理接收到的消息
  void _handleMessage(String line) async {
    if (line.trim().isEmpty) return;

    try {
      final message = jsonDecode(line);
      final response = await _processMessage(message);
      
      if (response != null) {
        stdout.writeln(jsonEncode(response));
      }
    } catch (e) {
      stderr.writeln('Error processing message: $e');
      _sendError(-32700, 'Parse error', null);
    }
  }

  /// 处理 JSON-RPC 消息
  Future<Map<String, dynamic>?> _processMessage(Map<String, dynamic> message) async {
    final method = message['method'] as String?;
    final id = message['id'];
    final params = message['params'] as Map<String, dynamic>?;

    try {
      switch (method) {
        case 'initialize':
          return _handleInitialize(id, params);
        
        case 'tools/list':
          return _handleToolsList(id);
        
        case 'tools/call':
          return await _handleToolCall(id, params);
        
        case 'resources/list':
          return _handleResourcesList(id);
        
        case 'resources/read':
          return await _handleResourceRead(id, params);
        
        case 'prompts/list':
          return _handlePromptsList(id);
        
        case 'prompts/get':
          return await _handlePromptGet(id, params);
        
        default:
          return _createErrorResponse(id, -32601, 'Method not found');
      }
    } catch (e) {
      stderr.writeln('Error handling method $method: $e');
      return _createErrorResponse(id, -32603, 'Internal error: $e');
    }
  }

  /// 处理初始化请求
  Map<String, dynamic> _handleInitialize(dynamic id, Map<String, dynamic>? params) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'protocolVersion': '2024-11-05',
        'capabilities': {
          'tools': {'listChanged': false},
          'resources': {'subscribe': false, 'listChanged': false},
          'prompts': {'listChanged': false},
        },
        'serverInfo': {
          'name': 'flutter-pokedex-mcp',
          'version': '1.0.0',
        },
      },
    };
  }

  /// 处理工具列表请求
  Map<String, dynamic> _handleToolsList(dynamic id) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'tools': tools.listTools(),
      },
    };
  }

  /// 处理工具调用请求
  Future<Map<String, dynamic>> _handleToolCall(dynamic id, Map<String, dynamic>? params) async {
    if (params == null || !params.containsKey('name')) {
      return _createErrorResponse(id, -32602, 'Invalid params');
    }

    final toolName = params['name'] as String;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    try {
      final result = await tools.callTool(toolName, arguments);
      return {
        'jsonrpc': '2.0',
        'id': id,
        'result': result,
      };
    } catch (e) {
      return _createErrorResponse(id, -32603, 'Tool execution failed: $e');
    }
  }

  /// 处理资源列表请求
  Map<String, dynamic> _handleResourcesList(dynamic id) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'resources': resources.listResources(),
      },
    };
  }

  /// 处理资源读取请求
  Future<Map<String, dynamic>> _handleResourceRead(dynamic id, Map<String, dynamic>? params) async {
    if (params == null || !params.containsKey('uri')) {
      return _createErrorResponse(id, -32602, 'Invalid params');
    }

    final uri = params['uri'] as String;

    try {
      final content = await resources.readResource(uri);
      return {
        'jsonrpc': '2.0',
        'id': id,
        'result': {
          'contents': [content],
        },
      };
    } catch (e) {
      return _createErrorResponse(id, -32603, 'Resource read failed: $e');
    }
  }

  /// 处理提示词列表请求
  Map<String, dynamic> _handlePromptsList(dynamic id) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'result': {
        'prompts': prompts.listPrompts(),
      },
    };
  }

  /// 处理获取提示词请求
  Future<Map<String, dynamic>> _handlePromptGet(dynamic id, Map<String, dynamic>? params) async {
    if (params == null || !params.containsKey('name')) {
      return _createErrorResponse(id, -32602, 'Invalid params');
    }

    final promptName = params['name'] as String;
    final arguments = params['arguments'] as Map<String, dynamic>? ?? {};

    try {
      final result = await prompts.getPrompt(promptName, arguments);
      return {
        'jsonrpc': '2.0',
        'id': id,
        'result': result,
      };
    } catch (e) {
      return _createErrorResponse(id, -32603, 'Prompt get failed: $e');
    }
  }

  /// 创建错误响应
  Map<String, dynamic> _createErrorResponse(dynamic id, int code, String message) {
    return {
      'jsonrpc': '2.0',
      'id': id,
      'error': {
        'code': code,
        'message': message,
      },
    };
  }

  /// 发送错误消息
  void _sendError(int code, String message, dynamic id) {
    final error = _createErrorResponse(id, code, message);
    stdout.writeln(jsonEncode(error));
  }
}

/// 主函数 - 启动 MCP 服务器
void main(List<String> args) async {
  final projectRoot = Platform.environment['PROJECT_ROOT'] ?? 
                      Directory.current.path;
  
  final server = FlutterMcpServer(projectRoot);
  await server.start();

  // 保持服务器运行
  await ProcessSignal.sigterm.watch().first;
  stderr.writeln('Server shutting down...');
}
