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
  bool _isDarkTheme = CustomTheme.currentTheme == CustomTheme.darkTheme;
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
      appBar: _buildAppbar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
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

  Future<void> _share(String url) async {
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

  _buildAppbar() {
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
          label: const Text(
            'Share',
          ),
          onPressed: () => _haveUrl ? _share(_url) : null,
          icon: const Icon(
            Icons.share,
          ),
        )
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(
          10.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Dark Theme',
                ),
                Switch(
                  value: _isDarkTheme,
                  onChanged: (value) async {
                    final prefs = await SharedPreferences.getInstance();
                    setState(
                          () {
                        _isDarkTheme = value;
                        prefs.setBool(
                          'isDarkTheme',
                          _isDarkTheme,
                        );
                        widget.themeCallback(value
                            ? CustomTheme.darkTheme
                            : CustomTheme.lightTheme);
                      },
                    );
                  },
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const InfoPage(
                        title: 'Info',
                      );
                    },
                  ),
                );
              },
              icon: const Icon(
                Icons.info,
              ),
              label: Text(
                'Info',
                style: _isDarkTheme
                    ? const TextStyle(
                  color: Color(0xffd8dee9),
                )
                    : const TextStyle(
                  color: Color(0xff4c566a),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
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
