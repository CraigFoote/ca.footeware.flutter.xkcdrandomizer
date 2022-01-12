import 'package:flutter/material.dart';

import 'custom_theme.dart';
import 'home_page.dart';

void main() {
  runApp(const XKCDRandomizerApp());
}

class XKCDRandomizerApp extends StatefulWidget {
  const XKCDRandomizerApp({Key? key}) : super(key: key);
  final String title = 'XKCD Randomizer';

  @override
  XKCDRandomizerAppState createState() => XKCDRandomizerAppState();
}

class XKCDRandomizerAppState extends State<XKCDRandomizerApp> {
  void themeCallback(value) {
    setState(() => CustomTheme.currentTheme = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: CustomTheme.currentTheme,
      debugShowCheckedModeBanner: false,
      home: HomePage(themeCallback),
    );
  }
}
