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
  final _passCtrl  = TextEditingController(); // <- FALTABA
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

  Future<void> _goByRole(String role) async {
    if (!mounted) return;
    final upper = role.toUpperCase();

    if (upper == 'ATHLETE') {
      // Gate: si no existe Athlete -> Setup Flow
      final repo = AthleteRepository(AthleteRemoteDataSource());
      final userId = _session.getUserId();
      debugPrint('⚙️ USER ID desde SessionService: $userId');
      if (userId <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: userId no válido en sesión.')),
        );
        return;
      }
      final list = await repo.getAll(); // fallback robusto
      final exists = list.any((a) => a.userId == userId);

      if (!mounted) return;
      if (!exists) {
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
    }

    // Home por defecto
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const AthleteHomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

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

      // --- Token ---
      final token = (data['token'] ?? '').toString();
      if (token.isEmpty) throw Exception('Token no recibido');
      await _session.setToken(token);

      // --- UserId: raíz o dentro de "user" ---
      int userId = -1;
      if (data['id'] != null) {
        userId = int.tryParse('${data['id']}') ?? -1;            // <- raíz
      } else if (data['user'] is Map && data['user']['id'] != null) {
        userId = int.tryParse('${data['user']['id']}') ?? -1;    // <- anidado
      }
      if (userId <= 0) {
        throw Exception('userId no recibido del backend');
      }
      await _session.setUserId(userId);

      // --- Role (opcional) ---
      String role = 'ATHLETE';
      if (data['roles'] is List && (data['roles'] as List).isNotEmpty) {
        role = '${data['roles'][0]}';
      } else if (data['user'] is Map &&
          data['user']['roles'] is List &&
          (data['user']['roles'] as List).isNotEmpty) {
        role = '${data['user']['roles'][0]}';
      }
      await _session.setRole(role);

      await _goByRole(role);
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
    const green  = Color(0xFF66FF66);   // título "Inicia Sesión"
    const lilac  = Color(0xFFC8B8FF);   // franja lila
    const textG  = Color(0xFFBDBDBD);   // gris descrip.
    const purple = Color(0xFF8A5CF6);   // link "Regístrate"

    return AppBackground(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Inicia Sesión',
                  style: TextStyle(
                    color: green,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
                      'sed do eiusmod tempor incididunt. A laborare dolore magna aliqua.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textG, fontSize: 12, height: 1.35),
                ),
              ),
              const SizedBox(height: 24),

              // Franja lila con campos
              Container(
                decoration: BoxDecoration(
                  color: lilac,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Usuario o email',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _emailCtrl,
                      hint: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Ingresa tu email';
                        if (!t.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _passCtrl,
                      hint: '••••••••',
                      obscure: _obscure,
                      trailing: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                      validator: (v) =>
                      (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          final email = _emailCtrl.text.trim();
                          if (email.isEmpty || !email.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ingresa un email válido antes de continuar.')),
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SetPasswordScreen(email: email)),
                          );
                        },
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Botón principal
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text(
                    'Inicia Sesión',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Center(
                child: Text(
                  'o regístrate con',
                  style: TextStyle(color: textG, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialCircle(icon: Icons.g_mobiledata_rounded),
                  SizedBox(width: 16),
                  _SocialCircle(icon: Icons.facebook_rounded),
                  SizedBox(width: 16),
                  _SocialCircle(icon: Icons.apple_rounded),
                ],
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Aún no tienes una cuenta? ',
                    style: TextStyle(color: textG, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: purple,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

  const _Input({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          suffixIcon: trailing,
        ),
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final IconData icon;
  const _SocialCircle({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}
