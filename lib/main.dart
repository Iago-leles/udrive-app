import 'package:distribuida/infoHandler/app_info.dart';
import 'package:distribuida/telas/cadastro.dart';
import 'package:distribuida/telas/login.dart';
import 'package:distribuida/telas/main_screen.dart';
import 'package:distribuida/telas/search_places_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
      title: 'U-Drive Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginUser(),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
      ),
    );
  }
}
