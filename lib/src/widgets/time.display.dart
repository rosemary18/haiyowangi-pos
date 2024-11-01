import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeDisplay extends StatefulWidget {

  const TimeDisplay({super.key});

  @override
  State<TimeDisplay> createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {

  String currentTime = '';
  Timer? timeId;

  @override
  void initState() {
    super.initState();

    // Memulai timer untuk memperbarui waktu setiap milidetik
    _startTimer();
  }

  void _startTimer() {

    // Memperbarui waktu setiap 1 detik
    timeId = Timer.periodic(const Duration(seconds: 1), _updateTime);
  }

  void _updateTime(_) {
    setState(() {
      DateTime now = DateTime.now();
      currentTime = DateFormat('EEEE, dd/MM/yyyy, HH:mm:ss').format(now);
    });
  }

  @override
  void dispose () {
    super.dispose();
    if (timeId != null) {
      timeId?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        currentTime,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}