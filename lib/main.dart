// lib/main.dart
import 'package:flutter/material.dart';

// Services
import 'package:after_hours/services/api_service.dart';

// Core screens (tabs)
import 'package:after_hours/screens/login_page.dart';
import 'package:after_hours/screens/register_page.dart';
import 'package:after_hours/screens/profile_page.dart';
import 'package:after_hours/screens/feed_page.dart';
import 'package:after_hours/screens/friends_page.dart';
import 'package:after_hours/screens/log_drink_page.dart';
import 'package:after_hours/screens/leaderboard_page.dart';
import 'package:after_hours/screens/settings_page.dart';

// Info/utility screens
import 'package:after_hours/screens/view_information_page.dart';
import 'package:after_hours/screens/reset_password_page.dart';
import 'package:after_hours/screens/drinking_safely_page.dart';
import 'package:after_hours/screens/policies_page.dart';
import 'package:after_hours/screens/about_app_page.dart';
import 'package:after_hours/screens/feedback_page.dart';
import 'package:after_hours/screens/contact_page.dart';

// Friends extras (create these if you haven't)
import 'package:after_hours/screens/friend_requests_page.dart';
import 'package:after_hours/screens/friends_search_page.dart';
import 'package:after_hours/screens/friend_profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'After Hours: Ranked',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f0c29),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1c1842),
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 12),
          type: BottomNavigationBarType.fixed,
        ),
      ),

      // Splash/auth gate
      home: AuthWrapper(apiService: apiService),

      // Static routes
      routes: {
        '/login': (_) => LoginPage(apiService: apiService),
        '/register': (_) => RegisterPage(apiService: apiService),

        // Tabs as pushable routes
        '/profile': (_) => ProfilePage(apiService: apiService),
        '/settings': (_) => SettingsPage(apiService: apiService),
        '/feed': (_) => FeedPage(apiService: apiService),
        '/friends': (_) => FriendsPage(apiService: apiService),
        '/log-drink': (_) => LogDrinkPage(apiService: apiService),
        '/ranks': (_) => LeaderboardPage(apiService: apiService),

        // Info/utility
        '/view-information': (_) => ViewInformationPage(apiService: apiService),
        '/reset-password': (_) => ResetPasswordPage(apiService: apiService),
        '/drinking-safely': (_) => DrinkingSafelyPage(apiService: apiService),
        '/policies': (_) => PoliciesPage(apiService: apiService),
        '/about-app': (_) => AboutAppPage(apiService: apiService),
        '/feedback': (_) => FeedbackPage(apiService: apiService),
        '/contact': (_) => ContactPage(apiService: apiService),

        // Friends extras (lists)
        '/friends/requests': (_) => FriendRequestsPage(apiService: apiService),
        '/friends/search': (_) => const FriendsSearchPage(),
      },

      // Dynamic routes (e.g. friend profile by username)
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/friends/profile/') == true) {
          final username = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (_) => FriendProfilePage(
              username: username,
              apiService: apiService,
            ),
          );
        }
        return null;
      },
    );
  }
}

/// Decides where to go at launch based on auth state.
class AuthWrapper extends StatefulWidget {
  final ApiService apiService;
  const AuthWrapper({super.key, required this.apiService});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    widget.apiService.onAuthStateChanged = () {
      if (mounted) setState(() {});
    };
    // Removed bootstrap() call (Option A)
  }

  @override
  void dispose() {
    widget.apiService.onAuthStateChanged = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If authenticated, land on Profile tab (index 4 to match bottom bar)
    return widget.apiService.isAuthenticated
        ? MainAppWrapper(apiService: widget.apiService, initialIndex: 4)
        : LoginPage(apiService: widget.apiService);
  }
}

/// Container for the tabbed app (Feed, Friends, Log Drink, Ranks, Profile)
class MainAppWrapper extends StatefulWidget {
  final ApiService apiService;
  final int initialIndex;
  const MainAppWrapper({
    super.key,
    required this.apiService,
    this.initialIndex = 0,
  });

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _screens = [
      FeedPage(apiService: widget.apiService),
      FriendsPage(apiService: widget.apiService),
      LogDrinkPage(apiService: widget.apiService),
      LeaderboardPage(apiService: widget.apiService),
      ProfilePage(apiService: widget.apiService),
    ];
  }

  void _onTabTapped(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Log Drink',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Ranks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
