import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'comic_page.dart';
import 'custom_theme.dart';
import 'info_page.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.themeCallback, {Key? key}) : super(key: key);

  final Function(ThemeData) themeCallback;

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool switchValue = false;
  final PageController _controller = PageController(
    keepPage: false,
  );

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  void _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue = (prefs.getBool('darkTheme') ?? false);
      widget.themeCallback(
          switchValue ? CustomTheme.darkTheme : CustomTheme.lightTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'XKCD Randomizer',
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: 'Preferences',
            );
          },
        ),
      ),
      drawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              Row(
                children: [
                  const Text('Dark Theme'),
                  Switch(
                    value: switchValue,
                    onChanged: (value) async {
                      final prefs = await SharedPreferences.getInstance();
                      setState(() {
                        switchValue = value;
                        prefs.setBool('darkTheme', switchValue);
                        widget.themeCallback(value
                            ? CustomTheme.darkTheme
                            : CustomTheme.lightTheme);
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      child: Builder(
                        builder: (_) => const Icon(
                          Icons.info,
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) {
                              return const InfoPage(
                                title: 'Info',
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: 1000,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Swipe to see a random XKCD comic.',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Icon(
                  Icons.swipe,
                ),
              ],
            );
          } else {
            return const ComicPage();
          }
        },
      ),
    );
  }
}
