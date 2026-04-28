import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _remember = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final ({bool remember, String? email}) prev =
        await AuthService.instance.readRememberedEmail();
    if (!mounted) return;
    setState(() {
      _remember = prev.remember;
      if (prev.email != null) _email.text = prev.email!;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.loginEmail(
      email: _email.text,
      password: _password.text,
      rememberMe: _remember,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      _showError(auth.errorMessage);
    }
  }

  Future<void> _google() async {
    final AuthProvider auth = context.read<AuthProvider>();
    final bool ok = await auth.loginGoogle();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else if (auth.errorMessage != null) {
      _showError(auth.errorMessage);
    }
  }

  void _showError(String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openTelegram() async {
    final Uri uri = Uri.parse(AppConstants.telegramUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient,
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: AppColors.accentGlow, blurRadius: 30),
                      ],
                    ),
                    child: const Icon(
                      Icons.flight_takeoff_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms),
                const SizedBox(height: 22),
                Text(
                  'Welcome back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue your winning streak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  validator: Validators.password,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(_obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Checkbox(
                      value: _remember,
                      activeColor: AppColors.accent,
                      onChanged: (bool? v) =>
                          setState(() => _remember = v ?? false),
                    ),
                    const Text('Remember me',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context)
                          .pushNamed(AppRouter.forgotPassword),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: AppColors.accent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Sign In',
                  icon: Icons.login_rounded,
                  loading: auth.isBusy,
                  onPressed: _submit,
                ),
                const SizedBox(height: 22),
                Row(
                  children: const <Widget>[
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with',
                          style: TextStyle(color: AppColors.textMuted)),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.g_mobiledata_rounded,
                            color: AppColors.accent, size: 26),
                        label: const Text('Google'),
                        onPressed: _google,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.phone_iphone_rounded,
                            color: AppColors.accent),
                        label: const Text('Phone'),
                        onPressed: () => Navigator.of(context)
                            .pushNamed(AppRouter.phoneLogin),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                  label: const Text('Join our Telegram'),
                  onPressed: _openTelegram,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRouter.register),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
