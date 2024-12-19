import 'package:shared_preferences/shared_preferences.dart';

Future<int> loadHighScore() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('highScore') ?? 0;
}

Future<void> saveHighScore(int highScore) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('highScore', highScore);
}
