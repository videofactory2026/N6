import React, { useState } from "react";
import { View, Text, Pressable, Switch, Alert, ScrollView, TextInput } from "react-native";
import { ui } from "../ui/ui";
import { useAppState } from "../state/AppState";
import { ActivityLevel } from "../models/types";

export function SettingsScreen() {
  const { profile, setProfile, settings, setSettings, resetAll } = useAppState();
  const [age, setAge] = useState(String(profile.age));
  const [height, setHeight] = useState(String(profile.heightCm));
  const [weight, setWeight] = useState(String(profile.weightKg));
  const [activity, setActivity] = useState<ActivityLevel>(profile.activityLevel);

  function saveProfile() {
    const a = Number(age); const h = Number(height); const w = Number(weight);
    if (!a || !h || !w) return;
    setProfile({ ...profile, age: a, heightCm: h, weightKg: w, activityLevel: activity });
    Alert.alert("Saved", "Profile updated.");
  }

  return (
    <ScrollView contentContainerStyle={ui.screen}>
      <View style={ui.card}>
        <Text style={ui.h2}>Privacy controls</Text>
        <View style={[ui.row, { justifyContent: "space-between" }]}>
          <Text style={ui.text}>Enable AI meal logging</Text>
          <Switch value={settings.aiLoggingEnabled} onValueChange={(v) => setSettings({ aiLoggingEnabled: v })} />
        </View>
        <Text style={ui.small}>You can still log meals manually if AI is disabled.</Text>
      </View>

      <View style={ui.card}>
        <Text style={ui.h2}>User profile</Text>
        <Text style={ui.small}>Used for BMR/TDEE and step estimates.</Text>

        <Text style={[ui.text, { marginTop: 10 }]}>Age</Text>
        <TextInput style={ui.input} value={age} onChangeText={setAge} keyboardType="numeric" />
        <Text style={[ui.text, { marginTop: 10 }]}>Height (cm)</Text>
        <TextInput style={ui.input} value={height} onChangeText={setHeight} keyboardType="numeric" />
        <Text style={[ui.text, { marginTop: 10 }]}>Weight (kg)</Text>
        <TextInput style={ui.input} value={weight} onChangeText={setWeight} keyboardType="numeric" />

        <Text style={[ui.text, { marginTop: 10 }]}>Activity level</Text>
        <View style={[ui.row, { flexWrap: "wrap" }]}>
          {(["sedentary","light","moderate","active"] as ActivityLevel[]).map(lvl => (
            <Pressable key={lvl} style={[ui.button, { borderColor: activity === lvl ? "#222" : "#ccc" }]} onPress={() => setActivity(lvl)}>
              <Text style={ui.btnText}>{lvl}</Text>
            </Pressable>
          ))}
        </View>

        <Pressable style={[ui.button, { marginTop: 12 }]} onPress={saveProfile}>
          <Text style={ui.btnText}>Save Profile</Text>
        </Pressable>
      </View>

      <View style={ui.card}>
        <Text style={ui.h2}>Danger zone</Text>
        <Pressable
          style={[ui.button, { borderColor: "crimson" }]}
          onPress={() => Alert.alert("Delete all data?", "This removes meals, weights, learning and settings.", [
            { text: "Cancel", style: "cancel" },
            { text: "Delete", style: "destructive", onPress: () => resetAll().catch(()=>{}) }
          ])}
        >
          <Text style={[ui.btnText, { color: "crimson" }]}>Delete all local data</Text>
        </Pressable>
        <Text style={ui.small}>Sometimes the best habit is deleting the app. But you wanted AI, so.</Text>
      </View>
    </ScrollView>
  );
}
