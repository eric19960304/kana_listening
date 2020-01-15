import 'dart:math';
import 'dart:collection';
import 'package:sqflite/sqflite.dart';

class Vocabs {
  Database db;
  
  int vocabCount = 0;
  var rand = new Random();
  var usedVocabsRowid = new LinkedHashSet();

  Vocabs({this.db});

  Future init() async {
    int count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM vocabs'));
    // print("DB vocab count: " + count.toString());
    this.vocabCount = count;
  }

  void dispose() async {
    await this.db.close();
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
      'vocabs',
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

  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
      word: json["word"],
      meaning: json["meaning"],
      hiragana: json["hiragana"],
      romaji: json["romaji"],
      level: json["level"]
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
    var normalizedRomaji = "";
    var hasNormalized = false;
    var convertTable = { "ō": "oo", "ū": "uu", "ā": "aa", "ī": "ii", "ē": "ee" };
    for(int i=0; i<romaji.length; i++) {
      if(convertTable.containsKey(romaji[i])){
        hasNormalized = true;
        normalizedRomaji += convertTable[romaji[i]];
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
