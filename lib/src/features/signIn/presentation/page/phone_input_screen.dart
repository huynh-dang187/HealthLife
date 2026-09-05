import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:healthlife/src/common/constants/colors.dart';
import 'package:healthlife/src/common/extensions/context_x.dart';
import 'package:healthlife/src/common/extensions/num_x.dart';
import 'package:healthlife/src/core/presentation/widgets/button.dart';
import 'package:healthlife/src/core/presentation/widgets/text.dart';
import 'package:healthlife/src/features/signIn/data/models/country_codes_model.dart';
import 'package:healthlife/src/features/signIn/data/models/otp_args_model.dart';
import 'package:healthlife/src/features/signIn/data/repositories/auth_repository.dart';
import 'package:healthlife/src/features/signIn/presentation/cubit/phone/phone_input_cubit.dart';
import 'package:healthlife/src/shared/router/route_names.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _goAfterAuth(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final completed = doc.data()?['profileCompleted'] ?? false;
    if (!context.mounted) return;
    context.go(completed ? RouteNames.home : RouteNames.profile_name);
  }

  Future<void> _pickCountry() async {
    final selected = await showModalBottomSheet<CountryCode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.builder(
          itemCount: kCountryCodes.length,
          itemBuilder: (context, index) {
            final c = kCountryCodes[index];
            return ListTile(
              leading: Text(c.flagEmoji, style: const TextStyle(fontSize: 24)),
              title: Text(c.name),
              trailing: AppText.medium(c.dialCode, fontSize: 14),
              onTap: () => Navigator.of(context).pop(c),
            );
          },
        ),
      ),
    );
    if (selected != null) {
      // ignore: use_build_context_synchronously
      context.read<PhoneInputCubit>().selectCountry(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PhoneInputCubit(AuthRepository()),
      child: BlocConsumer<PhoneInputCubit, PhoneInputState>(
        listener: (context, state) {
          switch (state) {
            case PhoneOtpSent(
              :final verificationId,
              :final fullPhone,
              :final resendToken,
            ):
              context.push(
                RouteNames.phone_otp,
                extra: OtpArgs(
                  verificationId: verificationId,
                  fullPhone: fullPhone,
                  resendToken: resendToken,
                ),
              );
            case PhoneAutoSignedIn():
              _goAfterAuth(context);
            case PhoneInputFailure(:final message):
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            default:
              break;
          }
        },
        builder: (context, state) {
          final country = state is PhoneInputInitial
              ? state.country
              : kVietnamCountry;
          final isSubmitting = state is PhoneInputSubmitting;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: AppText.bold('Nhập số điện thoại', fontSize: 18),
            ),
            body: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: context.paddingBottomForButton,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  32.gap,
                  AppText.bold('Số điện thoại của bạn', fontSize: 22),
                  8.gap,
                  AppText.regular(
                    'Chúng tôi sẽ gửi mã xác nhận qua SMS',
                    fontSize: 13,
                    color: UIColors.textBody,
                  ),
                  24.gap,
                  // Ô chọn quốc gia
                  InkWell(
                    onTap: _pickCountry,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: UIColors.lightGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            country.flagEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                          12.gap,
                          Expanded(
                            child: AppText.medium(country.name, fontSize: 14),
                          ),
                          AppText.medium(country.dialCode, fontSize: 14),
                          8.gap,
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: UIColors.textBody,
                          ),
                        ],
                      ),
                    ),
                  ),
                  12.gap,
                  TextField(
                    controller: _phoneController,
                    enabled: !isSubmitting,
                    autofocus: true,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: InputDecoration(
                      prefixText: '${country.dialCode} ',
                      hintText: 'Số điện thoại',
                      filled: true,
                      fillColor: UIColors.lightGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: UIColors.pink),
                      ),
                    ),
                  ),
                  32.gap,
                  AppButton.fill(
                    enable: !isSubmitting,
                    onTap: () => context.read<PhoneInputCubit>().sendOtp(
                      _phoneController.text,
                    ),
                    title: 'Gửi mã xác nhận',
                    height: 50,
                    width: double.infinity,
                    titleWidget: isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
