import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/schedule_store.dart';
import 'models/pet_store.dart';
import 'screens/auth_page.dart';
import 'screens/getting_started_page.dart';
import 'screens/home_page.dart';
import 'screens/mypets_page.dart';
import 'screens/calendar_page.dart';
import 'screens/alerts_page.dart';
import 'screens/contact_page.dart'; 

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScheduleStore()),
        ChangeNotifierProvider(create: (_) => PetStore()),
      ],
      child: MaterialApp(
        title: 'PetCare', // changed app name
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.green),
        home: const LoadingScreen(),
        routes: {
          '/auth': (c) => const AuthPage(),
          '/home': (c) => const HomePage(),
          '/mypets': (c) => const MyPetsPage(),
          '/calendar': (c) => const CalendarPage(),
          '/alerts': (c) => const AlertsPage(),
          '/contact': (c) => const ContactPage(),
        },
      ),
    );
  }
}

// Simple loading / splash screen that shows an image for 3 seconds then navigates.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // wait 3 seconds then navigate to GettingStartedPage
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const GettingStartedPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Use the image asset (ensure it is added to pubspec and path matches)
                Image.asset(
                  'assets/images/logo.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
