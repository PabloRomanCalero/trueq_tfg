import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trueq/screens/bottomNavigation/chats/chat_messages.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:trueq/utils/helper_functions.dart';
import '../../../main.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPage();
}

class _ChatsPage extends State<ChatsPage> {
  bool showInactiveChats = false;
  final userId = supabase.auth.currentUser?.id;

  RealtimeChannel? _messagesChannel;
  final Map<String, Map<String, dynamic>> lastMessagesMap = {};

  final Map<String, bool> onlineUsers = {};
  RealtimeChannel? _presenceChannel;

  @override
  void initState() {
    super.initState();
    _initRealtimeSubscription();
    _loadLastMessages();
    _initPresenceSubscription();
  }

  @override
  void dispose() {
    if (_messagesChannel != null) {
      supabase.removeChannel(_messagesChannel!);
    }
    if (_presenceChannel != null) {
      supabase.removeChannel(_presenceChannel!);
    }
    super.dispose();
  }

  //Para cargar en tiempo real los mensajes que se envien mientras estas en la pantalla
  void _initRealtimeSubscription() {
    _messagesChannel = supabase
        .channel('public:messages')
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'messages',
      callback: (payload) {
        final newMessage = payload.newRecord;
        final chatId = newMessage['chat_id'];
        final message = newMessage['message'];
        final createdAt = newMessage['created_at'];

        setState(() {
          lastMessagesMap[chatId] = {
            'message': message,
            'created_at': createdAt,
          };
        });
      },
    ).subscribe();
  }

  void _initPresenceSubscription() {
    _presenceChannel = supabase.channel('online_users', opts: const RealtimeChannelConfig());

    _presenceChannel!
      .onPresenceJoin((payload) {
        for (final entry in payload.newPresences) {
          final userId = entry.payload['user_id'];
          setState(() {
            onlineUsers[userId] = true;
          });
        }
      })
      .onPresenceLeave((payload) {
        for (final entry in payload.leftPresences) {
          final userId = entry.payload['user_id'];
          setState(() {
            onlineUsers.remove(userId);
          });
        }
      })
      .subscribe((status, _) {
        if (status == RealtimeSubscribeStatus.subscribed) {
          final currentUserId = supabase.auth.currentUser?.id;
          if (currentUserId != null) {
            _presenceChannel!.track({'user_id': currentUserId});
          }
        }
      });
  }

  Future<void> _loadLastMessages() async {
    if (userId == null) return;

    final chatList = await supabase
        .from('chats')
        .select('id')
        .or('user1_id.eq.$userId,user2_id.eq.$userId');

    final chatIds = chatList.map((chat) => chat['id']).toList();

    final futures = chatIds.map((chatId) {
      return supabase
        .from('messages')
        .select('message, created_at')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle()
        .then((message) => {
          'chat_id': chatId,
          'message': message?['message'],
          'created_at': message?['created_at'],
        });
    }).toList();

    final messages = await Future.wait(futures);
    lastMessagesMap.clear();
    for (var message in messages) {
      if (message['message'] != null) {
        setState(() {
          lastMessagesMap[message['chat_id']] = {
            'message': message['message'],
            'created_at': message['created_at'],
          };
        });
      }
    }
  }


  Stream<List<Map<String, dynamic>>> _chatStream() {
    if (userId == null) return const Stream.empty();

    return supabase
      .from('chats')
      .stream(primaryKey: ['id'])
      .map((chats) => chats.where((chat) => chat['user1_id'] == userId || chat['user2_id'] == userId).toList())
      .asyncMap((filteredChats) async {
      if (filteredChats.isEmpty) return [];

      final userIds = filteredChats.map((chat) => chat['user1_id'] == userId ? chat['user2_id'] : chat['user1_id']).toSet().toList();
      final productIds = filteredChats
        .expand((chat) => [chat['product1_id'], chat['product2_id']])
        .toSet()
        .toList();

      final results = await Future.wait([
        supabase
          .from('users')
          .select('username, avatar_url, id')
          .inFilter('id', userIds),
        supabase
          .from('products')
          .select('id, title, user_id, status')
          .inFilter('id', productIds),
      ]);

      final usersList = results[0];
      final productsList = results[1];

      final usersMap = {for (var user in usersList) user['id']: user};
      final productsMap = {for (var product in productsList) product['id']: product};

      final infoChats = filteredChats.map((chat) {
        final otherUserId = chat['user1_id'] == userId ? chat['user2_id'] : chat['user1_id'];
        final userResponse = usersMap[otherUserId];
        final product1 = productsMap[chat['product1_id']];
        final product2 = productsMap[chat['product2_id']];

        chat['disabled'] = (product1?['status'] ?? '') != 'available' || (product2?['status'] ?? '') != 'available';

        if (product1?['user_id'] == otherUserId) {
          chat['other_user_product'] = product1?['title'];
          chat['my_product'] = product2?['title'];
        } else {
          chat['other_user_product'] = product2?['title'];
          chat['my_product'] = product1?['title'];
        }

        chat['other_user'] = userResponse;

        return chat;
      }).toList();

      return infoChats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: kBottomNavigationBarHeight.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.filter_alt_outlined, size: 20.sp, color: ColorsTrueq.primary),
                    SizedBox(width: 8.w),
                    Text(
                      TextsTrueq.to.getText('inactiveChats'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                      ),
                    ),
                  ],
                ),
                Switch(
                  activeColor: ColorsTrueq.primary,
                  value: showInactiveChats,
                  onChanged: (val) {
                    setState(() {
                      showInactiveChats = val;
                    });
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: ColorsTrueq.lightGrey),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: ColorsTrueq.primary)
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final chats = snapshot.data;
                final filteredChats = showInactiveChats
                  ? chats?.where((chat) => chat['disabled'] == true).toList()
                  : chats?.where((chat) => chat['disabled'] == false).toList();

                if (chats == null || chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 60.sp, color: ColorsTrueq.primary),
                        SizedBox(height: 16.sp),
                        Text(
                          TextsTrueq.to.getText('noChatsYet'),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: 10.h),
                  itemCount: filteredChats?.length,
                  itemBuilder: (context, index) {
                    final chat = filteredChats?[index];
                    final chatId = chat?['id'];
                    final otherUserProduct = chat?['other_user_product'];
                    final myProduct = chat?['my_product'];
                    final username = chat?['other_user']?['username'] ?? TextsTrueq.to.getText('usernameNotAvailable');

                    final disabled = chat?['disabled'] == true;

                    final lastMessageData = lastMessagesMap[chatId] ?? {};
                    final createdAt = lastMessageData['created_at'];
                    final timeString = createdAt != null ? DateFormat("HH:mm").format(DateTime.parse(createdAt)) : '';

                    return IgnorePointer(
                      ignoring: disabled,
                      child: Opacity(
                        opacity: disabled ? 0.5 : 1.0,
                        child: ListTile(
                          leading: Stack(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: chat?['other_user']['avatar_url'],
                                  fit: BoxFit.cover,
                                  width: 50.w,
                                  height: 50.h,
                                ),
                              ),
                              if (onlineUsers[chat?['other_user']['id']] == true)
                                Positioned(
                                  bottom: 0,
                                  right: 3.w,
                                  child: Container(
                                    width: 10.w,
                                    height: 10.h,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: ColorsTrueq.light, width: 1.5.w),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text('$username ($otherUserProduct)-($myProduct)'),
                          subtitle: disabled ? Text(
                            TextsTrueq.to.getText('chatDisabled'),
                            style: TextStyle(color: Colors.red.shade300, fontSize: 14.sp),
                          )
                          : lastMessageData['message'] == null ? Text(
                            TextsTrueq.to.getText('noMessagesChat'),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: ColorsTrueq.darkGrey, fontSize: 14.sp),
                          )
                          : Text(
                            lastMessageData['message'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          trailing: Column(
                            children: [
                              Text(
                                timeString,
                                style: TextStyle(
                                  color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (!disabled && (chat?['unread_count'] ?? 0) > 0)
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: const BoxDecoration(
                                    color: ColorsTrueq.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${chat?['unread_count']}',
                                    style: TextStyle(
                                      color: ColorsTrueq.light,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            if (!disabled) {
                              Get.to(() => ChatMessages(
                                chatId: chatId,
                                otherUserId: chat?['other_user']['id']
                              ));
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
