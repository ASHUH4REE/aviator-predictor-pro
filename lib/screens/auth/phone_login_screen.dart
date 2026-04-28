import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../core/constants.dart';
import '../../core/router.dart';
import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phone = TextEditingController(text: '+1');
  final TextEditingController _otp = TextEditingController();
  String? _verificationId;
  bool _busy = false;

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _busy = true);
    try {
      await AuthService.instance.sendPhoneCode(
        phoneE164: _phone.text.trim(),
        onCodeSent: (String id) {
          if (!mounted) return;
          setState(() {
            _verificationId = id;
            _busy = false;
          });
        },
        onError: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? 'Failed to send code.')),
          );
        },
      );
    } catch (e) {
      setState(() => _busy = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _verify() async {
    if (_verificationId == null) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.confirmPhoneCode(
        verificationId: _verificationId!,
        smsCode: _otp.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message ?? 'Invalid code.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool codeStage = _verificationId != null;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text('Phone sign in'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!codeStage) ...<Widget>[
                const Text(
                  'Use your phone number to sign in. We\'ll text a 6-digit code.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone (E.164 format)',
                    hintText: '+15551234567',
                    prefixIcon: Icon(Icons.phone_iphone_rounded),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Send code',
                  icon: Icons.sms_rounded,
                  loading: _busy,
                  onPressed: _sendCode,
                ),
              ] else ...<Widget>[
                const Text(
                  'Enter the 6-digit code we just sent.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 22),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  textStyle: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14),
                    fieldHeight: 54,
                    fieldWidth: 44,
                    activeColor: AppColors.accent,
                    selectedColor: AppColors.accent,
                    inactiveColor: AppColors.border,
                    activeFillColor: AppColors.cardHigh,
                    selectedFillColor: AppColors.cardHigh,
                    inactiveFillColor: AppColors.cardHigh,
                  ),
                  enableActiveFill: true,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Verify',
                  icon: Icons.verified_rounded,
                  loading: _busy,
                  onPressed: _verify,
                ),
                TextButton(
                  onPressed: () => setState(() => _verificationId = null),
                  child: const Text(
                    'Use a different number',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
