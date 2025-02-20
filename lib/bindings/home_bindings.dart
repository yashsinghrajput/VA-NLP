import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../services/speech_service.dart';
import '../services/database_service.dart';
import '../services/nlp_service.dart';
import '../services/calendar_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<SpeechService>(() => SpeechService());
    Get.lazyPut<DatabaseService>(() => DatabaseService());
    Get.lazyPut<NLPService>(() => NLPService());
    Get.lazyPut<CalendarService>(() => CalendarService());
  }
}
