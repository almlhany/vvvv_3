import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const AlarmApp());

const kBg = Color(0xFF0B0B14);
const kCard = Color(0xFF14142A);
const kViolet = Color(0xFF7C5CFF);
const kMint = Color(0xFF00E5C3);

const kDayShort = {1: 'ن', 2: 'ث', 3: 'ر', 4: 'خ', 5: 'ج', 6: 'س', 7: 'ح'};
const kDayName = {
  1: 'الاثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
  5: 'الجمعة',
  6: 'السبت',
  7: 'الأحد',
};

String fmt(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.period == DayPeriod.am ? 'ص' : 'م'}';
}

String daysText(Set<int> d) {
  if (d.isEmpty) return 'مرة واحدة';
  if (d.length == 7) return 'كل يوم';
  final l = d.toList()..sort();
  return l.map((e) => kDayName[e]).join('، ');
}

class AlarmApp extends StatelessWidget {
  const AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'منبه',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kViolet, secondary: kMint),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class Alarm {
  Alarm({
    required this.time,
    this.label = 'منبه',
    this.enabled = true,
    Set<int>? days,
  }) : days = days ?? <int>{};

  TimeOfDay time;
  String label;
  bool enabled;
  Set<int> days; // DateTime.weekday: 1 = الاثنين ... 7 = الأحد
  String? lastKey;
  DateTime? snoozeUntil;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Alarm> _alarms = [
    Alarm(
        time: const TimeOfDay(hour: 6, minute: 30),
        label: 'الاستيقاظ',
        days: {1, 2, 3, 4, 5}),
    Alarm(
        time: const TimeOfDay(hour: 22, minute: 0),
        label: 'وقت النوم',
        enabled: false),
  ];
  DateTime _now = DateTime.now();
  Timer? _timer;
  bool _ringing = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    setState(() => _now = now);
    if (_ringing) return;
    final key = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
    for (final a in _alarms) {
      if (!a.enabled) continue;
      bool due;
      if (a.snoozeUntil != null) {
        due = !now.isBefore(a.snoozeUntil!);
      } else {
        final dayOk = a.days.isEmpty || a.days.contains(now.weekday);
        due = dayOk &&
            now.hour == a.time.hour &&
            now.minute == a.time.minute &&
            a.lastKey != key;
      }
      if (due) {
        a.lastKey = key;
        _ring(a);
        break;
      }
    }
  }

  Future<void> _ring(Alarm a) async {
    _ringing = true;
    a.snoozeUntil = null;
    final res = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => RingingPage(alarm: a),
      ),
    );
    _ringing = false;
    if (res == 'snooze') {
      a.snoozeUntil = DateTime.now().add(const Duration(minutes: 5));
    } else if (a.days.isE