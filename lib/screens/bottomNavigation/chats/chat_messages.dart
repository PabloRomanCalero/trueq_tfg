import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/main.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/supabase_constants.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:trueq/utils/helper_functions.dart';

import '../profile/my_products/other_profile.dart';


class ChatMessages extends StatefulWidget {
  final String chatId;
  final String otherUserId;


  const ChatMessages({super.key, required this.chatId, required this.otherUserId});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final userId = Supabase.instance.client.auth.currentUser?.id;
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final response = await supabase
        .from('users')
        .select('avatar_url, username')
        .eq('id', widget.otherUserId)
        .maybeSingle();

    if (response != null) {
      setState(() {
        user = response;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || userId == null) return;

    FocusScope.of(context).unfocus();

    await supabase.from('messages').insert({
      'chat_id': widget.chatId,
      'sender_id': userId,
      'message': _controller.text.trim()
    });

    final response = await supabase
      .from('users')
      .select('player_id')
      .eq('id', widget.otherUserId)
      .single();

    sendPushNotification([response['player_id']], _controller.text.trim());

    Future.delayed(Duration(milliseconds: 100), (){
      if(_scrollController.hasClients){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
    _controller.clear();
  }

  Future<void> sendPushNotification(List<String> playerIds, String message) async {
    final String appId = OneSignalKeys.appId;
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': OneSignalKeys.restApiKey,
    };

    final body = jsonEncode({
      'app_id': appId,
      'include_player_ids': playerIds,
      'headings': {'en': 'Nuevo Mensaje'},
      'contents': {'en': message},
    });

    await http.post(url, headers: headers, body: body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: user == null
        ? AppBar(
          title: Text(TextsTrueq.to.getText('loadingPage'), style: TextStyle(fontSize: 14.sp)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        )
        : AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => OtherProfile(userId: widget.otherUserId));
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(user!['avatar_url']),
                      radius: 18.r,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      user!['username'] ?? 'Usuario',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase
                .from('messages')
                .stream(primaryKey: ['id'])
                .eq('chat_id', widget.chatId)
                .order('created_at', ascending: true)
                .map((data) => List<Map<String, dynamic>>.from(data)),

              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: ColorsTrueq.primary,));

                final messages = snapshot.data!;

                //Para eliminar repetidos(en supabase ponen 1 de insert y otro de prueba que se debe eliminar)
                final uniqueMessages = {for (var message in messages) message['id']: message}.values.toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(SizesTrueq.inputFieldRadius),
                  itemCount: uniqueMessages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final message = uniqueMessages[index];
                    final isMe = message['sender_id'] == userId;
                    final date = HelperFunctions.formatDatetime(message['created_at']);

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: ChatBubble(
                          clipper: ChatBubbleClipper8(
                            type: isMe ? BubbleType.sendBubble : BubbleType.receiverBubble,
                            radius: SizesTrueq.inputFieldRadius,
                          ),
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          margin: EdgeInsets.symmetric(vertical: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          backGroundColor: isMe ? ColorsTrueq.primary300 : ColorsTrueq.greyChatMessage,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      message['message'],
                                      style: TextStyle(fontSize: 16.sp, color: ColorsTrueq.light),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: isMe ? MainAxisAlignment.start : MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    date,
                                    style: TextStyle(fontSize: 12.sp, color: ColorsTrueq.light),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1.h),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: TextsTrueq.to.getText('writeMessage'),
                        hintStyle: TextStyle(fontSize: 14.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SizesTrueq.inputFieldRadius),
                          borderSide: BorderSide(
                            color: ColorsTrueq.primary,
                            width: 2.0.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send_rounded, size: 24.sp),
                    onPressed: _sendMessage,
                    color: ColorsTrueq.primary,
                  )
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
