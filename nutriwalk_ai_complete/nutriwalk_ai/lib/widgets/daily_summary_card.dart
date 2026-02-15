import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final balance = appState.dailyBalance;
        final profile = appState.userProfile;

        if (balance == null || profile == null) {
          return const SizedBox();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric(
                      context,
                      'Calories In',
                      balance.caloriesIn.round().toString(),
                      Icons.restaurant,
                      Colors.orange,
                    ),
                    _buildMetric(
                      context,
                      'Steps',
                      balance.steps.toString(),
                      Icons.directions_walk,
                      Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric(
                      context,
                      'Burned',
                      balance.caloriesBurned.round().toString(),
                      Icons.local_fire_department,
                      Colors.red,
                    ),
                    _buildMetric(
                      context,
                      'Deficit',
                      balance.deficit.round().toString(),
                      balance.deficit >= 0 ? Icons.trending_up : Icons.trending_down,
                      balance.deficit >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: balance.isOnTrack
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: balance.isOnTrack
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        balance.isOnTrack ? Icons.check_circle : Icons.info,
                        color: balance.isOnTrack ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        balance.isOnTrack ? 'On Track!' : 'Needs Attention',
                        style: TextStyle(
                          color: balance.isOnTrack ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
