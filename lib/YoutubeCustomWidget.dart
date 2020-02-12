import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
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
  YoutubePlayerController _youtubeController;
  ScrollController _scrollController;

  PlayerState _playerState;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  var sentences = [];
  var currentSentence = 0;

  @override
  void initState() {
    super.initState();

    _youtubeController = YoutubePlayerController(
      initialVideoId: 'H14bBuluwB8',
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        forceHideAnnotation: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        enableCaption: false,

      ),
    ); //..addListener(listener);


    _youtubeController.addListener(_youtubeListener);
    _playerState = PlayerState.unknown;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    print(_scrollController.toString());

    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("reach the bottom");
    }
    if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("reach the top");
      });
    }
  }

  void _youtubeListener() {

    var current_secs = _youtubeController.value.position.inSeconds;
    var position = current_secs.round();
    print('YT Listener actvated ${position}');


    // TODO: Find closest caption
    for(var i=currentSentence; i<sentences.length; i++) {
      var start = double.parse(sentences[i]['start']);
      var seconds =  start.round();
      if (position == seconds) {
        print('                           the index is ${i}');
        _scrollController.animateTo(
            i * 80.0, duration: Duration(milliseconds: 300),
            curve: Curves.easeOut);
        currentSentence = i;
      }
    }

    if (_isPlayerReady) {
      if (_youtubeController.value.playerState == PlayerState.ended) {
        print('Video Ended!');
      }
      if (mounted && !_youtubeController.value.isFullScreen) {
        setState(() {
          _playerState = _youtubeController.value.playerState;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: AppBar(
          title: Text(
            'Shadowing Practice',
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
      ),
      body: Column(
        children: <Widget> [
          YoutubePlayer(
            controller: _youtubeController,
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
//                  fetchPost();
                },
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
              fetchPost();
            },
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: sentences.length,
              itemBuilder: (context, index) {
                var start = double.parse(sentences[index]['start']);
                var seconds =  start.round();

                return Card(
                  child: ListTile(
                    leading: index == currentSentence
                        ? Icon(Icons.directions_run) : Icon(Icons.navigate_next),
                    subtitle: Text(seconds.toString() + ' secs'),
                    title: Text(
                      sentences[index][r'$t'],
                      style: index == currentSentence
                          ? TextStyle(color: Colors.white):
                          TextStyle(color: Colors.black45),
                    ),
                    onTap: () {
                      print('onTap : move to ${seconds} ${start}' );
                      _youtubeController.seekTo(Duration(seconds: seconds));
                      var postion = index * 80.0;
                      _scrollController.animateTo(
                          postion, duration: Duration(milliseconds: 300),
                          curve: Curves.easeOut);
                    },
                    onLongPress: () {
                      print('Long press');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  fetchPost() async {
    var url = 'https://www.youtube.com/api/timedtext?v=H14bBuluwB8&lang=en';
    var xml2json = Xml2Json();

    var response = await http.get(url);
    var unescape = HtmlUnescape();
    var body = unescape.convert(response.body);
    print('Response status: ${response.statusCode}');

    xml2json.parse(body);
    var jsonData = json.decode(xml2json.toGData());
    var transcript = jsonData['transcript'];
    sentences = transcript['text'];

    for (var sentence in transcript['text']) {
      print(sentence['start']);
      print(sentence[r'$t']);
    }

    if (response.statusCode == 200) {
      print('-------------------------------------------');
      print('${response.body}');

    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _youtubeController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

}
