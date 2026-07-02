import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_database.dart';
import '../../domain/entities/app_user.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 300));
    final user = LocalDatabase.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (user == null) {
      setState(() => _error = 'Incorrect email or password.');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DashboardPage(currentUser: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Logo(),
              const SizedBox(height: 40),
              _LoginCard(
                formKey: _formKey, emailCtrl: _emailCtrl, passCtrl: _passCtrl,
                obscure: _obscure, loading: _loading, error: _error,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
                onSubmit: _submit,
              ),
              const SizedBox(height: 16),
              _CredentialsHint(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.softShadow,
        ),
        // Replace with Image.asset('assets/images/logo.png') once logo is added
        child: const Center(
          child: Text('KSL', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(height: 16),
      const Text(AppConstants.appName,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        textAlign: TextAlign.center),
      const SizedBox(height: 4),
      const Text('Business Management System',
        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
    ],
  );
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure, loading;
  final String? error;
  final VoidCallback onToggleObscure, onSubmit;

  const _LoginCard({
    required this.formKey, required this.emailCtrl, required this.passCtrl,
    required this.obscure, required this.loading, required this.error,
    required this.onToggleObscure, required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 420,
    padding: const EdgeInsets.all(32),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: AppTheme.softShadow,
    ),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sign in', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Enter your credentials to continue',
            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 28),
          const Text('Email address', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'you@kineticsolutions.zm',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: 18),
          const Text('Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            controller: passCtrl,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                onPressed: onToggleObscure,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          if (error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorLight, borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.errorColor.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 16),
                const SizedBox(width: 8),
                Text(error!, style: const TextStyle(color: AppTheme.errorColor, fontSize: 13)),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              child: loading
                ? const SizedBox(height: 18, width: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Sign in'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CredentialsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 420,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.primary50, borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
    ),
    child: const Row(children: [
      Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 16),
      SizedBox(width: 8),
      Expanded(child: Text(
        'Default admin  ·  admin@kineticsolutions.zm  ·  Admin@123',
        style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
      )),
    ]),
  );
}
