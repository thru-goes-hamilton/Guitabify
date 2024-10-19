import 'package:flutter/material.dart';
import 'package:guitabify/home_page.dart';
import 'package:guitabify/record_page.dart';
import 'package:guitabify/tab_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: HomePage.id,
        routes: {
          HomePage.id: (context) => const HomePage(),
          RecordPage.id: (context) => const RecordPage(),
        });
  }
}
