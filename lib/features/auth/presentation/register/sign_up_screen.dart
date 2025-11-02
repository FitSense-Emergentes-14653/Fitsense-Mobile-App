import 'package:flutter/material.dart';
import 'package:fitsense/core/widgets/drawer/background.dart';

// data layer
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailOrPhoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  final _auth = AuthRepository(AuthRemoteDataSource());

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailOrPhoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      // Para este MVP sólo se registra en tabla users (email + password + role)
      final email = _emailOrPhoneCtrl.text.trim();
      final ok = await _auth.registerUser(
        email: email,
        password: _passCtrl.text,
        role: 'ATHLETE', // por defecto
      );

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro exitoso. Inicia sesión.')),
        );
        Navigator.of(context).pop(); // ← volver al Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo registrar')),
        );
      }
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
    const green = Color(0xFF66FF66);
    const lilac = Color(0xFFC8B8FF);
    const textG = Color(0xFFBDBDBD);

    return AppBackground(
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // header
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
                  'Crea Una Cuenta',
                  style: TextStyle(
                      color: green, fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  '¡Hay Que Empezar!',
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),

              // franja lila con campos
              Container(
                decoration: BoxDecoration(
                    color: lilac, borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    const _Label('Email'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _emailOrPhoneCtrl,
                      hint: 'tucorreo@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return 'Ingresa tu email';
                        if (!t.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const _Label('Contraseña'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _passCtrl,
                      hint: '••••••••••••••',
                      obscure: _obscure1,
                      trailing: IconButton(
                        onPressed: () => setState(()=> _obscure1 = !_obscure1),
                        icon: Icon(_obscure1
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                      validator: (v) =>
                      (v == null || v.length < 6)
                          ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Confirma tu contraseña'),
                    const SizedBox(height: 8),
                    _Input(
                      controller: _confirmCtrl,
                      hint: '••••••••••••••',
                      obscure: _obscure2,
                      trailing: IconButton(
                        onPressed: () => setState(()=> _obscure2 = !_obscure2),
                        icon: Icon(_obscure2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                      ),
                      validator: (v) =>
                      (v != _passCtrl.text) ? 'Las contraseñas no coinciden' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'By continuing, you agree to\nTerms of Use and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textG, fontSize: 11, height: 1.3),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _onRegister,
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
                    height: 22, width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Regístrate',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 14),
              const Center(
                child: Text('o regístrate con',
                    style: TextStyle(color: textG, fontSize: 12)),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _SocialCircle(icon: Icons.g_mobiledata_rounded),
                  SizedBox(width: 16),
                  _SocialCircle(icon: Icons.facebook_rounded),
                  SizedBox(width: 16),
                  _SocialCircle(icon: Icons.fingerprint_rounded),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: textG, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(), // volver al login
                    child: const Text('Log in',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
    );
  }
}

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
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
      width: 44, height: 44,
      decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E), shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    );
  }
}
