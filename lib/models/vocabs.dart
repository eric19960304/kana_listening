import 'dart:collection';
import 'dart:math';

import 'package:sqflite/sqflite.dart';

class Vocabs {
  final Database db;

  int vocabCount = 0;
  var rand = Random();
  var usedVocabsRowid = LinkedHashSet();

  Vocabs({required this.db});

  Future<void> init() async {
    int? count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM vocabs'),
    );
    this.vocabCount = count ?? 0;
  }

  Future<Vocab?> drawWord() async {
    if (usedVocabsRowid.length >= vocabCount) {
      usedVocabsRowid = LinkedHashSet();
    }

    var rowid = rand.nextInt(vocabCount);
    while (usedVocabsRowid.contains(rowid)) {
      // draw again
      rowid = rand.nextInt(vocabCount);
    }

    List<Map<String, dynamic>> result = await db.query(
      'vocabs',
      columns: ['word', 'meaning', 'hiragana', 'romaji', 'level'],
      where: 'ROWID = ?',
      whereArgs: [rowid],
    );

    if (result.isNotEmpty) {
      usedVocabsRowid.add(rowid);
      return Vocab.fromMap(result[0]);
    }

    return null;
  }
}

class Vocab {
  final String word;
  final String meaning;
  final String hiragana;
  final String romaji;
  final int level;

  const Vocab({
    required this.word,
    required this.meaning,
    required this.hiragana,
    required this.romaji,
    required this.level,
  });

  factory Vocab.fromMap(Map<String, dynamic> map) {
    return Vocab(
      word: map['word'] ?? '',
      meaning: map['meaning'] ?? '',
      hiragana: map['hiragana'] ?? '',
      romaji: map['romaji'] ?? '',
      level: map['level'] ?? 0,
    );
  }

  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
      word: json["word"] ?? '',
      meaning: json["meaning"] ?? '',
      hiragana: json["hiragana"] ?? '',
      romaji: json["romaji"] ?? '',
      level: json["level"] ?? 0,
    );
  }

  String getPronounciationText() {
    return hasHiragana() ? this.hiragana : this.word;
  }

  bool hasHiragana() {
    return this.hiragana.isNotEmpty;
  }

  bool isWantedVocab() {
    return this.word.length >= 4 && this.meaning.isNotEmpty;
  }

  bool isCorrectPronounce(String input) {
    var normalizedRomaji = "";
    var hasNormalized = false;
    var convertTable = {"ō": "oo", "ū": "uu", "ā": "aa", "ī": "ii", "ē": "ee"};
    for (int i = 0; i < romaji.length; i++) {
      if (convertTable.containsKey(romaji[i])) {
        hasNormalized = true;
        normalizedRomaji += convertTable[romaji[i]]!;
      } else {
        normalizedRomaji += romaji[i];
      }
    }

    return input == word ||
        input == romaji ||
        (hasNormalized && input == normalizedRomaji) ||
        (hasHiragana() && input == hiragana);
  }
}
