import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb; // Disponible si se necesita
import 'package:fitsense/core/widgets/drawer/background.dart';

// Session & Auth
import 'package:fitsense/infrastructure/services/session_service.dart';
import 'package:fitsense/features/auth/presentation/login/login_screen.dart';

// Athlete data
import 'package:fitsense/features/auth/data/datasources/athlete_remote_data_source.dart';
import 'package:fitsense/features/auth/data/models/athlete_model.dart';
import 'package:fitsense/features/auth/domain/repositories/athlete_repository.dart';

// Setup por si falta el perfil
import 'package:fitsense/features/auth/presentation/setup/athlete_setup_flow.dart';

// Edit flow
import 'package:fitsense/features/auth/presentation/settings/athlete_edit_flow.dart';

class AthleteSettingsScreen extends StatefulWidget {
  final int userId;
  const AthleteSettingsScreen({super.key, required this.userId});

  @override
  State<AthleteSettingsScreen> createState() => _AthleteSettingsScreenState();
}

class _AthleteSettingsScreenState extends State<AthleteSettingsScreen> {
  static const purple = Color(0xFF8A5CF6);

  final _session = SessionService();
  final _repo = AthleteRepository(AthleteRemoteDataSource());
  Future<AthleteModel?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<AthleteModel?> _load() async {
    await _session.init();
    if (widget.userId <= 0) return null;
    return _repo.findByUserIdOrNull(widget.userId);
  }

