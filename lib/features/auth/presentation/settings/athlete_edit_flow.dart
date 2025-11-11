import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';

import '../../data/datasources/athlete_remote_data_source.dart';
import '../../data/models/athlete_model.dart';
import '../../domain/repositories/athlete_repository.dart';

/// Flujo de edición por pasos, igual al setup, pero precargado
/// y guardando con updateAthlete().
class AthleteEditFlow extends StatefulWidget {
  final AthleteModel athlete;
  const AthleteEditFlow({super.key, required this.athlete});

  @override
  State<AthleteEditFlow> createState() => _AthleteEditFlowState();
}

class _AthleteEditFlowState extends State<AthleteEditFlow> {
  final _pc = PageController();
  int _step = 0;

  // Estado editable (precargado desde widget.athlete)
  String? gender; // 'Masculino' / 'Femenino'
  int age = 18;
  double weight = 60;
  bool useKg = true; // siempre mostramos en KG por defecto (toggle permite LB)
  int heightCm = 165;
  String? goal; // “Perder Peso”, etc.
  String activityLevel = 'Intermedio';
  final equipment = <String>[]; // lista editada

  // Campos nuevos
  String? environment; // "Casa" | "Gimnasio" | "Aire Libre" | "Sin preferencia"
  int frecuency = 3;    // 1..5 (veces por semana)

  String freqLabel(int v) => switch (v) {
        1 => 'Muy baja (1/sem.)',
        2 => 'Baja (2/sem.)',
        3 => 'Media (3–4/sem.)',
        4 => 'Alta (5–6/sem.)',
        5 => 'Intensa (7/sem.)',
        _ => '',
      };

  // Nombre y teléfono
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final _repo = AthleteRepository(AthleteRemoteDataSource());
  final _session = SessionService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Precargar desde el Athlete recibido
    final a = widget.athlete;

    gender = (a.gender.isEmpty) ? null : a.gender; // 'Masculino'/'Femenino'
    age = (a.age == 0) ? 18 : a.age;
    weight = (a.weight == 0) ? 60 : a.weight; // suponemos ya en KG
    heightCm = (a.height == 0) ? 165 : a.height.round();
    goal = (a.goal.isEmpty) ? null : a.goal;
    activityLevel = a.activityLevel.isEmpty ? 'Intermedio' : a.activityLevel;
    environment = (a.environment.isEmpty) ? null : a.environment;
    frecuency = (a.frecuency == 0) ? 3 : a.frecuency;

    equipment.clear();
    equipment.addAll(a.equipment);

