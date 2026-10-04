import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:froggycrosser/class/fly.dart';
import 'package:froggycrosser/class/river_log.dart';
import 'package:froggycrosser/class/vehicle.dart';

class Game extends StatefulWidget {
  const Game({super.key});
  @override
  State<StatefulWidget> createState() {
    return _GameState();
  }
}

// Susunan lane dari atas ke bawah:
// 0 = seberang sungai (finish), 1-3 = sungai, 4 = rest area,
// 5-7 = jalan raya, 8 = start
class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  final int _initValue = 60;
  final int _totalLanes = 9;
  final int _startLane = 8;
  final double _frogSize = 36;
  final double _dt = 0.025; // 25 ms per tick game loop

  late int _hitung;
  Timer? _timer; // timer hitung mundur (1 detik)
  Timer? _timer2; // game loop (25 ms)

  final Random _random = Random();

  int _score = 0;
  int _frogs = 0;
  late int _lane;
  double _frogX = 0.5; // posisi relatif terhadap lebar layar (0.0 - 1.0)
  late int _maxLane; // lane terjauh yang dicapai, untuk poin langkah maju

  String _message = '';
  Color _messageColor = Colors.white;
  int _messageTicks = 0;

  Fly? _fly;

  late AnimationController _hopController;
  late Animation<double> _hopAnimation;

  final List<Vehicle> _vehicles = [
    // Lane 7: Truk (lambat)
    Vehicle(type: 'truck', lane: 7, x: 20, speed: 70, width: 130, height: 42),
    Vehicle(type: 'truck', lane: 7, x: 240, speed: 70, width: 130, height: 42),
    // Lane 6: Mobil (sedang)
    Vehicle(type: 'car', lane: 6, x: 50, speed: -130, width: 85, height: 40),
    Vehicle(type: 'car', lane: 6, x: 260, speed: -130, width: 85, height: 40),
    // Lane 5: Mobil Balap (cepat)
    Vehicle(type: 'race_car', lane: 5, x: 10, speed: 210, width: 90, height: 38),
    Vehicle(type: 'race_car', lane: 5, x: 280, speed: 210, width: 90, height: 38),
  ];

  final List<RiverLog> _logs = [
    RiverLog(lane: 3, x: 20, speed: 80, width: 110),
    RiverLog(lane: 3, x: 220, speed: 80, width: 110),
    RiverLog(lane: 2, x: 40, speed: -110, width: 125),
    RiverLog(lane: 2, x: 250, speed: -110, width: 125),
    RiverLog(lane: 1, x: 10, speed: 95, width: 105),
    RiverLog(lane: 1, x: 210, speed: 95, width: 105),
  ];

  @override
  void initState() {
    super.initState();
    _hitung = _initValue;
    _lane = _startLane;
    _maxLane = _startLane;

    _hopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _hopAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _hopController, curve: Curves.easeInOut),
    );

    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _hitung--;

        if (_fly != null) {
          _fly!.seconds--;
          if (_fly!.seconds <= 0) {
            _fly = null;
          }
        }
        if (_hitung % 10 == 0) {
          spawnFly();
        }
      });

      if (_hitung <= 0) {
        timer.cancel();
        _timer2?.cancel();
        context.pushReplacement('/result?score=$_score&frogs=$_frogs');
      }
    });
    startTimer2();
  }

  void startTimer2() {
    _timer2 = Timer.periodic(const Duration(milliseconds: 25), (timer) {
      double width = MediaQuery.of(context).size.width;
      setState(() {
        for (Vehicle v in _vehicles) {
          v.move(_dt, width);
        }
        for (RiverLog l in _logs) {
          l.move(_dt, width);
        }
        if (_messageTicks > 0) {
          _messageTicks--;
        }

        checkRiver(width);
        checkVehicle(width);
        checkFly();
      });
    });
  }

  // Lalat muncul acak di lane kayu (1-3) atau rest area (4)
  void spawnFly() {
    _fly = Fly(
      lane: 1 + _random.nextInt(4),
      x: 0.15 + _random.nextDouble() * 0.7,
    );
  }

  void checkRiver(double width) {
    if (_lane < 1 || _lane > 3) return;

    double frogPixel = _frogX * width;
    for (RiverLog l in _logs) {
      if (l.lane == _lane &&
          frogPixel >= l.x - 15 &&
          frogPixel <= l.x + l.width + 15) {
        // katak ikut hanyut bersama kayu
        _frogX += l.speed * _dt / width;
        if (_frogX < 0.02 || _frogX > 0.98) {
          frogDie('TENGGELAM! Terbawa arus sungai!');
        }
        return;
      }
    }
    frogDie('SPLASH! Katak tenggelam di sungai!');
  }

  void checkVehicle(double width) {
    if (_lane < 5 || _lane > 7) return;

    double frogPixel = _frogX * width;
    for (Vehicle v in _vehicles) {
      if (v.lane == _lane &&
          frogPixel >= v.x - 10 &&
          frogPixel <= v.x + v.width + 10) {
        frogDie('SPLAT! Tertabrak ${v.name}!');
        return;
      }
    }
  }

  void checkFly() {
    if (_fly == null || _fly!.lane != _lane) return;

    if ((_frogX - _fly!.x).abs() < 0.12) {
      _score += 50;
      _fly = null;
      showMessage('+50 BONUS LALAT!', Colors.amber);
    }
  }

  void frogDie(String reason) {
    showMessage(reason, Colors.red);
    resetFrog();
  }

  void resetFrog() {
    _lane = _startLane;
    _maxLane = _startLane;
    _frogX = 0.5;
  }

  void showMessage(String msg, Color color) {
    _message = msg;
    _messageColor = color;
    _messageTicks = 56; // sekitar 1.4 detik
  }

  void moveFrog(int dLane, double dX) {
    if (!(_timer?.isActive ?? false)) return;

    _hopController.forward(from: 0.0);
    setState(() {
      int newLane = _lane + dLane;
      if (newLane >= 0 && newLane <= _startLane) {
        _lane = newLane;
      }

      // poin untuk setiap langkah maju yang baru
      if (_lane < _maxLane) {
        _score += 10;
        _maxLane = _lane;
      }

      _frogX = (_frogX + dX).clamp(0.08, 0.92);

      // berhasil menyeberang
      if (_lane == 0) {
        _frogs++;
        _score += 100;
        showMessage('SEBERANG SUKSES! +100', Colors.green);
        resetFrog();
      }
    });
  }

  String formatTime(int hitung) {
    var minutes = (hitung ~/ 60).toString().padLeft(2, '0');
    var seconds = (hitung % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer2?.cancel();
    _hopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_hitung / _initValue).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game'),
      ),
      body: Column(
        children: <Widget>[
          LinearPercentIndicator(
            center: Text(
              formatTime(_hitung),
              style: const TextStyle(color: Colors.white),
            ),
            lineHeight: 20.0,
            percent: progress,
            backgroundColor: Colors.grey,
            progressColor: _hitung <= 10 ? Colors.red : Colors.green,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Score: $_score',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Katak: $_frogs',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -100) {
                  moveFrog(-1, 0); // swipe atas
                } else if (v > 100) {
                  moveFrog(1, 0); // swipe bawah
                }
              },
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -100) {
                  moveFrog(0, -0.12); // swipe kiri
                } else if (v > 100) {
                  moveFrog(0, 0.12); // swipe kanan
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double laneHeight = constraints.maxHeight / _totalLanes;
                  double width = constraints.maxWidth;

                  return Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Column(
                        children: List.generate(_totalLanes, (int i) {
                          return laneBackground(i, laneHeight);
                        }),
                      ),
                      ...List.generate(_logs.length, (int i) {
                        RiverLog l = _logs[i];
                        return Positioned(
                          top: l.lane * laneHeight + (laneHeight - l.height) / 2,
                          left: l.x,
                          child: Image.asset(
                            'assets/images/log.png',
                            width: l.width,
                            height: l.height,
                            fit: BoxFit.fill,
                          ),
                        );
                      }),
                      if (_fly != null) flyWidget(laneHeight, width),
                      ...List.generate(_vehicles.length, (int i) {
                        Vehicle v = _vehicles[i];
                        return Positioned(
                          top: v.lane * laneHeight + (laneHeight - v.height) / 2,
                          left: v.x,
                          child: Transform.flip(
                            flipX: v.speed < 0,
                            child: Image.asset(
                              v.image,
                              width: v.width,
                              height: v.height,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      }),
                      Positioned(
                        top: _lane * laneHeight + (laneHeight - _frogSize) / 2,
                        left: _frogX * width - _frogSize / 2,
                        child: ScaleTransition(
                          scale: _hopAnimation,
                          child: Image.asset(
                            'assets/images/frog.png',
                            width: _frogSize,
                            height: _frogSize,
                          ),
                        ),
                      ),
                      if (_messageTicks > 0)
                        Positioned(
                          top: laneHeight * 4,
                          left: 20,
                          right: 20,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _messageColor, width: 2),
                              ),
                              child: Text(
                                _message,
                                style: TextStyle(
                                  color: _messageColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget laneBackground(int i, double laneHeight) {
    Color color;
    String text = '';
    if (i == 0) {
      color = Colors.green.shade800;
      text = 'FINISH';
    } else if (i <= 3) {
      color = i % 2 == 0 ? Colors.blue.shade800 : Colors.blue.shade600;
    } else if (i == 4) {
      color = Colors.green.shade600;
      text = 'REST AREA';
    } else if (i <= 7) {
      color = i % 2 == 0 ? Colors.grey.shade800 : Colors.grey.shade700;
    } else {
      color = Colors.green.shade600;
      text = 'START';
    }

    return Container(
      height: laneHeight,
      width: double.infinity,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  // Animasi kemunculan lalat (membesar dari 0)
  Widget flyWidget(double laneHeight, double width) {
    return Positioned(
      top: _fly!.lane * laneHeight + (laneHeight - _fly!.size) / 2,
      left: _fly!.x * width - _fly!.size / 2,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_fly),
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Image.asset(
          'assets/images/fly.png',
          width: _fly!.size,
          height: _fly!.size,
        ),
      ),
    );
  }
}
