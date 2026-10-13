import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const GuessApp());

class GuessApp extends StatelessWidget {
  const GuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GuessGame(),
    );
  }
}

class GuessGame extends StatefulWidget {
  const GuessGame({super.key});

  @override
  State<GuessGame> createState() => _GuessGameState();
}

class _GuessGameState extends State<GuessGame> {
  final _controller = TextEditingController();
  int _secret = Random().nextInt(100) + 1;
  int _attempts = 0;
  String _message = 'خمّن رقماً بين 1 و 100';

  void _check() {
    final guess = int.tryParse(_controller.text);
    if (guess == null) {
      setState(() => _message = 'أدخل رقماً صحيحاً');
      return;
    }
    _attempts++;
    setState(() {
      if (guess < _secret) {
        _message = '⬆️ الرقم أكبر';
      } else if (guess > _secret) {
        _message = '⬇️ الرقم أصغر';
      } else {
        _message = '🎉 صحيح! الرقم $_secret في $_attempts محاولة';
      }
    });
    _controller.clear();
  }

  void _restart() {
    setState(() {
      _secret = Random().nextInt(100) + 1;
      _attempts = 0;
      _message = 'خمّن رقماً بين 1 و 100';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لعبة التخمين')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onSubmitted: (_) => _check(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _check, child: const Text('تخمين')),
            TextButton(onPressed: _restart, child: const Text('لعبة جديدة')),
          ],
        ),
      ),
    );
  }
}