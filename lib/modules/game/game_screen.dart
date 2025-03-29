import 'dart:async';
import 'dart:math';
import 'package:flag_master/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/flag_data.dart';
import '../../network/local/cache_helper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  String currentCountry = '';
  String currentFlagPath = '';
  List<String> options = [];
  bool isAnswered = false;
  int score = 0;
  final player = AudioPlayer();
  final player2 = AudioPlayer();
  List<String> recentFlags = [];

  @override
  void initState() {
    super.initState();
    player.setVolume(0.3);
    player2.setVolume(0.3);
    _loadScore();
    _showRandomFlag();
  }

  Future<void> _loadScore() async {
    int? savedScore = await CacheHelper.getData(key: 'score');
    if (savedScore != null) {
      setState(() {
        score = savedScore;
      });
    }
  }

  Future<void> _saveScore() async {
    await CacheHelper.saveData(key: 'score', value: score);
  }

  void _showRandomFlag() {
    var random = Random();
    List<String> countryNames = countryFlagPaths.keys.toList();

    String randomCountry;
    do {
      randomCountry = countryNames[random.nextInt(countryNames.length)];
    } while (recentFlags.contains(randomCountry));

    recentFlags.add(randomCountry);
    if (recentFlags.length > 5) {
      recentFlags.removeAt(0);
    }

    options = _getRandomOptions(countryNames, randomCountry);

    setState(() {
      currentCountry = randomCountry;
      currentFlagPath = countryFlagPaths[randomCountry]!;
      isAnswered = false;
    });
  }

  List<String> _getRandomOptions(List<String> allOptions, String correctOption) {
    var random = Random();
    List<String> randomOptions = [correctOption];

    while (randomOptions.length < 4) {
      String randomOption = allOptions[random.nextInt(allOptions.length)];
      if (!randomOptions.contains(randomOption)) {
        randomOptions.add(randomOption);
      }
    }

    randomOptions.shuffle();

    return randomOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Score: $score',
            style: TextStyle(
              fontFamily: 'futura',
              fontSize: 24,
              color: MyColors.blackColor,
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(-0.2),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(currentFlagPath, width: 400, height: 300),
                ),
              ),
              const SizedBox(width: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: options.map((option) => _buildOptionButton(option)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    bool isCorrect = option == currentCountry;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: isAnswered
                ? (isCorrect ? [Colors.green, Colors.lightGreen] : [Colors.red, Colors.redAccent])
                : [MyColors.blackGreyColor, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: isAnswered ? null : () => _handleAnswer(option),
          child: SizedBox(
            width: 250,
            height: 50,
            child: Center(
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'bebas',
                  foreground: Paint()
                    ..style = PaintingStyle.fill
                    ..strokeWidth = 0.5
                    ..color = MyColors.whiteColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAnswer(String selectedOption) async {
    setState(() {
      isAnswered = true;
    });

    if (selectedOption == currentCountry) {
      setState(() {
        score++;
      });
      await player.play(AssetSource('sound/correct.mp3'));
    } else {
      setState(() {
        score--;
      });
      await player2.play(AssetSource('sound/wrong.mp3'));
    }

    _saveScore();

    _delayedNextFlag();
  }

  void _delayedNextFlag() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showRandomFlag();
      });
    });
  }
}
