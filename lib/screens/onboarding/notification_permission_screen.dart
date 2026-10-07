import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/sea_mascot.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  Future<void> _enable(BuildContext context) async {
    // Grab everything we need before the await — no context use afterwards.
    final settings = context.read<SettingsProvider>();
    final tasks = context.read<TaskProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final granted = await NotificationService.instance.requestPermission();

    settings
      ..setNotificationsEnabled(granted)
      ..markPermissionAsked();
    tasks.rescheduleAll();
    navigator.pop();

    if (!granted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('ยังไม่ได้รับอนุญาต — เปิดได้ทีหลังในตั้งค่าของเครื่องนะ'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 132,
                    height: 132,
                    decoration: const BoxDecoration(
                      color: AppColors.seafoam,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const SeaMascot(size: 92, mood: SeaMood.happy),
                  ),
                  const Positioned(
                    right: -4,
                    top: 2,
                    child: Text('🔔', style: TextStyle(fontSize: 34)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('เปิดการแจ้งเตือนไหม', style: AppText.heading(size: 20)),
              const SizedBox(height: 10),
              const Text(
                'เราจะเตือนคุณเบา ๆ ตอนถึงเวลาที่นัดไว้เท่านั้น\nไม่มีสแปม ไม่มีข้อความรบกวนอื่น',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.mutedText, height: 1.7),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _enable(context),
                  child: const Text('เปิดการแจ้งเตือน'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<SettingsProvider>().markPermissionAsked();
                    Navigator.of(context).pop();
                  },
                  child: const Text('ไว้ทีหลัง'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
