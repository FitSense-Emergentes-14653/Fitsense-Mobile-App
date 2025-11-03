import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';

class AthleteChatbotScreen extends StatefulWidget {
  const AthleteChatbotScreen({super.key});

  @override
  State<AthleteChatbotScreen> createState() => _AthleteChatbotScreenState();
}

class _AthleteChatbotScreenState extends State<AthleteChatbotScreen> {
  final _scrollController = ScrollController();

  static const _routinePlan = """✨ Tu plan mensual

📌Notas generales: Mantén un RPE de 7-8, realiza técnica estricta en cada ejercicio y prioriza la forma sobre el peso. Asegúrate de calentar adecuadamente antes de cada sesión y estirar al finalizar.

🔥Frecuencia sugerida: 4 días/semana

📅 Semana 1-4
- Upper+Core: Dumbbell Bench Press 3x10 (RPE 7), One-Arm Dumbbell Row 3x12, Arnold Press 3x12, Hanging Knee Raises 3x15.
- Lower: Back Squat 4x8 (RPE 8), Romanian Deadlift 3x10, Walking Lunges 3x12 por pierna, Glute Bridge 3x15.
- HIIT + Core: Sprint intervals 10x40" on/20" off, Mountain Climbers 3x40", Russian Twists 3x20.
- Movilidad + Cardio suave: Flow de movilidad 20', bicicleta ligera 25'.

💪 Semana 5-8
- Upper Strength: Bench Press 5x5 (RPE 8), Weighted Pull-Ups 4x6, Dumbbell Shoulder Press 3x8, Plank 3x60".
- Lower Strength: Deadlift 5x5 (RPE 8), Bulgarian Split Squat 4x10 por pierna, Hip Thrust 4x12, Calf Raises 4x15.
- Conditioning: Assault Bike 5x2' (recuperación 1'), Battle Ropes 5x45", V-ups 4x15.
- Recuperación activa: Caminata ligera 40', sesión de estiramientos globales 20'.

✅ Recomendaciones: Monitorea tu sueño, hidrátate correctamente y registra sensaciones cada semana para ajustar cargas.""";

  static const List<_QuickPrompt> _quickPrompts = [
    _QuickPrompt(label: 'Ver mi rutina', message: 'Quiero una rutina'),
    _QuickPrompt(
      label: 'Ideas de nutrición',
      message: 'Dame ideas para mi nutrición',
    ),
    _QuickPrompt(
      label: 'Consejos de descanso',
      message: 'Necesito consejos para descansar mejor',
    ),
  ];

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
      '¡Hola! Soy FitBot. Puedo ayudarte con dudas sobre tu plan, hábitos o metas. ¿En qué te acompaño hoy?',
      fromUser: false,
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _dispatchMessage(String text) {
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, fromUser: true));
    });
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(text: _generateResponse(text), fromUser: false),
        );
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String userMessage) {
    final lower = userMessage.toLowerCase();
    if (lower.contains('quiero una rutina') || lower.contains('mi rutina')) {
      return _routinePlan;
    }
    if (lower.contains('nutric')) {
      return 'Recuerda priorizar proteínas magras, carbohidratos complejos y verduras en cada comida. ¡La hidratación también cuenta!';
    }
    if (lower.contains('rutina') || lower.contains('entreno')) {
      return 'Puedes alternar días de fuerza y de cardio. Asegúrate de incluir movilidad y estiramientos para recuperarte mejor.';
    }
    if (lower.contains('descanso') || lower.contains('sueño')) {
      return 'Dormir entre 7 y 9 horas ayuda a mejorar tu rendimiento. Intenta mantener horarios regulares y evitar pantallas antes de dormir.';
    }
    return 'Gracias por tu mensaje. Estoy aquí para acompañarte en tu progreso. ¡Cuéntame más detalles para darte una recomendación personalizada!';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const bubbleRadius = Radius.circular(18);

    return AppBackground(
      useSafeArea: false,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'FitBot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.bolt, color: Colors.amber, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Asistente virtual',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final alignment =
                  message.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                  final color = message.fromUser
                      ? const Color(0xFF8A5CF6)
                      : Colors.white.withOpacity(0.08);
                  final textColor = message.fromUser ? Colors.white : Colors.white;

                  return Align(
                    alignment: alignment,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.only(
                            topLeft: bubbleRadius,
                            topRight: bubbleRadius,
                            bottomLeft:
                            message.fromUser ? bubbleRadius : const Radius.circular(4),
                            bottomRight:
                            message.fromUser ? const Radius.circular(4) : bubbleRadius,
                          ),
                          border: message.fromUser
                              ? null
                              : Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: textColor, fontSize: 15),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101010),
                border: Border(
                  top: BorderSide(color: Colors.white12),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final prompt = _quickPrompts[index];
                        return ActionChip(
                          label: Text(prompt.label),
                          backgroundColor: Colors.white.withOpacity(0.08),
                          labelStyle: const TextStyle(color: Colors.white),
                          side: const BorderSide(color: Colors.white24),
                          onPressed: () => _dispatchMessage(prompt.message),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: _quickPrompts.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool fromUser;

  const _ChatMessage({required this.text, required this.fromUser});
}

class _QuickPrompt {
  final String label;
  final String message;

  const _QuickPrompt({required this.label, required this.message});
}