import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class Vocabs {
  List<Vocab> vocabsList;
  int position = 0;
  var rand = new Random();

  Vocabs({this.vocabsList});

  factory Vocabs.fromJson(List<dynamic> data) {
    return Vocabs(vocabsList: data);
  }

  static Future<Vocabs> loadVocabs() async {
    String vocabJson = await rootBundle.loadString("assets/n5_to_n1.json");
    final jsonResponse = (jsonDecode(vocabJson) as List)
      .map((e) => new Vocab.fromJson(e))
      .toList();
    return new Vocabs.fromJson(jsonResponse);
  }

  Vocab drawWord() {
    do {
      this.position = rand.nextInt(this.vocabsList.length);
    } while (
      this.vocabsList[this.position].word.length < 4 ||
      this.vocabsList[this.position].meaning.length == 0
    );
    return this.vocabsList[this.position];
  }
}

class Vocab {
  String word;
  String meaning;
  String hiragana;
  String romaji;
  int level;

  Vocab({word, meaning, hiragana, romaji, level}) {
    this.word = word;
    this.meaning = meaning;
    this.hiragana = hiragana;
    this.romaji = romaji;
    this.level = level;
  }

  String getPronounciationText() {
    return hasHiragana() ? this.hiragana : this.word;
  }

  bool hasHiragana() {
    return this.hiragana.length > 0;
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
}
