import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:smart_shadowing_tool/caption.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'video_list.dart';


class YoutubeCustomWidget extends StatefulWidget {
  final String videoId;
  YoutubeCustomWidget({Key key, @required this.videoId}) : super(key: key) {
    print("DEBUG" + videoId);
  }

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<YoutubeCustomWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  YoutubePlayerController _youtubeController;
  PlayerState _playerState;
  bool _isPlayerReady = false;
  double _volume = 100;
  bool _muted = false;

  ScrollController _scrollController;

  YoutubeCaption caption;
  var sentences = [];
  var currentSentence = 0;

  final cardExtent = 70.0;

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
    caption = YoutubeCaption();
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

    // TODO: Scroll precisely
    for(var i=currentSentence; i<sentences.length; i++) {
      var start = double.parse(sentences[i]['start']);
      var seconds =  start.round();
      if (position == seconds) {
        print('                           the index is ${i}');
        _scrollController.animateTo(
            i * cardExtent, duration: Duration(milliseconds: 300),
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
                  getCaption();
                },
              ),
            ],
            onReady: () {
              _isPlayerReady = true;
//              fetchPost();
//              sentences = caption.fetchCaption('H14bBuluwB8', 'en');
//              print(sentences);
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 1.0),
              itemExtent: cardExtent,
              controller: _scrollController,
              itemCount: sentences.length,
              itemBuilder: (context, index) {
                var start = double.parse(sentences[index]['start']);
                var seconds =  start.round();

                return Card(
//                  margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 0),
//                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: ListTile(
                    leading: index == currentSentence
                        ? Icon(Icons.directions_run) : Icon(Icons.navigate_next),
                    subtitle: Text(seconds.toString() + ' secs', style:TextStyle( fontSize: 12.0)),
                    title: Text(
                      sentences[index][r'$t'],
                      style: index == currentSentence
                          ? TextStyle(color: Colors.white, fontSize: 14.0):
                          TextStyle(color: Colors.black45, fontSize: 12.0),
                    ),
                    onTap: () {
                      print('onTap : move to ${seconds} ${start}' );
                      _youtubeController.seekTo(Duration(seconds: seconds));
                      var postion = index * cardExtent;
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

  getCaption() async {

    dynamic json_data = await caption.fetchCaption('H14bBuluwB8', 'en');
    print("---- Event Handler ---------------------");
    print(sentences);
    setState(() {
      sentences = json_data;
    });
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
