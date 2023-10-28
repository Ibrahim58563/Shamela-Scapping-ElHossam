import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shamela_scraping_elhosam/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final status = await Permission.storage.status;
  await Permission.storage.request();
  await Permission.manageExternalStorage.request();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
