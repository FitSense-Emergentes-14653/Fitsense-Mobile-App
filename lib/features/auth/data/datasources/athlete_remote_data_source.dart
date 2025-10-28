import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/services/base_service.dart';
import '../models/athlete_model.dart';

class AthleteRemoteDataSource extends BaseService {
  Map<String, String> _headers(String token) =>
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};

  // GET /athletes
  Future<List<AthleteModel>> getAllAthletes({required String token}) async {
    final url = Uri.parse('$baseUrl/athletes');
    final res = await http.get(url, headers: _headers(token));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) {
        return data.map((e) => AthleteModel.fromJson(e)).toList();
      } else if (data is Map && data['content'] is List) {
        return List<Map<String, dynamic>>.from(data['content'])
            .map(AthleteModel.fromJson)
            .toList();
      }
    }
    throw Exception('Error al obtener atletas: ${res.statusCode}');
  }

  // GET /athletes/{athleteId}
  Future<AthleteModel> getAthleteById({
    required String token,
    required int athleteId,
  }) async {
    final url = Uri.parse('$baseUrl/athletes/$athleteId');
    final res = await http.get(url, headers: _headers(token));
    if (res.statusCode == 200) {
      return AthleteModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error al obtener atleta ID $athleteId');
  }

  // POST /athletes
  Future<AthleteModel> createAthlete({
    required String token,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl/athletes');
    final res = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return AthleteModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error al crear atleta: ${res.body}');
  }

  // PUT /athletes/{athleteId}
  Future<AthleteModel> updateAthlete({
    required String token,
    required int athleteId,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl/athletes/$athleteId');
    final res = await http.put(
      url,
      headers: _headers(token),
      body: jsonEncode(body),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return AthleteModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Error al actualizar atleta: ${res.body}');
  }

  // DELETE /athletes/{athleteId}
  Future<void> deleteAthlete({
    required String token,
    required int athleteId,
  }) async {
    final url = Uri.parse('$baseUrl/athletes/$athleteId');
    final res = await http.delete(url, headers: _headers(token));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Error al eliminar atleta: ${res.statusCode}');
    }
  }
}
