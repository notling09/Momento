import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/momento_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Datums- und Zeitformate fuer Deutsch und Englisch laden.
  await initializeDateFormatting();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final controller = await MomentoController.bootstrap();
  runApp(MomentoApp(controller: controller));
}
