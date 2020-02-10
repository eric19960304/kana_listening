import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/vocabs.dart';

class VocabsLoader {
  List<Vocab> vocabList;
  Database db;
  Vocabs vocabs;

  Future<Vocabs> load() async {
    await initRawVocabsJson();
    await initDB();
    await initVocabs();
    return this.vocabs;
  }

  Future<void> initRawVocabsJson() async {
    final rawJson = await rootBundle.loadString("assets/data/n5_to_n1_words.json");
    final vocabJson = jsonDecode(rawJson) as List;
    this.vocabList = vocabJson.map((i) => Vocab.fromJson(i)).toList();
  }

  Future<void> initDB() async {
    String dbPath = await getDatabasesPath();
    this.db = await openDatabase(
      join(dbPath, 'words_sqlite3.db'),
      onCreate: (db, version) async { return copyDataToDB(db); }, 
      version: 1
    );
  }

  Future<void> copyDataToDB(Database db) async {
    this.db = db;
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
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    Batch batch = db.batch();
    for (var w in this.vocabList) {
      batch.rawInsert('INSERT INTO vocabs VALUES (?,?,?,?,?,?,?)',
          [w.word, w.meaning, w.hiragana, w.romaji, w.level, timestamp, 0]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> initVocabs() async {
    this.vocabs = Vocabs(db: this.db);
    await this.vocabs.init();
  }
}
