import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/flag_data.dart';
import '../../network/local/cache_helper.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  String currentCountry = '';
  String currentFlagPath = '';
  List<String> options = [];
  bool isAnswered = false;
  bool isLoading = false;
  int score = 0;
  int questionNumber = 1;
  int streak = 0;
  int bestStreak = 0;

  final player = AudioPlayer();
  final player2 = AudioPlayer();
  List<String> recentFlags = [];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupAudio();
    _loadGameData();
    _showRandomFlag();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _setupAudio() {
    player.setVolume(0.3);
    player2.setVolume(0.3);
  }

  Future<void> _loadGameData() async {
    final savedScore = await CacheHelper.getData(key: 'score');
    final savedBestStreak = await CacheHelper.getData(key: 'best_streak');

    if (mounted) {
      setState(() {
        score = savedScore ?? 0;
        bestStreak = savedBestStreak ?? 0;
      });
    }
  }

  Future<void> _saveGameData() async {
    await CacheHelper.saveData(key: 'score', value: score);
    await CacheHelper.saveData(key: 'best_streak', value: bestStreak);
  }

  void _showRandomFlag() {
    setState(() {
      isLoading = true;
    });

    final random = math.Random();
    final countryNames = countryFlagPaths.keys.toList();

    String randomCountry;
    do {
      randomCountry = countryNames[random.nextInt(countryNames.length)];
    } while (recentFlags.contains(randomCountry) && countryNames.length > 1);

    recentFlags.add(randomCountry);
    if (recentFlags.length > 10) { // Increased to avoid repetition
      recentFlags.removeAt(0);
    }

    options = _getRandomOptions(countryNames, randomCountry);

    setState(() {
      currentCountry = randomCountry;
      currentFlagPath = countryFlagPaths[randomCountry]!;
      isAnswered = false;
      isLoading = false;
    });

    _animationController.forward(from: 0);
  }

  List<String> _getRandomOptions(List<String> allOptions, String correctOption) {
    final random = math.Random();
    final randomOptions = <String>[correctOption];

    while (randomOptions.length < 4) {
      final randomOption = allOptions[random.nextInt(allOptions.length)];
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: isLargeScreen
          ? _buildLargeScreenHeader()
          : _buildSmallScreenHeader(),
      centerTitle: true,
    );
  }

  Widget _buildLargeScreenHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreCard('Score', score.toString(), Icons.stars, Colors.amber),
        const SizedBox(width: 20),
        _buildScoreCard('Streak', streak.toString(), Icons.local_fire_department, Colors.orange),
        const SizedBox(width: 20),
        _buildScoreCard('Best', bestStreak.toString(), Icons.emoji_events, Colors.purple),
      ],
    );
  }

  Widget _buildSmallScreenHeader() {
    return Column(
      children: [
        Text(
          'Question $questionNumber',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCompactScore('Score: $score', Icons.stars, Colors.amber),
            const SizedBox(width: 15),
            _buildCompactScore('Streak: $streak', Icons.local_fire_department, Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactScore(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 800;
    final isMediumScreen = screenSize.width > 600;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
        child: isLargeScreen
            ? _buildDesktopLayout()
            : _buildMobileLayout(isMediumScreen),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildFlagSection(),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 2,
            child: _buildOptionsSection(isDesktop: true),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(bool isMediumScreen) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Expanded(
            flex: isMediumScreen ? 2 : 1,
            child: _buildFlagSection(),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 1,
            child: _buildOptionsSection(isDesktop: false),
          ),
        ],
      ),
    );
  }

  Widget _buildFlagSection() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Center(
            child: Hero(
              tag: 'flag_$currentCountry',
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 300,
                ),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 2,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        currentFlagPath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.flag,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionsSection({required bool isDesktop}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Which country is this?',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value + (index * 5)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildOptionButton(
                        options[index],
                        index,
                        isDesktop: isDesktop,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(String option, int index, {required bool isDesktop}) {
    final isCorrect = option == currentCountry;
    final isSelected = isAnswered;

    Color buttonColor;
    if (isSelected && isCorrect) {
      buttonColor = Colors.green;
    } else if (isSelected && !isCorrect) {
      buttonColor = Colors.red;
    } else {
      buttonColor = Colors.blue;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: isSelected
              ? (isCorrect
              ? [Colors.green, Colors.lightGreen]
              : [Colors.red, Colors.redAccent])
              : [buttonColor, buttonColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: isAnswered ? null : () => _handleAnswer(option),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (isSelected && isCorrect)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24,
                  )
                else if (isSelected && !isCorrect)
                  const Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAnswer(String selectedOption) async {
    if (isAnswered) return;

    setState(() {
      isAnswered = true;
    });

    final isCorrect = selectedOption == currentCountry;

    if (isCorrect) {
      setState(() {
        score++;
        streak++;
        if (streak > bestStreak) {
          bestStreak = streak;
        }
      });
      await player.play(AssetSource('sound/correct.mp3'));
    } else {
      setState(() {
        score = math.max(0, score - 1); // Prevent negative scores
        streak = 0;
      });
      await player2.play(AssetSource('sound/wrong.mp3'));
    }

    questionNumber++;
    await _saveGameData();
    _delayedNextFlag();
  }

  void _delayedNextFlag() {
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _showRandomFlag();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    player.dispose();
    player2.dispose();
    super.dispose();
  }
}