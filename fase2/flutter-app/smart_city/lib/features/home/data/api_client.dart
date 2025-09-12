import 'dart:convert';
import 'package:http/http.dart' as http;
import 'structs.dart';

class ApiClient {
  final http.Client _client;
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String abaseUrl= 'https://fastapi-api-1nhl.onrender.com';

  Uri _u(String path) => Uri.parse('${ApiClient.abaseUrl}$path');

  Future<List<Alerta>> fetchAlertas({int? limit}) async {
    final path = limit != null ? '/alertas/$limit' : '/alertas';
    final res = await _client.get(_u(path));
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar alertas');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Alerta.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Trafico>> fetchTrafico() async {
    final res = await _client.get(_u('/trafico'));
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar trafico');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Trafico.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Ambiente>> fetchAmbiente() async {
    final res = await _client.get(_u('/ambiente'));
    if (res.statusCode != 200) {
      throw Exception('Error ${res.statusCode} al cargar ambiente');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => Ambiente.fromJson(e as Map<String, dynamic>)).toList();
  }
}
