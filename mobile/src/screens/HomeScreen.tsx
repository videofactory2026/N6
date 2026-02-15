import React, { useEffect, useMemo, useState } from "react";
import { View, Text, Pressable, ScrollView } from "react-native";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { RootStackParamList } from "../App";
import { ui } from "../ui/ui";
import { useAppState } from "../state/AppState";
import { calorieToMovement } from "../services/movementEngine";
import { getWeekStartISO, weeklyDeficitGate, caloriesInWeek } from "../services/weeklyEngine";
import { getTodayStepsHealthConnect } from "../services/stepTracking";
import { shouldSendEveningNudge, fireNudge } from "../services/nudgeEngine";

type Props = NativeStackScreenProps<RootStackParamList, "Home">;

function isoDate(d = new Date()) {
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

export function HomeScreen({ navigation }: Props) {
  const { profile, meals, behavior, nudges, addNudgeLog } = useAppState();
  const [stepsToday, setStepsToday] = useState(0);
  const today = isoDate();

  const caloriesToday = useMemo(() => meals.filter(m => m.dateISO === today).reduce((a,b)=>a+(b.calories||0),0), [meals, today]);
  const movement = useMemo(() => calorieToMovement(profile, caloriesToday), [profile, caloriesToday]);

  const weekStart = useMemo(() => getWeekStartISO(new Date()), []);
  const weeklyCalories = useMemo(() => caloriesInWeek(meals, weekStart), [meals, weekStart]);
  const weeklyTargetSum = movement.calorieTarget * 7;
  const weekly = useMemo(() => weeklyDeficitGate(weeklyTargetSum, weeklyCalories), [weeklyTargetSum, weeklyCalories]);

  useEffect(() => { (async () => {
    const res = await getTodayStepsHealthConnect();
    setStepsToday(res.steps);
  })(); }, []);

  useEffect(() => {
    const decision = shouldSendEveningNudge({
      now: new Date(),
      caloriesIn: caloriesToday,
      calorieTarget: movement.calorieTarget,
      stepsToday,
      stepTarget: behavior.dynamicStepTarget,
      weeklyDeficitSufficient: weekly.isSufficient,
      nudgesLast7d: nudges.slice(0, 7)
    });

    if (decision.send) {
      fireNudge("NutriWalk AI", `Gentle nudge: ${movement.steps} extra steps (~${movement.minutes} min) can balance today.`)
        .then(() => addNudgeLog({ id: String(Date.now()), dateISO: today, decision: "sent", userAction: "unknown" }))
        .catch(() => {});
    }
  }, [caloriesToday, stepsToday, behavior.dynamicStepTarget, weekly.isSufficient]);

  return (
    <ScrollView contentContainerStyle={ui.screen}>
      <View style={ui.card}>
        <Text style={ui.h1}>Today</Text>
        <Text style={ui.text}>Calories eaten: <Text style={{ fontWeight: "700" }}>{caloriesToday}</Text></Text>
        <Text style={ui.text}>Steps today: <Text style={{ fontWeight: "700" }}>{stepsToday}</Text> (target {behavior.dynamicStepTarget})</Text>
        <Text style={ui.small}>Weekly deficit: {Math.round(weekly.weeklyDeficit)} kcal • {weekly.advisory}</Text>
      </View>

      <View style={ui.card}>
        <Text style={ui.h2}>Calorie → Movement suggestion</Text>
        <Text style={ui.text}>Calorie target: {movement.calorieTarget} kcal</Text>
        <Text style={ui.text}>Surplus today: {movement.surplus} kcal</Text>
        <Text style={ui.text}>Suggested: {movement.steps} steps (~{movement.minutes} min, {movement.km} km)</Text>
        <Text style={ui.small}>Not a punishment system. You’re welcome.</Text>
      </View>

      <View style={ui.row}>
        <Pressable style={ui.button} onPress={() => navigation.navigate("MealCapture")}>
          <Text style={ui.btnText}>Log Meal (Photo)</Text>
        </Pressable>
        <Pressable style={ui.button} onPress={() => navigation.navigate("Weight")}>
          <Text style={ui.btnText}>Log Weight</Text>
        </Pressable>
      </View>

      <View style={ui.row}>
        <Pressable style={ui.button} onPress={() => navigation.navigate("Insights")}>
          <Text style={ui.btnText}>Weekly Insights</Text>
        </Pressable>
        <Pressable style={ui.button} onPress={() => navigation.navigate("Settings")}>
          <Text style={ui.btnText}>Settings</Text>
        </Pressable>
      </View>
    </ScrollView>
  );
}
