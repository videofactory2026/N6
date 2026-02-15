import React, { useMemo } from "react";
import { View, Text, ScrollView } from "react-native";
import { ui } from "../ui/ui";
import { useAppState } from "../state/AppState";
import { getWeekStartISO, weeklyDeficitGate, caloriesInWeek } from "../services/weeklyEngine";
import { calorieToMovement } from "../services/movementEngine";

export function InsightsScreen() {
  const { profile, meals, behavior } = useAppState();

  const weekStart = useMemo(() => getWeekStartISO(new Date()), []);
  const movementBase = useMemo(() => calorieToMovement(profile, 0), [profile]);
  const weeklyTargetSum = movementBase.calorieTarget * 7;

  const weeklyCaloriesIn = useMemo(() => caloriesInWeek(meals, weekStart), [meals, weekStart]);
  const weekly = useMemo(() => weeklyDeficitGate(weeklyTargetSum, weeklyCaloriesIn), [weeklyTargetSum, weeklyCaloriesIn]);

  return (
    <ScrollView contentContainerStyle={ui.screen}>
      <View style={ui.card}>
        <Text style={ui.h2}>Weekly deficit (intelligence layer)</Text>
        <Text style={ui.text}>Week start: {weekStart}</Text>
        <Text style={ui.text}>Weekly target calories: {weeklyTargetSum}</Text>
        <Text style={ui.text}>Calories eaten this week: {weeklyCaloriesIn}</Text>
        <Text style={ui.text}>Weekly deficit: <Text style={{ fontWeight: "700" }}>{Math.round(weekly.weeklyDeficit)}</Text> kcal</Text>
        <Text style={ui.small}>{weekly.advisory}</Text>
      </View>

      <View style={ui.card}>
        <Text style={ui.h2}>Adaptive target</Text>
        <Text style={ui.text}>Dynamic step target: <Text style={{ fontWeight: "700" }}>{behavior.dynamicStepTarget}</Text></Text>
        <Text style={ui.small}>If you comply often, target increases (max 12k). If not, it eases off (min 8k).</Text>
      </View>
    </ScrollView>
  );
}
