import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService extends GetxController {
  final SpeechToText _speechToText = SpeechToText();

  var isListening = false.obs;
  var timerSeconds = 0.obs;
  var transcribedText = ''.obs;
  var isInitialized = false.obs;
  var errorMessage = ''.obs; 

  @override
  void onInit() {
    super.onInit();
    initSpeech();
  }

  Future<void> initSpeech() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => errorMessage.value = "Error: $error",
      );

      isInitialized.value = available;
      if (!available) errorMessage.value = "Speech recognition not available";
    } catch (e) {
      errorMessage.value = "Initialization failed: $e";
      isInitialized.value = false;
    }
  }

  Future<void> startListening() async {
    errorMessage.value = '';

    if (!isInitialized.value) {
      errorMessage.value = "SpeechToText not initialized";
      return;
    }

    bool hasPermission = await _speechToText.hasPermission;

    if (!hasPermission) {
      errorMessage.value = "Microphone permission denied";
      return;
    }

    try {
      isListening.value = true;
      timerSeconds.value = 0;
      transcribedText.value = "";

      _startTimer();

      await _speechToText.listen(
        onResult: (result) {
          transcribedText.value = _cleanTranscription(result.recognizedWords);
        },
        listenOptions: SpeechListenOptions(
          partialResults: true,
          listenMode: ListenMode.confirmation,
        ),
        onSoundLevelChange: (level) {
        },
      );
    } catch (e) {
      errorMessage.value = "Listening failed: $e";
      await stopListening();
    }
  }

  Future<void> stopListening() async {
    try {
      if (isListening.value) {
        await _speechToText.stop();
        isListening.value = false;
      }
    } catch (e) {
      errorMessage.value = "Stop listening failed: $e";
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (isListening.value) {
        timerSeconds.value++;
        _startTimer();
      }
    });
  }

  String _cleanTranscription(String text) {
    final words = text.split(' ');
    final filteredWords = <String>[];
    String? previousWord;

    for (final word in words) {
      if (word.isNotEmpty && word != previousWord) {
        filteredWords.add(word);
        previousWord = word;
      }
    }

    return filteredWords.join(' ').trim();
  }
}
