// ==============================================================================
// DOSYA ADI: lib/features/auth/presentation/login_screen.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Kullanıcı Giriş (Ekran 1) arayüzüdür.
// - E-posta ve şifre doğrulama, şifre gizleme/gösterme ve giriş eylemlerini yönetir.
// - Başarılı girişte Profil Seçim Ekranına (ProfileSelectionScreen) yönlendirir.
// - Kayıt Ol (RegisterScreen) ve Şifremi Unuttum (ForgotPasswordScreen) ekranlarına geçiş sağlar.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../profile/presentation/profile_selection_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// Kullanıcı giriş ekranı widget'ı.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = 'ahmet@ilactakip.com';
  String _password = 'password123';
  bool _obscurePassword = true;

  void _onLogin() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Navigate to Profile Selection Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ProfileSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.appTitle,
        showProfileAvatar: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon / Logo
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header Texts
                  Text(
                    l10n.loginTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.loginSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    initialValue: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return l10n.errorRequiredField;
                      }
                      return null;
                    },
                    onSaved: (val) => _email = val ?? '',
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    initialValue: _password,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return l10n.isTr ? 'En az 6 karakter olmalıdır' : 'Must be at least 6 characters';
                      }
                      return null;
                    },
                    onSaved: (val) => _password = val ?? '',
                  ),
                  const SizedBox(height: 10),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(l10n.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  ElevatedButton(
                    onPressed: _onLogin,
                    child: Text(l10n.loginButton),
                  ),
                  const SizedBox(height: 24),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: Text(
                          l10n.registerButton,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
