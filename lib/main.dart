import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const XKCDRandomizerApp());
}

class XKCDRandomizerApp extends StatelessWidget {
  const XKCDRandomizerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XKCD Randomizer',
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color.fromRGBO(76, 86, 106, 1.0),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromRGBO(46, 52, 64, 1.0),
            foregroundColor: Color.fromRGBO(216, 222, 233, 1.0),
          )),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
