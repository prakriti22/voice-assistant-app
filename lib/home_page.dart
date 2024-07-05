import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:voice/feature_box.dart';
import 'package:voice/openapi_service.dart';
import 'package:voice/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final flutterTts = FlutterTts();
  final stt.SpeechToText speechToText = stt.SpeechToText();
  bool isListening = false;
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedcontent;
  String? generateimageuri;
  String response = '';
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize(
      onError: (error) => print('Error: $error'),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> startListening() async {
    await speechToText.listen(
      onResult: (result) => setState(() {
        lastWords = result.recognizedWords;
      }),
    );
    setState(() {
      isListening = true;
    });
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {
      isListening = false;
    });

    // Call OpenAIService with the recognized words
    String result = await openAIService.isArtPromptAPI(lastWords);
    setState(() {
      response = result; // Store the result to display it
    });
  }

  Future<void> systemspeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    speechToText
        .cancel(); // Cancel the speech recognition when disposing the widget
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('Assistant')),
        centerTitle: true,
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image:
                              AssetImage('assets/images/virtualAssistant.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Chat container
            FadeInRight(
              child: Visibility(
                visible: generateimageuri == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.borderColor),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedcontent == null
                          ? 'How can I help'
                          : generatedcontent!,
                      style: TextStyle(
                        color: Pallete.mainFontColor,
                        fontSize: generatedcontent == null ? 25 : 18,
                        fontFamily: 'Cera Pro',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Display the response
            if (response.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                  top: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Pallete.borderColor),
                  borderRadius: BorderRadius.circular(20).copyWith(
                    topLeft: Radius.zero,
                  ),
                ),
                child: Text(
                  response,
                  style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontFamily: 'Cera Pro',
                      fontSize: generatedcontent == null ? 25 : 18),
                ),
              ),
            if (generateimageuri != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generateimageuri!),
                ),
              ),
            // Suggestions text
            SlideInLeft(
              child: Visibility(
                visible: generatedcontent == null && generateimageuri == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few suggestions',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Features
            Visibility(
              visible: generatedcontent == null && generateimageuri == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descripText: 'Optimal way to stay organized with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: delay + start),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descripText:
                          'Get creative and generate top-notch images with Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: delay + delay + start),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descripText:
                          'Get the best of both Dall-E and ChatGPT with a voice powered assistant',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(microseconds: start + delay + delay),
        child: FloatingActionButton(
          onPressed: () async {
            if (speechToText.isAvailable && !speechToText.isListening) {
              await startListening();
            } else if (speechToText.isListening) {
              final speech = await openAIService.isArtPromptAPI(lastWords);
              if (speech.contains('https')) {
                generateimageuri = speech;
                generatedcontent = null;
                setState(() {});
              } else {
                generateimageuri = null;
                generatedcontent = speech;
                await systemspeak(speech);
                setState(() {});
              }

              await systemspeak(speech);
              await stopListening();
            } else {
              await initSpeechToText();
            }
          },
          child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
        ),
      ),
    );
  }
}
