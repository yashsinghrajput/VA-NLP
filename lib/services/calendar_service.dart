import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

//provide clientId to use calendar services
class CalendarService {
  Future<void> addEvent(
      String title, DateTime date, String time, String location) async {
    final client = await clientViaUserConsent(
        ClientId(" "), [CalendarApi.calendarScope], (url) {
    });

    final calendarApi = CalendarApi(client);

    List<String> timeParts = time.split(":");
    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = int.tryParse(timeParts[1]) ?? 0;
    DateTime dateTime = DateTime(date.year, date.month, date.day, hour, minute);

    Event event = Event()
      ..summary = title
      ..location = location
      ..start = EventDateTime(dateTime: dateTime.toUtc())
      ..end = EventDateTime(dateTime: dateTime.add(Duration(hours: 1)).toUtc());

    await calendarApi.events.insert(event, "primary");
  }
}
