import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';

import 'comic_page.dart';
import 'about_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int? _latestNum;

  @override
  void initState() {
    _getLatestNum();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: Center(
        child: Image.asset('images/xkcd_logo.png'),
      ),
      backgroundColor: const Color.fromRGBO(76, 86, 106, 1.0),
    );
  }

  _buildAppbar() {
    return AppBar(
      title: const Text(
        'XKCD Randomizer',
      ),
      actions: [
        OutlinedButton(
          child: const Text(
            'Randomize!',
          ),
          onPressed: () => _latestNum == null
              ? null
              : setState(() {
                  _showComic(Random().nextInt(_latestNum! + 1));
                }),
        ),
        OutlinedButton.icon(
          label: const Text(
            'About',
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return const InfoPage(
                    title: 'About',
                  );
                },
              ),
            );
          },
          icon: const Icon(
            Icons.info,
          ),
        )
      ],
    );
  }

  void _getLatestNum() async {
    var latestUrl = Uri(scheme: 'https', host: 'xkcd.com', path: 'info.0.json');
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(client);
    await http.get(latestUrl).then((response) => setState(() {
          Map<String, dynamic> result = json.decode(response.body);
          _latestNum = result['num'];
        }));
  }

  void _showComic(int comicNumber) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ComicPage(comicNumber)));
  }
}

// then((response) async {
// if (response.statusCode == 200) {
// Map<String, dynamic> result = json.decode(response.body);
// return result['num'];
// } else {
// throw Exception(response.statusCode);
// }
// }, onError: (e) => throw Exception(e));
// throw Exception('Unknown error');
