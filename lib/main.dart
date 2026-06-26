import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/meals_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/steps_screen.dart';
import 'screens/workouts_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: StreamBuilder<User?>(
        stream: AuthService.instance.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _Splash();
          }
          return snapshot.hasData ? const RootShell() : const LoginScreen();
        },
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 56, color: AppColors.teal),
            SizedBox(height: 16),
            Text(
              'Vital',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppColors.teal,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    StepsScreen(),
    WorkoutsScreen(),
    MealsScreen(),
    SleepScreen(),
  ];

  static const _destinations = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Home'),
    (Icons.directions_walk_outlined, Icons.directions_walk_rounded, 'Steps'),
    (Icons.fitness_center_outlined, Icons.fitness_center_rounded, 'Workout'),
    (Icons.restaurant_outlined, Icons.restaurant_rounded, 'Meals'),
    (Icons.bedtime_outlined, Icons.bedtime_rounded, 'Sleep'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              useIndicator: true,
              indicatorColor: AppColors.teal.withOpacity(0.12),
              backgroundColor: AppColors.surface,
              leading: const SizedBox(height: 8),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _AvatarMenu(),
                  ),
                ),
              ),
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2),
                        label: Text(d.$3),
                      ))
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1,
                color: AppColors.line),
            Expanded(
              child: IndexedStack(index: _index, children: _pages),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.$1),
                  selectedIcon: Icon(d.$2),
                  label: d.$3,
                ))
            .toList(),
      ),
    );
  }
}

class _AvatarMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(60, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user?.displayName ?? 'User',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.ink)),
              Text(user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.inkSoft)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'signout',
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18, color: AppColors.inkSoft),
            SizedBox(width: 10),
            Text('Sign out'),
          ]),
        ),
      ],
      onSelected: (v) async {
        if (v == 'signout') await AuthService.instance.signOut();
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.teal.withOpacity(0.12),
        backgroundImage: user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : null,
        child: user?.photoURL == null
            ? const Icon(Icons.person_rounded,
                color: AppColors.teal, size: 22)
            : null,
      ),
    );
  }
}
