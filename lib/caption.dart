import 'dart:convert';

import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

const baseURL = 'https://www.youtube.com/api/timedtext';

class YoutubeCaption {

  dynamic caption;

  Future<dynamic> fetchCaption(String videoId, String lang) async {
    var url = '${baseURL}?v=$videoId&lang=$lang';

    print(url);
    var xml2json = Xml2Json();
    var unescape = HtmlUnescape();

    var response = await http.get(url);
    if (response.statusCode == 200) {
      print('-------------------------------------------');
      print('${response.body}');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    var body = unescape.convert(response.body);
    print('Response status: ${response.statusCode}');
    xml2json.parse(body);

    var jsonData = json.decode(xml2json.toGData());
    var transcript = jsonData['transcript'];

//    for (var sentence in transcript['text']) {
//      print(sentence['start']);
//      print(sentence[r'$t']);
//    }
    caption = transcript['text'];
    return caption;
  }
}