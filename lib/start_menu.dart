import 'package:flutter/material.dart';
import 'information_page.dart';
import 'game_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'main.dart'; // routeObserver buradan gelecek
import 'package:shared_preferences/shared_preferences.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

class StartMenuPage extends StatefulWidget {
  const StartMenuPage({Key? key}) : super(key: key);

  @override
  State<StartMenuPage> createState() => _StartMenuPageState();
}

class _StartMenuPageState extends State<StartMenuPage> with RouteAware {
  bool _isMusicPlaying = false;
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // Kaydedilmiş kullanıcı adı için pin getirir
  Future<String?> getPinForUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pin_$name');
  }

  // Kullanıcı adı ve PIN kaydeder
  Future<void> saveUserAndPin(String name, String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
    await prefs.setString('pin_$name', pin);
  }

  // Kullanıcı adı var mı kontrol eder
  Future<bool> userExists(String name) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('pin_$name');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _startMusicIfNeeded();
      final savedName = await _getSavedUserName();
      if (savedName != null) {
        _isimController.text = savedName;
      }
    });
  }

  Future<String?> _getSavedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }
  void _startMusicIfNeeded() async {
    if (_audioPlayer.state != PlayerState.playing) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/gamemusic.mp3'));
      setState(() {
        _isMusicPlaying = true;
      });
    }
  }


  Future<void> _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/gamemusic.mp3'));
    }
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _isimController.dispose();
    _pinController.dispose();
    super.dispose();
  }
  @override
  void didPopNext() async {
    if (_audioPlayer.state != PlayerState.playing) {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/gamemusic.mp3'));
      setState(() {
        _isMusicPlaying = true;
      });
    }
  }

  Future<void> _startGame() async {
    String name = _isimController.text.trim();
    String pin = _pinController.text.trim();

    if (name.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter both username and PIN.")),
      );
      return;
    }

    bool exists = await userExists(name);

    if (exists) {
      String? savedPin = await getPinForUser(name);
      if (savedPin != pin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect PIN. Please try again.")),
        );
        return;
      }
      // PIN doğru, giriş yap
    } else {
      // Yeni kullanıcı, kaydet
      await saveUserAndPin(name, pin);
    }

    await saveUserAndPin(name, pin); // Son kullanıcı adı kaydı
    _audioPlayer.stop();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(playerName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/snake_cover.jpeg',
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InformationPage()),
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 10,
            child: IconButton(
              icon: Icon(
                _isMusicPlaying ? Icons.volume_up : Icons.volume_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: _toggleMusic,
            ),
          ),
          Positioned(
            bottom: 180,
            left: 50,
            right: 50,
            child: TextField(
              controller: _isimController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black54,
                hintText: 'UserName',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110,
            left: 50,
            right: 50,
            child: TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black54,
                hintText: 'PIN',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: const Text("Start Game"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
