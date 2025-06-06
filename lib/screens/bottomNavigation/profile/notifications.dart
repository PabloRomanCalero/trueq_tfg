import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trueq/utils/constants/colors.dart';
import 'package:trueq/utils/constants/sizes.dart';
import 'package:trueq/utils/constants/text_strings.dart';
import 'package:trueq/utils/helper_functions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> with WidgetsBindingObserver {
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override // Detecta si vuelve del fondo para actualizar el permiso, esta función es del WidgetsBindingObserver
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    final permission = await Permission.notification.status;
    setState(() {
      notificationsEnabled = permission.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          TextsTrueq.to.getText('notifications'),
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizesTrueq.defaultSpace.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TextsTrueq.to.getText('notificationSettings'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Opacity(
              opacity: notificationsEnabled ? 1.0 : 0.5,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  TextsTrueq.to.getText('enableNotifications'),
                  style: TextStyle(fontSize: 16.sp),
                ),
                subtitle: Text(
                  TextsTrueq.to.getText('enableNotificationsInfo'),
                  style: TextStyle(color: dark ? ColorsTrueq.lightGrey : ColorsTrueq.darkGrey),
                ),
                value: notificationsEnabled,
                activeColor: ColorsTrueq.primary,
                onChanged: (_) async {
                  await openAppSettings();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
