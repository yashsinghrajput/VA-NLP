import 'package:get/get.dart';
import '../services/speech_service.dart';
import '../services/database_service.dart';
import '../models/task_model.dart';
import '../services/nlp_service.dart';
import '../services/calendar_service.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  final SpeechService speechService = Get.put(SpeechService());
  final DatabaseService dbService = Get.put(DatabaseService());
  final NLPService nlpService = Get.put(NLPService());
  final CalendarService calendarService = Get.put(CalendarService());
  final DatabaseService databaseService = Get.put(DatabaseService());

  var tasks = <Task>[].obs;

  var isProcessing = false.obs;

  @override
  void onInit() {
    fetchTasks();
    super.onInit();
  }

  void fetchTasks() async {
    tasks.value = await dbService.getTasks();
  }

  void addTask(String title, String details, String deadline) async {
    if (title.isEmpty) {
      return;
    }

    String formattedDeadline = deadline.isNotEmpty ? deadline : "No deadline";

    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    Task newTask = Task(
      title: title,
      details: details,
      deadline: formattedDeadline,
      createdAt: now,
    );

    try {
      int result = await dbService.insertTask(newTask);
      if (result > 0) {
        fetchTasks();
      }
    } catch (e) {
      print("❌ Error inserting task: $e");
    }
  }

  Future<void> processTranscription() async {
    isProcessing.value = true;
    String text = speechService.transcribedText.value;

    if (text.isEmpty) {
      isProcessing.value = false;
      return;
    }

    try {
      Map<String, dynamic> extractedActions =
          await nlpService.extractActions(text);

      if (extractedActions.isEmpty) {}

      if (extractedActions["task"] != "No task detected") {
        String task = extractedActions["task"];
        String details = extractedActions["details"];
        String deadline = extractedActions["deadline"];

        addTask(task, details, deadline);
        speechService.transcribedText.value = "";
        speechService.update();
      }

      if (extractedActions["event"] != "No event detected") {
        try {
          String event = extractedActions["event"];
          DateTime date = DateTime.now();
          String time = extractedActions["deadline"];
          String location = "No location provided";

          await calendarService.addEvent(event, date, time, location);
        } catch (e) {}
      }
    } catch (e) {
    } finally {
      isProcessing.value = false;
    }
  }

  void sendMessage(String recipient, String medium, String message) {
    if (medium.toLowerCase() == "email") {
    } else if (medium.toLowerCase() == "sms") {
    } else if (medium.toLowerCase() == "slack") {
    } else {}
  }

  String parseDate(String dateText) {
    try {
      if (dateText.toLowerCase().contains("tomorrow")) {
        return DateFormat("yyyy-MM-dd")
            .format(DateTime.now().add(Duration(days: 1)));
      } else if (dateText.toLowerCase().contains("next Monday")) {
        return DateFormat("yyyy-MM-dd")
            .format(DateTime.now().add(Duration(days: 7)));
      }
      return dateText; // Fallback if not recognized
    } catch (e) {
      return "Unknown date";
    }
  }
}
