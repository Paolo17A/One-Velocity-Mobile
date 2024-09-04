import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';
import 'package:one_velocity_mobile/widgets/custom_padding_widgets.dart';
import 'package:one_velocity_mobile/widgets/text_widgets.dart';

import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_text_field_widget.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: topAppBar(),
      body: Scaffold(
        appBar: appBarWidget(actions: [
          popUpMenu(context, currentPath: NavigatorRoutes.changePassword)
        ]),
        drawer: appDrawer(context, ref, route: NavigatorRoutes.changePassword),
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: all20Pix(
                    child: Column(
                  children: [
                    blackSarabunBold('CHANGE PASSWORD', fontSize: 40),
                    _passwordTextFields(),
                    vertical20Pix(
                        child: ElevatedButton(
                            onPressed: () => updatePassword(context, ref,
                                currentPasswordController:
                                    currentPasswordController,
                                newPasswordController: newPasswordController,
                                confirmNewPasswordController:
                                    confirmNewPasswordController),
                            child: whiteSarabunBold('UPDATE PASSWORD')))
                  ],
                )),
              ),
            )),
      ),
    );
  }

  Widget _passwordTextFields() {
    return vertical20Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: roundedNimbusContainer(context,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CustomTextField(
                  text: 'Current Password',
                  controller: currentPasswordController,
                  textInputType: TextInputType.visiblePassword,
                  displayPrefixIcon: Icon(Icons.lock)),
              vertical10Pix(
                  child: CustomTextField(
                      text: 'New Password',
                      controller: newPasswordController,
                      textInputType: TextInputType.visiblePassword,
                      displayPrefixIcon: Icon(Icons.lock))),
              CustomTextField(
                  text: 'Confirm New Password',
                  controller: confirmNewPasswordController,
                  textInputType: TextInputType.visiblePassword,
                  displayPrefixIcon: Icon(Icons.lock)),
            ])),
      ),
    );
  }
}
