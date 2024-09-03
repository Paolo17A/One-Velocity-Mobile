import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_velocity_mobile/providers/loading_provider.dart';
import 'package:one_velocity_mobile/utils/string_util.dart';
import 'package:one_velocity_mobile/widgets/app_bar_widget.dart';
import '../widgets/chat_messages.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/new_message_widget.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
//==============================================================================

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: topAppBar(),
          body: Scaffold(
            appBar: appBarWidget(mayPop: true),
            body: stackedLoadingContainer(
                context,
                ref.read(loadingProvider).isLoading,
                Column(children: [
                  Expanded(
                      child: ChatMessages(
                          otherUID: adminID,
                          senderUID: FirebaseAuth.instance.currentUser!.uid)),
                  NewMessage(
                    otherName: 'ADMIN',
                    otherUID: adminID,
                    senderUID: FirebaseAuth.instance.currentUser!.uid,
                    isClient: true,
                  )
                ])),
          )),
    );
  }
}
