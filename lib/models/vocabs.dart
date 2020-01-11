import 'dart:math';
import 'dart:collection';
import 'package:sqflite/sqflite.dart';

class Vocabs {
  Database db;
  
  final tableName = 'vocabs';
  int vocabCount = 0;
  var rand = new Random();
  var usedVocabsRowid = new LinkedHashSet();

  Vocabs({this.db});

  Future init() async {
    this.vocabCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
  }

  Future<Vocab> drawWord() async {
    if(usedVocabsRowid.length >= vocabCount){
      usedVocabsRowid = new LinkedHashSet();
    }

    var rowid = rand.nextInt(vocabCount);
    while(usedVocabsRowid.contains(rowid)) {
      // draw again
      rowid = rand.nextInt(vocabCount);
    }

    List<Map<String, dynamic>> result = await db.query(
      tableName,
      columns: ['word', 'meaning', 'hiragana', 'romaji', 'level'],
      where: 'ROWID = ?',
      whereArgs: [rowid]
    );

    if(result.length > 0){
      usedVocabsRowid.add(rowid);
      return Vocab.fromMap(result[0]);
    }

    return null;
  }

}

class Vocab {
  String word;
  String meaning;
  String hiragana;
  String romaji;
  int level;

  Vocab({this.word,this.meaning, this.hiragana, this.romaji, this.level});

  factory Vocab.fromMap(Map<String, dynamic> map) {
    return Vocab(
      word: map['word'],
      meaning: map['meaning'],
      hiragana: map['hiragana'],
      romaji: map['romaji'],
      level: map['level']
    );
  }

  String getPronounciationText() {
    return hasHiragana() ? this.hiragana : this.word;
  }

  bool hasHiragana() {
    return this.hiragana.length > 0;
  }

  bool isWantedVocab() {
    return this.word.length >=4 && this.meaning.length > 0;
  }

  bool isCorrectPronounce(String input) {
    var normalizedInput = "";
    var hasChoonpu = false;
    var convertTable = { "ō": "oo", "ū": "uu", "ā": "aa", "ī": "ii", "ē": "ee" };
    for(int i=0; i<input.length; i++) {
      if(convertTable.containsKey(input[i])){
        hasChoonpu = true;
        normalizedInput += convertTable[input[i]];
      } else {
        normalizedInput += input[i];
      }
    }

    return input == word ||
      input == romaji || 
      (hasChoonpu && input == normalizedInput ) ||
      (hasHiragana() && input == hiragana);
  }
}
