import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'package:http/http.dart' as http;

void main() async {
  final Vocabs vocabs = await Vocabs.loadVocabs();
  runApp(MyApp(vocabs: vocabs));
}

class MyApp extends StatelessWidget {
  final Vocabs vocabs;

  const MyApp({
    Key key,
    this.vocabs
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kana listening test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Kana Listening Test', vocabs: this.vocabs),
      debugShowCheckedModeBanner: false
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.vocabs}) : super(key: key);

  final String title;
  Vocabs vocabs;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Vocab vocab;

  @override
  initState() {
    super.initState();
    vocab = widget.vocabs.drawWord();
  }

  void _displayWord() {
    setState(() {
      vocab = widget.vocabs.drawWord();
    });
  }

  Future<String> _getVocabAudioUrl(vocab) async {
    var url = 'https://ttsmp3.com/makemp3.php';
    String msg = "";
    if(vocab.hiragana.length>0){
      msg = vocab.hiragana;
    }else{
      msg = vocab.word;
    }
    var response = await http.post(url, body: {'msg': msg, 'lang': 'Mizuki', 'source': 'ttsmp3'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    final jsonResponse = jsonDecode(response.body);
    VocabAudioResponse res = new VocabAudioResponse.fromJson(jsonResponse);
    return res.url;
  }

  @override
  Widget build(BuildContext context) {
    String displayWord = "";
    if(vocab.hiragana.length>0){
      displayWord = vocab.hiragana;
    }else{
      displayWord = vocab.word;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              displayWord,
              style: Theme.of(context).textTheme.display1,
              textAlign: TextAlign.center,
            ),
            new Container(
              margin: const EdgeInsets.only(bottom: 15.0),
              child : Text(
                vocab.romaji,
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center
              ),
            ),
            Text(
              '[${vocab.meaning}]',
              style: Theme.of(context).textTheme.body1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayWord,
        tooltip: 'Next Word',
        child: Icon(Icons.navigate_next),
      ),
    );
  }
}

class Vocabs {
  List<Vocab> vocabsList;
  int position = 0;
  var rand = new Random();

  Vocabs ({
    this.vocabsList
  });

  factory Vocabs.fromJson(List<dynamic> data){
    return Vocabs(vocabsList: data);
  }

  static Future<Vocabs> loadVocabs() async {
    String vocabJson = await rootBundle.loadString("assets/allVocab.json");
    final jsonResponse = (jsonDecode(vocabJson) as List).map((e) => new Vocab.fromJson(e)).toList();
    return new Vocabs.fromJson(jsonResponse);
  }

  Vocab drawWord(){
    do{
      this.position = rand.nextInt(this.vocabsList.length);
    }while(this.vocabsList[this.position].word.length < 4 || 
      this.vocabsList[this.position].word.length < 4);
    return this.vocabsList[this.position];
  }
}
class Vocab {
  String word;
  String meaning;
  String hiragana;
  String romaji;
  int level;

  Vocab({
    this.word,
    this.meaning,
    this.hiragana,
    this.romaji,
    this.level
  });

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

class VocabAudioResponse {
  String text;
  String url;
  String mp3;

  VocabAudioResponse({
    this.text,
    this.url,
    this.mp3
  });

  factory VocabAudioResponse.fromJson(Map<String, dynamic> json) {
    return VocabAudioResponse(
      text: json["Text"],
      url: json["URL"],
      mp3: json["MP3"],
    );
  }
}
