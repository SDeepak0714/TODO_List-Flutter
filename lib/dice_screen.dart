import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class DiceScreen extends StatefulWidget {
  @override
  _DiceScreenState createState() => _DiceScreenState();
}

class _DiceScreenState extends State<DiceScreen> with SingleTickerProviderStateMixin {
  int _diceNumber = 1;
  int _predictedNumber = 1;
  String _resultMessage = '';
  int _score = 0;
  int _timeLeft = 10;
  late Timer _timer;
  String _difficulty = 'Easy';
  int _highScore = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (_score > _highScore) {
      setState(() {
        _highScore = _score;
      });
      prefs.setInt('highScore', _score);
    }
  }

  void _rollDice() async {
    _controller.forward(from: 0); // Start the dice roll animation
    await Future.delayed(Duration(milliseconds: 500)); // Wait for animation to complete
    setState(() {
      _diceNumber = Random().nextInt(6) + 1; // Generate a random dice number

      // Check the guess based on the selected difficulty
      if (_difficulty == 'Easy' && _predictedNumber == _diceNumber ||
          _difficulty == 'Medium' &&
              (_predictedNumber - 1 <= _diceNumber &&
                  _predictedNumber + 1 >= _diceNumber) ||
          _difficulty == 'Hard' && (_predictedNumber % 2 == _diceNumber % 2)) {
        _resultMessage = '🎉 Correct Guess! +10 Points';
        _score += 10;
      } else {
        _resultMessage = '❌ Wrong Guess! Try Again.';
      }
    });
    _saveHighScore(); // Save the high score if applicable

    // Reset the timer to 10 seconds and restart it
    _timer.cancel(); // Cancel the existing timer
    setState(() {
      _timeLeft = 10; // Reset time left
    });
    _startTimer(); // Restart the timer
  }

  void _updatePrediction(int? predictedNumber) {
    setState(() {
      if (predictedNumber != null) {
        _predictedNumber = predictedNumber;
        _resultMessage = '';
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        setState(() {
          _resultMessage = '⏱️ Time’s Up!';
        });
      }
    });
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _timeLeft = 10;
      _resultMessage = '';
    });
    _startTimer();
  }

  void _shareScore() {
    Share.share('I scored $_score points in the Dice Prediction Game! Can you beat my score?');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Dice Prediction Game'),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: _shareScore,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          width: size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildTimeAndScoreSection(),
                SizedBox(height: 30),
                _buildDiceAnimationSection(),
                SizedBox(height: 30),
                _buildResultMessage(),
                SizedBox(height: 30),
                _buildPredictionSection(),
                SizedBox(height: 30),
                _buildControlsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeAndScoreSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('⏳ Time Left', '$_timeLeft'),
        _buildStatCard('🏆 High Score', '$_highScore'),
        _buildStatCard('⭐ Your Score', '$_score'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildDiceAnimationSection() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + _animation.value * 0.3,
          child: child,
        );
      },
      child: Image.asset(
        'assets/$_diceNumber.png',
        height: 200,
        width: 200,
      ),
    );
  }

  Widget _buildResultMessage() {
    return Text(
      _resultMessage,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPredictionSection() {
    return Container(
      width: 150, 
      // height: 60, // Decreased the width here
      padding: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<int>(
        value: _predictedNumber,
        items: List.generate(
          6,
          (index) => DropdownMenuItem(
            value: index + 1,
            child: Text('Guess: ${index + 1}', style: TextStyle(fontSize: 18)),
          ),
        ),
        onChanged: _updatePrediction,
      ),
    );
  }

  Widget _buildControlsSection() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _rollDice,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amberAccent,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text('🎲 Roll Dice', style: TextStyle(fontSize: 20)),
        ),
        SizedBox(height: 20),
        Container(
          width: 150,  // Decreased the width here
          child: DropdownButton<String>(
            value: _difficulty,
            items: [
              DropdownMenuItem(value: 'Easy', child: Text('Easy')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Hard', child: Text('Hard')),
            ],
            onChanged: (value) {
              setState(() {
                _difficulty = value!;
                _restartGame();
              });
            },
          ),
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: _restartGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text('🔄 Restart Game', style: TextStyle(fontSize: 20)),
        ),
      ],
    );
  }
}
