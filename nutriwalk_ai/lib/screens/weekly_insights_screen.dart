import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state_provider.dart';

class WeeklyInsightsScreen extends StatelessWidget {
  const WeeklyInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final intelligence = appState.weeklyIntelligence;

        if (intelligence == null) {
          return const Center(child: Text('Loading insights...'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Weekly Intelligence',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildMetricRow(
                      context,
                      'Weekly Deficit',
                      '${intelligence.weeklyDeficit.round()} kcal',
                      intelligence.weeklyDeficit >= 3500
                          ? Colors.green
                          : intelligence.weeklyDeficit >= 0
                              ? Colors.orange
                              : Colors.red,
                      Icons.local_fire_department,
                    ),
                    const Divider(height: 24),
                    _buildMetricRow(
                      context,
                      'Avg Steps',
                      '${intelligence.avgSteps.round()}',
                      Colors.blue,
                      Icons.directions_walk,
                    ),
                    const Divider(height: 24),
                    _buildMetricRow(
                      context,
                      'Days On Track',
                      '${intelligence.daysCompliant}/7',
                      Colors.purple,
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Advisory',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      intelligence.advisory,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
