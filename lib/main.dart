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

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;

    if (wide) {
      // Sidebar layout for web / wide screens
      return Scaffold(
        body: Row(
          children: [
            // Rail + avatar stacked in a Column
            Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: _go,
                    labelType: NavigationRailLabelType.all,
                    useIndicator: true,
                    // const teal @ 12% alpha
                    indicatorColor: const Color(0x1F0E7C7B),
                    backgroundColor: AppColors.surface,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard_rounded),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.directions_walk_outlined),
                        selectedIcon: Icon(Icons.directions_walk_rounded),
                        label: Text('Steps'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.fitness_center_outlined),
                        selectedIcon: Icon(Icons.fitness_center_rounded),
                        label: Text('Workout'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.restaurant_outlined),
                        selectedIcon: Icon(Icons.restaurant_rounded),
                        label: Text('Meals'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.bedtime_outlined),
                        selectedIcon: Icon(Icons.bedtime_rounded),
                        label: Text('Sleep'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.line),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: _AvatarMenu(),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppColors.line),
            Expanded(
              child: IndexedStack(index: _index, children: _pages),
            ),
          ],
        ),
      );
    }

    // Bottom-bar layout for mobile / narrow screens
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_walk_outlined),
            selectedIcon: Icon(Icons.directions_walk_rounded),
            label: 'Steps',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant_rounded),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.bedtime_outlined),
            selectedIcon: Icon(Icons.bedtime_rounded),
            label: 'Sleep',
          ),
        ],
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
      offset: const Offset(64, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              Icon(Icons.logout_rounded, size: 18, color: AppColors.inkSoft),
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
        radius: 20,
        // const teal @ 12% alpha
        backgroundColor: const Color(0x1F0E7C7B),
        backgroundImage: user?.photoURL != null
            ? NetworkImage(user!.photoURL!)
            : null,
        child: user?.photoURL == null
            ? const Icon(Icons.person_rounded, color: AppColors.teal, size: 22)
            : null,
      ),
    );
  }
}
