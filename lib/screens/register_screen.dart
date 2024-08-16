import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_field_widget.dart';
import '../widgets/text_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileNumberController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileNumberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarWidget(mayPop: true),
        body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(child: _registerContainer()),
          ),
        ),
      ),
    );
  }

  Widget _registerContainer() {
    return SizedBox(
      width: double.infinity,
      child: roundedWhiteContainer(context,
          child: Column(
            children: [
              vertical20Pix(
                  child: Image.asset(
                ImagePaths.logo,
                scale: 4,
              )),
              blackSarabunBold('REGISTER', fontSize: 32),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      text: 'Email Address',
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      displayPrefixIcon: const Icon(Icons.email))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      text: 'Password',
                      controller: passwordController,
                      textInputType: TextInputType.visiblePassword,
                      displayPrefixIcon: const Icon(Icons.lock))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextField(
                      text: 'Confirm Password',
                      controller: confirmPasswordController,
                      textInputType: TextInputType.visiblePassword,
                      displayPrefixIcon: const Icon(Icons.lock))),
              const Gap(30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                    text: 'First Name',
                    controller: firstNameController,
                    textInputType: TextInputType.name,
                    displayPrefixIcon: const Icon(Icons.person)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                    text: 'Last Name',
                    controller: lastNameController,
                    textInputType: TextInputType.name,
                    displayPrefixIcon: const Icon(Icons.person)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextField(
                    text: 'Mobile Number',
                    controller: mobileNumberController,
                    textInputType: TextInputType.number,
                    displayPrefixIcon: const Icon(Icons.phone)),
              ),
              submitButton(context,
                  label: 'REGISTER',
                  onPress: () => registerNewUser(context, ref,
                      emailController: emailController,
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                      firstNameController: firstNameController,
                      lastNameController: lastNameController,
                      mobileNumberController: mobileNumberController)),
              const Divider(color: CustomColors.blackBeauty),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.forgotPassword),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  )),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(NavigatorRoutes.login),
                  child: const Text(
                    'Already have an account?',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ))
            ],
          )),
    );
  }
}
