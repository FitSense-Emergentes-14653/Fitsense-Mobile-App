import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import '../../domain/models/water_intake_model.dart';

/// Servicio para gestionar la hidratación del atleta
///
/// Endpoints correctos (verificados con curl):
/// - GET  /hydration/{athleteId} - Obtener hidratación del día actual
/// - POST /hydration/{athleteId}?amount={amount} - Agregar/quitar agua (amount: ±250ml)
/// - PUT  /hydration/goal/{athleteId}?hydrationGoal={goal} - Actualizar meta de hidratación
///
/// Conversión: 1 vaso = 250ml
/// Swagger UI: http://localhost:8080/swagger-ui/index.html#/Hydration
class WaterIntakeService {
  final SessionService _session = SessionService();

  Future<String?> _getToken() async {
    await _session.init();
    return _session.getToken();
  }

  Future<WaterIntakeModel?> getTodayWaterIntake(int athleteId) async {
    try {
      final token = await _getToken();
      print('🔵 [HYDRATION] Token obtenido: ${token != null ? "✓" : "✗"}');
      if (token == null) throw Exception('No token available');

      final today = DateTime.now();

      // Endpoint correcto: GET /hydration/{athleteId}
      final url = '${AppConfig.apiBaseUrl}/hydration/$athleteId';

      print('🔵 [HYDRATION] AthleteId: $athleteId');
      print('🔵 [HYDRATION] GET Request URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔵 [HYDRATION] Response Status: ${response.statusCode}');
      print('🔵 [HYDRATION] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔵 [HYDRATION] Datos parseados: $data');
        print('🔵 [HYDRATION] Total (ml): ${data['total']}');
        print('🔵 [HYDRATION] Goal (ml): ${data['hydrationGoal']}');

        final glasses = (data['total'] ?? 0) ~/ 250;
        final goalGlasses = (data['hydrationGoal'] ?? 2000) ~/ 250;

        print('🔵 [HYDRATION] Convertido a vasos: $glasses / $goalGlasses');

        return WaterIntakeModel(
          id: data['id'] ?? 0,
          athleteId: athleteId,
          glasses: glasses,
          date: today,
          goalGlasses: goalGlasses,
        );
      } else if (response.statusCode == 404) {
        print('🔵 [HYDRATION] No hay registro para hoy, usando valores por defecto');
        return WaterIntakeModel(
          id: 0,
          athleteId: athleteId,
          glasses: 0,
          date: today,
          goalGlasses: 8, // Default 2000ml
        );
      }

      print('🔴 [HYDRATION] Error inesperado, status code: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [HYDRATION] Error obteniendo agua del día: $e');
      return null;
    }
  }

  Future<WaterIntakeModel?> addWater(int athleteId, int amount) async {
    try {
      final token = await _getToken();
      print('💧 [ADD WATER] Token obtenido: ${token != null ? "✓" : "✗"}');
      if (token == null) throw Exception('No token available');

      // Endpoint correcto: POST /hydration/{athleteId}?amount={amount}
      final url = '${AppConfig.apiBaseUrl}/hydration/$athleteId?amount=$amount';

      print('💧 [ADD WATER] POST Request URL: $url');
      print('💧 [ADD WATER] Amount: $amount ml');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('💧 [ADD WATER] Response Status: ${response.statusCode}');
      print('💧 [ADD WATER] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('💧 [ADD WATER] Datos parseados: $data');

        final glasses = (data['total'] ?? 0) ~/ 250;
        final goalGlasses = (data['hydrationGoal'] ?? 2000) ~/ 250;
        print('💧 [ADD WATER] Nuevo consumo en vasos: $glasses / $goalGlasses');

        return WaterIntakeModel(
          id: data['id'] ?? 0,
          athleteId: athleteId,
          glasses: glasses,
          date: DateTime.now(),
          goalGlasses: goalGlasses,
        );
      }

      print('🔴 [ADD WATER] Error, status code: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [ADD WATER] Error agregando agua: $e');
      return null;
    }
  }

  Future<WaterIntakeModel?> updateGoal(int athleteId, int newGoalInGlasses) async {
    try {
      final token = await _getToken();
      print('🎯 [UPDATE GOAL] Token obtenido: ${token != null ? "✓" : "✗"}');
      if (token == null) throw Exception('No token available');

      final newGoalInMl = newGoalInGlasses * 250;

      // Endpoint correcto: PUT /hydration/goal/{athleteId}?hydrationGoal={value}
      final url = '${AppConfig.apiBaseUrl}/hydration/goal/$athleteId?hydrationGoal=$newGoalInMl';

      print('🎯 [UPDATE GOAL] Nueva meta: $newGoalInGlasses vasos ($newGoalInMl ml)');
      print('🎯 [UPDATE GOAL] PUT Request URL: $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🎯 [UPDATE GOAL] Response Status: ${response.statusCode}');
      print('🎯 [UPDATE GOAL] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('🎯 [UPDATE GOAL] Datos parseados: $data');

        final glasses = (data['total'] ?? 0) ~/ 250;
        final goalGlasses = (data['hydrationGoal'] ?? newGoalInMl) ~/ 250;
        print('🎯 [UPDATE GOAL] Meta actualizada a: $goalGlasses vasos');

        return WaterIntakeModel(
          id: data['id'] ?? 0,
          athleteId: athleteId,
          glasses: glasses,
          date: DateTime.now(),
          goalGlasses: goalGlasses,
        );
      }

      print('🔴 [UPDATE GOAL] Error, status code: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [UPDATE GOAL] Error actualizando meta: $e');
      return null;
    }
  }

  Future<WaterIntakeModel?> incrementWaterIntake(int athleteId) async {
    return await addWater(athleteId, 250);
  }

  Future<WaterIntakeModel?> decrementWaterIntake(int athleteId) async {
    return await addWater(athleteId, -250);
  }
}

