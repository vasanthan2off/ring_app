import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/ring_service.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({super.key});

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage> {
  final RingService ringService = RingService.instance;

  final List<FlSpot> _heartRateSpots = [];
  late Timer _timer;
  double _time = 0;

  @override
  void initState() {
    super.initState();

    // Update chart when heart rate changes
    ringService.heartRate.addListener(() {
      int bpm = ringService.heartRate.value;
      setState(() {
        _heartRateSpots.add(FlSpot(_time, bpm.toDouble()));
        if (_heartRateSpots.length > 50) {
          _heartRateSpots.removeAt(0); // Keep graph clean
        }
      });
    });

    // Increment time for x-axis every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _time += 1;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Widget _buildHeartRateChart() {
    double minY = _heartRateSpots.isEmpty
        ? 0
        : _heartRateSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 10;
    double maxY = _heartRateSpots.isEmpty
        ? 200
        : _heartRateSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 10;

    if (minY < 0) minY = 0; // Prevent negative values

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _heartRateSpots,
            isCurved: true,
            color: Colors.deepPurple,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            barWidth: 2,
          ),
        ],
        gridData: FlGridData(show: false), // ❌ hide all grid lines
        borderData: FlBorderData(show: false), // ❌ no border
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Heart Rate", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: ringService.heartRate,
        builder: (context, bpm, _) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "$bpm bpm",
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Resting heart rate: 60 bpm",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Heart Rate Trend",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        "$bpm bpm",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text("Today +2%",
                          style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _heartRateSpots.isEmpty
                      ? const Center(child: Text("Waiting for heart data..."))
                      : _buildHeartRateChart(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
