import 'package:flutter/material.dart';

// Fondo negro reutilizable
import 'package:fitsense/core/widgets/drawer/background.dart';

// Data layer (auth)
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

// Athlete (gate)
import '../../data/datasources/athlete_remote_data_source.dart';
import '../../domain/repositories/athlete_repository.dart';
import '../setup/athlete_setup_flow.dart';

// Session
import '../../../../infrastructure/services/session_service.dart';

// Destinos
import 'package:fitsense/features/auth/presentation/home/athlete_home_screen.dart';
import 'package:fitsense/features/auth/presentation/register/sign_up_screen.dart';

// Reset Password
import 'package:fitsense/features/auth/presentation/reset-password/set_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- UI/State ---
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  // --- Services ---
  final _session = SessionService();
  final _auth = AuthRepository(AuthRemoteDataSource());

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  // Cambiado para RECIBIR userId y pasarlo al Home / Setup
  Future<void> _goByRole(String role, int userId) async {
    if (!mounted) return;
    final upper = role.toUpperCase();

    if (upper == 'ATHLETE') {
      // Gate: si no existe Athlete -> Setup Flow
      final repo = AthleteRepository(AthleteRemoteDataSource());

      if (userId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: userId no válido.')),
        );
        return;
      }

      // Ideal: tener endpoint /athletes/me; por ahora fallback:
      final list = await repo.getAll();
      final athlete = list.where((a) => a.userId == userId).firstOrNull;

      if (!mounted) return;

      if (athlete == null) {
        // No existe perfil de atleta -> ir al setup
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) => const AthleteSetupFlow(),
            transitionsBuilder: (_, a, __, child) =>
                FadeTransition(opacity: a, child: child),
          ),
        );
        return;
      }

      // El atleta existe -> guardar su ID en la sesión
      await _session.setAthleteId(athlete.id);
    }

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => AthleteHomeScreen(userId: userId),
        transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
      ),
          (_) => false,
    );
  }
  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await _session.init();

    try {
      final email = _emailCtrl.text.trim();
      final pass  = _passCtrl.text;

      final data = await _auth.signInUser(email: email, password: pass);
      if (data == null) throw Exception('No se pudo iniciar sesión');

      final token = (data['token'] ?? '').toString();
      if (token.isEmpty) throw Exception('Token no recibido');
      await _session.setToken(token);

      int userId = -1;
      if (data['id'] != null) {
        userId = int.tryParse('${data['id']}') ?? -1;            // raíz
      } else if (data['user'] is Map && data['user']['id'] != null) {
        userId = int.tryParse('${data['user']['id']}') ?? -1;    // anidado
      }
      if (userId <= 0) {
        throw Exception('userId no recibido del backend');
      }
      await _session.setUserId(userId);

      String role = 'ATHLETE';
      if (data['roles'] is List && (data['roles'] as List).isNotEmpty) {
        role = '${data['roles'][0]}';
      } else if (data['user'] is Map &&
          data['user']['roles'] is List &&
          (data['user']['roles'] as List).isNotEmpty) {
        role = '${data['user']['roles'][0]}';
      }
      await _session.setRole(role);

      await _goByRole(role, userId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final maxWidth = isLargeScreen ? 500.0 : screenWidth;

    return AppBackground(
      scrollable: true,
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 32 : 20,
            vertical: isLargeScreen ? 32 : 16,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header mejorado
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                SizedBox(height: isLargeScreen ? 40 : 24),

                // Logo/Icono
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCF24D).withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: isLargeScreen ? 48 : 40,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: isLargeScreen ? 32 : 24),

                // Título principal
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Bienvenido de nuevo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: isLargeScreen ? 32 : 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Inicia Sesión',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: isLargeScreen ? 16 : 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isLargeScreen ? 16 : 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 32 : 16),
                  child: Text(
                    'Ingresa tus credenciales para continuar tu viaje fitness',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: isLargeScreen ? 15 : 13,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: isLargeScreen ? 40 : 32),

              // Container de campos con glassmorphism
              Container(
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
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(isLargeScreen ? 28 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCCF24D).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: Color(0xFFCCF24D),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isLargeScreen ? 15 : 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Input(
                      controller: _emailCtrl,
                      hint: 'tu@email.com',
                      keyboardType: TextInputType.emailAddress,
                      isLargeScreen: isLargeScreen,
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Ingresa tu email';
                        if (!t.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    SizedBox(height: isLargeScreen ? 24 : 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8B8FF).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: Color(0xFFC8B8FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Contraseña',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: isLargeScreen ? 15 : 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _Input(
                      controller: _passCtrl,
                      hint: '••••••••',
                      obscure: _obscure,
                      isLargeScreen: isLargeScreen,
                      trailing: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white70,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          final email = _emailCtrl.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un email válido antes de continuar.'),
                                backgroundColor: Color(0xFF8A5CF6),
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SetPasswordScreen(email: email),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.help_outline,
                          size: 16,
                          color: Color(0xFFCCF24D),
                        ),
                        label: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: const Color(0xFFCCF24D),
                            fontWeight: FontWeight.w700,
                            fontSize: isLargeScreen ? 14 : 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isLargeScreen ? 32 : 24),

              // Botón principal mejorado
              SizedBox(
                height: isLargeScreen ? 56 : 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCCF24D), Color(0xFFC8B8FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCCF24D).withValues(alpha: 0.4),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.login_rounded,
                                  color: Colors.black,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: isLargeScreen ? 17 : 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: isLargeScreen ? 32 : 24),

              // Divider con texto
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'o continúa con',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: isLargeScreen ? 13 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isLargeScreen ? 24 : 20),

              // Redes sociales mejoradas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialCircle(
                    icon: Icons.g_mobiledata_rounded,
                    isLargeScreen: isLargeScreen,
                  ),
                  SizedBox(width: isLargeScreen ? 20 : 16),
                  _SocialCircle(
                    icon: Icons.facebook_rounded,
                    isLargeScreen: isLargeScreen,
                  ),
                  SizedBox(width: isLargeScreen ? 20 : 16),
                  _SocialCircle(
                    icon: Icons.apple_rounded,
                    isLargeScreen: isLargeScreen,
                  ),
                ],
              ),

              SizedBox(height: isLargeScreen ? 32 : 24),

              // Link de registro mejorado
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 24 : 20,
                    vertical: isLargeScreen ? 14 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¿Aún no tienes cuenta?',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: isLargeScreen ? 14 : 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 350),
                              pageBuilder: (_, __, ___) => const SignUpScreen(),
                              transitionsBuilder: (_, a, __, c) {
                                return FadeTransition(
                                  opacity: a,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.1, 0),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(
                                      parent: a,
                                      curve: Curves.easeOutCubic,
                                    )),
                                    child: c,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8A5CF6), Color(0xFFA78BFA)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Regístrate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: isLargeScreen ? 14 : 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isLargeScreen ? 32 : 24),
            ],
          ),
        ),
      ),
    )
    );
  }
}

// ---------- Widgets internos ----------

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;
  final String? Function(String?)? validator;
  final bool isLargeScreen;

  const _Input({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
    this.validator,
    this.isLargeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isLargeScreen ? 54 : 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: isLargeScreen ? 15 : 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w500,
            fontSize: isLargeScreen ? 15 : 14,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 18 : 16,
            vertical: isLargeScreen ? 16 : 14,
          ),
          suffixIcon: trailing,
        ),
      ),
    );
  }
}

class _SocialCircle extends StatefulWidget {
  final IconData icon;
  final bool isLargeScreen;

  const _SocialCircle({
    required this.icon,
    this.isLargeScreen = false,
  });

  @override
  State<_SocialCircle> createState() => _SocialCircleState();
}

class _SocialCircleState extends State<_SocialCircle> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.isLargeScreen ? 56.0 : 52.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) setState(() => _pressed = false);
        // TODO: Implementar login social
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login social próximamente'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF8A5CF6),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: widget.isLargeScreen ? 28 : 26,
          ),
        ),
      ),
    );
  }
}
