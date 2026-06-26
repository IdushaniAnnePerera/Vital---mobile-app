import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'steps_screen.dart';
import 'workouts_screen.dart';
import 'meals_screen.dart';
import 'meds_screen.dart';
import 'sleep_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseService.instance;
  int _steps = 0;
  int _calories = 0;
  double _sleep = 0;
  int _medCount = 0;

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final steps = await _db.getSteps(days: 1);
    final meals = await _db.getMeals(_today);
    final sleep = await _db.getSleep(days: 1);
    final meds = await _db.getMedications();
    setState(() {
      _steps = steps.where((e) => e.date == _today).fold(0, (a, e) => a + e.steps);
      _calories = meals.fold(0, (a, m) => a + m.calories);
      _sleep = sleep.where((e) => e.date == _today).fold(0.0, (a, e) => a + e.hours);
      _medCount = meds.length;
    });
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting();
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(greeting,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.inkSoft)),
              const SizedBox(height: 2),
              Text('Your day',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.05,
                children: [
                  _DomainCard(
                    title: 'Steps',
                    value: NumberFormat.decimalPattern().format(_steps),
                    unit: 'today',
                    icon: Icons.directions_walk,
                    color: AppColors.steps,
                    onTap: () => _open(const StepsScreen()),
                  ),
                  _DomainCard(
                    title: 'Workouts',
                    value: 'Plan',
                    unit: 'a session',
                    icon: Icons.fitness_center,
                    color: AppColors.workout,
                    onTap: () => _open(const WorkoutsScreen()),
                  ),
                  _DomainCard(
                    title: 'Meals',
                    value: '$_calories',
                    unit: 'kcal today',
                    icon: Icons.restaurant,
                    color: AppColors.meals,
                    onTap: () => _open(const MealsScreen()),
                  ),
                  _DomainCard(
                    title: 'Medication',
                    value: '$_medCount',
                    unit: _medCount == 1 ? 'reminder' : 'reminders',
                    icon: Icons.medication,
                    color: AppColors.meds,
                    onTap: () => _open(const MedsScreen()),
                  ),
                  _DomainCard(
                    title: 'Sleep',
                    value: _sleep > 0 ? _sleep.toStringAsFixed(1) : '—',
                    unit: _sleep > 0 ? 'hrs last night' : 'not logged',
                    icon: Icons.bedtime,
                    color: AppColors.sleep,
                    onTap: () => _open(const SleepScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _DomainCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DomainCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: AppColors.ink,
                )),
            Text(unit,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.inkSoft)),
            const SizedBox(height: 4),
            Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
