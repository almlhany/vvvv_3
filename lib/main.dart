import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const AlarmApp());

const kBg = Color(0xFF0B0B14);
const kCard = Color(0xFF14142A);
const kViolet = Color(0xFF7C5CFF);
const kMint = Color(0xFF00E5C3);

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
  Set<int> days;
  String? lastKey;
  DateTime? snoozeUntil;
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
      days: {1, 2, 3, 4, 5},
    ),
    Alarm(
      time: const TimeOfDay(hour: 22, minute: 0),
      label: 'وقت النوم',
      enabled: false,
    ),
  ];
  DateTime _now = DateTime.now();
  late Timer _timer;
  bool _ringing = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _tick() {
    final now = DateTime.now();
    setState(() => _now = now);
    if (_ringing) return;

    final key = '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
    for (final a in _alarms) {
      if (!a.enabled) continue;

      bool due = false;
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
    }
  }

  void _addAlarm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditAlarmPage(
        onSave: (alarm) {
          setState(() => _alarms.add(alarm));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'منبّهاتك',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ),
      body: _alarms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off_rounded,
                      size: 64, color: kViolet.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('لا توجد منبّهات بعد',
                      style: TextStyle(fontSize: 16, color: Colors.white70)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final (i, a) in _alarms.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AlarmCard(
                      alarm: a,
                      onTap: () => _editAlarm(i),
                      onToggle: (val) => setState(() => a.enabled = val),
                      onDelete: () => setState(() => _alarms.removeAt(i)),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        backgroundColor: kViolet,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _editAlarm(int idx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditAlarmPage(
        alarm: _alarms[idx],
        onSave: (alarm) {
          setState(() => _alarms[idx] = alarm);
        },
      ),
    );
  }
}

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const AlarmCard({
    required this.alarm,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: alarm.enabled ? kViolet.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fmt(alarm.time),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kMint,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: alarm.enabled,
                  onChanged: onToggle,
                  activeColor: kMint,
                  inactiveTrackColor: Colors.white12,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              daysText(alarm.days),
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onDelete,
              child: Text(
                'حذف',
                style: TextStyle(fontSize: 12, color: Colors.red.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditAlarmPage extends StatefulWidget {
  final Alarm? alarm;
  final ValueChanged<Alarm> onSave;

  const EditAlarmPage({this.alarm, required this.onSave});

  @override
  State<EditAlarmPage> createState() => _EditAlarmPageState();
}

class _EditAlarmPageState extends State<EditAlarmPage> {
  late TimeOfDay _time;
  late String _label;
  late bool _enabled;
  late Set<int> _days;
  late TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    if (widget.alarm != null) {
      _time = widget.alarm!.time;
      _label = widget.alarm!.label;
      _enabled = widget.alarm!.enabled;
      _days = Set.from(widget.alarm!.days);
    } else {
      _time = TimeOfDay.now();
      _label = 'منبه';
      _enabled = true;
      _days = <int>{};
    }
    _labelController = TextEditingController(text: _label);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_days.contains(day)) {
        _days.remove(day);
      } else {
        _days.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تعديل المنبّه',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (t != null) setState(() => _time = t);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kViolet.withOpacity(0.3)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('الوقت',
                        style:
                            TextStyle(fontSize: 12, color: Colors.white54)),
                    const SizedBox(height: 8),
                    Text(
                      fmt(_time),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kMint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              onChanged: (val) => _label = val,
              decoration: InputDecoration(
                hintText: 'اسم المنبّه',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: kCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('الأيام المتكررة',
                style: TextStyle(fontSize: 12, color: Colors.white54)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (int day = 1; day <= 7; day++)
                  GestureDetector(
                    onTap: () => _toggleDay(day),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _days.contains(day) ? kViolet : kCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kViolet.withOpacity(0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        kDayName[day]!.substring(0, 1),
                        style: TextStyle(
                          color: _days.contains(day) ? kBg : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final alarm = Alarm(
                    time: _time,
                    label: _labelController.text,
                    enabled: _enabled,
                    days: _days,
                  );
                  Navigator.pop(context);
                  widget.onSave(alarm);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kViolet,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'حفظ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RingingPage extends StatefulWidget {
  final Alarm alarm;

  const RingingPage({required this.alarm});

  @override
  State<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends State<RingingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: Tween<double>(begin: 1, end: 1.2).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: kViolet,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alarm, size: 64, color: kBg),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              widget.alarm.label,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fmt(widget.alarm.time),
              style: const TextStyle(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, 'snooze'),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: kCard,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.snooze,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('غفوة'),
                  ],
                ),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, 'dismiss'),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: kMint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 48,
                          color: kBg,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('إيقاف'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}