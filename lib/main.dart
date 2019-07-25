import 'dart:async' show Future;
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';

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
  bool isLoading;
  TextEditingController userInputController;
  FlutterTts flutterTts;

  @override
  initState() {
    super.initState();
    counter = 1;
    vocab = widget.vocabs.drawWord();
    isShowAnswer = false;
    isAudioPlaying = false;
    isLoading = true;
    userInputController = new TextEditingController();

    flutterTts = new FlutterTts();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isAudioPlaying = false;
      });
    });

    flutterTts.setLanguage("ja-JP").then((result) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _displayNextWord() {
    Vocab newVocab = widget.vocabs.drawWord();
    setState(() {
      counter++;
      vocab = newVocab;
      isShowAnswer = false;
      userInputController.clear();
    });
  }

  void _showAnswer() {
    setState(() {
      isShowAnswer = !isShowAnswer;
    });
  }

  void _playAudio() async {
    int result = await flutterTts.speak(vocab.word);
    if (result == 1) setState(() => isAudioPlaying = true);
  }

  @override
  void dispose() {
    userInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String questionNumber = counter.toString();
    bool isInputCorrect = userInputController.text == vocab.word ||
        (vocab.hasHiragana() && userInputController.text == vocab.hiragana);
    String result = isInputCorrect ? 'O' : 'X';

    var textfiledPadding =
        (MediaQuery.of(context).viewInsets.bottom - 56.0).abs();

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Visibility(
          visible: !isLoading,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                  child: Expanded(
                      child: new Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                        padding: EdgeInsets.only(bottom: textfiledPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Q$questionNumber',
                              style: Theme.of(context).textTheme.display1,
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                  top: 15.0, bottom: 15.0),
                              child: Ink(
                                decoration: ShapeDecoration(
                                  color: Colors.green,
                                  shape: CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: isAudioPlaying
                                      ? Icon(Icons.pause)
                                      : Icon(Icons.play_arrow),
                                  iconSize: 76.0,
                                  color: Colors.white,
                                  tooltip: 'Pronounce',
                                  onPressed: _playAudio,
                                ),
                              ),
                            ),
                            new Center(
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: userInputController,
                                onSubmitted: (input) {
                                  _showAnswer();
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter the word you heard',
                                  filled: true,
                                  fillColor: Colors.black26,
                                  contentPadding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(25.7),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(25.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  )),
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
                                visible: vocab.hasHiragana(),
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
                                    color: Colors.grey, fontSize: 18.0),
                                textAlign: TextAlign.center,
                              ),
                              Visibility(
                                visible: userInputController.text.length > 0,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 45.0, bottom: 15.0),
                                  child: Text(
                                    'Your input: ${userInputController.text} ($result)',
                                    style: TextStyle(color: isInputCorrect? Colors.green : Colors.red),
                                  ),
                                ),
                              )
                            ])),
                  ),
                  visible: isShowAnswer,
                ),
                new Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Row(
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
                )
              ],
            ),
          ),
        ));
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
    String vocabJson = await rootBundle.loadString("assets/n5_to_n1.json");
    final jsonResponse = (jsonDecode(vocabJson) as List)
        .map((e) => new Vocab.fromJson(e))
        .toList();
    return new Vocabs.fromJson(jsonResponse);
  }

  Vocab drawWord() {
    do {
      this.position = rand.nextInt(this.vocabsList.length);
    } while (this.vocabsList[this.position].word.length < 4  ||
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
        level: json["level"]);
  }
}
