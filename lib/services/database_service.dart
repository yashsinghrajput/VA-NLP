import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'tasks.db');
    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          details TEXT NOT NULL,
          deadline TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

        await db.execute('''
        CREATE TABLE meeting_summaries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          summary TEXT NOT NULL,
          points TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE meeting_summaries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            summary TEXT NOT NULL,
            points TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        }
      },
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;


    try {
      int id = await db.insert(
        'tasks',
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return id;
    } catch (e) {
      return -1;
    }
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final result = await db.query('tasks');
    return result.map((task) => Task.fromMap(task)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> saveMeetingSummary(String summary, List<String> points) async {
    final db = await database;
    String formattedPoints = points.join(" | ");
    String createdAt = DateTime.now().toIso8601String();

    Map<String, dynamic> summaryData = {
      'summary': summary,
      'points': formattedPoints,
      'createdAt': createdAt,
    };

    return await db.insert('meeting_summaries', summaryData);
  }
}
