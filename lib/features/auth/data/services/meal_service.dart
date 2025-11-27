import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitsense/infrastructure/config/app_config.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import '../../domain/models/meal_model.dart';

class MealService {
  final SessionService _session = SessionService();

  Future<String?> _getToken() async {
    await _session.init();
    return _session.getToken();
  }

  Future<DailyCaloriesSummary?> getDailySummary(int athleteId) async {
    try {
      // TODO: Reemplazar con endpoint real cuando esté disponible
      // Por ahora retornamos datos estáticos de ejemplo

      print('📊 [MealService] Usando datos estáticos (endpoint no disponible)');

      final today = DateTime.now();

      // Datos estáticos de ejemplo
      final sampleMeals = [
        MealModel(
          id: 1,
          athleteId: athleteId,
          name: 'Avena con frutas',
          mealType: 'breakfast',
          calories: 350,
          protein: 12.0,
          carbs: 58.0,
          fats: 8.0,
          date: today,
        ),
        MealModel(
          id: 2,
          athleteId: athleteId,
          name: 'Pollo con arroz y ensalada',
          mealType: 'lunch',
          calories: 650,
          protein: 45.0,
          carbs: 72.0,
          fats: 15.0,
          date: today,
        ),
        MealModel(
          id: 3,
          athleteId: athleteId,
          name: 'Yogurt con granola',
          mealType: 'snack',
          calories: 200,
          protein: 10.0,
          carbs: 28.0,
          fats: 6.0,
          date: today,
        ),
      ];

      final totalCalories = sampleMeals.fold<int>(0, (sum, meal) => sum + meal.calories);
      final totalProtein = sampleMeals.fold<double>(0, (sum, meal) => sum + meal.protein);
      final totalCarbs = sampleMeals.fold<double>(0, (sum, meal) => sum + meal.carbs);
      final totalFats = sampleMeals.fold<double>(0, (sum, meal) => sum + meal.fats);

      return DailyCaloriesSummary(
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFats: totalFats,
        goalCalories: 2200,
        meals: sampleMeals,
      );
    } catch (e) {
      print('Error obteniendo resumen de calorías: $e');
      return null;
    }
  }

  Future<MealModel?> addMeal(MealModel meal) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No token available');

      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/meals'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(meal.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return MealModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error agregando comida: $e');
      return null;
    }
  }

  Future<bool> deleteMeal(int mealId) async {
    try {
      // TODO: Implementar cuando el endpoint esté disponible
      print('⚠️ [MealService] Endpoint de eliminar comida no disponible aún');

      // Simulamos éxito
      return true;
    } catch (e) {
      print('Error eliminando comida: $e');
      return false;
    }
  }
}

