import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter/services.dart';

import 'models/vocabs.dart';
import 'views/home_page.dart';
import 'views/loading_frame.dart';
import 'helpers/vocabs_loader.dart';

final String appName = "Kana Listening";

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

  Vocabs vocabs;
  VocabsLoader vLoader;
  FlutterTts tts;

  @override
  void initState() {
    super.initState();

    this.vLoader = VocabsLoader();
    this.tts = FlutterTts();
    this.tts.setLanguage("ja");
    this.vLoader = new VocabsLoader();
    this.vLoader.load().then((v){
      setState(() {
        this.vocabs = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(this.vocabs == null || this.tts == null) {
      return loadingPage();
    }

    return MaterialApp(
        title: appName,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: HomePage(title: appName, vocabs: this.vocabs, tts: this.tts),
        debugShowCheckedModeBanner: false);
  }

  Widget loadingPage() {
    return MaterialApp(
        title: appName,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: LoadingFrame(),
        debugShowCheckedModeBanner: false);
  }
}
