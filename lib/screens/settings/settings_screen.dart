import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/colors.dart';
import '../../app/text_styles.dart';
import '../../providers/settings_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/sea_mascot.dart';
import '../onboarding/notification_permission_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    void openPermissionScreen() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NotificationPermissionScreen()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ตั้งค่า'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          const _ProfileCard(),
          const _GroupTitle('🔔 การแจ้งเตือน'),
          _SettingsGroup(children: [
            _SettingsRow(
              icon: Icons.notifications_none_rounded,
              iconBg: AppColors.sky,
              iconColor: AppColors.oceanBlue,
              title: 'การแจ้งเตือน',
              subtitle: settings.notificationsEnabled ? 'เปิดอยู่' : 'ปิดอยู่',
              trailing: Switch(
                value: settings.notificationsEnabled,
                onChanged: (v) {
                  context.read<SettingsProvider>().setNotificationsEnabled(v);
                  // Turning off cancels every pending reminder; turning on brings them back.
                  context.read<TaskProvider>().rescheduleAll();
                  if (v && !settings.hasAskedNotificationPermission) {
                    openPermissionScreen();
                  }
                },
              ),
              onTap: openPermissionScreen,
            ),
            _SettingsRow(
              icon: Icons.access_time_rounded,
              iconBg: AppColors.sunnySoft,
              iconColor: AppColors.overdue,
              title: 'เวลาเตือนความจำเริ่มต้น',
              subtitle: settings.defaultReminderLabel,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: settings.defaultReminderTime,
                );
                if (picked != null && context.mounted) {
                  context.read<SettingsProvider>().setDefaultReminderTime(picked);
                }
              },
            ),
          ]),
          const _GroupTitle('🎨 รูปลักษณ์'),
          _SettingsGroup(children: [
            _SettingsRow(
              icon: Icons.palette_outlined,
              iconBg: AppColors.lavenderSoft,
              iconColor: Color(0xFF6D28D9),
              title: 'ธีม',
              subtitle: 'อ่อนโยน (สว่าง)',
              onTap: () => _showComingSoon(context, 'ธีมมืดกำลังจะตามมาใน V2 🌙'),
            ),
          ]),
          const _GroupTitle('🐚 ข้อมูล'),
          _SettingsGroup(children: [
            _SettingsRow(
              icon: Icons.cleaning_services_outlined,
              iconBg: AppColors.seafoam,
              iconColor: AppColors.deepOcean,
              title: 'ล้างงานที่เสร็จแล้ว',
              onTap: () => _confirmClear(context),
            ),
            _SettingsRow(
              icon: Icons.waves_rounded,
              iconBg: AppColors.coralSoft,
              iconColor: Color(0xFFBE185D),
              title: 'เกี่ยวกับ SeaList',
              subtitle: 'v1.0.0',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'SeaList',
                applicationVersion: '1.0.0',
                applicationLegalese: 'เคลียร์หัว แล้วไปใช้ชีวิตต่อ 🌊',
              ),
            ),
          ]),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'ทำด้วยใจ ให้เป็นสมุดเล่มเล็ก ๆ ริมทะเล 🌊',
              style: TextStyle(fontSize: 12, color: AppColors.faintText),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    final tasks = context.read<TaskProvider>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('ล้างงานที่เสร็จแล้วทั้งหมด?'),
        content: const Text('งานที่ทำเสร็จแล้วจะถูกลบออกจากรายการ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              tasks.clearCompleted();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('ล้าง', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sky, AppColors.seafoam],
        ),
      ),
      child: Row(
        children: [
          const SeaMascot(size: 68),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SeaList', style: AppText.heading(size: 21)),
                const SizedBox(height: 2),
                const Text(
                  'เคลียร์หัว แล้วไปใช้ชีวิตต่อ 🌊',
                  style: TextStyle(fontSize: 13.5, color: AppColors.mutedText, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10, left: 4),
      child: Text(text, style: AppText.heading(size: 14, color: AppColors.deepOcean)),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(22);
    return Container(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: AppColors.deepOcean.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // Material inside the shadow so row ripples show up (and get clipped).
      child: Material(
        color: Colors.white,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1) const Divider(height: 1, indent: 62, endIndent: 16),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.mutedText),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded, size: 22, color: Color(0xFFC3D3D8)),
          ],
        ),
      ),
    );
  }
}
