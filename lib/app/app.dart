import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/main_shell.dart';
import 'theme.dart';

class SeaListApp extends StatelessWidget {
  const SeaListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'SeaList',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        // Thai everywhere: date/time pickers, dialogs, text-selection menus…
        locale: const Locale('th'),
        supportedLocales: const [Locale('th'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const MainShell(),
      ),
    );
  }
}
