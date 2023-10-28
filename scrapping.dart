import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

var finishedCount = 0;
late int allCount;
Future<List<Chapter>> scrape(String url) async {
  if (url.endsWith('/') == false) url += '/';
  final lastPageNumber = await getLastPageNumber('${url}1');
  allCount = lastPageNumber;
  final urls = List<String>.empty(growable: true);
  for (var i = 1; i <= lastPageNumber; i++) urls.add('$url$i');
  final pagesFuturs = urls.map((e) async => await getPage(e));
  final pages = await Future.wait(pagesFuturs);
  print('');

  final newPages = pages.skip(1).fold(List<Chapter>.from([pages.first]),
      (previousValue, element) {
    if (previousValue.last.title != element.title)
      previousValue.add(Chapter(element.title, ''));

    previousValue.last.text += '${element.text}\n';
    return previousValue;
  });
  return newPages;
}

Future<Chapter> getPage(String url) async {
  http.Response response;
  while (true) {
    try {
      response = await http.get(Uri.parse(url)).timeout(Duration(minutes: 5));
      break;
    } catch (e) {
      continue;
    }
  }

  if (response.statusCode != 200) throw ArgumentError('url is wrong >> $url');

  final parser = html_parser.parse(response.body);
  final text = parser
      .querySelector('.nass.margin-top-10')
      ?.children
      .map((e) => '${e.text}\n')
      .reduce((value, element) => '$value $element');

  if (text == null) throw 'can not get the page';

  var level = parser
      .querySelector('.size-12')
      ?.children
      .where((c) => c.localName == 'a')
      .skip(1)
      .map((e) => e.text)
      .reduce((value, element) => '$value $element');
  if (level == null) throw 'can not find the chapter name';

  finishedCount++;
  stdout.write('\rfinish ($finishedCount/$allCount)');
  return Chapter(level, text);
}

Future<int> getLastPageNumber(String url) async {
  var response = await http.get(Uri.parse(url));
  if (response.statusCode != 200) throw ArgumentError('The url is wrong');
  var parser = html_parser.parse(response.body);
  return int.parse(parser
          .getElementsByClassName('btn btn-3d btn-white btn-sm')
          .skip(4)
          .first
          .attributes['href']
          ?.split('/')
          .last
          .split('#')
          .first ??
      '-1');
}

class Chapter {
  String title;
  String text;

  Chapter(this.title, this.text);

  Map<String, dynamic> toJson() {
    return {'title': title, 'text': text};
  }
}
