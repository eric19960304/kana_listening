import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'models/vocabs.dart';
import 'views/home_page.dart';
import 'views/loading_frame.dart';

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

  FlutterTts flutterTts = new FlutterTts();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (vocabs != null) {
      vocabs.dispose();
    }
  }

  Future<void> initData(BuildContext context) async {
    await flutterTts.setLanguage("ja-JP");
    var db = await initDB(context);
    vocabs = Vocabs(db: db);
    await vocabs.init();
  }

  Future<Database> initDB(BuildContext context) async {
    final Future<Database> database =
        openDatabase(
          join(await getDatabasesPath(), 'words_sqlite3.db'),
          onCreate: (db, version) { return copyDataToDB(context, db); }, 
          version: 1
        );
    return database;
  }

  void copyDataToDB(BuildContext context, Database db) async {
    final String vocabsText = await DefaultAssetBundle.of(context)
        .loadString("assets/data/n5_to_n1_words.json");
    final vocabJson = jsonDecode(vocabsText) as List;
    List<Vocab> vocabList = vocabJson.map((i) => Vocab.fromJson(i)).toList();
    
    // print("parsed vocabs: " + vocabList.length.toString());

    db.execute('''
      CREATE TABLE IF NOT EXISTS vocabs(
        word TEXT,
        meaning TEXT,
        hiragana TEXT,
        romaji TEXT,
        level INTEGER,
        created_time INTEGER,
        is_user_defined INTEGER
      )
      ''');
    int timestamp = new DateTime.now().millisecondsSinceEpoch;

    Batch batch = db.batch();
    for (var w in vocabList) {
      batch.rawInsert('INSERT INTO vocabs VALUES (?,?,?,?,?,?,?)', [
        w.word,
        w.meaning,
        w.hiragana,
        w.romaji,
        w.level,
        timestamp,
        0
      ]);
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: initData(context),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? MaterialApp(
                  title: 'Kana Listening',
                  theme: ThemeData(
                    brightness: Brightness.dark,
                    primarySwatch: Colors.blue,
                  ),
                  home: HomePage(
                      title: 'Kana Listening',
                      vocabs: vocabs,
                      flutterTts: flutterTts),
                  debugShowCheckedModeBanner: false)
              : MaterialApp(
                  title: 'Kana Listening',
                  theme: ThemeData(
                    brightness: Brightness.dark,
                    primarySwatch: Colors.blue,
                  ),
                  home: LoadingFrame(),
                  debugShowCheckedModeBanner: false);
        });
  }
}
