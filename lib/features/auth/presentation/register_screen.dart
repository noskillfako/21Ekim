// ==============================================================================
// DOSYA ADI: lib/features/auth/presentation/register_screen.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Yeni kullanıcı kayıt (Sign Up) ekranını oluşturur.
// - E-posta, parola, parola doğrulama ve KVKK onayı kontrollerini içerir.
// - Başarılı kayıt sonrasında kullanıcıyı doğrudan ProfileSelectionScreen'e yönlendirir.
// - Giriş Ekranı (LoginScreen) ile çift yönlü geçiş ilişkisi vardır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../profile/presentation/profile_selection_screen.dart';

/// [RegisterScreen] yeni kullanıcı kaydı alma ekranı bileşeni.
/// Form doğrulama ve KVKK kabulü zorunluluklarını denetler.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _password = '';
  bool _obscurePassword = true;
  bool _kvkkConsent = false;

  /// Kayıt işlemini tetikler:
  /// Form geçerliliğini ve KVKK onayını denetler, geçerli ise profil seçim ekranına aktarır.
  void _onRegister() {
    final l10n = AppL10n.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_kvkkConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isTr
                ? 'Lütfen KVKK ve Gizlilik Onayını kabul ediniz.'
                : 'Please accept the privacy policy and consent.',
          ),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
      return;
    }
    _formKey.currentState!.save();

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
        title: l10n.registerTitle,
        showBackButton: true,
        showProfileAvatar: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.registerTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.registerSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Email
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.emailLabel,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (val) {
                      if (val == null || !val.contains('@')) {
                        return l10n.isTr ? 'Geçerli bir e-posta giriniz' : 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
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
                      _password = val;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_reset_rounded),
                    ),
                    validator: (val) {
                      if (val != _password) {
                        return l10n.isTr ? 'Şifreler eşleşmiyor' : 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // KVKK Checkbox
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _kvkkConsent,
                    onChanged: (val) {
                      setState(() {
                        _kvkkConsent = val ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      l10n.kvkkConsent,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: _onRegister,
                    child: Text(l10n.registerButton),
                  ),
                  const SizedBox(height: 20),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.loginButton,
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
