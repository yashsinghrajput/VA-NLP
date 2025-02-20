import 'package:googleapis/language/v1.dart' as language;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class NLPService {
  static final _scopes = [language.CloudNaturalLanguageApi.cloudLanguageScope];

  Future<Map<String, dynamic>> extractActions(String text) async {

    final credentials = await _getServiceAccountCredentials();
    final client = await auth.clientViaServiceAccount(credentials, _scopes);
    final languageApi = language.CloudNaturalLanguageApi(client);

    final request = language.AnalyzeEntitiesRequest(
      document: language.Document(
        type: "PLAIN_TEXT",
        content: text,
      ),
      encodingType: "UTF8",
    );

    try {
      final response = await languageApi.documents.analyzeEntities(request);

      List<language.Entity> entities = response.entities ?? [];

      String? task;
      String? details;
      String? deadline;

      for (var entity in entities) {

        if (["WORK_OF_ART", "EVENT", "OTHER", "CONSUMER_GOOD"]
            .contains(entity.type)) {
          task ??= entity.name;
        }

        if (["DATE", "NUMBER", "TIME"].contains(entity.type)) {
          deadline ??= entity.name;
        }

        if (entity.type == "OTHER") {
          details = entity.name;
        }
      }

      String? extractedDateTime = _extractDateTime(text);
      if (extractedDateTime != null) {
        deadline = extractedDateTime;
      }

      task ??= _extractTask(text);

      if (task == null) {
        return {};
      }

      Map<String, dynamic> structuredActions = {
        "task": task,
        "details": details ?? "No details provided",
        "deadline": deadline ?? "No deadline provided"
      };

      return structuredActions;
    } catch (e) {
      throw Exception("Failed to process text: $e");
    } finally {
      client.close();
    }
  }

  String _extractTask(String text) {
    String cleanedText = text
        .replaceAll(
            RegExp(
                r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday|today|tomorrow|next\s+\w+|at\s+\d{1,2}(:\d{2})?\s?(AM|PM|am|pm)?)\b',
                caseSensitive: false),
            '')
        .trim();

    return cleanedText;
  }

  String? _extractDateTime(String text) {
    RegExp datePattern = RegExp(
        r'\b(monday|tuesday|wednesday|thursday|friday|saturday|sunday|today|tomorrow|next\s+\w+)\b',
        caseSensitive: false);

    RegExp timePattern = RegExp(r'\b(\d{1,2}(:\d{2})?\s?(AM|PM|am|pm)?)\b',
        caseSensitive: false);

    String? dateMatch = datePattern.firstMatch(text)?.group(0);
    String? timeMatch = timePattern.firstMatch(text)?.group(0);

    if (dateMatch != null && timeMatch != null) {
      return "$dateMatch at $timeMatch";
    } else if (dateMatch != null) {
      return dateMatch;
    } else if (timeMatch != null) {
      return timeMatch;
    }

    return null;
  }

  String? _extractPotentialTask(String text) {
    text = text
        .toLowerCase()
        .replaceAll(RegExp(r"\b(remind me to|please|can you)\b"), "")
        .trim();

    List<String> taskIndicators = [
      "submit",
      "complete",
      "finish",
      "send",
      "call",
      "buy",
      "schedule"
    ];
    List<String> words = text.split(" ");

    for (int i = 0; i < words.length; i++) {
      if (taskIndicators.contains(words[i]) && i + 1 < words.length) {
        return words.sublist(i).join(" "); // Extracts everything after the verb
      }
    }
    return null;
  }

  Future<auth.ServiceAccountCredentials> _getServiceAccountCredentials() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/serviceaccount.json');
      final Map<String, dynamic> jsonParsed = jsonDecode(jsonString);

      if (!jsonParsed.containsKey("client_email") ||
          !jsonParsed.containsKey("private_key")) {
        throw Exception("🚨 Missing required fields in service account JSON");
      }

      final credentials = auth.ServiceAccountCredentials(
        jsonParsed["client_email"] as String,
        auth.ClientId("", ""),
        jsonParsed["private_key"] as String,
      );

      return credentials;
    } catch (e) {
      throw Exception("Failed to load credentials: $e");
    }
  }
}
