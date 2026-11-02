import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/theme.dart';
import '../../providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Web client (client_type 3) do google-services.json — usado como serverClientId.
  static const _googleServerClientId =
      '256081882572-7aivc39fnl48r3kt3jtr4jleto72jtpl.apps.googleusercontent.com';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _afterAuth() async {
    final hasName = ref.read(nameProvider).isNotEmpty;
    if (!mounted) return;
    context.go(hasName ? '/' : '/onboarding');
  }

  // -------------------------------------------------------------------------
  // E-mail e senha
  // -------------------------------------------------------------------------
  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _snack('Informe e-mail e senha.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      await _afterAuth();
    } on FirebaseAuthException catch (e) {
      _snack(_authError(e));
    } catch (e) {
      _genericError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Google
  // -------------------------------------------------------------------------
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn(
        serverClientId: _googleServerClientId,
      ).signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      await _afterAuth();
    } catch (e) {
      _genericError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Apple
  // -------------------------------------------------------------------------
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');
      await FirebaseAuth.instance.signInWithProvider(appleProvider);
      await _afterAuth();
    } catch (e) {
      _genericError(e);
    }
  }

  // -------------------------------------------------------------------------
  // Helpers de erro / feedback
  // -------------------------------------------------------------------------
  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado. Toque em "Entrar".';
      case 'weak-password':
        return 'A senha precisa ter no mínimo 6 caracteres.';
      case 'invalid-email':
        return 'E-mail em formato inválido.';
      default:
        return 'Erro na autenticação: ${e.message}';
    }
  }

  void _genericError(Object e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    final s = e.toString();
    String msg = 'Não foi possível entrar no momento.';
    if (s.contains('MissingPlugin') ||
        s.contains('no app') ||
        s.contains('No Firebase App') ||
        s.contains('firebase')) {
      msg = 'Firebase indisponível nesta plataforma. Teste no celular (APK).';
    }
    _snack(msg);
  }

  void _snack(String msg) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Logo
                Center(
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: const Icon(
                      Icons.anchor_rounded,
                      color: AppColors.gold,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Âncora',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  'Devocional',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),

                // Card com campos
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'E-mail',
                          hintText: 'exemplo@email.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _signInWithEmail(),
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: 'Mínimo 6 caracteres',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        ElevatedButton(
                          onPressed: _signInWithEmail,
                          child: Text(
                            _isRegistering ? 'Criar conta' : 'Entrar',
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () => setState(
                            () => _isRegistering = !_isRegistering,
                          ),
                          child: Text(
                            _isRegistering
                                ? 'Já tem conta? Entrar'
                                : 'Não tem conta? Cadastre-se',
                            style: const TextStyle(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Divisor
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'ou continue com',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Bolinhas redondas Google + Apple
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialCircleButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      iconColor: const Color(0xFF4285F4),
                      onTap: _isLoading ? null : _signInWithGoogle,
                    ),
                    const SizedBox(width: 40),
                    _SocialCircleButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      iconColor: Colors.black,
                      onTap: _isLoading ? null : _signInWithApple,
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Acesso de teste (sem Firebase) para rodar no Linux/desktop
                TextButton(
                  onPressed: () =>
                      context.go(ref.read(nameProvider).isEmpty ? '/onboarding' : '/'),
                  child: const Text(
                    'Entrar sem conta (teste)',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  const _SocialCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 62,
              height: 62,
              child: Icon(icon, size: 34, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
