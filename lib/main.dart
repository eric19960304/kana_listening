import 'dart:async' show Future;
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

void main() async {
  final Vocabs vocabs = await Vocabs.loadVocabs();
  runApp(MyApp(vocabs: vocabs));
}

class MyApp extends StatelessWidget {
  final Vocabs vocabs;

  const MyApp({Key key, this.vocabs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Kana Listening Test',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Kana Listening Test', vocabs: this.vocabs),
        debugShowCheckedModeBanner: false);
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.vocabs}) : super(key: key);

  final String title;
  final Vocabs vocabs;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int counter;
  Vocab vocab;
  bool isShowAnswer;
  bool isAudioPlaying;
  String audioUrl;
  AudioPlayer audioPlayer;

  @override
  initState() {
    super.initState();

    counter = 1;
    vocab = widget.vocabs.drawWord();
    isShowAnswer = false;
    isAudioPlaying = false;
    audioUrl = "";
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        isAudioPlaying = false;
      });
    });
  }

  void _displayNextWord() async {
    audioUrl = await getVocabAudioUrl(vocab);
    setState(() {
      counter++;
      vocab = widget.vocabs.drawWord();
      isShowAnswer = false;
    });
  }

  void _showAnswer() {
    setState(() {
      isShowAnswer = !isShowAnswer;
    });
  }

  void _playAudio() async {
    setState(() {
      isAudioPlaying = true;
    });
    await audioPlayer.play(audioUrl);
  }

  @override
  Widget build(BuildContext context) {
    bool isHiraganaExist = vocab.hiragana.length > 0;
    String questionNumber = counter.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Q'+questionNumber,
              style: Theme.of(context).textTheme.display2,
              textAlign: TextAlign.center,
            ),
            Visibility(
              child: Expanded(
                child: new Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: Ink(
                      decoration: ShapeDecoration(
                        color: Colors.green,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: isAudioPlaying ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                        iconSize: 60.0,
                        color: Colors.white,
                        tooltip: 'Pronounce',
                        onPressed: _playAudio,
                      ),
                    ),
                  ),
                ),
              ),
              visible: !isShowAnswer,
            ),
            Visibility(
              child: new Expanded(
                child: new Align(
                    alignment: Alignment.center,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            vocab.word,
                            style: Theme.of(context).textTheme.display2,
                            textAlign: TextAlign.center,
                          ),
                          Visibility(
                            child: Text(
                              vocab.hiragana,
                              style: Theme.of(context).textTheme.display2,
                              textAlign: TextAlign.center,
                            ),
                            visible: isHiraganaExist,
                          ),
                          new Container(
                            margin: const EdgeInsets.only(bottom: 15.0),
                            child: Text(vocab.romaji,
                            style: Theme.of(context).textTheme.display1,
                            textAlign: TextAlign.center),
                          ),
                          Text(
                            '[${vocab.meaning}]',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 18.0
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ])),
              ),
              visible: isShowAnswer,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.visibility),
                      iconSize: 36.0,
                      color: Colors.black87,
                      tooltip: 'Show Answer',
                      onPressed: _showAnswer,
                    ),
                  ),
                ),
                Container(
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.navigate_next),
                      iconSize: 36.0,
                      color: Colors.black87,
                      tooltip: 'Next Word',
                      onPressed: _displayNextWord,
                    ),
                  ),
                ),
              ],
            ),
            Text('\n')
          ],
        ),
      ),
    );
  }
}

class Vocabs {
  List<Vocab> vocabsList;
  int position = 0;
  var rand = new Random();

  Vocabs({this.vocabsList});

  factory Vocabs.fromJson(List<dynamic> data) {
    return Vocabs(vocabsList: data);
  }

  static Future<Vocabs> loadVocabs() async {
    String vocabJson = await rootBundle.loadString("assets/allVocab.json");
    final jsonResponse = (jsonDecode(vocabJson) as List)
        .map((e) => new Vocab.fromJson(e))
        .toList();
    return new Vocabs.fromJson(jsonResponse);
  }

  Vocab drawWord() {
    do {
      this.position = rand.nextInt(this.vocabsList.length);
    } while (this.vocabsList[this.position].word.length < 4 ||
        this.vocabsList[this.position].word.length < 4 ||
        this.vocabsList[this.position].meaning.length == 0);
    return this.vocabsList[this.position];
  }
}

class Vocab {
  String word;
  String meaning;
  String hiragana;
  String romaji;
  int level;

  Vocab({this.word, this.meaning, this.hiragana, this.romaji, this.level});

  factory Vocab.fromJson(Map<String, dynamic> json) {
    return Vocab(
        word: json["word"],
        meaning: json["meaning"],
        hiragana: json["hiragana"],
        romaji: json["romaji"],
        level: json["level"]);
  }
}

class VocabAudioResponse {
  String text;
  String url;
  String mp3;

  VocabAudioResponse({this.text, this.url, this.mp3});

  factory VocabAudioResponse.fromJson(Map<String, dynamic> json) {
    return VocabAudioResponse(
      text: json["Text"],
      url: json["URL"],
      mp3: json["MP3"],
    );
  }
}


Future<String> getVocabAudioUrl(vocab) async {
  var url = 'https://ttsmp3.com/makemp3.php';
  String msg = "";
  if (vocab.hiragana.length > 0) {
    msg = vocab.hiragana;
  } else {
    msg = vocab.word;
  }
  var response = await http
      .post(url, body: {'msg': msg, 'lang': 'Mizuki', 'source': 'ttsmp3'});
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  final jsonResponse = jsonDecode(response.body);
  VocabAudioResponse res = new VocabAudioResponse.fromJson(jsonResponse);
  return res.url;
}