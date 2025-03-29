import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/flag_data.dart';
import '../../network/local/cache_helper.dart';
import 'package:audioplayers/audioplayers.dart';

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

  final player = AudioPlayer();
  final player2 = AudioPlayer();

  @override
  void initState() {
    super.initState();
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
        title: Text('Score: $score', style: Theme.of(context).textTheme.titleLarge),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 600;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          currentFlagPath,
                          width: isWide ? 450 : 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: options.map((option) => _buildOptionButton(option, isWide)).toList(),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _showRandomFlag,
                      icon: const Icon(Icons.refresh, size: 28),
                      label: const Text('Next Flag', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option, bool isWide) {
    return ElevatedButton(
      onPressed: () => !isAnswered ? _handleAnswer(option) : null,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: isAnswered
            ? (option == currentCountry ? Colors.green : Colors.red)
            : Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: isWide ? 80 : 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(option, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
    Timer(const Duration(seconds: 2), _showRandomFlag);
  }
}
