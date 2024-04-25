import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ComicPage extends StatefulWidget {
  const ComicPage(this._comicNumber, {Key? key}) : super(key: key);

  final int _comicNumber;

  @override
  State<StatefulWidget> createState() => ComicPageState();
}

class ComicPageState extends State<ComicPage> {
  Future<PermissionStatus> get permission async {
    return await Permission.storage.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: Center(
        child: FutureBuilder<Uri>(
            future: _getImageUrl(widget._comicNumber),
            builder: (BuildContext context, AsyncSnapshot<Uri> snapshot) {
              if (!snapshot.hasData) {
                // while data is loading:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // data loaded:
                final url = snapshot.data.toString();
                return Image.network(url);
              }
            }),
      ),
      backgroundColor: const Color.fromRGBO(76, 86, 106, 1.0),
    );
  }

  Future<Uri> _getImageUrl(int comicNumber) async {
    late Uri imgLink;
    Uri itemLink = Uri(
        scheme: 'https', host: 'xkcd.com', path: '/$comicNumber/info.0.json');
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(client);
    await http.get(itemLink).then((response) async {
      if (response.statusCode == 200) {
        Map<String, dynamic> result = json.decode(response.body);
        imgLink = Uri.parse(result['img']);
      } else {
        throw Exception(response.statusCode);
      }
    }, onError: (e) => throw Exception(e));
    return imgLink;
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
          onPressed: () => setState(() {
                  _showComic(Random().nextInt(widget._comicNumber + 1));
                }),
        ),
        OutlinedButton.icon(
          label: const Text(
            'Share',
          ),
          onPressed: () => {
            _share(Uri(
                scheme: 'https',
                host: 'xkcd.com',
                path: '/${widget._comicNumber}/info.0.json'))
          },
          icon: const Icon(
            Icons.share,
          ),
        )
      ],
    );
  }

  Future<void> _share(Uri url) async {
    var uri = Uri.parse('https://xkcd.com/${url.toString()}/info.0.json');
    if (Platform.isAndroid) {
      if (await permission.isGranted) {
        var response = await get(uri);
        var directory = await getTemporaryDirectory();
        File imgFile = File('${directory.path}/xkcd-$url');
        var bodyBytes = response.bodyBytes;
        imgFile.writeAsBytes(bodyBytes);
        final box = context.findRenderObject() as RenderBox;
        Share.shareFiles([imgFile.path],
            subject: 'XKCD comic',
            sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
      }
    } else {
      Clipboard.setData(ClipboardData(text: uri.toString()));
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

  void _showComic(int comicNumber) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ComicPage(comicNumber)));
  }
}