    nameCtrl.text = a.fullname;
    phoneCtrl.text = a.phone;
  }

  // ---- Navegación ----
  void _next() {
    // total páginas = 10 (0..9)
    if (_step < 9) {
      setState(() => _step++);
      _pc.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      _save();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pc.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      Navigator.pop(context);
    }
  }

  // ---- Guardar (UPDATE) ----
  Future<void> _save() async {
    if (gender == null || goal == null || nameCtrl.text.trim().isEmpty || environment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa género, meta, nombre y entorno de entrenamiento.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _session.init();

      // Peso final en KG (si eligieron LB, convertir)
      final wKg = useKg ? weight : weight * 0.45359237;

      final updated = widget.athlete.copyWith(
        fullname: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        gender: gender!,
        age: age,
        weight: double.parse(wKg.toStringAsFixed(1)),
        height: heightCm.toDouble(),
        goal: goal!,
        activityLevel: activityLevel,
        equipment: List<String>.from(equipment),
        environment: environment!,
        frecuency: frecuency,
      );

      // IMPORTANTE: en edición llamamos updateAthlete
      final saved = await _repo.updateAthlete(widget.athlete.id, updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      // Devolvemos el Athlete actualizado
      Navigator.of(context).pop(saved);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    const green = Color(0xFFCCF24D);

    Widget nextBtn(String text) => SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            onPressed: _saving ? null : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        );

    return AppBackground(
      useSafeArea: false,
      child: Column(
        children: [
          // AppBar simple
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 12.0,
              right: 12.0,
              bottom: 12,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.yellow),
                ),
                const Spacer(),
                const Text(
                  'Editar perfil',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              itemBuilder: (context, index) {
                return _buildPage(index, nextBtn, lilac, green);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(int index, Function(String) nextBtn, Color lilac, Color green) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final maxW = constraints.maxWidth > 800 ? 600.0 : constraints.maxWidth - 32;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 32.0 : 16.0, vertical: 16.0),
            child: Center(
              child: SizedBox(
                width: maxW,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index == 0)
                      _IntroStep(
                        onNext: _next,
                        heroAsset: 'lib/assets/images/woman-training-workout-gym.png',
                        isWide: isWide,
                      )
                    else if (index == 1)
                      _CardScaffold(
                        title: '¿Cuál Es Tu Género?',
                        subtitle: 'Selecciona tu género para personalizar tus objetivos.',
                        isWide: isWide,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GenderOption(
                              label: 'Masculino',
                              icon: Icons.male_rounded,
                              selected: gender == 'Masculino',
                              onTap: () => setState(() => gender = 'Masculino'),
                            ),
                            SizedBox(width: isWide ? 24 : 16),
                            _GenderOption(
                              label: 'Femenino',
                              icon: Icons.female_rounded,
                              selected: gender == 'Femenino',
                              onTap: () => setState(() => gender = 'Femenino'),
                            ),
                          ],
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 2)
                      _CardScaffold(
                        title: '¿Cuántos Años Tienes?',
                        subtitle: 'Desliza para ajustar tu edad.',
                        isWide: isWide,
                        child: _NumberPicker(
                          value: age,
                          min: 10,
                          max: 90,
                          onChanged: (v) => setState(() => age = v),
                          accent: lilac,
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 3)
                      _CardScaffold(
                        title: '¿Cuál Es Tu Peso?',
                        subtitle: 'Selecciona la unidad y ajusta tu peso.',
                        isWide: isWide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ToggleButtons(
                              isSelected: [useKg, !useKg],
                              borderRadius: BorderRadius.circular(12),
                              children: const [
                                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('KG')),
                                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('LB')),
                              ],
                              onPressed: (i) => setState(() => useKg = (i == 0)),
                            ),
                            const SizedBox(height: 12),
                            _SliderWithMarks(
                              min: 30,
                              max: 180,
                              value: weight,
                              onChanged: (v) => setState(() => weight = v),
                              accent: lilac,
                              label: '${weight.toStringAsFixed(0)} ${useKg ? 'Kg' : 'Lb'}',
                            ),
                          ],
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 4)
                      _CardScaffold(
                        title: '¿Cuál Es Tu Altura?',
                        subtitle: 'Ajusta tu altura en centímetros.',
                        isWide: isWide,
                        child: _SliderWithMarks(
                          min: 140,
                          max: 200,
                          value: heightCm.toDouble(),
                          onChanged: (v) => setState(() => heightCm = v.round()),
                          accent: lilac,
                          label: '$heightCm cm',
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 5)
                      _CardScaffold(
                        title: '¿Cuál Es Tu Meta?',
                        subtitle: 'Elige una opción.',
                        isWide: isWide,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (final o in const [
                                'Perder Peso',
                                'Ganar Peso',
                                'Aumento de masa muscular',
                                'Moldear El Cuerpo',
                                'Otros',
                              ])
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(o, style: const TextStyle(color: Colors.black)),
                                    leading: Radio<String>(
                                      value: o,
                                      groupValue: goal,
                                      onChanged: (v) => setState(() => goal = v),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 6)
                      _CardScaffold(
                        title: 'Nivel De Actividad Física',
                        subtitle: 'Elige tu nivel.',
                        isWide: isWide,
                        child: Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final o in const ['Principiante', 'Intermedio', 'Avanzado'])
                              ChoiceChip(
                                label: Text(o, style: TextStyle(color: activityLevel == o ? Colors.white : Colors.black)),
                                selected: activityLevel == o,
                                selectedColor: green,
                                backgroundColor: Colors.white,
                                onSelected: (_) => setState(() => activityLevel = o),
                              ),
                          ],
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 7)
                      _CardScaffold(
                        title: '¿Dónde entrenas normalmente?',
                        subtitle: 'Selecciona tu entorno habitual.',
                        isWide: isWide,
                        child: Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final o in const ['Casa', 'Gimnasio', 'Aire Libre', 'Sin preferencia'])
                              ChoiceChip(
                                label: Text(o, style: TextStyle(color: environment == o ? Colors.black : Colors.black54)),
                                selected: environment == o,
                                selectedColor: lilac,
                                backgroundColor: Colors.white,
                                onSelected: (_) => setState(() => environment = o),
                              ),
                          ],
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 8)
                      _CardScaffold(
                        title: '¿Con qué frecuencia entrenas?',
                        subtitle: 'Veces por semana',
                        isWide: isWide,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$frecuency', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.black)),
                            Slider(
                              value: frecuency.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: freqLabel(frecuency),
                              onChanged: (v) => setState(() => frecuency = v.round()),
                            )
                          ],
                        ),
                        bottom: nextBtn('Siguiente'),
                      )
                    else if (index == 9)
                      _CardScaffold(
                        title: 'Datos de Contacto',
                        subtitle: 'Tu nombre y teléfono.',
                        isWide: isWide,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TextBox(hint: 'Nombre Completo', controller: nameCtrl),
                              const SizedBox(height: 12),
                              _TextBox(
                                hint: 'Teléfono (opcional)',
                                controller: phoneCtrl,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Equipamiento (opcional)',
                                style: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final e in const ['Mancuernas', 'Banda elástica', 'Colchoneta', 'Cuerda'])
                                    FilterChip(
                                      selected: equipment.contains(e),
                                      label: Text(e),
                                      onSelected: (s) {
                                        setState(() {
                                          if (s) {
                                            equipment.add(e);
                                          } else {
                                            equipment.remove(e);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        bottom: SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E1E1E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(color: Colors.white24),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Guardar cambios', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/* ----------------------- UI helpers (mismos del setup) ----------------------- */

class _IntroStep extends StatelessWidget {
  final String heroAsset;
  final VoidCallback onNext;
  final bool isWide;
  const _IntroStep({required this.heroAsset, required this.onNext, required this.isWide});

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(isWide ? 16.0 : 12.0),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: isWide ? 400 : 280,
            ),
            child: AspectRatio(
              aspectRatio: isWide ? 16 / 9 : 4 / 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(heroAsset, fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.35)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: lilac,
                      padding: EdgeInsets.symmetric(
                        horizontal: isWide ? 24.0 : 16.0,
                        vertical: isWide ? 20.0 : 14.0,
                      ),
                      child: Text(
                        'Ajusta tus datos para mantener tu plan al día.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isWide ? 18.0 : 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Repasemos tus datos en pocos pasos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isWide ? 16.0 : 14.0,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: isWide ? 200 : 180,
          height: isWide ? 50 : 46,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.white24),
              ),
            ),
            child: Text(
              'Comenzar',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isWide ? 16.0 : 14.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _CardScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottom;
  final bool isWide;

  const _CardScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottom,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isWide ? 24.0 : 20.0,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isWide ? 16.0 : 14.0,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
          decoration: BoxDecoration(
            color: lilac,
            borderRadius: BorderRadius.circular(isWide ? 12.0 : 8.0),
          ),
          child: child,
        ),
        const SizedBox(height: 24),
        bottom,
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.black : Colors.black54;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _NumberPicker extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Color accent;

  const _NumberPicker({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: const TextStyle(fontSize: 48, color: Colors.black, fontWeight: FontWeight.w800)),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max - min),
          activeColor: Colors.black87,
          inactiveColor: accent.withValues(alpha: 0.6),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class _SliderWithMarks extends StatelessWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final Color accent;
  final String label;

  const _SliderWithMarks({
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    required this.accent,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.black)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: Colors.black87,
          inactiveColor: accent.withValues(alpha: 0.6),
          onChanged: onChanged,
        ),
      ],
    );
  }
}


class _TextBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _TextBox({required this.controller, required this.hint, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          hintText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14),
        ).copyWith(hintText: hint),
      ),
    );
  }
}
