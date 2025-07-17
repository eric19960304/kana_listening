import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/vocabs.dart';
import '../views/answer_frame.dart';
import '../views/loading_frame.dart';
import '../views/question_frame.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.vocabs,
    required this.tts,
  });

  final String title;
  final Vocabs vocabs;
  final FlutterTts tts;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  QuestionFrame? qFrame;
  AnswerFrame? aFrame;
  Vocabs? vocabs;
  int counter = 1;
  bool isShowAnswer = false;
  bool isLoading = false;
  late TextEditingController userInputController;

  @override
  initState() {
    super.initState();

    userInputController = TextEditingController();

    drawVocab().then((newVocab) {
      if (newVocab == null) {
        throw 'No vocab in DB';
      }

      setState(() {
        qFrame = QuestionFrame(
          questionNumber: counter.toString(),
          vocab: newVocab,
          showAnswer: showAnswer,
          userInputController: userInputController,
          flutterTts: widget.tts,
        );
        aFrame = AnswerFrame(
          vocab: newVocab,
          userInputController: userInputController,
        );
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    userInputController.dispose();
    super.dispose();
  }

  Future<Vocab?> drawVocab() async {
    Vocab? v;
    do {
      v = await widget.vocabs.drawWord();
    } while (v != null && !v.isWantedVocab());
    return v;
  }

  Future<void> displayNextWord() async {
    Vocab? newVocab = await drawVocab();
    if (newVocab == null) return;

    counter++;
    userInputController.clear();
    QuestionFrame qf = QuestionFrame(
      questionNumber: counter.toString(),
      vocab: newVocab,
      showAnswer: showAnswer,
      userInputController: userInputController,
      flutterTts: widget.tts,
    );

    AnswerFrame af = AnswerFrame(
      vocab: newVocab,
      userInputController: userInputController,
    );

    setState(() {
      isShowAnswer = false;
      qFrame = qf;
      aFrame = af;
    });
  }

  void showAnswer() {
    setState(() {
      isShowAnswer = !isShowAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingFrame();
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(child: isShowAnswer ? aFrame : qFrame),
            Container(
              padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.visibility),
                        iconSize: 36.0,
                        color: Colors.black87,
                        tooltip: 'Show Answer',
                        onPressed: showAnswer,
                      ),
                    ),
                  ),
                  Container(
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.white,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.navigate_next),
                        iconSize: 36.0,
                        color: Colors.black87,
                        tooltip: 'Next Word',
                        onPressed: displayNextWord,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
