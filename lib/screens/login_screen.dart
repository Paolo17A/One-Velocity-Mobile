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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
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
            child: all20Pix(child: _logInContainer()),
          ),
        ),
      ),
    );
  }

  Widget _logInContainer() {
    return SizedBox(
        width: double.infinity,
        child: roundedWhiteContainer(context,
            child: Column(children: [
              vertical20Pix(
                  child: Image.asset(
                ImagePaths.logo,
                scale: 4,
              )),
              montserratBlackBold('LOG-IN', fontSize: 32),
              const Gap(24),
              CustomTextField(
                  text: 'Email Address',
                  controller: emailController,
                  textInputType: TextInputType.emailAddress,
                  displayPrefixIcon: const Icon(Icons.email)),
              const Gap(16),
              CustomTextField(
                text: 'Password',
                controller: passwordController,
                textInputType: TextInputType.visiblePassword,
                displayPrefixIcon: const Icon(Icons.lock),
                onSearchPress: () => logInUser(context, ref,
                    emailController: emailController,
                    passwordController: passwordController),
              ),
              submitButton(context,
                  label: 'LOG-IN',
                  onPress: () => logInUser(context, ref,
                      emailController: emailController,
                      passwordController: passwordController)),
              const Divider(color: CustomColors.blackBeauty),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.forgotPassword),
                  child: montserratBlackBold('Forgot Password?',
                      fontSize: 16, textDecoration: TextDecoration.underline)),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(NavigatorRoutes.register),
                  child: montserratBlackBold('Don\'t have an account?',
                      fontSize: 16, textDecoration: TextDecoration.underline))
            ])));
  }
}
