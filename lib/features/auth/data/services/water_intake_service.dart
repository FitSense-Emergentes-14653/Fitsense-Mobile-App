import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import '../../domain/models/water_intake_model.dart';

class WaterIntakeService {
  final SessionService _session = SessionService();

  Future<String?> _getToken() async {
    await _session.init();
    return _session.getToken();
  }

  Future<WaterIntakeModel?> getTodayWaterIntake(int athleteId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token available');

      final today = DateTime.now();

      // GET /hydration/today/{athleteId}
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/hydration/today/$athleteId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Mapear la respuesta del backend
        return WaterIntakeModel(
          id: data['id'] ?? 0,
          athleteId: athleteId,
          glasses: data['glassesConsumed'] ?? 0,
          date: today,
          goalGlasses: data['dailyGoal'] ?? 8,
        );
      } else if (response.statusCode == 404) {
        // No hay registro para hoy
        return WaterIntakeModel(
          id: 0,
          athleteId: athleteId,
          glasses: 0,
          date: today,
          goalGlasses: 8,
        );
      }
      return null;
    } catch (e) {
      print('Error obteniendo agua del día: $e');
      return null;
    }
  }

  Future<WaterIntakeModel?> addWaterGlass(int athleteId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token available');

      // POST /hydration/add
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/hydration/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'athleteId': athleteId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return WaterIntakeModel(
          id: data['id'] ?? 0,
          athleteId: athleteId,
          glasses: data['glassesConsumed'] ?? 0,
          date: DateTime.now(),
          goalGlasses: data['dailyGoal'] ?? 8,
        );
      }
      return null;
    } catch (e) {
      print('Error agregando vaso de agua: $e');
      return null;
    }
  }

  Future<WaterIntakeModel?> updateGoal(int athleteId, int newGoal) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token available');

      // PUT /hydration/goal
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/hydration/goal'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'athleteId': athleteId,
          'newGoal': newGoal,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WaterIntakeModel(
          id: data['id'] ?? 0,
          athleteId: athleteId,
          glasses: data['glassesConsumed'] ?? 0,
          date: DateTime.now(),
          goalGlasses: data['dailyGoal'] ?? newGoal,
        );
      }
      return null;
    } catch (e) {
      print('Error actualizando meta: $e');
      return null;
    }
  }

  Future<WaterIntakeModel?> incrementWaterIntake(int athleteId) async {
    return await addWaterGlass(athleteId);
  }

  Future<WaterIntakeModel?> decrementWaterIntake(int athleteId) async {
    // Por ahora no hay endpoint para decrementar, retornamos el estado actual
    final current = await getTodayWaterIntake(athleteId);
    print('⚠️ Decrementar agua aún no implementado en el backend');
    return current;
  }
}

