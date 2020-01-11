import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/vocabs.dart'; // includes Vocabs and Vocab classes
import '../views/question_frame.dart';
import '../views/answer_frame.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title, this.vocabs, this.flutterTts})
      : super(key: key);

  final String title;
  final Vocabs vocabs;
  final FlutterTts flutterTts;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int counter = 1;
  bool isShowAnswer = false;
  QuestionFrame qFrame;
  AnswerFrame aFrame;
  Vocabs vocabs;
  Vocab vocab;
  TextEditingController userInputController = new TextEditingController();

  @override
  initState() {
    super.initState();

    drawVocab().then((newVocab) {
      setState(() {
        vocab = newVocab;
        createNewFrames();
      });
    });
  }

  @override
  void dispose() {
    userInputController.dispose();
    super.dispose();
  }

  Future<Vocab> drawVocab() async {
    Vocab v;
    do {
      v = await widget.vocabs.drawWord();
    } while (!v.isWantedVocab());
    return v;
  }

  void displayNextWord() async {
    drawVocab().then((newVocab) {
      setState(() {
        counter++;
        vocab = newVocab;
        isShowAnswer = false;
        userInputController.clear();
        createNewFrames();
      });
    });
  }

  void showAnswer() {
    setState(() {
      isShowAnswer = !isShowAnswer;
    });
  }

  void createNewFrames() {
    qFrame = new QuestionFrame(
      questionNumber: counter.toString(),
      vocab: vocab,
      showAnswer: showAnswer,
      userInputController: userInputController,
      flutterTts: widget.flutterTts,
    );
    aFrame = new AnswerFrame(
      vocab: vocab,
      userInputController: userInputController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: isShowAnswer ? aFrame : qFrame,
            ),
            Container(
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
                        onPressed: showAnswer,
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
                        onPressed: displayNextWord,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
