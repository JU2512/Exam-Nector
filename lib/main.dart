import 'package:flutter/material.dart';
//import 'features/home_screen/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/Onboarding_cards.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  runApp(const ExamNectarApp());
}

class ExamNectarApp extends StatelessWidget {
  const ExamNectarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam-Nectar',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9ED), // Nectar cream
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF4B400), // Nectar gold
        ),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
