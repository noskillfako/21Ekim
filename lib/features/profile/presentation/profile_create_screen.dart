// ==============================================================================
// DOSYA ADI: lib/features/profile/presentation/profile_create_screen.dart
// İŞLEVİ VE ETKİLEDİĞİ SAYFALAR:
// - Yeni aile/birey profili oluşturma form ekranını sunar.
// - Doğum tarihi ve cinsiyet seçimine göre otomatik avatar hesaplamasını canlı önizler.
// - Yeni profili [ProfilesNotifier] üzerinden sisteme ekler ve aktif profil olarak seçer.
// - Profil Seçim Ekranı (ProfileSelectionScreen) veya Ayarlar sekmesinden çağrılır.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/profile_avatar.dart';

/// [ProfileCreateScreen] yeni profil oluşturma ve yaş/cinsiyete göre dinamik avatar belirleme ekranı.
class ProfileCreateScreen extends ConsumerStatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  ConsumerState<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends ConsumerState<ProfileCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  DateTime _birthDate = DateTime(1995, 6, 15);
  String _gender = 'female'; // 'female' | 'male'
  String _relation = 'self'; // 'self' | 'mother' | 'father' | 'child'

  /// Doğum tarihi ve cinsiyete göre hesaplanan avatar anahtarı.
  String get _currentAvatarKey => ProfileModel.computeAvatarKey(_birthDate, _gender);

  /// Doğum tarihinden kullanıcının yaşını hesaplar.
  int get _calculatedAge {
    final now = DateTime.now();
    int age = now.year - _birthDate.year;
    if (now.month < _birthDate.month ||
        (now.month == _birthDate.month && now.day < _birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// Profil oluşturma formunu onaylar, kaydeder ve yeni profili aktif profil yapar.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await ref.read(profilesProvider.notifier).addProfile(
          name: _name.trim(),
          birthDate: _birthDate,
          gender: _gender,
          relation: _relation,
        );

    final profiles = ref.read(profilesProvider);
    if (profiles.isNotEmpty) {
      await ref.read(activeProfileIdProvider.notifier).selectProfile(profiles.last.id);
    }

    if (mounted) {
      final l10n = AppL10n.of(context);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profileCreatedSuccess(_name)),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppL10n.of(context);

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.createProfileTitle,
        showBackButton: true,
        showProfileAvatar: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Live Avatar Preview Header
              Center(
                child: Column(
                  children: [
                    ProfileAvatar(
                      avatarKey: _currentAvatarKey,
                      radius: 44,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${l10n.automaticAvatarLabel}: ${_getAvatarRoleLabel(_currentAvatarKey, l10n)} ($_calculatedAge ${l10n.ageYears})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.profileNameLabel,
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? l10n.errorRequiredField : null,
                onSaved: (val) => _name = val ?? '',
              ),
              const SizedBox(height: 16),

              // Birth Date Field
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.12)),
                ),
                leading: const Icon(Icons.cake_rounded),
                title: Text(l10n.birthDateLabel),
                subtitle: Text(
                  DateFormat('dd MMMM yyyy', l10n.isTr ? 'tr_TR' : 'en_US').format(_birthDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _birthDate,
                      firstDate: DateTime(1920),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _birthDate = picked);
                    }
                  },
                  child: Text(l10n.change),
                ),
              ),
              const SizedBox(height: 16),

              // Gender Selector
              Text(
                l10n.genderLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.female_rounded, size: 18),
                      label: Text(l10n.genderFemale),
                      selected: _gender == 'female',
                      onSelected: (selected) {
                        if (selected) setState(() => _gender = 'female');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      avatar: const Icon(Icons.male_rounded, size: 18),
                      label: Text(l10n.genderMale),
                      selected: _gender == 'male',
                      onSelected: (selected) {
                        if (selected) setState(() => _gender = 'male');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Relation Selector
              Text(
                l10n.relationLabel,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.relationSelf),
                    selected: _relation == 'self',
                    onSelected: (s) => s ? setState(() => _relation = 'self') : null,
                  ),
                  ChoiceChip(
                    label: Text(l10n.relationMother),
                    selected: _relation == 'mother',
                    onSelected: (s) => s ? setState(() => _relation = 'mother') : null,
                  ),
                  ChoiceChip(
                    label: Text(l10n.relationFather),
                    selected: _relation == 'father',
                    onSelected: (s) => s ? setState(() => _relation = 'father') : null,
                  ),
                  ChoiceChip(
                    label: Text(l10n.relationChild),
                    selected: _relation == 'child',
                    onSelected: (s) => s ? setState(() => _relation = 'child') : null,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: Text(l10n.saveProfileButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAvatarRoleLabel(String key, AppL10n l10n) {
    switch (key.toLowerCase()) {
      case 'child_female':
        return l10n.avatarChildFemale;
      case 'child_male':
        return l10n.avatarChildMale;
      case 'adult_female':
        return l10n.avatarAdultFemale;
      case 'adult_male':
        return l10n.avatarAdultMale;
      case 'elder_female':
        return l10n.avatarElderFemale;
      case 'elder_male':
        return l10n.avatarElderMale;
      default:
        return 'Profil';
    }
  }
}
