import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/infrastructure/services/session_service.dart';
import 'package:fitsense/features/auth/presentation/home/athlete_home_screen.dart';

import '../../data/datasources/athlete_remote_data_source.dart';
import '../../data/models/athlete_model.dart';
import '../../domain/repositories/athlete_repository.dart';

class AthleteSetupFlow extends StatefulWidget {
  const AthleteSetupFlow({super.key});

  @override
  State<AthleteSetupFlow> createState() => _AthleteSetupFlowState();
}

class _AthleteSetupFlowState extends State<AthleteSetupFlow> {
  final _pc = PageController();
  int _step = 0;

  // Estado a recolectar
  String? gender;                   // 'M' / 'F'
  int age = 28;
  double weight = 75;
  bool useKg = true;                // KG/LB toggle
  int heightCm = 165;
  String? goal;                     // “Perder Peso”, etc.
  String activityLevel = 'Intermedio';
  final equipment = <String>[];     // libre

  // Nombre y teléfono (requeridos por modelo)
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final _repo = AthleteRepository(AthleteRemoteDataSource());
  final _session = SessionService();
  bool _saving = false;

  // helpers
  void _next() {
    if (_step < 7) {
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

  Future<void> _save() async {
    // Validaciones mínimas
    if (gender == null || goal == null || nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa género, meta y nombre.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final userId = _session.getUserId();

      // Peso en KG (si usa LB convertir)
      final wKg = useKg ? weight : weight * 0.45359237;

      final model = AthleteModel(
        id: 0,
        userId: userId,
        fullname: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        gender: gender!,
        age: age,
        weight: double.parse(wKg.toStringAsFixed(1)),
        height: heightCm.toDouble(),
        goal: goal!,
        activityLevel: activityLevel,
        equipment: equipment,
      );

      await _repo.createAthlete(
        userId: model.userId,
        fullname: model.fullname,
        phone: model.phone,
        gender: model.gender,
        age: model.age,
        weight: model.weight,
        height: model.height,
        goal: model.goal,
        activityLevel: model.activityLevel,
        equipment: model.equipment,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil creado. ¡Bienvenido!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AthleteHomeScreen()),
            (_) => false,
      );
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
    const green = Color(0xFFCCF24D); // tono del mock para resaltados

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
          const SizedBox(height: 36),
          // AppBar simple
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: _back,
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.yellow),
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pc,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 0) Intro
                _IntroStep(
                  onNext: _next,
                  heroAsset: 'lib/assets/images/woman-training-workout-gym.png',
                ),

                // 1) Género
                _CardScaffold(
                  title: '¿Cuál Es Tu Género?',
                  subtitle: 'Selecciona tu género para personalizar tus objetivos.',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _GenderOption(
                        label: 'Masculino',
                        icon: Icons.male_rounded,
                        selected: gender == 'Masculino',
                        onTap: () => setState(() => gender = 'Masculino'),
                      ),
                      _GenderOption(
                        label: 'Femenino',
                        icon: Icons.female_rounded,
                        selected: gender == 'Femenino',
                        onTap: () => setState(() => gender = 'Femenino'),
                      ),
                    ],
                  ),
                  bottom: nextBtn('Siguiente'),
                ),

                // 2) Edad
                _CardScaffold(
                  title: '¿Cuántos Años Tienes?',
                  subtitle: 'Desliza para ajustar tu edad.',
                  child: _NumberPicker(
                    value: age,
                    min: 10,
                    max: 90,
                    onChanged: (v) => setState(() => age = v),
                    accent: lilac,
                  ),
                  bottom: nextBtn('Siguiente'),
                ),

                // 3) Peso (KG/LB)
                _CardScaffold(
                  title: '¿Cuál Es Tu Peso?',
                  subtitle: 'Selecciona la unidad y ajusta tu peso.',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ToggleButtons(
                        isSelected: [useKg, !useKg],
                        borderRadius: BorderRadius.circular(12),
                        children: const [Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('KG')),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('LB')),
                        ],
                        onPressed: (i) => setState(() => useKg = (i == 0)),
                      ),
                      const SizedBox(height: 12),
                      _SliderWithMarks(
                        min: 30, max: 180, value: weight,
                        onChanged: (v) => setState(() => weight = v),
                        accent: lilac,
                        label: '${weight.toStringAsFixed(0)} ${useKg ? 'Kg' : 'Lb'}',
                      ),
                    ],
                  ),
                  bottom: nextBtn('Siguiente'),
                ),

                // 4) Altura
                _CardScaffold(
                  title: '¿Cuál Es Tu Altura?',
                  subtitle: 'Ajusta tu altura en centímetros.',
                  child: _SliderWithMarks(
                    min: 140, max: 200, value: heightCm.toDouble(),
                    onChanged: (v) => setState(() => heightCm = v.round()),
                    accent: lilac,
                    label: '$heightCm cm',
                  ),
                  bottom: nextBtn('Siguiente'),
                ),

                // 5) Meta
                _CardScaffold(
                  title: '¿Cuál Es Tu Meta?',
                  subtitle: 'Elige una opción.',
                  child: _SingleChoice(
                    options: const [
                      'Perder Peso',
                      'Ganar Peso',
                      'Aumentar de Masa',
                      'Moldear El Cuerpo',
                      'Otros',
                    ],
                    value: goal,
                    onChanged: (v) => setState(() => goal = v),
                  ),
                  bottom: nextBtn('Siguiente'),
                ),

                // 6) Nivel de Actividad
                _CardScaffold(
                  title: 'Nivel De Actividad Física',
                  subtitle: 'Elige tu nivel.',
                  child: _SingleChoiceChips(
                    options: const ['Principiante', 'Intermedio', 'Avanzado'],
                    value: activityLevel,
                    onChanged: (v) => setState(() => activityLevel = v),
                    accent: green,
                  ),
                  bottom: nextBtn('Siguiente'),
                ),

                // 7) Datos de contacto (Nombre + Teléfono) + Equipamiento opcional
                _CardScaffold(
                  title: 'Datos de Contacto',
                  subtitle: 'Necesitamos tu nombre y teléfono.',
                  child: Column(
                    children: [
                      _TextBox(hint: 'Nombre Completo', controller: nameCtrl),
                      const SizedBox(height: 12),
                      _TextBox(hint: 'Teléfono (opcional)', controller: phoneCtrl, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Equipamiento (opcional)', style: TextStyle(color: Colors.white.withOpacity(.9), fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final e in ['Mancuernas','Banda elástica','Colchoneta','Cuerda'])
                            FilterChip(
                              selected: equipment.contains(e),
                              label: Text(e),
                              onSelected: (s){
                                setState(() {
                                  if (s) equipment.add(e); else equipment.remove(e);
                                });
                              },
                            ),
                        ],
                      ),
                    ],
                  ),
                  bottom: nextBtn('Guardar y continuar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- UI helpers --------------------

class _IntroStep extends StatelessWidget {
  final String heroAsset;
  final VoidCallback onNext;
  const _IntroStep({required this.heroAsset, required this.onNext});

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 9/16,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(heroAsset, fit: BoxFit.cover),
                  Container(color: Colors.black.withOpacity(.35)),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: lilac,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: const Text(
                        'La Constancia Es La Clave Del Progreso.\n¡No Te Rindas!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Antes de comenzar, cuéntanos algunos detalles para personalizar tu plan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 180, height: 46,
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
            child: const Text('Siguiente', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _CardScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final Widget bottom;

  const _CardScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    const lilac = Color(0xFFC8B8FF);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: lilac, borderRadius: BorderRadius.circular(8)),
            child: child,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: bottom,
          ),
        ],
      ),
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
        width: 130, height: 160,
        decoration: BoxDecoration(
          color: Colors.white, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
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
      children: [
        Text('$value', style: const TextStyle(fontSize: 48, color: Colors.black, fontWeight: FontWeight.w800)),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: (max-min),
          activeColor: Colors.black87,
          inactiveColor: accent.withOpacity(.6),
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
      children: [
        Text(label, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: Colors.black87,
          inactiveColor: accent.withOpacity(.6),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _SingleChoice extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  const _SingleChoice({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final o in options)
          RadioListTile<String>(
            value: o,
            groupValue: value,
            onChanged: (v) => onChanged(v!),
            title: Text(o),
          ),
      ],
    );
  }
}

class _SingleChoiceChips extends StatelessWidget {
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;
  final Color accent;
  const _SingleChoiceChips({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        for (final o in options)
          ChoiceChip(
            label: Text(o),
            selected: value == o,
            selectedColor: accent,
            onSelected: (_) => onChanged(o),
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
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }
}