  String _freqLabel(int n) {
    // Mapeo 1..7 por compatibilidad, mostrando 1..5 con etiquetas friendly
    if (n <= 1) return 'Muy ocasional';
    if (n == 2) return 'Ligero (2/sem)';
    if (n == 3) return 'Moderado (3/sem)';
    if (n == 4) return 'Constante (4/sem)';
    if (n == 5) return 'Frecuente (5/sem)';
    if (n == 6) return 'Intenso (6/sem)';
    return 'Diario (7/sem)';
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty) return 'A';
    if (p.length == 1) return p.first.characters.first.toUpperCase();
    return (p.first.characters.first + p.last.characters.first).toUpperCase();
  }

  Future<void> _logout() async {
    await _session.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
          (_) => false,
    );
  }

  Future<void> _goToEdit(AthleteModel athlete) async {
    final updated = await Navigator.of(context).push<AthleteModel>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => AthleteEditFlow(athlete: athlete),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ),
    );

    // Si el flujo devolvió un Athlete actualizado, refrescamos UI
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        // refresca sin re-llamar API
        _future = Future.value(updated);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado.')),
      );
    } else {
      // opcional: recargar por si cambió algo fuera
      setState(() {
        _future = _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final maxWidth = isLargeScreen ? 900.0 : screenWidth;

    return AppBackground(
      useSafeArea: false,
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.fromLTRB(
              isLargeScreen ? 32 : 18,
              isLargeScreen ? 24 : 12,
              isLargeScreen ? 32 : 18,
              isLargeScreen ? 24 : 18,
            ),
            child: Column(
              children: [
                // Top bar responsive
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        tooltip: 'Volver',
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 16 : 12),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.settings, color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Configuración',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isLargeScreen ? 26 : 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLargeScreen) const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isLargeScreen ? 20 : 12,
                          vertical: isLargeScreen ? 14 : 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(
                        isLargeScreen ? 'Cerrar sesión' : 'Salir',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isLargeScreen ? 32 : 16),

                // Content
                Expanded(
                  child: FutureBuilder<AthleteModel?>(
                    future: _future,
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFCCF24D),
                          ),
                        );
                      }

                      final athlete = snap.data;
                      if (athlete == null) {
                        return _EmptyCard(
                          title: 'Aún no completas tu perfil',
                          subtitle: 'Cuéntanos tus datos para personalizar tu experiencia.',
                          actionText: 'Completar ahora',
                          isLargeScreen: isLargeScreen,
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 350),
                                pageBuilder: (_, __, ___) => const AthleteSetupFlow(),
                                transitionsBuilder: (_, a, __, c) =>
                                    FadeTransition(opacity: a, child: c),
                              ),
                            );
                          },
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Header card mejorado
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFC8B8FF), Color(0xFFCCF24D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFC8B8FF).withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: isLargeScreen
                                  ? Row(
                                      children: [
                                        _buildAvatar(athlete.fullname, isLargeScreen),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: _buildProfileInfo(athlete, isLargeScreen),
                                        ),
                                        const SizedBox(width: 16),
                                        _buildEditButton(athlete, isLargeScreen),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Row(
                                          children: [
                                            _buildAvatar(athlete.fullname, isLargeScreen),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: _buildProfileInfo(athlete, isLargeScreen),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _buildEditButton(athlete, isLargeScreen),
                                      ],
                                    ),
                            ),

                            SizedBox(height: isLargeScreen ? 24 : 14),

                            // Layout responsive para las cards
                            if (isLargeScreen)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _InfoCard(
                                          title: 'Datos físicos',
                                          icon: Icons.accessibility_new,
                                          isLargeScreen: isLargeScreen,
                                          children: [
                                            _InfoRow(icon: Icons.person_outline, label: 'Género', value: athlete.gender, isLargeScreen: isLargeScreen),
                                            _InfoRow(icon: Icons.cake_outlined, label: 'Edad', value: '${athlete.age} años', isLargeScreen: isLargeScreen),
                                            _InfoRow(
                                              icon: Icons.monitor_weight_outlined,
                                              label: 'Peso',
                                              value: '${athlete.weight.toStringAsFixed(1)} kg',
                                              isLargeScreen: isLargeScreen,
                                            ),
                                            _InfoRow(
                                              icon: Icons.height_outlined,
                                              label: 'Altura',
                                              value: '${athlete.height.toStringAsFixed(0)} cm',
                                              isLargeScreen: isLargeScreen,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        _InfoCard(
                                          title: 'Equipamiento',
                                          icon: Icons.fitness_center,
                                          isLargeScreen: isLargeScreen,
                                          children: [
                                            if (athlete.equipment.isEmpty)
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Row(
                                                  children: const [
                                                    Icon(Icons.info_outline, size: 18, color: Colors.black54),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'Sin equipamiento registrado',
                                                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            else
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  for (final e in athlete.equipment) _ChipTag(text: e, isLargeScreen: isLargeScreen),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _InfoCard(
                                      title: 'Objetivos y actividad',
                                      icon: Icons.trending_up,
                                      isLargeScreen: isLargeScreen,
                                      children: [
                                        _InfoRow(icon: Icons.flag_outlined, label: 'Meta', value: athlete.goal, isLargeScreen: isLargeScreen),
                                        _InfoRow(icon: Icons.bolt_outlined, label: 'Nivel', value: athlete.activityLevel, isLargeScreen: isLargeScreen),
                                        _InfoRow(icon: Icons.place_outlined, label: 'Entorno', value: athlete.environment, isLargeScreen: isLargeScreen),
                                        _InfoRow(
                                          icon: Icons.schedule_outlined,
                                          label: 'Frecuencia',
                                          value: _freqLabel(athlete.frecuency),
                                          isLargeScreen: isLargeScreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  _InfoCard(
                                    title: 'Datos físicos',
                                    icon: Icons.accessibility_new,
                                    isLargeScreen: isLargeScreen,
                                    children: [
                                      _InfoRow(icon: Icons.person_outline, label: 'Género', value: athlete.gender, isLargeScreen: isLargeScreen),
                                      _InfoRow(icon: Icons.cake_outlined, label: 'Edad', value: '${athlete.age} años', isLargeScreen: isLargeScreen),
                                      _InfoRow(
                                        icon: Icons.monitor_weight_outlined,
                                        label: 'Peso',
                                        value: '${athlete.weight.toStringAsFixed(1)} kg',
                                        isLargeScreen: isLargeScreen,
                                      ),
                                      _InfoRow(
                                        icon: Icons.height_outlined,
                                        label: 'Altura',
                                        value: '${athlete.height.toStringAsFixed(0)} cm',
                                        isLargeScreen: isLargeScreen,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoCard(
                                    title: 'Objetivos y actividad',
                                    icon: Icons.trending_up,
                                    isLargeScreen: isLargeScreen,
                                    children: [
                                      _InfoRow(icon: Icons.flag_outlined, label: 'Meta', value: athlete.goal, isLargeScreen: isLargeScreen),
                                      _InfoRow(icon: Icons.bolt_outlined, label: 'Nivel', value: athlete.activityLevel, isLargeScreen: isLargeScreen),
                                      _InfoRow(icon: Icons.place_outlined, label: 'Entorno', value: athlete.environment, isLargeScreen: isLargeScreen),
                                      _InfoRow(
                                        icon: Icons.schedule_outlined,
                                        label: 'Frecuencia',
                                        value: _freqLabel(athlete.frecuency),
                                        isLargeScreen: isLargeScreen,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoCard(
                                    title: 'Equipamiento',
                                    icon: Icons.fitness_center,
                                    isLargeScreen: isLargeScreen,
                                    children: [
                                      if (athlete.equipment.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: const [
                                              Icon(Icons.info_outline, size: 18, color: Colors.black54),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Sin equipamiento registrado',
                                                  style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: [
                                            for (final e in athlete.equipment) _ChipTag(text: e, isLargeScreen: isLargeScreen),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),

                            SizedBox(height: isLargeScreen ? 32 : 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String fullname, bool isLargeScreen) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: isLargeScreen ? 40 : 32,
        backgroundColor: purple,
        child: Text(
          _initials(fullname),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: isLargeScreen ? 22 : 18,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AthleteModel athlete, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          athlete.fullname,
          style: TextStyle(
            fontSize: isLargeScreen ? 22 : 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.phone, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                athlete.phone.isNotEmpty ? athlete.phone : 'Sin teléfono',
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditButton(AthleteModel athlete, bool isLargeScreen) {
    return SizedBox(
      width: isLargeScreen ? null : double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _goToEdit(athlete),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 24 : 16,
            vertical: isLargeScreen ? 16 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white24),
          ),
          elevation: 4,
        ),
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: Text(
          'Editar Perfil',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isLargeScreen ? 15 : 14,
          ),
        ),
      ),
    );
  }
}

/* ---------------- Widgets de soporte (privados de este archivo) --------- */

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isLargeScreen;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isLargeScreen ? 20 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.black, size: isLargeScreen ? 22 : 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: isLargeScreen ? 18 : 16,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeScreen ? 16 : 12),
          Container(
            padding: EdgeInsets.all(isLargeScreen ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLargeScreen;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLargeScreen ? 10 : 8),
      padding: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 12 : 10,
        horizontal: isLargeScreen ? 14 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFCCF24D).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.black87,
              size: isLargeScreen ? 20 : 18,
            ),
          ),
          SizedBox(width: isLargeScreen ? 14 : 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: isLargeScreen ? 15 : 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: isLargeScreen ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  final String text;
  final bool isLargeScreen;

  const _ChipTag({required this.text, this.isLargeScreen = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 16 : 12,
        vertical: isLargeScreen ? 10 : 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCCF24D).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Colors.black),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: isLargeScreen ? 14 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;
  final bool isLargeScreen;

  const _EmptyCard({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isLargeScreen ? 500 : double.infinity),
        padding: EdgeInsets.all(isLargeScreen ? 40 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add,
                size: isLargeScreen ? 48 : 40,
                color: Colors.black,
              ),
            ),
            SizedBox(height: isLargeScreen ? 24 : 20),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: isLargeScreen ? 22 : 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isLargeScreen ? 12 : 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: isLargeScreen ? 15 : 14,
              ),
            ),
            SizedBox(height: isLargeScreen ? 32 : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCF24D),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    vertical: isLargeScreen ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.arrow_forward, size: 20),
                label: Text(
                  actionText,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: isLargeScreen ? 16 : 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
