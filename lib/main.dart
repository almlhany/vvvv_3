import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FightingGameApp());

const kBg = Color(0xFF0A0E27);
const kCard = Color(0xFF1A1F3A);
const kRed = Color(0xFFFF4757);
const kBlue = Color(0xFF1E90FF);
const kGold = Color(0xFFFFD700);
const kGreen = Color(0xFF2ED573);

class FightingGameApp extends StatelessWidget {
  const FightingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'معركة الأبطال',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kRed, secondary: kBlue),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const GameScreen(),
    );
  }
}

class Character {
  final String name;
  final String emoji;
  int maxHp;
  int currentHp;
  int attackPower;
  int defensePower;

  Character({
    required this.name,
    required this.emoji,
    required this.maxHp,
    required this.attackPower,
    required this.defensePower,
  }) : currentHp = maxHp;

  int getAttackDamage() {
    return attackPower + Random().nextInt(10);
  }

  int takeDamage(int damage) {
    int actualDamage = max(1, damage - defensePower);
    currentHp = max(0, currentHp - actualDamage);
    return actualDamage;
  }

  bool isAlive() => currentHp > 0;

  void heal(int amount) {
    currentHp = min(maxHp, currentHp + amount);
  }

  void reset() {
    currentHp = maxHp;
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Character player;
  late Character enemy;
  String battleLog = 'بدء المعركة!';
  bool gameOver = false;
  bool playerWon = false;
  bool isPlayerTurn = true;
  late AnimationController _playerAttackController;
  late AnimationController _enemyAttackController;

  @override
  void initState() {
    super.initState();
    _initGame();
    _playerAttackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _enemyAttackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _initGame() {
    player = Character(
      name: 'أنت',
      emoji: '⚔️',
      maxHp: 100,
      attackPower: 15,
      defensePower: 5,
    );

    enemy = Character(
      name: 'العدو',
      emoji: '👹',
      maxHp: 80,
      attackPower: 12,
      defensePower: 3,
    );

    battleLog = 'بدء المعركة! اختر هجومك';
    gameOver = false;
    playerWon = false;
    isPlayerTurn = true;
  }

  void _playerAttack(String type) {
    if (!isPlayerTurn || gameOver) return;

    int damage = 0;
    String message = '';

    if (type == 'normal') {
      damage = player.getAttackDamage();
      message = 'هجوم عادي!';
    } else if (type == 'power') {
      damage = (player.getAttackDamage() * 1.5).toInt();
      message = 'هجوم قوي! 💥';
    } else if (type == 'heal') {
      player.heal(25);
      message = 'تم الشفاء بـ 25 نقطة! 🩹';
      damage = 0;
    }

    int actualDamage = enemy.takeDamage(damage);

    setState(() {
      if (damage > 0) {
        battleLog = '$message\nالضرر: $actualDamage';
      } else {
        battleLog = message;
      }
      isPlayerTurn = false;
    });

    _playerAttackController.forward().then((_) {
      _playerAttackController.reset();
      Future.delayed(const Duration(milliseconds: 800), _enemyTurn);
    });
  }

  void _enemyTurn() {
    if (gameOver) return;

    int actionType = Random().nextInt(100);
    String attackType = 'normal';
    String actionName = 'هجوم عادي';

    if (actionType < 30 && enemy.currentHp < enemy.maxHp * 0.5) {
      enemy.heal(20);
      battleLog = 'العدو: تم الشفاء بـ 20 نقطة! 🩹';
      actionName = 'شفاء';
    } else if (actionType < 60) {
      attackType = 'power';
      actionName = 'هجوم قوي';
    }

    if (actionName != 'شفاء') {
      int damage = enemy.getAttackDamage();
      if (attackType == 'power') {
        damage = (damage * 1.5).toInt();
      }

      int actualDamage = player.takeDamage(damage);
      battleLog = 'العدو: $actionName\nالضرر: $actualDamage';
    }

    setState(() {});

    _enemyAttackController.forward().then((_) {
      _enemyAttackController.reset();
      _checkGameStatus();
      if (!gameOver) {
        setState(() => isPlayerTurn = true);
      }
    });
  }

  void _checkGameStatus() {
    setState(() {
      if (!enemy.isAlive()) {
        gameOver = true;
        playerWon = true;
        battleLog = '🎉 انتصرت! انت بطل! 🎉';
      } else if (!player.isAlive()) {
        gameOver = true;
        playerWon = false;
        battleLog = '😢 تم هزيمتك! حاول مرة أخرى';
      }
    });
  }

  void _resetGame() {
    setState(() {
      _initGame();
    });
  }

  @override
  void dispose() {
    _playerAttackController.dispose();
    _enemyAttackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double playerHpPercent = player.currentHp / player.maxHp;
    double enemyHpPercent = enemy.currentHp / enemy.maxHp;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          '⚔️ معركة الأبطال ⚔️',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.05).animate(
                  CurvedAnimation(parent: _enemyAttackController, curve: Curves.easeInOut),
                ),
                child: Column(
                  children: [
                    Text(
                      enemy.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      enemy.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kRed, width: 2),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الصحة:'),
                              Text(
                                '${enemy.currentHp}/${enemy.maxHp}',
                                style: const TextStyle(
                                  color: kRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: enemyHpPercent,
                              minHeight: 20,
                              backgroundColor: Colors.grey.shade700,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                enemyHpPercent > 0.3 ? kRed : kRed.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGold, width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      '📜 سجل المعركة',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kGold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(minHeight: 80),
                      child: Text(
                        battleLog,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.05).animate(
                  CurvedAnimation(parent: _playerAttackController, curve: Curves.easeInOut),
                ),
                child: Column(
                  children: [
                    Text(
                      player.emoji,
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: kCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBlue, width: 2),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('الصحة:'),
                              Text(
                                '${player.currentHp}/${player.maxHp}',
                                style: const TextStyle(
                                  color: kBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: playerHpPercent,
                              minHeight: 20,
                              backgroundColor: Colors.grey.shade700,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                playerHpPercent > 0.3 ? kBlue : kRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (!gameOver)
                Column(
                  children: [
                    Text(
                      isPlayerTurn ? '🎮 دورك الآن!' : '⏳ انتظر دور العدو...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isPlayerTurn ? kGreen : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isPlayerTurn ? () => _playerAttack('normal') : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kBlue,
                              disabledBackgroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'هجوم عادي\n⚔️',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isPlayerTurn ? () => _playerAttack('power') : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kRed,
                              disabledBackgroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'هجوم قوي\n💥',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isPlayerTurn ? () => _playerAttack('heal') : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGreen,
                              disabledBackgroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'شفاء\n🩹',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: playerWon ? kGreen.withOpacity(0.2) : kRed.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: playerWon ? kGreen : kRed,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        battleLog,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: playerWon ? kGreen : kRed,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'لعبة جديدة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}