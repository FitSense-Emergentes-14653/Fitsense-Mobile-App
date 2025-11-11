import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fitsense/core/widgets/drawer/background.dart';
import 'package:fitsense/infrastructure/config/app_config.dart';

class AthleteChatbotScreen extends StatefulWidget {
  final int userId;
  const AthleteChatbotScreen({super.key, required this.userId});

  @override
  State<AthleteChatbotScreen> createState() => _AthleteChatbotScreenState();
}

class _AthleteChatbotScreenState extends State<AthleteChatbotScreen> {
  /// URL base del chatbot - usa detección automática de plataforma
  /// - Android Emulator: http://10.0.2.2:8085
  /// - Web (Chrome): http://localhost:8085
  String get _baseUrl => AppConfig.chatbotBaseUrl;

  final _scrollController = ScrollController();
  final _inputCtrl = TextEditingController();
  bool _loadingSession = true;
  bool _sending = false;
  String? _error;

  String? _sessionId;
  bool _botTyping = false;

  final List<_ChatMessage> _messages = <_ChatMessage>[];

  static const List<_QuickPrompt> _quickPrompts = [
    _QuickPrompt(label: 'Ver mi rutina', message: 'Quiero una rutina'),
    _QuickPrompt(label: 'Ideas de nutrición', message: 'Dame ideas para mi nutrición'),
    _QuickPrompt(label: 'Consejos de descanso', message: 'Necesito consejos para descansar mejor'),
  ];

  @override
  void initState() {
    super.initState();

    _messages.add(const _ChatMessage(
      text: '¡Hola! Soy FitBot. Puedo ayudarte con tu plan, hábitos o metas. '
          '¿En qué te acompaño hoy?',
      fromUser: false,
    ));

    _startSession();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _startSession() async {
    setState(() {
      _loadingSession = true;
      _error = null;
    });

    try {
      // Logs de debugging
      print('🤖 [Chatbot] Plataforma detectada: ${AppConfig.platformInfo}');
      print('🌐 [Chatbot] URL del chatbot: $_baseUrl');
      print('👤 [Chatbot] Usuario ID: ${widget.userId}');

      final uri = Uri.parse('$_baseUrl/session/start');
      print('📡 [Chatbot] Iniciando POST a: $uri');

      final res = await http.post(
        uri,
        headers: const {
          'accept': '*/*',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'userId': '${widget.userId}',
        }),
      );

      print('✅ [Chatbot] Respuesta: ${res.statusCode}');

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final ok = json['ok'] == true;
      final sid = (json['sessionId'] ?? '').toString();

      if (!ok || sid.isEmpty) {
        throw Exception('No se pudo iniciar la sesión de chat');
      }

      setState(() {
        _sessionId = sid;
        _loadingSession = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingSession = false;
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(text: trimmed, fromUser: true));
      _sending = true;
      _botTyping = true;
    });
    _scrollToBottom();

    try {
      print('💬 [Chatbot] Enviando mensaje: "$trimmed"');
      final uri = Uri.parse('$_baseUrl/chat/send');
      print('📡 [Chatbot] POST a: $uri');

      final res = await http.post(
        uri,
        headers: const {
          'accept': '*/*',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'userId': '${widget.userId}',
          'message': trimmed,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final Map<String, dynamic> json = jsonDecode(res.body);
      final reply = (json['reply'] ?? '').toString();

      // Campos extra del backend
      final canChange = json['canChange']?.toString();
      final generatedPlan = json['generatedPlan']?.toString();
      final daysSince = json['daysSinceLastPlan']?.toString();

      final suffix = [
        if (canChange != null) 'canChange: $canChange',
        if (generatedPlan != null) 'generatedPlan: $generatedPlan',
        if (daysSince != null) 'daysSinceLastPlan: $daysSince',
      ].join(' · ');

      final botText = suffix.isEmpty ? reply : '$reply\n\n— $suffix';

      setState(() {
        _messages.add(_ChatMessage(text: botText, fromUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error enviando mensaje: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _botTyping = false;
      });
      _scrollToBottom();
    }
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _tapQuickPrompt(_QuickPrompt p) {
    _sendMessage(p.message);
    _inputCtrl.clear();
  }


  @override
  Widget build(BuildContext context) {
    const bubbleRadius = Radius.circular(18);

    if (_loadingSession) {
      return const AppBackground(
        useSafeArea: false,
        child: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_error != null) {
      return AppBackground(
        useSafeArea: false,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    'No se pudo iniciar el chat.\n$_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _startSession,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AppBackground(
      useSafeArea: false,
      child: SafeArea(
        child: Column(
          children: [
            // Header
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
                  // Indicador de plataforma (útil para debugging)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          AppConfig.platformInfo == 'Android'
                              ? Icons.android
                              : AppConfig.platformInfo == 'Web'
                                  ? Icons.web
                                  : Icons.phone_iphone,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          AppConfig.platformInfo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_sessionId != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'ID: ${_sessionId!.length > 8 ? _sessionId!.substring(0, 8) : _sessionId}...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),

            // Mensajes
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                itemCount: _messages.length + (_botTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_botTyping && index == _messages.length) {
                    // Indicador "escribiendo..."
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.only(
                            topLeft: bubbleRadius,
                            topRight: bubbleRadius,
                            bottomRight: bubbleRadius,
                            bottomLeft: const Radius.circular(4),
                          ),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: const Text('Escribiendo…',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    );
                  }

                  final m = _messages[index];
                  final alignment = m.fromUser ? Alignment.centerRight : Alignment.centerLeft;
                  final color = m.fromUser
                      ? const Color(0xFF8A5CF6)
                      : Colors.white.withOpacity(0.08);
                  return Align(
                    alignment: alignment,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 280),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.only(
                            topLeft: bubbleRadius,
                            topRight: bubbleRadius,
                            bottomLeft:
                            m.fromUser ? bubbleRadius : const Radius.circular(4),
                            bottomRight:
                            m.fromUser ? const Radius.circular(4) : bubbleRadius,
                          ),
                          border: m.fromUser ? null : Border.all(color: Colors.white12),
                        ),
                        child: Text(m.text,
                            style:
                            const TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Barra inferior
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF101010),
                border: Border(top: BorderSide(color: Colors.white12)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickPrompts.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final p = _quickPrompts[i];
                        return ActionChip(
                          label: Text(p.label),
                          backgroundColor: const Color(0xFF8A5CF6),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide.none,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          onPressed: _sending ? null : () => _tapQuickPrompt(p),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputCtrl,
                          enabled: !_sending,
                          onSubmitted: (v) {
                            _sendMessage(v);
                            _inputCtrl.clear();
                          },
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje…',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.06),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                              const BorderSide(color: Color(0xFF8A5CF6)),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _sending
                            ? null
                            : () {
                          final text = _inputCtrl.text;
                          _sendMessage(text);
                          _inputCtrl.clear();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _sending
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.send_rounded),
                      ),
                    ],
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
