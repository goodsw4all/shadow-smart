import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:youtube_parser/youtube_parser.dart';
import 'package:smart_shadowing_tool/screens/youtube.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Youtube player')),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                OutlineButton(
                  onPressed: () {
//              Navigator.of(context).pushNamed('/youtube');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return YoutubeCustomWidget(
                        videoId: 'Hi its me',
                      );
                    }));
                  },
                  child: Text('Open customize player'),
                ),
                TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Paste the YouTube URL'),
                  onChanged: (text) {
                    String foo = getIdFromUrl(text);
                    print("First text field: $text $foo");
                  },
                ),
              ]),
        ),
      ),
    );
  }
}
