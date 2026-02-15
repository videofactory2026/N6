import React, { useMemo, useState } from "react";
import { View, Text, TextInput, Pressable, ScrollView } from "react-native";
import { ui } from "../ui/ui";
import { useAppState } from "../state/AppState";
import { LineChart } from "react-native-chart-kit";
import { Dimensions } from "react-native";

function isoToday() {
  const d = new Date();
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

function movingAverage(values: number[], window = 7) {
  return values.map((_, i) => {
    const start = Math.max(0, i - window + 1);
    const slice = values.slice(start, i + 1);
    return slice.reduce((a,b)=>a+b,0) / slice.length;
  });
}

export function WeightScreen() {
  const { weights, addWeight } = useAppState();
  const [val, setVal] = useState("");

  const sorted = useMemo(() => [...weights].sort((a,b)=>a.dateISO.localeCompare(b.dateISO)), [weights]);
  const labels = sorted.slice(-14).map(w => w.dateISO.slice(5));
  const data = sorted.slice(-14).map(w => w.weightKg);
  const ma = movingAverage(data, 7);

  const plateau = useMemo(() => {
    if (data.length < 14) return false;
    const first = data[data.length - 14];
    const last = data[data.length - 1];
    return (first - last) < 0.3;
  }, [data]);

  function save() {
    const n = Number(val);
    if (!n || n < 20 || n > 300) return;
    addWeight({ dateISO: isoToday(), weightKg: n });
    setVal("");
  }

  return (
    <ScrollView contentContainerStyle={ui.screen}>
      <View style={ui.card}>
        <Text style={ui.h2}>Log today’s weight</Text>
        <TextInput style={ui.input} value={val} onChangeText={setVal} keyboardType="numeric" placeholder="e.g., 78.5" />
        <Pressable style={ui.button} onPress={save}>
          <Text style={ui.btnText}>Save Weight</Text>
        </Pressable>
        {plateau && <Text style={{ marginTop: 8, color: "crimson" }}>Plateau detected (14 days). Consider small routine changes.</Text>}
      </View>

      {data.length >= 2 && (
        <View style={ui.card}>
          <Text style={ui.h2}>Trend (last 14 logs)</Text>
          <LineChart
            data={{ labels, datasets: [{ data }, { data: ma }] }}
            width={Dimensions.get("window").width - 60}
            height={220}
            yAxisSuffix="kg"
            chartConfig={{
              backgroundGradientFrom: "#ffffff",
              backgroundGradientTo: "#ffffff",
              decimalPlaces: 1,
              color: (o=1) => `rgba(0, 0, 0, ${o})`,
              labelColor: (o=1) => `rgba(0, 0, 0, ${o})`,
              propsForDots: { r: "2" }
            }}
            bezier
            style={{ marginTop: 10, borderRadius: 12 }}
          />
          <Text style={ui.small}>Second line is 7-day moving average.</Text>
        </View>
      )}
    </ScrollView>
  );
}
