import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import 'package:one_velocity_mobile/widgets/custom_miscellaneous_widgets.dart';

import '../providers/cart_provider.dart';
import '../utils/firebase_util.dart';

class UnityScreen extends ConsumerStatefulWidget {
  const UnityScreen({super.key});

  @override
  ConsumerState<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends ConsumerState<UnityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(loadingProvider).toggleLoading(true);
      ref.read(cartProvider).setCartItems(await getCartEntries(context));
    });
  }

  UnityWidgetController? unityWidgetController;
  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(),
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          UnityWidget(
              unloadOnDispose: true,
              onUnityCreated: onUnityCreated,
              onUnityMessage: onUnityMessage)),
    );
  }

  void onUnityMessage(message) async {
    ref.read(loadingProvider).toggleLoading(true);
    List<String> splitMessages = message.split('/');
    if (splitMessages.first == PaymentTypes.product) {
      await addProductToCart(context, ref, productID: splitMessages.last);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Paint job gagawin palang')));
    }
    ref.read(loadingProvider).toggleLoading(false);
  }

  void onUnityCreated(controller) {
    unityWidgetController = controller;
    ref.read(loadingProvider).toggleLoading(false);
  }
}
