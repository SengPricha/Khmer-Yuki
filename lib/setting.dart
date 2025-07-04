import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:yuki/language_provider.dart';
import 'package:yuki/theme_provider.dart';
import 'package:yuki/sound_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          appLocalizations.settings,
          style: GoogleFonts.moul(color: Theme.of(context).textTheme.bodyLarge!.color),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () async {
            try {
              if (SoundController.isSoundOn) {
                await _player
                    .play(AssetSource('audios/open.wav'))
                    .timeout(const Duration(seconds: 1));
              }
            } catch (e) {
              print("🔴 Error playing sound: $e");
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(5),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                themeProvider.isDarkMode
                    ? appLocalizations.darkMode
                    : appLocalizations.lightMode,
                style: GoogleFonts.siemreap(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              trailing: Switch.adaptive(
                value: themeProvider.isDarkMode,
                onChanged: (value) async {
                  try {
                    if (SoundController.isSoundOn) {
                      await _player
                          .play(AssetSource('audios/open.wav'))
                          .timeout(const Duration(seconds: 1));
                    }
                  } catch (e) {
                    print("🔴 Error playing sound: $e");
                  }
                  themeProvider.toggleTheme(value);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 60),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
            ),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(
                appLocalizations.currentLanguage(
                  languageProvider.locale.languageCode == 'km'
                      ? appLocalizations.khmer
                      : appLocalizations.english,
                ),
                style: GoogleFonts.siemreap(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () => languageProvider.toggleLanguage(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero, 
                  minimumSize: const Size(40, 40), 
                  shape: const CircleBorder(), 
                ),
                child: ClipOval( 
                  child: Image.asset(
                    
                    languageProvider.locale.languageCode == 'km'
                        ? 'assets/images/eng.png' 
                        : 'assets/images/khmer.png', 
                    width: 36, 
                    height: 36, 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}