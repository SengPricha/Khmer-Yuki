import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuki/ad_video_page.dart';
import 'package:yuki/sound_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> animalImages = [
    'assets/images/rat.png',
    'assets/images/ox.png',
    'assets/images/tiger.png',
    'assets/images/rabbit.png',
    'assets/images/dragon.png',
    'assets/images/snake.png',
    'assets/images/horse.png',
    'assets/images/goat.png',
    'assets/images/monkey.png',
    'assets/images/rooster.png',
    'assets/images/dog.png',
    'assets/images/pig.png',
  ];

  final Map<int, List<int>> betsByAnimal = {};
  int? resultIndex;
  int userMoney = 100000;

  int selectedBetAmount = 10000;

  final List<int> moneyOptions = [
    100,
    200,
    500,
    1000,
    2000,
    5000,
    10000,
    15000,
    20000,
    30000,
    50000,
    100000,
    200000,
  ];

  String _getMoneyImage(int amount) {
    switch (amount) {
      case 100:
        return 'assets/images/100.png';
      case 200:
        return 'assets/images/200.png';
      case 500:
        return 'assets/images/500.png';
      case 1000:
        return 'assets/images/1000.png';
      case 2000:
        return 'assets/images/2000.png';
      case 5000:
        return 'assets/images/5000.png';
      case 10000:
        return 'assets/images/10000.png';
      case 15000:
        return 'assets/images/15000.png';
      case 20000:
        return 'assets/images/20000.png';
      case 30000:
        return 'assets/images/30000.png';
      case 50000:
        return 'assets/images/50000.png';
      case 100000:
        return 'assets/images/100000.png';
      case 200000:
        return 'assets/images/200000.png';
      default:
        return 'assets/images/200000.png';
    }
  }

  final AudioPlayer _player = AudioPlayer();

  bool isSoundOn = SoundController.isSoundOn;

  Future<void> _playResultSound(bool isWin) async {
    if (!SoundController.isSoundOn) {
      print("🔇 Sound is off");
      return;
    }

    final soundFile = isWin ? 'audios/win.wav' : 'audios/lose.wav';

    try {
      await _player.setVolume(1.0); // optional
      await _player.play(AssetSource(soundFile));
      print("🔊 Playing: $soundFile");
    } catch (e) {
      print("🔴 Failed to play result sound: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    saveData();
    _player.dispose();
    super.dispose();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userMoney', userMoney);
    await prefs.setString('betsByAnimal', jsonEncode(betsByAnimal));
    print('Data saved: Money=$userMoney, Bets=$betsByAnimal');
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMoney = prefs.getInt('userMoney');
    final savedBets = prefs.getString('betsByAnimal');

    if (savedMoney != null) {
      userMoney = savedMoney;
    } else {
      userMoney = 100000;
    }

    if (savedBets != null) {
      try {
        final decoded = jsonDecode(savedBets) as Map<String, dynamic>;
        betsByAnimal.clear();
        decoded.forEach((key, value) {
          betsByAnimal[int.parse(key)] = (value as List<dynamic>).cast<int>();
        });
      } catch (e) {
        print('Error decoding saved bets: $e');
        betsByAnimal.clear();
      }
    }
    print('Data loaded: Money=$userMoney, Bets=$betsByAnimal');
    setState(() {});
  }

  String getAnimalName(int index) {
    const names = [
      "ជូត",
      "ឆ្លូវ",
      "ខាល",
      "ថោះ",
      "រោង",
      "ម្សាញ់",
      "មមីរ",
      "មមែ",
      "វក",
      "រកា",
      "ច",
      "កុរ",
    ];
    return names[index];
  }

  int _getTotalBetAmountForAnimal(int index) {
    return (betsByAnimal[index] ?? []).fold(0, (sum, amount) => sum + amount);
  }

  void handleAnimalTap(int index) async {
    final appLocalizations = AppLocalizations.of(context)!;
    print('Attempting to place bet on index $index');
    print(
      'Current userMoney: $userMoney, selectedBetAmount: $selectedBetAmount',
    );

    if (userMoney >= selectedBetAmount) {
      try {
        if (SoundController.isSoundOn) {
          await _player
              .play(AssetSource('audios/click.wav'))
              .timeout(Duration(seconds: 1));
        }
      } catch (e) {
        print("🔴 Error playing sound: $e");
      }

      setState(() {
        userMoney -= selectedBetAmount;
        betsByAnimal.putIfAbsent(index, () => []).add(selectedBetAmount);
        saveData();
      });
      print('Bet placed successfully on index $index. New money: $userMoney');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.titleMoney,
            style: GoogleFonts.koulen(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      print('Not enough money to place bet!');
    }
  }

  void _showMoneySelectorDialog() {
    final appLocalizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appLocalizations.selectMoney,
                  style: GoogleFonts.koulen(fontSize: 20),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    moneyOptions.map((amount) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBetAmount = amount;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  selectedBetAmount == amount
                                      ? Colors.green
                                      : Colors.grey,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            'assets/images/${amount}.png',
                            width: 80,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appLocalizations.close),
              ),
            ],
          ),
    );
  }

  void playGame() async {
    final appLocalizations = AppLocalizations.of(context)!;
    if (betsByAnimal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appLocalizations.txtMoney,
            style: GoogleFonts.koulen(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      resultIndex = Random().nextInt(animalImages.length);
    });

    await Future.delayed(const Duration(milliseconds: 800));
    int totalBetOnWinningAnimal = _getTotalBetAmountForAnimal(resultIndex!);

    await _playResultSound(totalBetOnWinningAnimal > 0);
    int winnings = totalBetOnWinningAnimal * 11;

    await showDialog(
      context: context,
      builder: (_) {
        final appLocalizations = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(
            totalBetOnWinningAnimal > 0
                ? appLocalizations.youwin
                : appLocalizations.youlose,
            style: GoogleFonts.koulen(fontSize: 30),
          ),
          content: Text(
            totalBetOnWinningAnimal > 0
                ? appLocalizations.betWonMessage(_formatMoney(winnings))
                : appLocalizations.txtbox,
            style: GoogleFonts.fasthand(fontSize: 20),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                appLocalizations.close,
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );

    setState(() {
      if (totalBetOnWinningAnimal > 0) userMoney += winnings;
      betsByAnimal.clear();
      saveData();
    });
  }

  void resetGame() {
    final appLocalizations = AppLocalizations.of(context)!;
    setState(() {
      resultIndex = null;
      betsByAnimal.clear();
      saveData();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appLocalizations.ready,
          style: GoogleFonts.koulen(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatMoney(int money) {
    return money.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;
    double boxSize = screenHeight / 3.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child:
                  isDarkMode
                      ? Container(key: ValueKey('dark'), color: Colors.black)
                      : Image.asset(
                        'assets/images/bg.png',
                        key: ValueKey('light'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                try {
                                  if (SoundController.isSoundOn) {
                                    await _player
                                        .play(AssetSource('audios/open.wav'))
                                        .timeout(Duration(seconds: 1));
                                  }
                                } catch (e) {
                                  print("Error playing sound: $e");
                                }
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                            Expanded(
                              child: Text(
                                appLocalizations.title,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.moulpali(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 6,
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(animalImages.length, (
                              index,
                            ) {
                              return GestureDetector(
                                onTap: () => handleAnimalTap(index),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: boxSize,
                                      height: boxSize,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              getAnimalName(index),
                                              style: GoogleFonts.moul(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                  ),
                                              child: Image.asset(
                                                animalImages[index],
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 2,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  '${_formatMoney(_getTotalBetAmountForAnimal(index))} ៛',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (betsByAnimal[index] != null &&
                                        betsByAnimal[index]!.isNotEmpty)
                                      Positioned(
                                        bottom: 25,
                                        child: SizedBox(
                                          width: 40,
                                          height:
                                              40 +
                                              ((betsByAnimal[index]?.length ??
                                                          1) -
                                                      1) *
                                                  6.0,
                                          child: Stack(
                                            clipBehavior: Clip.none,
                                            children: List.generate(
                                              betsByAnimal[index]!.length,
                                              (i) {
                                                final betAmount =
                                                    betsByAnimal[index]![i];
                                                return Positioned(
                                                  bottom: i * 6.0,
                                                  child: Image.asset(
                                                    _getMoneyImage(betAmount),
                                                    width: 40,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AdVideoPage(
                                          onAdCompleted: () {
                                            setState(() {
                                              userMoney += 50000;
                                              saveData();
                                            });
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  appLocalizations.getmoney,
                                                  style: GoogleFonts.koulen(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                backgroundColor: Colors.green,
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add_circle_outline),
                            ),
                            Text(
                              appLocalizations.yourmoney,
                              style: GoogleFonts.moul(
                                fontSize: 16,
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyLarge!.color,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: _showMoneySelectorDialog,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/${selectedBetAmount}.png',
                                width: 60,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${_formatMoney(userMoney)} ៛",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge!.color,
                          ),
                        ),
                        if (userMoney == 0)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => AdVideoPage(
                                        onAdCompleted: () {
                                          setState(() {
                                            userMoney += 50000;
                                            saveData();
                                          });
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                appLocalizations.getmoney,
                                                style: GoogleFonts.koulen(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              backgroundColor: Colors.green,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              appLocalizations.addmoney,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        const SizedBox(height: 5),
                        Container(
                          width: boxSize * 0.8,
                          height: boxSize * 0.8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(
                              color:
                                  resultIndex != null
                                      ? Colors.amber
                                      : Colors.grey,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow:
                                resultIndex != null
                                    ? [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.amber.withOpacity(0.6),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                    : [],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 800),
                            switchInCurve: Curves.easeInOutCubic,
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                            ) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child:
                                resultIndex != null
                                    ? Image.asset(
                                      animalImages[resultIndex!],
                                      key: ValueKey<int>(resultIndex!),
                                    )
                                    : Container(
                                      key: const ValueKey<String>('no_result'),
                                      alignment: Alignment.center,
                                      child: Text(
                                        appLocalizations.result,
                                        style: GoogleFonts.koulen(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyLarge!.color,
                                        ),
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    if (SoundController.isSoundOn) {
                                      await _player
                                          .play(AssetSource('audios/start.wav'))
                                          .timeout(Duration(seconds: 1));
                                    }
                                  } catch (e) {
                                    print("🔴 Error playing sound: $e");
                                  }
                                  playGame();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                ),
                                child: Text(
                                  appLocalizations.open,
                                  style: GoogleFonts.koulen(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    if (SoundController.isSoundOn) {
                                      await _player
                                          .play(AssetSource('audios/start.wav'))
                                          .timeout(Duration(seconds: 1));
                                    }
                                  } catch (e) {
                                    print("🔴 Error playing sound: $e");
                                  }
                                  resetGame();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                ),
                                child: Text(
                                  appLocalizations.restart,
                                  style: GoogleFonts.koulen(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
