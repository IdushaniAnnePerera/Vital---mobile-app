import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

/// Single SQLite database for all Vital data. One file, five tables.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'vital.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE steps(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            steps INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            durationMin INTEGER NOT NULL,
            calories INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE meals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            name TEXT NOT NULL,
            mealType TEXT NOT NULL,
            calories INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE medications(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            dosage TEXT NOT NULL,
            hour INTEGER NOT NULL,
            minute INTEGER NOT NULL,
            active INTEGER NOT NULL
          )''');
        await db.execute('''
          CREATE TABLE sleep(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            hours REAL NOT NULL,
            quality INTEGER NOT NULL
          )''');
      },
    );
  }

  // ---- Steps ----
  Future<void> upsertSteps(StepEntry e) async {
    final db = await database;
    final existing = await db.query('steps', where: 'date = ?', whereArgs: [e.date]);
    if (existing.isEmpty) {
      await db.insert('steps', e.toMap()..remove('id'));
    } else {
      await db.update('steps', {'steps': e.steps}, where: 'date = ?', whereArgs: [e.date]);
    }
  }

  Future<List<StepEntry>> getSteps({int days = 7}) async {
    final db = await database;
    final rows = await db.query('steps', orderBy: 'date DESC', limit: days);
    return rows.map(StepEntry.fromMap).toList();
  }

  // ---- Workouts ----
  Future<void> addWorkout(Workout w) async {
    final db = await database;
    await db.insert('workouts', w.toMap()..remove('id'));
  }

  Future<List<Workout>> getWorkouts() async {
    final db = await database;
    final rows = await db.query('workouts', orderBy: 'date DESC, id DESC');
    return rows.map(Workout.fromMap).toList();
  }

  Future<void> deleteWorkout(int id) async {
    final db = await database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Meals ----
  Future<void> addMeal(Meal m) async {
    final db = await database;
    await db.insert('meals', m.toMap()..remove('id'));
  }

  Future<List<Meal>> getMeals(String date) async {
    final db = await database;
    final rows = await db.query('meals', where: 'date = ?', whereArgs: [date], orderBy: 'id DESC');
    return rows.map(Meal.fromMap).toList();
  }

  Future<void> deleteMeal(int id) async {
    final db = await database;
    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Medications ----
  Future<int> addMedication(Medication m) async {
    final db = await database;
    return db.insert('medications', m.toMap()..remove('id'));
  }

  Future<List<Medication>> getMedications() async {
    final db = await database;
    final rows = await db.query('medications', orderBy: 'hour, minute');
    return rows.map(Medication.fromMap).toList();
  }

  Future<void> deleteMedication(int id) async {
    final db = await database;
    await db.delete('medications', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Sleep ----
  Future<void> upsertSleep(SleepEntry s) async {
    final db = await database;
    final existing = await db.query('sleep', where: 'date = ?', whereArgs: [s.date]);
    if (existing.isEmpty) {
      await db.insert('sleep', s.toMap()..remove('id'));
    } else {
      await db.update('sleep', {'hours': s.hours, 'quality': s.quality},
          where: 'date = ?', whereArgs: [s.date]);
    }
  }

  Future<List<SleepEntry>> getSleep({int days = 7}) async {
    final db = await database;
    final rows = await db.query('sleep', orderBy: 'date DESC', limit: days);
    return rows.map(SleepEntry.fromMap).toList();
  }
}
