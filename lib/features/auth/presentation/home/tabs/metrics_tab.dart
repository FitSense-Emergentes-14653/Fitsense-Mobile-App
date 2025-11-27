import 'package:flutter/material.dart';
import 'package:fitsense/features/auth/data/services/water_intake_service.dart';
import 'package:fitsense/features/auth/data/services/meal_service.dart';
import 'package:fitsense/features/auth/domain/models/water_intake_model.dart';
import 'package:fitsense/features/auth/domain/models/meal_model.dart';

class MetricsTab extends StatefulWidget {
  final int userId;

  const MetricsTab({super.key, required this.userId});

  @override
  State<MetricsTab> createState() => _MetricsTabState();
}

class _MetricsTabState extends State<MetricsTab> {
  final WaterIntakeService _waterService = WaterIntakeService();
  final MealService _mealService = MealService();

  WaterIntakeModel? _waterIntake;
  DailyCaloriesSummary? _caloriesSummary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final water = await _waterService.getTodayWaterIntake(widget.userId);
    final calories = await _mealService.getDailySummary(widget.userId);

    setState(() {
      _waterIntake = water;
      _caloriesSummary = calories;
      _loading = false;
    });
  }

  Future<void> _incrementWater() async {
    final updated = await _waterService.incrementWaterIntake(widget.userId);
    if (updated != null) {
      setState(() => _waterIntake = updated);
    }
  }

  Future<void> _decrementWater() async {
    final updated = await _waterService.decrementWaterIntake(widget.userId);
    if (updated != null) {
      setState(() => _waterIntake = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8A5CF6)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF8A5CF6),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Mis Métricas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seguimiento diario',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            _buildWaterIntakeCard(),

            const SizedBox(height: 24),

            _buildCaloriesCard(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterIntakeCard() {
    final glasses = _waterIntake?.glasses ?? 0;
    final goal = _waterIntake?.goalGlasses ?? 8;
    final progress = goal > 0 ? (glasses / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4FC3F7).withValues(alpha: 0.2),
            const Color(0xFF29B6F6).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Color(0xFF4FC3F7),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Hidratación',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4FC3F7)),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$glasses / $goal vasos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% completado',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: glasses > 0 ? _decrementWater : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.white,
                    iconSize: 40,
                    disabledColor: Colors.white.withValues(alpha: 0.3),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _incrementWater,
                    icon: const Icon(Icons.add_circle),
                    color: const Color(0xFF4FC3F7),
                    iconSize: 40,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard() {
    final summary = _caloriesSummary;
    if (summary == null) {
      return const SizedBox();
    }

    final progress = summary.progress.clamp(0.0, 1.0);
    final progressColor = progress > 1.0
        ? Colors.red
        : progress > 0.8
            ? Colors.orange
            : const Color(0xFF8A5CF6);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8A5CF6).withValues(alpha: 0.2),
            const Color(0xFF7C3AED).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8A5CF6).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFF8A5CF6),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Calorías',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agregar comidas próximamente'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle),
                color: const Color(0xFF8A5CF6),
                iconSize: 32,
              ),
            ],
          ),
          const SizedBox(height: 32),

          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 20,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${summary.totalCalories}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'de ${summary.goalCalories} kcal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Proteína', summary.totalProtein, Colors.red),
              _buildMacroItem('Carbos', summary.totalCarbs, Colors.orange),
              _buildMacroItem('Grasas', summary.totalFats, Colors.yellow),
            ],
          ),

          const SizedBox(height: 24),

          const Divider(color: Colors.white24),

          const SizedBox(height: 16),

          const Text(
            'Comidas de hoy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if (summary.meals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No has registrado comidas hoy',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...summary.meals.map((meal) => _buildMealItem(meal)),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${value.toStringAsFixed(1)}g',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(MealModel meal) {
    final Map<String, String> mealTypeLabels = {
      'breakfast': 'Desayuno',
      'lunch': 'Almuerzo',
      'dinner': 'Cena',
      'snack': 'Snack',
    };

    final Map<String, IconData> mealTypeIcons = {
      'breakfast': Icons.breakfast_dining,
      'lunch': Icons.lunch_dining,
      'dinner': Icons.dinner_dining,
      'snack': Icons.cookie,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8A5CF6).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              mealTypeIcons[meal.mealType] ?? Icons.fastfood,
              color: const Color(0xFF8A5CF6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mealTypeLabels[meal.mealType] ?? meal.mealType,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  color: Color(0xFF8A5CF6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'P:${meal.protein.toInt()}g C:${meal.carbs.toInt()}g F:${meal.fats.toInt()}g',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

