import React, { useMemo, useState } from "react";
import { View, Text, Pressable, TextInput, ScrollView, ActivityIndicator } from "react-native";
import * as ImagePicker from "expo-image-picker";
import { ui } from "../ui/ui";
import { analyzeMealPhoto } from "../services/foodRecognitionService";
import { useAppState } from "../state/AppState";
import { MealItem, MealLog } from "../models/types";

function isoToday() {
  const d = new Date();
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

export function MealCaptureScreen() {
  const { addMeal, settings } = useAppState();
  const [busy, setBusy] = useState(false);
  const [items, setItems] = useState<MealItem[]>([]);
  const [portion, setPortion] = useState("1.0");
  const [error, setError] = useState<string | null>(null);

  const calories = useMemo(() => {
    const p = Math.min(2, Math.max(0.5, Number(portion || "1") || 1));
    return Math.round(items.reduce((a,b)=>a + (b.calories||0), 0) * p);
  }, [items, portion]);

  async function pickAndAnalyze() {
    setError(null);
    const perm = await ImagePicker.requestCameraPermissionsAsync();
    if (perm.status !== "granted") { setError("Camera permission needed."); return; }

    const res = await ImagePicker.launchCameraAsync({ quality: 0.7 });
    if (res.canceled) return;

    const uri = res.assets[0].uri;
    setBusy(true);
    try {
      if (!settings.aiLoggingEnabled) {
        setItems([{ name: "AI logging disabled (manual entry)", calories: 0, confidence: 0 }]);
        return;
      }
      const out = await analyzeMealPhoto(uri);
      setItems((out.items || []).map((i: any) => ({
        name: i.name,
        calories: Number(i.calories || 0),
        confidence: Number(i.confidence || 0)
      })));
    } catch (e: any) {
      setError(e?.message || "Failed to analyze");
      setItems([{ name: "Manual entry", calories: 0, confidence: 0 }]);
    } finally {
      setBusy(false);
    }
  }

  function updateItem(idx: number, field: "name" | "calories", value: string) {
    setItems(prev => prev.map((it, i) => {
      if (i !== idx) return it;
      if (field === "name") return { ...it, name: value };
      return { ...it, calories: Number(value || 0) };
    }));
  }

  function saveMeal() {
    const meal: MealLog = { id: String(Date.now()), dateISO: isoToday(), items, calories };
    addMeal(meal);
    setItems([]);
    setPortion("1.0");
    setError(null);
  }

  return (
    <ScrollView contentContainerStyle={ui.screen}>
      <View style={ui.card}>
        <Text style={ui.h2}>Capture meal photo</Text>
        <Pressable style={ui.button} onPress={pickAndAnalyze} disabled={busy}>
          <Text style={ui.btnText}>{busy ? "Analyzing..." : "Take Photo & Analyze"}</Text>
        </Pressable>
        {busy && <ActivityIndicator style={{ marginTop: 10 }} />}
        {!!error && <Text style={{ color: "crimson", marginTop: 8 }}>{error}</Text>}
        <Text style={ui.small}>AI guesses. You correct. Reality stays undefeated.</Text>
      </View>

      <View style={ui.card}>
        <Text style={ui.h2}>Results (editable)</Text>
        {items.map((it, idx) => (
          <View key={idx} style={{ gap: 6, marginTop: 10 }}>
            <TextInput style={ui.input} value={it.name} onChangeText={(v) => updateItem(idx, "name", v)} placeholder="Food name" />
            <TextInput style={ui.input} value={String(it.calories)} onChangeText={(v) => updateItem(idx, "calories", v)} placeholder="Calories" keyboardType="numeric" />
            <Text style={ui.small}>Confidence: {(it.confidence ?? 0).toFixed(2)}</Text>
          </View>
        ))}

        <View style={{ marginTop: 12, gap: 6 }}>
          <Text style={ui.text}>Portion multiplier (0.5x–2x)</Text>
          <TextInput style={ui.input} value={portion} onChangeText={setPortion} keyboardType="numeric" />
          <Text style={ui.text}>Total calories: <Text style={{ fontWeight: "700" }}>{calories}</Text></Text>
        </View>

        <Pressable style={[ui.button, { marginTop: 12 }]} onPress={saveMeal} disabled={!items.length}>
          <Text style={ui.btnText}>Save Meal</Text>
        </Pressable>
      </View>
    </ScrollView>
  );
}
