import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';

class ComicPage extends StatefulWidget {
  const ComicPage({Key? key}) : super(key: key);

  @override
  ComicPageState createState() => ComicPageState();
}

class ComicPageState extends State<ComicPage> {
  late String _url;
  late bool _haveUrl;

  Future<PermissionStatus> get permission async {
    return await Permission.storage.request();
  }

  @override
  initState() {
    super.initState();
    _haveUrl = false;
    _getComic();
  }

  void _getComic() async {
    var url = Uri(scheme: 'https', host: 'random-xkcd-img.herokuapp.com');
    final client = HttpClient();
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(client);
    await http.get(url).then(
      (response) async {
        if (response.statusCode == 200) {
          Map<String, dynamic> result = json.decode(response.body);
          _url = result['url'];
          setState(() => _haveUrl = true);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(5.0),
        child: Center(
          child: !_haveUrl
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : PhotoView(
                  imageProvider: NetworkImage(
                    _url,
                  ),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Share',
        child: const Icon(
          Icons.share,
        ),
        onPressed: () => _haveUrl ? share() : null,
      ),
    );
  }

  Future<void> share() async {
    if (await permission.isGranted) {
      final RenderBox box = context.findRenderObject() as RenderBox;
      var uri = Uri.parse(_url);
      String path = uri.path.toString();
      String filename = path.substring(path.lastIndexOf('/') + 1);
      var response = await get(uri);
      var directory = await getTemporaryDirectory();
      File imgFile = File('${directory.path}/$filename');
      var bodyBytes = response.bodyBytes;
      imgFile.writeAsBytes(bodyBytes);
      Share.shareFiles([imgFile.path],
          subject: 'XKCD comic',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }
  }
}
