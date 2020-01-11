import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/vocabs.dart'; // includes Vocabs and Vocab classes

class QuestionFrame extends StatefulWidget {
  const QuestionFrame(
      {Key key,
      this.vocab,
      this.userInputController,
      this.questionNumber,
      this.showAnswer,
      this.flutterTts})
      : super(key: key);

  final Vocab vocab;
  final TextEditingController userInputController;
  final String questionNumber;
  final void Function() showAnswer;
  final FlutterTts flutterTts;

  _QuestionFrameState createState() => _QuestionFrameState();
}

class _QuestionFrameState extends State<QuestionFrame> {
  bool isAudioPlaying = false;

  @override
  initState() {
    super.initState();

    widget.flutterTts.setCompletionHandler(() {
      setState(() {
        isAudioPlaying = false;
      });
    });
  }

  void playAudio() async {
    int result =
        await widget.flutterTts.speak(widget.vocab.getPronounciationText());
    if (result == 1) setState(() => isAudioPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    var textfiledPadding =
        (MediaQuery.of(context).viewInsets.bottom - 56.0).abs();

    return Expanded(
        child: new Align(
      alignment: Alignment.topCenter,
      child: Container(
          padding: EdgeInsets.only(bottom: textfiledPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Q${widget.questionNumber}',
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
              Container(
                margin: const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                    onPressed: playAudio,
                  ),
                ),
              ),
              new Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  controller: widget.userInputController,
                  onSubmitted: (input) {
                    widget.showAnswer();
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter the word you heard',
                    filled: true,
                    fillColor: Colors.black26,
                    contentPadding:
                        const EdgeInsets.only(bottom: 8.0, top: 8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black26),
                      borderRadius: BorderRadius.circular(25.7),
                    ),
                  ),
                ),
              ),
            ],
          )),
    ));
  }
}
