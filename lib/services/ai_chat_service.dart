import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class AiChatService {
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const String _modelName = 'deepseek-chat';

  // 请替换为你自己的 DeepSeek API Key
  static const String _defaultApiKey = 'sk-569813d6001b462cbede33c3c107a456';

  final Dio _dio = Dio();

  Stream<String> sendMessage(List<Map<String, String>> messages) async* {
    final requestBody = {
      "model": _modelName,
      "messages": messages,
      "stream": true,
      "temperature": 0.7,
    };

    try {
      final response = await _dio.post<ResponseBody>(
        _baseUrl,
        data: jsonEncode(requestBody),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_defaultApiKey',
            'Accept': 'text/event-stream',
          },
          responseType: ResponseType.stream,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final stream = response.data!.stream;
      String buffer = '';

      await for (final chunk in stream) {
        final text = utf8.decode(chunk);
        buffer += text;

        final lines = buffer.split('\n');
        buffer = lines.last;

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6);
            if (jsonStr == '[DONE]') return;

            try {
              final map = jsonDecode(jsonStr);
              final delta = map['choices'][0]['delta']['content'];
              if (delta != null && delta is String && delta.isNotEmpty) {
                yield delta;
              }
            } catch (e) {
              debugPrint('解析 SSE 数据失败: $e');
            }
          }
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        yield '❌ API Key 无效，请联系开发者。';
      } else if (e.response?.statusCode == 402) {
        yield '❌ 账户余额不足，请稍后再试。';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        yield '❌ 网络连接超时，请检查网络后重试。';
      } else {
        yield '❌ 网络错误：${e.message}';
      }
    } catch (e) {
      yield '❌ 未知错误：$e';
    }
  }
}
