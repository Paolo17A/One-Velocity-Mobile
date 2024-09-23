import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import '../providers/loading_provider.dart';
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
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover, image: AssetImage(ImagePaths.home_bg))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: stackedLoadingContainer(
                context,
                ref.read(loadingProvider).isLoading,
                Container(
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: all20Pix(
                        child: Column(
                          children: [
                            vertical10Pix(
                                child: Image.asset(ImagePaths.logo, scale: 5)),
                            vertical20Pix(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    child: blackSarabunBold(
                                        'Where Quality Meets Velocity',
                                        textAlign: TextAlign.left),
                                  ),
                                ],
                              ),
                            ),
                            _logInContainer(),
                          ],
                        ),
                      ),
                    ))),
          ),
        ),
      ),
    );
  }

  Widget _logInContainer() {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: roundedNimbusContainer(context,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              blackSarabunBold('LOG-IN', fontSize: 32),
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
              GestureDetector(
                  onTap: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.forgotPassword),
                  child: blackSarabunRegular('Forgot Password?',
                      fontSize: 16, decoration: TextDecoration.underline)),
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(NavigatorRoutes.register),
                  child: blackSarabunRegular('Don\'t have an account?',
                      fontSize: 16, decoration: TextDecoration.underline))
            ])));
  }
}
