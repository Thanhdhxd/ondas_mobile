import 'package:flutter/material.dart';
import 'package:ondas_mobile/app/app.dart';
import 'package:ondas_mobile/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const App());
}
