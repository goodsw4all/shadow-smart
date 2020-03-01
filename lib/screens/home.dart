import 'package:flutter/material.dart';
import 'package:smart_shadowing_tool/screens/youtube.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Youtube player')),
      body: Center(
        child: Column(children: <Widget>[
          OutlineButton(
            onPressed: () {
//              Navigator.of(context).pushNamed('/youtube');
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return YoutubeCustomWidget();
              }));
            },
            child: Text('Open customize player'),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/non_custom');
            },
            child: Text('Open non customize player'),
          ),
        ]),
      ),
    );
  }
}