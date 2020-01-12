import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'models/vocabs.dart';
import 'views/home_page.dart';

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
  FlutterTts flutterTts;
  bool isLoading;

  @override
  void initState() {
    super.initState();

    flutterTts = new FlutterTts();
    isLoading = true;
    initData().then((result) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> initData() async {
    await flutterTts.setLanguage("ja-JP");

    Database db = await initDB();
    vocabs = Vocabs(db: db);
    await vocabs.init();
  }

  Future<Database> initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "sqlite3.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "db", "sqlite3.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    }

    var db = await openDatabase(path);
    return db;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kana Listening',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: isLoading
            ? Scaffold(
                appBar: AppBar(
                  title: Text('Kana Listening'),
                ),
                body: Center(
                  child: Text('Loading...'),
                ),
              )
            : HomePage(
                title: 'Kana Listening',
                vocabs: vocabs,
                flutterTts: flutterTts),
        debugShowCheckedModeBanner: false);
  }
}
