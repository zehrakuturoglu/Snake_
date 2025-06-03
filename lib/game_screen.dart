import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'game_over.dart';

class GiftBox {
  final Offset position;
  final bool isGood;
  final String image;

  GiftBox({required this.position, required this.isGood, required this.image});
}

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(playerName: 'UserName'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  final String playerName; // ✅ PARAMETRE EKLENDİ

  const GameScreen({Key? key, required this.playerName}) : super(key: key);


  @override
  _GameScreenState createState() => _GameScreenState();
}
  List<Offset> walls = [];
  List<Offset> portals = [];
  Offset? portalA;
  Offset? portalB;


class _GameScreenState extends State<GameScreen> {
  static const int rowCount = 20;
  static const int colCount = 20;
  static const double cellSize = 20;

  List<Offset> snake = [const Offset(5, 5)];
  Offset food = const Offset(10, 10);
  String direction = 'right';
  Color snakeColor = Colors.green;
  bool isGameOver = false;
  bool isGameRunning = false;
  Timer? gameTimer;
  FocusNode focusNode = FocusNode();
  int score = 0;
  bool isSoundOn = true; // Ses açık mı kapalı mı kontrolü

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> playSound(String assetPath) async {
    if (!isSoundOn) return; // Ses kapalıysa çık
    await _audioPlayer.play(AssetSource(assetPath));
  }


  GiftBox? currentGiftBox; // 🎁 Aktif hediye kutusu
  final List<String> giftImages = [ // 🎁 Kullanılacak görseller
    'assets/images/gift.png',
    'assets/images/gift2.png',
    'assets/images/gift3.png',
  ];

  final random = Random();
  final List<String> foodImages = [
    'assets/images/ananas.jpg',
    'assets/images/armut.png',
    'assets/images/elma.png',
    'assets/images/karpuz.png',
    'assets/images/kiraz.png',
    'assets/images/kivi.png',
    'assets/images/portakal.png',
    'assets/images/çilek.png',

  ];
  late String currentFoodImage;

  @override
  void initState() {
    super.initState();
    spawnSnake();

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!isGameOver && isGameRunning) {
        setState(() {
          spawnFood();
        });
      }
    });

    // GIFT spawn her 10 saniyede bir
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!isGameOver && isGameRunning && currentGiftBox == null) {
        spawnGiftBox(); // 🎁 kutu çıkar
      }
    });
    // 🔁 10 saniyede bir 5 yeni duvar
    Timer.periodic(const Duration(seconds: 10), (_) {
      if (!isGameOver && isGameRunning) {
        spawnWalls(5);
      }
    });

