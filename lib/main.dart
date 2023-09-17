import 'package:flutter/material.dart';
import 'package:week52/home.dart';
import 'package:week52/addentry.dart';
import 'package:week52/bookmarks.dart';
import 'package:week52/history.dart';
import 'package:week52/productivedays.dart';
import 'package:week52/logDisplay.dart';
import 'package:week52/plandisplay.dart';
import 'package:week52/plan.dart';

void main() {
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light
        ),
        themeMode: ThemeMode.system,
        darkTheme: ThemeData(
            brightness: Brightness.dark
        ),
        routes: {
          '/home':(context)=>Home(),
          '/addentry':(context)=>AddEntry(),
          '/productivedays':(context)=>Productive(),
          '/bookmarks':(context)=>Bookmarks(),
          '/history':(context)=>History(),
          '/logdisplay':(context)=>LogDisplay(),
          '/plan':(context)=>Plan(),
          '/plandisplay':(context)=>Planner()
          },
        initialRoute: '/home',
    );
  }
}

