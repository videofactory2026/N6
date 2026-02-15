import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

class MovementRecommendationCard extends StatelessWidget {
  const MovementRecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final recommendation = appState.movementRecommendation;
        if (recommendation == null) return const SizedBox();

        Color urgencyColor;
        IconData urgencyIcon;
        switch (recommendation.urgency) {
          case 'low':
            urgencyColor = Colors.green;
            urgencyIcon = Icons.check_circle;
            break;
          case 'medium':
            urgencyColor = Colors.orange;
            urgencyIcon = Icons.info;
            break;
          case 'high':
            urgencyColor = Colors.red;
            urgencyIcon = Icons.warning;
            break;
          default:
            urgencyColor = Colors.grey;
            urgencyIcon = Icons.circle;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(urgencyIcon, color: urgencyColor),
                    const SizedBox(width: 8),
                    Text('Movement Suggestion',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(recommendation.message, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('${recommendation.stepsRequired}', 'steps',
                          Icons.directions_walk),
                      _buildStat(
                          '${recommendation.distanceKm.toStringAsFixed(1)}',
                          'km',
                          Icons.straighten),
                      _buildStat(
                          '${recommendation.minutesRequired}', 'min', Icons.timer),
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

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
