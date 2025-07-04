import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yuki/home.dart';
import 'package:yuki/setting.dart';
import 'package:yuki/sound_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Startpage extends StatefulWidget {
  const Startpage({super.key});

  @override
  State<Startpage> createState() => _StartpageState();
}

class _StartpageState extends State<Startpage> {
  final AudioPlayer _player = AudioPlayer();
  bool isSoundOn = SoundController.isSoundOn;
  void _confirmExit() async {
    if (SoundController.isSoundOn) {
      await _player.play(AssetSource('audios/open.wav'));
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final appLocalizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              appLocalizations.exitText,
              style: GoogleFonts.siemreap(),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  appLocalizations.no,
                  style: GoogleFonts.siemreap(color: Colors.white),
                ),
              ),
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
                onPressed: () => SystemNavigator.pop(),
                child: Text(
                  appLocalizations.yes,
                  style: GoogleFonts.siemreap(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = screenWidth < 400 ? 18 : 24;
    double contentFontSize = screenWidth < 400 ? 11 : 14;
    double buttonTextFontSize = screenWidth < 400 ? 14 : 16;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
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
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 30.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      isSoundOn ? Icons.volume_up : Icons.volume_off,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      size: 33,
                    ),
                    onPressed: () {
                      setState(() {
                        SoundController.toggleSound();
                        isSoundOn = SoundController.isSoundOn;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings,
                      size: 33,
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                    onPressed: () async {
                      try {
                        if (SoundController.isSoundOn) {
                          await _player
                              .play(AssetSource('audios/open.wav'))
                              .timeout(Duration(seconds: 1));
                        }
                      } catch (e) {
                        print("🔴 Error playing sound: $e");
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Setting()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logoicon.png', width: 150),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (SoundController.isSoundOn) {
                        await _player
                            .play(AssetSource('audios/open.wav'))
                            .timeout(Duration(seconds: 1));
                      }
                    } catch (e) {
                      print("🔴 Error playing sound: $e");
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 10,
                    ),
                    side: const BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    appLocalizations.start,
                    style: GoogleFonts.siemreap(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (SoundController.isSoundOn) {
                        await _player
                            .play(AssetSource('audios/open.wav'))
                            .timeout(Duration(seconds: 1));
                      }
                    } catch (e) {
                      print("🔴 Error playing sound: $e");
                    }
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text(
                              appLocalizations.about,
                              style: GoogleFonts.koulen(
                                fontSize: titleFontSize,
                              ),
                            ),
                            content: Text(
                              appLocalizations.aboutText,
                              style: GoogleFonts.battambang(
                                fontSize: contentFontSize,
                              ),
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
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  appLocalizations.close,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: buttonTextFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 10,
                    ),
                    side: const BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    appLocalizations.about,
                    style: GoogleFonts.siemreap(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: _confirmExit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 80,
                      vertical: 10,
                    ),
                    side: const BorderSide(color: Colors.grey, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    appLocalizations.exit,
                    style: GoogleFonts.siemreap(
                      fontSize: 16,
                      color: Colors.white,
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
