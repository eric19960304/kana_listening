import 'package:flutter/material.dart';

import '../models/vocabs.dart'; // includes Vocabs and Vocab classes

class AnswerFrame extends StatelessWidget {
  const AnswerFrame({
    super.key,
    required this.vocab,
    required this.userInputController,
  });

  final Vocab vocab;
  final TextEditingController userInputController;

  @override
  Widget build(BuildContext context) {
    bool isInputCorrect = vocab.isCorrectPronounce(userInputController.text);
    String result = isInputCorrect ? 'O' : 'X';

    return Container(
      child: Expanded(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                vocab.word,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Visibility(
                visible: vocab.hasHiragana(),
                child: Text(
                  vocab.hiragana,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  vocab.romaji,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                '[${vocab.meaning}]',
                style: const TextStyle(color: Colors.grey, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              Visibility(
                visible: userInputController.text.isNotEmpty,
                child: Container(
                  padding: const EdgeInsets.only(top: 45.0, bottom: 15.0),
                  child: Text(
                    'Your input: ${userInputController.text} ($result)',
                    style: TextStyle(
                      color: isInputCorrect ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
