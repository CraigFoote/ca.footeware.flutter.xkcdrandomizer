import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late String _url;
  late bool _haveUrl;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _haveUrl = false;
  }

  Future<PermissionStatus> get permission async {
    return await Permission.storage.request();
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
      appBar: buildAppbar(),
      drawer: buildDrawer(),
      body: buildBody(),
    );
  }

  Future<String> _getComicUrl() async {
    String _comicUrl = '';
    var lookupUrl = Uri(scheme: 'https', host: 'random-xkcd-img.herokuapp.com');
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(client);
    await http.get(lookupUrl).then((response) async {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        _comicUrl = result['url'];
      } else {
        throw Exception(response.statusCode);
      }
    }, onError: (e) => throw Exception(e));
    return _comicUrl;
  }

  Future<void> share(String url) async {
    if (Platform.isAndroid) {
      if (await permission.isGranted) {
        var uri = Uri.parse(url);
        String path = uri.path.toString();
        String filename = path.substring(path.lastIndexOf('/') + 1);
        var response = await get(uri);
        var directory = await getTemporaryDirectory();
        File imgFile = File('${directory.path}/$filename');
        var bodyBytes = response.bodyBytes;
        imgFile.writeAsBytes(bodyBytes);
        final box = context.findRenderObject() as RenderBox;
        Share.shareFiles([imgFile.path],
            subject: 'XKCD comic',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      }
    } else {
      Clipboard.setData(ClipboardData(text: url));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'URL copied to clipboard.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  buildAppbar() {
    return AppBar(
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
      actions: [
        OutlinedButton.icon(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          label: const Text(
            'Next',
          ),
          onPressed: () => setState(
            () {
              _getComicUrl();
            },
          ),
          icon: const Icon(
            Icons.arrow_forward_rounded,
          ),
        ),
        OutlinedButton.icon(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
          label: const Text(
            'Share',
          ),
          onPressed: () => _haveUrl ? share(_url) : null,
          icon: const Icon(
            Icons.share,
          ),
        )
      ],
    );
  }

  buildDrawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
              mainAxisAlignment: MainAxisAlignment.end,
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
    );
  }

  Widget buildBody() {
    return FutureBuilder(
      future: _getComicUrl(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          _url = snapshot.data as String;
          _haveUrl = true;
          return PhotoView(
            imageProvider: NetworkImage(
              _url,
            ),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          );
        }
      },
    );
  }
}
