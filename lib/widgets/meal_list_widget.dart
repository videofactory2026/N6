import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state_provider.dart';

class MealListWidget extends StatelessWidget {
  const MealListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final meals = appState.todayMeals;
        if (meals.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No meals logged today'),
            ),
          );
        }

        return Column(
          children: meals.map((meal) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.restaurant,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: Text('${meal.totalCalories.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    '${meal.items.length} items • ${DateFormat.jm().format(meal.createdAt)}'),
                trailing: PopupMenuButton(
                  itemBuilder: (context) =>
                      [const PopupMenuItem(value: 'delete', child: Text('Delete'))],
                  onSelected: (value) {
                    if (value == 'delete') appState.deleteMeal(meal.id);
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
