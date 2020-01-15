import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_list.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';

/// Homepage
class YoutubeCustomWidget extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<YoutubeCustomWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _controller;
  TextEditingController _idController;
  TextEditingController _seekToController;

  PlayerState _playerState;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: 'H14bBuluwB8',
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        forceHideAnnotation: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
      ),
    )..addListener(listener);

    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _playerState = PlayerState.unknown;

//    fetchPost();
  }

  fetchPost() async {
    var url = 'https://www.youtube.com/api/timedtext?v=H14bBuluwB8&lang=en';
    var xml2json = Xml2Json();

    var response = await http.get(url);
    var unescape = HtmlUnescape();
    var body = unescape.convert(response.body);
    xml2json.parse(body);
    var jsondata = xml2json.toGData();
    print('Response status: ${response.statusCode}');

//    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
//    String prettyprint = encoder.convert(json.decode(jsondata));
//    print(prettyprint);

    var json_data = json.decode(jsondata);
    var transcript = json_data['transcript'];

    for (var sentence in transcript['text']) {
      print(sentence['start'].toString());
      print(sentence[r'$t']);
    }
    _controller.seekTo(Duration(seconds:14, milliseconds: 954));

    // Await the http get response, then decode the json-formatted response.var response = await http.get(url);
    if (response.statusCode == 200) {
      print('-------------------------------------------');
//      print('Number of books about http: ${response.body}).');

    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void listener() {
    if (_isPlayerReady) {
      if (_controller.value.playerState == PlayerState.ended) {
        _showSnackBar('Video Ended!');
      }
      if (mounted && !_controller.value.isFullScreen) {
        setState(() {
          _playerState = _controller.value.playerState;
        });
      }
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Youtube Player Flutter',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_library),
            onPressed: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => VideoList(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.blueAccent,
            topActions: <Widget>[
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Test',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 25.0,
                ),
                onPressed: () {
                  _showSnackBar('Settings Tapped!');
                  _controller.seekTo(Duration(seconds: 15));
                  fetchPost();
                },
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
            },
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }
}
