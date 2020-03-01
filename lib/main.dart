import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home.dart';

import 'screens/youtube.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
        '/': (context) => HomeScreen(),
        '/youtube': (BuildContext context) => YoutubeCustomWidget(),
        '/non_custom': (BuildContext context) => null,
      },
      theme: ThemeData.dark(),
    );
  }
}
