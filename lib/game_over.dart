import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart'; // Klavye dinlemek için şart
import 'package:flutter/foundation.dart';
import 'high_score_manager.dart';
import 'package:collection/collection.dart';

class GameOverScreen extends StatefulWidget {
  final String playerName;
  final int score;

  const GameOverScreen({Key? key, required this.playerName, required this.score}) : super(key: key);

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
  }

class _GameOverScreenState extends State<GameOverScreen> {
  late VideoPlayerController _controller;
  late AudioPlayer _audioPlayer;
  final FocusNode _focusNode = FocusNode(); // Enter basınca çıkmak için

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

    // Skoru kaydet ama aynı isim varsa ekleme
    saveIfNewPlayer();

    Future.microtask(() async {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(
          AssetSource('sounds/gameover.mp3'),
          volume: 1.0,
        );
      } catch (error) {
        debugPrint('Ses oynatılırken hata: $error');
      }
    });

    _controller = VideoPlayerController.asset('assets/video/snakevideo.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      }).catchError((error) {
        debugPrint('Video başlatılamadı: $error');
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  void saveIfNewPlayer() async {
    final allScores = await HighScoreManager.getTopScores();

    final existingPlayer = allScores.firstWhereOrNull(
          (e) => e.name == widget.playerName,
    );

    if (existingPlayer == null) {
      // Yeni oyuncu, doğrudan kaydet
      await HighScoreManager.saveScore(widget.playerName, widget.score);
    } else if (widget.score > existingPlayer.score) {
      // Oyuncu zaten var ama bu sefer daha yüksek skor yaptı, güncelle
      await HighScoreManager.updateScore(widget.playerName, widget.score);
    } else {
      debugPrint("Oyuncu zaten var ama daha düşük skor yaptı, güncellenmedi.");
    }

    setState(() {}); // UI güncelle
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    _audioPlayer.dispose(); // sadece dispose, stop etme
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.pop(context);//bir öncceki sayfaya döndürür
            }

          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : Container(color: Colors.black),
            Container(
              color: Colors.black.withAlpha((0.5 * 255).toInt()), // Hafif karartı
            ),
            Center(
              child: FutureBuilder<List<ScoreEntry>>(
                future: HighScoreManager.getTop3Scores(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final top3 = snapshot.data!;
                  final isInTop3 = top3.any((entry) =>
                  entry.name == widget.playerName && entry.score == widget.score);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 20),

                      Text(
                        "🏆 The best 3 Score",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      ...top3.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final score = entry.value;
                        return Text(
                          "$index. ${score.name} :  ${score.score}",
                          style: TextStyle(color: Colors.white),
                        );
                      }).toList(),

                      if (!isInTop3) ...[
                        SizedBox(height: 30),
                        Text(
                          "Your Score: ${widget.playerName}  :  ${widget.score}",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),
                      Text(
                        defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS
                            ? 'Tap to return'
                            : 'Press Enter',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
