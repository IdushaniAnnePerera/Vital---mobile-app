import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

/// Stores all Vital data in Firestore under users/{uid}/.
/// Data is per-user and syncs across devices automatically.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final _db = FirebaseFirestore.instance;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(_uid).collection(name);

  // ---- Steps ----

  Future<void> upsertSteps(StepEntry e) async {
    if (_uid == null) return;
    await _col('steps').doc(e.date).set({'date': e.date, 'steps': e.steps});
  }

  Future<List<StepEntry>> getSteps({int days = 7}) async {
    if (_uid == null) return [];
    final snap = await _col('steps')
        .orderBy('date', descending: true)
        .limit(days)
        .get();
    return snap.docs
        .map((d) => StepEntry.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  // ---- Workouts ----

  Future<void> addWorkout(Workout w) async {
    if (_uid == null) return;
    await _col('workouts').add(w.toMap());
  }

  Future<List<Workout>> getWorkouts() async {
    if (_uid == null) return [];
    final snap =
        await _col('workouts').orderBy('date', descending: true).get();
    return snap.docs
        .map((d) => Workout.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> deleteWorkout(String id) async {
    if (_uid == null) return;
    await _col('workouts').doc(id).delete();
  }

  // ---- Meals ----

  Future<void> addMeal(Meal m) async {
    if (_uid == null) return;
    await _col('meals').add(m.toMap());
  }

  Future<List<Meal>> getMeals(String date) async {
    if (_uid == null) return [];
    final snap =
        await _col('meals').where('date', isEqualTo: date).get();
    return snap.docs
        .map((d) => Meal.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> deleteMeal(String id) async {
    if (_uid == null) return;
    await _col('meals').doc(id).delete();
  }

  // ---- Medications ----

  Future<String> addMedication(Medication m) async {
    if (_uid == null) return '';
    final ref = await _col('medications').add(m.toMap());
    return ref.id;
  }

  Future<List<Medication>> getMedications() async {
    if (_uid == null) return [];
    final snap = await _col('medications').orderBy('hour').get();
    return snap.docs
        .map((d) => Medication.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  Future<void> deleteMedication(String id) async {
    if (_uid == null) return;
    await _col('medications').doc(id).delete();
  }

  // ---- Sleep ----

  Future<void> upsertSleep(SleepEntry s) async {
    if (_uid == null) return;
    await _col('sleep')
        .doc(s.date)
        .set({'date': s.date, 'hours': s.hours, 'quality': s.quality});
  }

  Future<List<SleepEntry>> getSleep({int days = 7}) async {
    if (_uid == null) return [];
    final snap = await _col('sleep')
        .orderBy('date', descending: true)
        .limit(days)
        .get();
    return snap.docs
        .map((d) => SleepEntry.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }
}
