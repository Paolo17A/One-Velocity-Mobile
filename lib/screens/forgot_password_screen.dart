import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/widgets/custom_text_field_widget.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../providers/loading_provider.dart';
import '../utils/firebase_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarWidget(),
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: all20Pix(
                    child: Column(
                  children: [
                    blackSarabunBold('RESET PASSWORD', fontSize: 26),
                    Gap(20),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30)),
                      child: all20Pix(
                          child: Column(
                        children: [
                          CustomTextField(
                              text: 'Email',
                              controller: emailController,
                              textInputType: TextInputType.emailAddress,
                              displayPrefixIcon: Icon(Icons.email)),
                          vertical20Pix(
                            child: ElevatedButton(
                                onPressed: () => sendResetPasswordEmail(
                                    context, ref,
                                    emailController: emailController),
                                child: whiteSarabunRegular(
                                    'SEND PASSWORD RESET EMAIL',
                                    fontSize: 16)),
                          )
                        ],
                      )),
                    )
                  ],
                )),
              ),
            )),
      ),
    );
  }
}
