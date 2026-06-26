import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import 'meals_screen.dart';
import 'meds_screen.dart';
import 'sleep_screen.dart';
import 'steps_screen.dart';
import 'workouts_screen.dart';

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
    if (!mounted) return;
    setState(() {
      _steps = steps
          .where((e) => e.date == _today)
          .fold(0, (a, e) => a + e.steps);
      _calories = meals.fold(0, (a, m) => a + m.calories);
      _sleep = sleep
          .where((e) => e.date == _today)
          .fold(0.0, (a, e) => a + e.hours);
      _medCount = meds.length;
    });
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'there';
    final greeting = '${_greetingWord()}, $firstName';
    final wide = MediaQuery.of(context).size.width >= 700;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.inkSoft,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Your day',
                              style:
                                  Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d')
                                  .format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.inkSoft,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Avatar + sign-out (always visible; rail layout also shows it)
                      _AccountButton(user: user),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _DomainCard(
                      title: 'Steps',
                      value:
                          NumberFormat.decimalPattern().format(_steps),
                      unit: 'today',
                      icon: Icons.directions_walk_rounded,
                      color: AppColors.steps,
                      onTap: () => _open(const StepsScreen()),
                    ),
                    _DomainCard(
                      title: 'Workouts',
                      value: 'Plan',
                      unit: 'a session',
                      icon: Icons.fitness_center_rounded,
                      color: AppColors.workout,
                      onTap: () => _open(const WorkoutsScreen()),
                    ),
                    _DomainCard(
                      title: 'Meals',
                      value: '$_calories',
                      unit: 'kcal today',
                      icon: Icons.restaurant_rounded,
                      color: AppColors.meals,
                      onTap: () => _open(const MealsScreen()),
                    ),
                    _DomainCard(
                      title: 'Medication',
                      value: '$_medCount',
                      unit: _medCount == 1 ? 'reminder' : 'reminders',
                      icon: Icons.medication_rounded,
                      color: AppColors.meds,
                      onTap: () => _open(const MedsScreen()),
                    ),
                    _DomainCard(
                      title: 'Sleep',
                      value:
                          _sleep > 0 ? _sleep.toStringAsFixed(1) : '—',
                      unit:
                          _sleep > 0 ? 'hrs last night' : 'not logged',
                      icon: Icons.bedtime_rounded,
                      color: AppColors.sleep,
                      onTap: () => _open(const SleepScreen()),
                    ),
                  ]),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: wide ? 3 : 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greetingWord() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _AccountButton extends StatelessWidget {
  final dynamic user;
  const _AccountButton({required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user?.displayName ?? 'User',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.ink),
              ),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.inkSoft),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'signout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded,
                  size: 18, color: AppColors.inkSoft),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      onSelected: (v) async {
        if (v == 'signout') await AuthService.instance.signOut();
      },
      child: CircleAvatar(
        radius: 22,
        // const teal @ 12% alpha
        backgroundColor: const Color(0x1F0E7C7B),
        backgroundImage: (user?.photoURL as String?) != null
            ? NetworkImage(user!.photoURL as String)
            : null,
        child: (user?.photoURL as String?) == null
            ? const Icon(Icons.person_rounded,
                color: AppColors.teal, size: 24)
            : null,
      ),
    );
  }
}

// Extracted helper so _DomainCard can create semi-transparent domain colours
// without calling the deprecated withOpacity method.
Color _domainTint(Color c, int alpha255) => Color.fromARGB(
      alpha255,
      (c.value >> 16) & 0xFF,
      (c.value >> 8) & 0xFF,
      c.value & 0xFF,
    );

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
          boxShadow: [
            BoxShadow(
              color: _domainTint(color, 15), // ~6%
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _domainTint(color, 46), // ~18%
                    _domainTint(color, 26), // ~10%
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: AppColors.ink,
              ),
            ),
            Text(
              unit,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
