import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});
  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final _db = DatabaseService.instance;
  List<Meal> _meals = [];
  final _calorieGoal = 2000;

  static const _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await _db.getMeals(_today);
    setState(() => _meals = m);
  }

  Future<void> _addMeal() async {
    String mealType = _mealTypes.first;
    final nameCtrl = TextEditingController();
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
              Text('Log a meal',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: _mealTypes.map((t) {
                  final sel = t == mealType;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setSheet(() => mealType = t),
                    selectedColor: const Color(0x2E6A8E3C), // meals @ 18%
                    labelStyle: TextStyle(
                      color: sel ? AppColors.meals : AppColors.ink,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'What did you eat?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: calCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(backgroundColor: AppColors.meals),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Add meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved == true && nameCtrl.text.trim().isNotEmpty) {
      await _db.addMeal(Meal(
        date: _today,
        name: nameCtrl.text.trim(),
        mealType: mealType,
        calories: int.tryParse(calCtrl.text) ?? 0,
      ));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _meals.fold<int>(0, (sum, m) => sum + m.calories);
    final progress = (total / _calorieGoal).clamp(0.0, 1.0);
    final remaining = _calorieGoal - total;

    return Scaffold(
      appBar: AppBar(title: const Text('Meals')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.meals,
        onPressed: _addMeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log meal', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Today',
            trailing: Text('Goal $_calorieGoal kcal',
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatBlock(
                  value: NumberFormat.decimalPattern().format(total),
                  unit: 'kcal',
                  caption: remaining >= 0
                      ? '$remaining kcal remaining'
                      : '${-remaining} kcal over goal',
                  color: AppColors.meals,
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.line,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.meals),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text("Today's meals",
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (_meals.isEmpty)
            const Card(
              child: EmptyState(
                  icon: Icons.restaurant,
                  message: 'Nothing logged yet. Add your first meal.'),
            )
          else
            ..._meals.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0x246A8E3C), // meals @ 14%
                        child: Text(m.mealType[0],
                            style: const TextStyle(
                                color: AppColors.meals,
                                fontWeight: FontWeight.w700)),
                      ),
                      title: Text(m.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700)),
                      subtitle: Text('${m.mealType} · ${m.calories} kcal'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.inkSoft),
                        onPressed: () async {
                          await _db.deleteMeal(m.id!);
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
