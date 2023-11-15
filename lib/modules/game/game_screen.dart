import 'dart:async';
import 'dart:math';
import 'package:flag_master/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import '../../data/flag_data.dart';
import '../../network/local/cache_helper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String currentCountry = '';
  String currentFlagPath = '';
  List<String> options = [];
  bool isAnswered = false;
  int score = 0;

  @override
  void initState() {
    super.initState();
    _loadScore(); // Load the score when the screen is initialized
    _showRandomFlag();
  }

  // Load the score from SharedPreferences
  Future<void> _loadScore() async {
    int? savedScore = await CacheHelper.getData(key: 'score');
    if (savedScore != null) {
      setState(() {
        score = savedScore;
      });
    }
  }

  // Save the score to SharedPreferences
  Future<void> _saveScore() async {
    await CacheHelper.saveData(key: 'score', value: score);
  }

  void _showRandomFlag() {
    var random = Random();
    List<String> countryNames = countryFlagPaths.keys.toList();
    String randomCountry = countryNames[random.nextInt(countryNames.length)];

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
        title: Center(child: Text('Score: $score',style: TextStyle(fontFamily: 'futura',fontSize: 20),)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage(currentFlagPath)),
            const SizedBox(height: 30),
            _buildOptionButton(options[0]),
            _buildOptionButton(options[1]),
            _buildOptionButton(options[2]),
            _buildOptionButton(options[3]),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ElevatedButton(
        onPressed: () {
          if (!isAnswered) {
            _handleAnswer(option);
          }
        },
        style: ButtonStyle(
          backgroundColor: isAnswered
              ? (option == currentCountry
              ? MaterialStateProperty.all(Colors.green)
              : MaterialStateProperty.all(Colors.red))
              : MaterialStateProperty.all(MyColors.fire),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Center(child: Text(option,textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontFamily: 'bebas'),)),
        ),
      ),
    );
  }

  void _handleAnswer(String selectedOption) {
    setState(() {
      isAnswered = true;
    });

    if (selectedOption == currentCountry) {
      setState(() {
        score++;
      });
    } else {
      setState(() {
        score--;
      });
    }

    _saveScore(); // Save the score after updating it

    _delayedNextFlag();
  }

  void _delayedNextFlag() {
    Timer(const Duration(seconds: 4), () {
      setState(() {
        _showRandomFlag();
      });
    });
  }
}
