import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../widgets/glow_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editingName = false;
  final TextEditingController _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(AppUser user) async {
    final ImagePicker picker = ImagePicker();
    final XFile? f =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (f == null || !mounted) return;
    LoadingOverlay.show(context);
    try {
      final String url = await StorageService.instance
          .uploadAvatar(uid: user.uid, file: File(f.path));
      await context.read<UserProvider>().updateAvatar(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      if (mounted) LoadingOverlay.dismiss(context);
    }
  }

  Future<void> _saveName(AppUser user) async {
    final String value = _name.text.trim();
    if (value.isEmpty) return;
    await context.read<UserProvider>().updateName(value);
    setState(() => _editingName = false);
  }

  Future<void> _changePassword(AppUser user) async {
    final String? newPass = await showDialog<String>(
      context: context,
      builder: (_) => _ChangePasswordDialog(),
    );
    if (newPass == null) return;
    try {
      await FirebaseAuth.instance.currentUser?.updatePassword(newPass);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated.')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed: ${e.message}. Sign in again and retry if required.')),
      );
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRouter.login,
      (Route<dynamic> _) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = context.watch<UserProvider>().profile;
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_editingName) _name.text = user.name;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient,
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                            color: AppColors.accentGlow, blurRadius: 24),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundColor: AppColors.cardHigh,
                      backgroundImage: user.avatar != null
                          ? NetworkImage(user.avatar!)
                          : null,
                      child: user.avatar == null
                          ? Text(
                              user.name.characters.first.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () => _pickAvatar(user),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.background, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  user.membership.label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Account'),
            GlowCard(
              child: Column(
                children: <Widget>[
                  _editingName
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: _name,
                                validator: Validators.required,
                                decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check_rounded,
                                  color: AppColors.success),
                              onPressed: () => _saveName(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: AppColors.textMuted),
                              onPressed: () =>
                                  setState(() => _editingName = false),
                            ),
                          ],
                        )
                      : ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.badge_rounded,
                              color: AppColors.accent),
                          title: const Text('Full name',
                              style:
                                  TextStyle(color: AppColors.textMuted)),
                          subtitle: Text(
                            user.name,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          trailing: TextButton(
                            onPressed: () =>
                                setState(() => _editingName = true),
                            child: const Text('Edit',
                                style: TextStyle(color: AppColors.accent)),
                          ),
                        ),
                  const Divider(color: AppColors.border, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.alternate_email_rounded,
                        color: AppColors.accent),
                    title: const Text('Email',
                        style: TextStyle(color: AppColors.textMuted)),
                    subtitle: Text(user.email,
                        style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone_rounded,
                        color: AppColors.accent),
                    title: const Text('Phone',
                        style: TextStyle(color: AppColors.textMuted)),
                    subtitle: Text(user.phone.isEmpty ? '—' : user.phone,
                        style: const TextStyle(color: AppColors.textPrimary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              gradient: false,
              label: 'Change password',
              icon: Icons.lock_reset_rounded,
              onPressed: () => _changePassword(user),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Logout',
              icon: Icons.logout_rounded,
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final TextEditingController _pw = TextEditingController();
  final TextEditingController _pw2 = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Change password',
          style: TextStyle(color: AppColors.textPrimary)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _pw,
              obscureText: true,
              validator: Validators.password,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _pw2,
              obscureText: true,
              validator: (String? v) => Validators.confirmPassword(v, _pw.text),
              decoration: const InputDecoration(labelText: 'Confirm password'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel',
              style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop(_pw.text);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
