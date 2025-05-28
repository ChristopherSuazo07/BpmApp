import 'dart:async';
import 'package:bpm/DataService/data_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Scafold extends StatefulWidget {
  const Scafold({super.key});

  @override
  State<Scafold> createState() => _ScafoldState();
}

class _ScafoldState extends State<Scafold> with SingleTickerProviderStateMixin {
  int _bpm = 75;
  final List<FlSpot> _bpmData = [];
  late Timer _timer;
  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  double _time = 0;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInBack)),
        weight: 50,
      ),
    ]).animate(_heartController);

    _colorAnimation = ColorTween(
      begin: Colors.redAccent,
      end: Colors.red[400],
    ).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      int newBPM = await getValueFromFirebase();

      setState(() {
        _bpm = newBPM;
        _adjustHeartAnimationSpeed(newBPM);

        _time += 0.1;
        _bpmData.add(FlSpot(_time, newBPM.toDouble()));
        if (_bpmData.length > 50) {
          _bpmData.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _heartController.dispose();
    super.dispose();
  }

  Future<int> getValueFromFirebase() async {
    int generatedValue = await Dataservice().bpm();
    return generatedValue;
  }

  void _adjustHeartAnimationSpeed(int bpm) {
  if (bpm <= 0) {
    // Si BPM es 0 o negativo, detenemos la animación del corazón.
    if (_heartController.isAnimating) {
      _heartController.stop();
    }
    return;
  }

  final secondsPerBeat = 60 / bpm;
  final newDuration = Duration(milliseconds: (secondsPerBeat * 1000).toInt());

  if (_heartController.duration != newDuration) {
    _heartController
      ..stop()
      ..duration = newDuration
      ..repeat(reverse: true);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Monitoreo de BPM',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[100],
                ),
              ),
              const SizedBox(height: 30),
              AnimatedBuilder(
                animation: _heartController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Icon(
                      Icons.favorite,
                      color: _colorAnimation.value,
                      size: 100,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                '$_bpm BPM',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[200],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 200,
                child: LineChart(
                  LineChartData(
                    backgroundColor: Colors.black,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 20,
                      verticalInterval: 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.green.withOpacity(0.3),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.green.withOpacity(0.3),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xFF353C40), width: 3.5),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _bpmData,
                        isCurved: true,
                        color: Colors.cyanAccent,
                        barWidth: 2.5,
                        dotData: const FlDotData(show: false),
                        preventCurveOvershootingThreshold: 10,
                      ),
                    ],
                    minY: 0, //Para poder visualizar el 0
                    maxY: 200,
                    clipData: const FlClipData.all(),
                    lineTouchData: const LineTouchData(enabled: false),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
