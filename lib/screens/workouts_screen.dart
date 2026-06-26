import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _db = DatabaseService.instance;
  List<Workout> _workouts = [];

  static const _types = ['Run', 'Strength', 'Cycling', 'Yoga', 'Swim', 'Walk'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final w = await _db.getWorkouts();
    setState(() => _workouts = w);
  }

  Future<void> _addWorkout() async {
    String type = _types.first;
    final durationCtrl = TextEditingController();
    final calCtrl = TextEditingController();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plan a workout',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _types.map((t) {
                  final sel = t == type;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setSheet(() => type = t),
                    selectedColor: const Color(0x2EF2682C), // workout @ 18%
                    labelStyle: TextStyle(
                      color: sel ? AppColors.workout : AppColors.ink,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories burned',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.workout),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Add workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true) {
      await _db.addWorkout(Workout(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        type: type,
        durationMin: int.tryParse(durationCtrl.text) ?? 0,
        calories: int.tryParse(calCtrl.text) ?? 0,
      ));
      _load();
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'Run':
        return Icons.directions_run;
      case 'Strength':
        return Icons.fitness_center;
      case 'Cycling':
        return Icons.directions_bike;
      case 'Yoga':
        return Icons.self_improvement;
      case 'Swim':
        return Icons.pool;
      default:
        return Icons.directions_walk;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCals =
        _workouts.fold<int>(0, (sum, w) => sum + w.calories);
    final totalMin =
        _workouts.fold<int>(0, (sum, w) => sum + w.durationMin);

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.workout,
        onPressed: _addWorkout,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'All time',
            child: Row(
              children: [
                Expanded(
                  child: StatBlock(
                    value: '$totalMin',
                    unit: 'min',
                    caption: 'Total active time',
                    color: AppColors.workout,
                  ),
                ),
                Expanded(
                  child: StatBlock(
                    value: NumberFormat.decimalPattern().format(totalCals),
                    unit: 'kcal',
                    caption: 'Total burned',
                    color: AppColors.workout,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('History',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_workouts.isEmpty)
            const Card(
              child: EmptyState(
                  icon: Icons.fitness_center,
                  message: 'No workouts yet. Plan your first one.'),
            )
          else
            ..._workouts.map((w) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0x24F2682C), // workout @ 14%
                        child: Icon(_iconFor(w.type),
                            color: AppColors.workout),
                      ),
                      title: Text(w.type,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      subtitle: Text(
                          '${w.durationMin} min · ${w.calories} kcal · ${w.date}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.inkSoft),
                        onPressed: () async {
                          await _db.deleteWorkout(w.id!);
                          _load();
                        },
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
