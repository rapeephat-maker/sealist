import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Thai month/weekday names for DateFormat(..., 'th').
  await initializeDateFormatting('th');

  // Local reminder notifications — safe to call even before the user grants
  // permission; actual permission is requested from the onboarding screen.
  // (init() never throws and quietly does nothing on web/desktop.)
  await NotificationService.instance.init();

  runApp(const SeaListApp());
}
