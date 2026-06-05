import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PublicToiletApi {
  static const String _baseUrl = 'http://openapi.seoul.go.kr:8088';
  static const String _serviceName = 'mgisToiletPoi';
  static const int _batchSize = 1000;

  final http.Client _client;

  PublicToiletApi({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey => dotenv.env['PUBLIC_TOILET_API_KEY'] ?? '';

  Future<List<Map<String, dynamic>>> fetchAllToilets() async {
    final first = await _fetchBatch(1, _batchSize);
    final totalCount = first['list_total_count'] as int;
    final rows = List<Map<String, dynamic>>.from(first['row'] as List);

    for (int start = _batchSize + 1; start <= totalCount; start += _batchSize) {
      final end = min(start + _batchSize - 1, totalCount);
      final batch = await _fetchBatch(start, end);
      rows.addAll(List<Map<String, dynamic>>.from(batch['row'] as List));
    }

    return rows;
  }

  Future<Map<String, dynamic>> _fetchBatch(int start, int end) async {
    final url = '$_baseUrl/$_apiKey/json/$_serviceName/$start/$end/';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('HTTP 오류: ${response.statusCode}');
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final data = body[_serviceName] as Map<String, dynamic>;
    final code = (data['RESULT'] as Map)['CODE'] as String;

    if (code != 'INFO-000') {
      throw Exception('API 오류: ${(data['RESULT'] as Map)['MESSAGE']}');
    }

    return data;
  }
}
