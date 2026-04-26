import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'helpers/vocabs_loader.dart';
import 'models/vocabs.dart';
import 'views/home_page.dart';
import 'views/loading_frame.dart';

final String appName = "Kana Listening";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  Vocabs? vocabs;
  VocabsLoader? vLoader;
  FlutterTts? tts;

  @override
  void initState() {
    super.initState();

    this.vLoader = VocabsLoader();
    this.tts = FlutterTts();
    _initTTS();
    _testTTS(); // Add debug test
    this.vLoader = VocabsLoader();
    this.vLoader!.load().then((v) {
      setState(() {
        this.vocabs = v;
      });
    });
  }

  Future<void> _initTTS() async {
    if (this.tts == null) return;

    try {
      // Get available languages first
      var languages = await this.tts!.getLanguages;
      print("Available languages: $languages");

      // Get available voices
      var voices = await this.tts!.getVoices;
      print("Available voices: $voices");

      // Try multiple approaches to set Japanese language
      bool japaneseSet = false;

      // Approach 1: Try ja-JP
      try {
        await this.tts!.setLanguage("ja-JP");
        japaneseSet = true;
        print("Successfully set language to ja-JP");
      } catch (e) {
        print("Failed to set ja-JP: $e");
      }

      // Approach 2: Try ja if ja-JP failed
      if (!japaneseSet) {
        try {
          await this.tts!.setLanguage("ja");
          japaneseSet = true;
          print("Successfully set language to ja");
        } catch (e) {
          print("Failed to set ja: $e");
        }
      }

      // Set other TTS parameters
      await this.tts!.setSpeechRate(0.4);
      await this.tts!.setPitch(1.0);
      await this.tts!.setVolume(1.0);
    } catch (e) {
      print("Error initializing TTS: $e");
      // Final fallback
      try {
        await this.tts!.setLanguage("en-US");
        print("Fallback to English TTS");
      } catch (e2) {
        print("All TTS initialization attempts failed: $e2");
      }
    }
  }

  // Debug method to test TTS functionality
  Future<void> _testTTS() async {
    if (this.tts == null) return;

    try {
      // Test different language codes
      var testLanguages = ["ja-JP"];
      for (var lang in testLanguages) {
        try {
          await this.tts!.setLanguage(lang);
          print("Successfully set language to: $lang");
        } catch (e) {
          print("Failed to set language $lang: $e");
        }
      }

      // Test Japanese text specifically
      await this.tts!.setLanguage("ja-JP");
    } catch (e) {
      print("TTS debug test failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.vocabs == null || this.tts == null) {
      return loadingPage();
    }

    return MaterialApp(
      title: appName,
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: HomePage(title: appName, vocabs: this.vocabs!, tts: this.tts!),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget loadingPage() {
    return MaterialApp(
      title: appName,
      theme: ThemeData(brightness: Brightness.dark, primarySwatch: Colors.blue),
      home: const LoadingFrame(),
      debugShowCheckedModeBanner: false,
    );
  }
}
