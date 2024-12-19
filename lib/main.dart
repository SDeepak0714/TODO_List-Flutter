import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'package:dice_game/dice_screen.dart';

void main() => runApp(DiceRollerApp());

class DiceRollerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dice Roller',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreenWithDelay(),
    );
  }
}

// StatefulWidget to manage the delay and navigation logic
class SplashScreenWithDelay extends StatefulWidget {
  @override
  _SplashScreenWithDelayState createState() => _SplashScreenWithDelayState();
}

class _SplashScreenWithDelayState extends State<SplashScreenWithDelay> {
  @override
  void initState() {
    super.initState();
    // Navigate to DiceScreen after a delay of 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      // Check if the widget is still mounted before navigation
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DiceScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen();
  }
}
