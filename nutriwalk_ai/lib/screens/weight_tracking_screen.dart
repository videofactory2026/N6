import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity_log.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  final DatabaseService _db = DatabaseService();
  List<WeightLog> _weights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeights();
  }

  Future<void> _loadWeights() async {
    final weights = await _db.getWeightLogs(30);
    setState(() {
      _weights = weights;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weight Tracking',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            ElevatedButton.icon(
              onPressed: _showAddWeightDialog,
              icon: const Icon(Icons.add),
              label: const Text('Log'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_weights.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Current Weight',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_weights.first.weight.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_weights.length >= 7) ...[
                    const SizedBox(height: 8),
                    Text(
                      '7-day avg: ${_calculate7DayAvg().toStringAsFixed(1)} kg',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _getWeightSpots(),
                        isCurved: true,
                        color: Theme.of(context).colorScheme.primary,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No weight data yet. Start tracking!'),
              ),
            ),
          ),
      ],
    );
  }

  List<FlSpot> _getWeightSpots() {
    return _weights.reversed.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();
  }

  double _calculate7DayAvg() {
    if (_weights.length < 7) return _weights.first.weight;
    final last7 = _weights.take(7).toList();
    final sum = last7.fold<double>(0, (sum, w) => sum + w.weight);
    return sum / last7.length;
  }

  Future<void> _showAddWeightDialog() async {
    final controller = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Weight'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(controller.text);
              if (weight != null) {
                await _db.saveWeightLog(
                  WeightLog(
                    id: const Uuid().v4(),
                    date: DateTime.now(),
                    weight: weight,
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.pop(context);
                await _loadWeights();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class WeightLog {
  final String id;
  final DateTime date;
  final double weight;
  final DateTime createdAt;

  WeightLog({
    required this.id,
    required this.date,
    required this.weight,
    required this.createdAt,
  });
}
