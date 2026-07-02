import 'package:flutter/material.dart';
import 'package:parkeer/core/database/database_helper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widgets/main_navigation.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  // await DatabaseHelper.instance.initialize();

  try {
    await DatabaseHelper.instance.initialize();
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrint(s.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkeer',
      locale: const Locale('id', 'ID'),
      theme: AppTheme.light,
      home: const MainNavigation(),
    );
  }
}
