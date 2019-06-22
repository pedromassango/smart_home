import 'package:flutter/material.dart';
import 'package:smart_home/pages/home_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Challenge',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
