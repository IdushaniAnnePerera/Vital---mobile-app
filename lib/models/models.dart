/// Data models for Vital. Each maps to a SQLite table row.

class StepEntry {
  final int? id;
  final String date; // yyyy-MM-dd
  final int steps;

  StepEntry({this.id, required this.date, required this.steps});

  Map<String, dynamic> toMap() => {'id': id, 'date': date, 'steps': steps};

  factory StepEntry.fromMap(Map<String, dynamic> m) =>
      StepEntry(id: m['id'], date: m['date'], steps: m['steps']);
}

class Workout {
  final int? id;
  final String date;
  final String type; // e.g. Run, Strength, Yoga
  final int durationMin;
  final int calories;

  Workout({
    this.id,
    required this.date,
    required this.type,
    required this.durationMin,
    required this.calories,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'type': type,
        'durationMin': durationMin,
        'calories': calories,
      };

  factory Workout.fromMap(Map<String, dynamic> m) => Workout(
        id: m['id'],
        date: m['date'],
        type: m['type'],
        durationMin: m['durationMin'],
        calories: m['calories'],
      );
}

class Meal {
  final int? id;
  final String date;
  final String name;
  final String mealType; // Breakfast, Lunch, Dinner, Snack
  final int calories;

  Meal({
    this.id,
    required this.date,
    required this.name,
    required this.mealType,
    required this.calories,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date,
        'name': name,
        'mealType': mealType,
        'calories': calories,
      };

  factory Meal.fromMap(Map<String, dynamic> m) => Meal(
        id: m['id'],
        date: m['date'],
        name: m['name'],
        mealType: m['mealType'],
        calories: m['calories'],
      );
}

class Medication {
  final int? id;
  final String name;
  final String dosage;
  final int hour; // reminder time
  final int minute;
  final bool active;

  Medication({
    this.id,
    required this.name,
    required this.dosage,
    required this.hour,
    required this.minute,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dosage': dosage,
        'hour': hour,
        'minute': minute,
        'active': active ? 1 : 0,
      };

  factory Medication.fromMap(Map<String, dynamic> m) => Medication(
        id: m['id'],
        name: m['name'],
        dosage: m['dosage'],
        hour: m['hour'],
        minute: m['minute'],
        active: m['active'] == 1,
      );
}

class SleepEntry {
  final int? id;
  final String date; // the morning you woke
  final double hours;
  final int quality; // 1–5

  SleepEntry({
    this.id,
    required this.date,
    required this.hours,
    required this.quality,
  });

  Map<String, dynamic> toMap() =>
      {'id': id, 'date': date, 'hours': hours, 'quality': quality};

  factory SleepEntry.fromMap(Map<String, dynamic> m) => SleepEntry(
        id: m['id'],
        date: m['date'],
        hours: (m['hours'] as num).toDouble(),
        quality: m['quality'],
      );
}
