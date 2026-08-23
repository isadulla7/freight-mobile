import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  String _formatPhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.startsWith('998') && digits.length == 12) return '+$digits';
    if (digits.length == 9) return '+998$digits';
    return '+998$digits';
  }

  void _requestOtp() {
    final phone = _formatPhone(_phoneController.text);
    if (phone.length < 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telefon raqamni to\'liq kiriting')),
      );
      return;
    }
    context.read<AuthBloc>().add(OtpRequested(phone));
  }

  void _verifyOtp(String phoneNumber) {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('6 xonali kodni kiriting')),
      );
      return;
    }
    context.read<AuthBloc>().add(OtpVerified(
          phoneNumber: phoneNumber,
          otp: otp,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isOtpSent = state is AuthOtpSent;
        final isLoading = state is AuthLoading;
        final phoneNumber = switch (state) {
          AuthOtpSent s => s.phoneNumber,
          AuthError s => s.phoneNumber,
          _ => null,
        };

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const Text(
                    'Freight',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Yuk tashish xizmatiga xush kelibsiz',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    enabled: !isOtpSent && !isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Telefon raqam',
                      hintText: '+998 90 123 45 67',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  if (isOtpSent || phoneNumber != null) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      enabled: !isLoading,
                      autofocus: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'SMS kod',
                        hintText: '000000',
                        prefixIcon: Icon(Icons.lock_outline),
                        counterText: '',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!isOtpSent && phoneNumber == null) {
                              _requestOtp();
                            } else {
                              _verifyOtp(
                                phoneNumber ?? _formatPhone(_phoneController.text),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isOtpSent || phoneNumber != null
                            ? 'Kirish'
                            : 'Kod yuborish'),
                  ),
                  if (isOtpSent) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _otpController.clear();
                          _requestOtp();
                        },
                        child: const Text('Kodni qayta yuborish'),
                      ),
                    ),
                  ],
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
