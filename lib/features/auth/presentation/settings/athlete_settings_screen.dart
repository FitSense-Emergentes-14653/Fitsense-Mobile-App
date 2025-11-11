import 'package:flutter/material.dart';
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
  static const lilac = Color(0xFFC8B8FF);
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
    return AppBackground(
      useSafeArea: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Configuración',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white24),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: FutureBuilder<AthleteModel?>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final athlete = snap.data;
                    if (athlete == null) {
                      return _EmptyCard(
                        title: 'Aún no completas tu perfil',
                        subtitle: 'Cuéntanos tus datos para personalizar tu experiencia.',
                        actionText: 'Completar ahora',
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
                          // Header card + botón Editar
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: lilac,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: purple,
                                  child: Text(
                                    _initials(athlete.fullname),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        athlete.fullname,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        athlete.phone.isNotEmpty ? athlete.phone : 'Sin teléfono',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _goToEdit(athlete),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(color: Colors.white24),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Editar', style: TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          _InfoCard(
                            title: 'Datos físicos',
                            children: [
                              _InfoRow(icon: Icons.person_outline, label: 'Género', value: athlete.gender),
                              _InfoRow(icon: Icons.cake_outlined, label: 'Edad', value: '${athlete.age}'),
                              _InfoRow(
                                icon: Icons.monitor_weight_outlined,
                                label: 'Peso',
                                value: '${athlete.weight.toStringAsFixed(1)} kg',
                              ),
                              _InfoRow(
                                icon: Icons.height_outlined,
                                label: 'Altura',
                                value: '${athlete.height.toStringAsFixed(0)} cm',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          _InfoCard(
                            title: 'Objetivos y actividad',
                            children: [
                              _InfoRow(icon: Icons.flag_outlined, label: 'Meta', value: athlete.goal),
                              _InfoRow(icon: Icons.bolt_outlined, label: 'Nivel', value: athlete.activityLevel),
                              _InfoRow(icon: Icons.place_outlined, label: 'Entorno', value: athlete.environment),
                              _InfoRow(
                                icon: Icons.schedule_outlined,
                                label: 'Frecuencia',
                                value: '${athlete.frecuency} /sem • ${_freqLabel(athlete.frecuency)}',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          _InfoCard(
                            title: 'Equipamiento',
                            children: [
                              if (athlete.equipment.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Sin equipamiento registrado',
                                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final e in athlete.equipment) _ChipTag(text: e),
                                  ],
                                ),
                            ],
                          ),

                          const SizedBox(height: 24),
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
    );
  }
}

/* ---------------- Widgets de soporte (privados de este archivo) --------- */

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(color: lilac, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
            ),
          ),
          Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  final String text;
  const _ChipTag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;
  const _EmptyCard({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: lilac, borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
              child: const Text('Completar ahora', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