// 🔁 15 saniyede bir portal oluştur
    Timer.periodic(const Duration(seconds: 15), (_) {
      if (!isGameOver && isGameRunning) {
        spawnPortals();
      }
    });

  }

  @override
  void dispose() {
    gameTimer?.cancel();
    focusNode.dispose();
    super.dispose();
  }

  void spawnSnake() {
    snake = [
      Offset(
        random.nextInt(colCount - 2).toDouble(),
        random.nextInt(rowCount - 2).toDouble(),
      )
    ];
    snakeColor = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    spawnFood();
    score = 0;
  }

  void spawnFood() {
    currentFoodImage = foodImages[random.nextInt(foodImages.length)];
    food = Offset(
      random.nextInt(colCount - 2).toDouble(),
      random.nextInt(rowCount - 2).toDouble(),
    );
  }
  void spawnGiftBox() {
    Offset position = Offset(
      random.nextInt(colCount - 2).toDouble(),
      random.nextInt(rowCount - 2).toDouble(),
    );

    bool isGood = random.nextBool(); // %50 iyi %50 kötü
    String selectedImage = giftImages[random.nextInt(giftImages.length)];

    setState(() {
      currentGiftBox = GiftBox(
        position: position,
        isGood: isGood,
        image: selectedImage,
      );
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!isGameOver && isGameRunning) {
        setState(() {
          currentGiftBox = null;
        });
      }
    });
  }


  void startGame() {
    resetGame();     // Oyunu sıfırla (yılanı ve skoru)
    resumeGame();    // Oyunu başlat
  }

  void resumeGame() {
    if (isGameRunning || isGameOver) return;
    isGameRunning = true;
    gameTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (isGameOver) {
        timer.cancel();
        return;
      }
      moveSnake();
    });
  }

  void pauseGame() {
    gameTimer?.cancel();
    isGameRunning = false;

  }


  void resetGame() {
    setState(() {
      isGameOver = false;
      isGameRunning = false;
      spawnSnake();
      direction = 'right';
      // 💥 Duvar ve portal temizlenip yeniden oluşturuluyor
      walls.clear();
      portals.clear();
      spawnWalls(5);
      spawnPortals();
    });
  }

  void moveSnake() {
    setState(() {
      Offset newHead;
      switch (direction) {
        case 'up':
          newHead = Offset(snake.first.dx, snake.first.dy - 1);
          break;
        case 'down':
          newHead = Offset(snake.first.dx, snake.first.dy + 1);
          break;
        case 'left':
          newHead = Offset(snake.first.dx - 1, snake.first.dy);
          break;
        case 'right':
        default:
          newHead = Offset(snake.first.dx + 1, snake.first.dy);
          break;
      }
      // 💥 Duvara çarptıysa oyun biter
      if (walls.contains(newHead)) {
        playSound('sounds/splat.mp3');  // 🔊 Çarpınca ses çal
        isGameOver = true;
        isGameRunning = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacement(context,
            MaterialPageRoute(
              builder: (context) => GameOverScreen(
                playerName: widget.playerName,
                score: score,
              ),
            ),
          );
        });
        return;
      }

// 🌀 Portal kontrolü
      if (portalA != null && portalB != null) {
        if (newHead == portalA) {
          newHead = portalB!;
          playSound('sounds/portals.mp3'); // 🌀 Portal sesi
        } else if (newHead == portalB) {
          newHead = portalA!;
          playSound('sounds/portals.mp3');
        }
      }

      if (newHead.dx < 0 || newHead.dx >= colCount - 2 || newHead.dy < 0 || newHead.dy >= rowCount) {
        playSound('sounds/splat.mp3'); // 🔊 Kenara çarpınca da ses çal
        isGameOver = true;
        isGameRunning = false;
        return;
      }

      snake.insert(0, newHead);
      if (newHead == food) {
        spawnFood();
        score += 1;
        playSound('sounds/eat.mp3'); // 🍎 Yeme sesi
      } else {
        snake.removeLast();
      }
      // 🎁 Gift Box kontrolü:
      if (currentGiftBox != null && newHead == currentGiftBox!.position) {
      int change = random.nextInt(5) + 1; // 1-5 arası
      bool increase = random.nextBool();  // %50 şans

      if (increase) {
      // Uzatma
      for (int i = 0; i < change; i++) {
      snake.add(snake.last);
      }
      score += change;
      } else {
      // Azaltma
      if (snake.length <= change) {
      // O kadar kısalırsa yılan yok oluyor => oyun biter
      isGameOver = true;
      isGameRunning = false;
      playSound('sounds/splat.mp3');  // 🔊 Çarpınca ses çal
      return;
      } else {
      for (int i = 0; i < change; i++) {
      snake.removeLast();
      score = score > 0 ? score - 1 : 0;
      }
      }
      }

      currentGiftBox = null; // kutuyu kaldır
      }

    });
  }
  void spawnWalls(int count) {
    walls.clear(); // önceki duvarları temizle
    for (int i = 0; i < count; i++) {
      Offset wallPos;
      do {
        wallPos = Offset(
          random.nextInt(colCount - 2).toDouble(),
          random.nextInt(rowCount - 2).toDouble(),
        );
      } while (snake.contains(wallPos) || wallPos == food || walls.contains(wallPos));

      walls.add(wallPos);
    }
  }
  void spawnPortals() {
    Offset newPortalA;
    Offset newPortalB;

    do {
      newPortalA = Offset(
        random.nextInt(colCount - 2).toDouble(),
        random.nextInt(rowCount - 2).toDouble(),
      );
    } while (snake.contains(newPortalA) || walls.contains(newPortalA) || newPortalA == food);

    do {
      newPortalB = Offset(
        random.nextInt(colCount - 2).toDouble(),
        random.nextInt(rowCount - 2).toDouble(),
      );
    } while (snake.contains(newPortalB) || walls.contains(newPortalB) || newPortalB == food || newPortalB == newPortalA);

    setState(() {
      portalA = newPortalA;
      portalB = newPortalB;
    });
  }


  Widget _buildSnakeHead() {
    return SizedBox(
      width: cellSize,
      height: cellSize,
      child: Stack(
        children: [
          Container(
            width: cellSize,
            height: cellSize,
            decoration: BoxDecoration(
              color: snakeColor,
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: cellSize * 0.25,
            left: cellSize * 0.25,
            child: Container(
              width: cellSize * 0.25,
              height: cellSize * 0.25,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: cellSize * 0.25,
            right: cellSize * 0.25,
            child: Container(
              width: cellSize * 0.25,
              height: cellSize * 0.25,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return  GameOverScreen(
        score: score,
        playerName: widget.playerName,
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: focusNode,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            // ⏎ Enter ile oyunu başlat
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              startGame();
            }

            // Space tuşu ile duraklat / devam et
            if (event.logicalKey == LogicalKeyboardKey.space) {
              setState(() {
                if (isGameRunning) {
                  pauseGame();
                } else {
                  resumeGame();
                }
              });
            }

            if (event.logicalKey == LogicalKeyboardKey.arrowUp && direction != 'down') direction = 'up';
            if (event.logicalKey == LogicalKeyboardKey.arrowDown && direction != 'up') direction = 'down';
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft && direction != 'right') direction = 'left';
            if (event.logicalKey == LogicalKeyboardKey.arrowRight && direction != 'left') direction = 'right';
          }
        },

        child: Stack(
          children: [
            // ✅ Arka plan resmi eklendi
            Positioned.fill(
              child: Image.asset(
                'assets/images/GZ .jpg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Score: $score",
                        style: const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        iconSize: 28,
                        onPressed: () {
                          setState(() {
                            isSoundOn = !isSoundOn;
                          });
                        },
                        icon: Icon(
                          isSoundOn ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),


                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (isGameRunning) {
                          pauseGame();
                        } else {
                          resumeGame();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      backgroundColor: Colors.white30, // Arka plan rengi (isteğe bağlı)
                    ),
                    child: Image.asset(
                      isGameRunning
                          ? 'assets/images/pause.png'
                          : 'assets/images/play.png',
                      width: 30,
                      height: 30,
                    ),
                  ),

                  const SizedBox(height: 10),

                  //const SizedBox(height: 20),
                  Container(
                    width: colCount * cellSize,
                    height: rowCount * cellSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Stack(
                      children: [
                        for (int i = 0; i < snake.length; i++)
                          Positioned(
                            left: snake[i].dx * cellSize,
                            top: snake[i].dy * cellSize,
                            child: i == 0
                                ? _buildSnakeHead()
                                : Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: snakeColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        Positioned(
                          left: food.dx * cellSize,
                          top: food.dy * cellSize,
                          child: Image.asset(
                            currentFoodImage,
                            width: cellSize,
                            height: cellSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (currentGiftBox != null)
                          Positioned(
                            left: currentGiftBox!.position.dx * cellSize,
                            top: currentGiftBox!.position.dy * cellSize,
                            child: Image.asset(
                              currentGiftBox!.image,
                              width: cellSize,
                              height: cellSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        for (var wall in walls)
                          Positioned(
                            left: wall.dx * cellSize,
                            top: wall.dy * cellSize,
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.rectangle,
                              ),
                            ),
                          ),
                        if (portalA != null)
                          Positioned(
                            left: portalA!.dx * cellSize,
                            top: portalA!.dy * cellSize,
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: Colors.purple,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        if (portalB != null)
                          Positioned(
                            left: portalB!.dx * cellSize,
                            top: portalB!.dy * cellSize,
                            child: Container(
                              width: cellSize,
                              height: cellSize,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
