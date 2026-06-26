import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/steps_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/sleep_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const VitalApp());
}

class VitalApp extends StatelessWidget {
  const VitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootShell(),
    );
  }
}

/// Bottom-nav shell. Home is the dashboard; the other tabs jump straight
/// into the four logging-heavy domains. Medication lives on the dashboard
/// card since it's reminder-driven rather than browsed daily.
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    StepsScreen(),
    WorkoutsScreen(),
    MealsScreen(),
    SleepScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.directions_walk_outlined),
              selectedIcon: Icon(Icons.directions_walk),
              label: 'Steps'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center_outlined),
              selectedIcon: Icon(Icons.fitness_center),
              label: 'Workout'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant),
              label: 'Meals'),
          NavigationDestination(
              icon: Icon(Icons.bedtime_outlined),
              selectedIcon: Icon(Icons.bedtime),
              label: 'Sleep'),
        ],
      ),
    );
  }
}
