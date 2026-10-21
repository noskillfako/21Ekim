// ==============================================================================
// DOSYA ADI: lib/features/auth/presentation/forgot_password_screen.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Şifremi Unuttum (Ekran 2) arayüzünü sağlar.
// - Kullanıcıdan e-posta adresi alarak şifre sıfırlama bağlantısı gönderim simülasyonunu yönetir.
// - Giriş Ekranından (LoginScreen) açılır ve başarılı gönderim sonrasında geri dönüş imkanı verir.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/app_top_bar.dart';

/// Şifre sıfırlama e-postası gönderme ekranı widget'ı.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _sent = false;

  void _onSend() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.resetPasswordTitle,
        showBackButton: true,
        showProfileAvatar: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _sent
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: Color(0xFF2E7D32),
                          size: 56,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.resetEmailSent,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_email adresine şifre sıfırlama yönergeleri iletildi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.backToLogin),
                      ),
                    ],
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.resetPasswordTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.resetPasswordDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 24),
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
                        onSaved: (val) => _email = val ?? '',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _onSend,
                        child: Text(l10n.sendResetLink),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.backToLogin),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
