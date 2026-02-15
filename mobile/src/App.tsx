import React, { useEffect } from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { SafeAreaProvider } from "react-native-safe-area-context";

import { HomeScreen } from "./screens/HomeScreen";
import { MealCaptureScreen } from "./screens/MealCaptureScreen";
import { WeightScreen } from "./screens/WeightScreen";
import { InsightsScreen } from "./screens/InsightsScreen";
import { SettingsScreen } from "./screens/SettingsScreen";
import { AppProvider } from "./state/AppState";
import { configureNotifications } from "./services/nudgeEngine";

export type RootStackParamList = {
  Home: undefined;
  MealCapture: undefined;
  Weight: undefined;
  Insights: undefined;
  Settings: undefined;
};

const Stack = createNativeStackNavigator<RootStackParamList>();

export default function App() {
  useEffect(() => { configureNotifications().catch(() => {}); }, []);

  return (
    <SafeAreaProvider>
      <AppProvider>
        <NavigationContainer>
          <Stack.Navigator>
            <Stack.Screen name="Home" component={HomeScreen} options={{ title: "NutriWalk AI" }} />
            <Stack.Screen name="MealCapture" component={MealCaptureScreen} options={{ title: "AI Meal Recognition" }} />
            <Stack.Screen name="Weight" component={WeightScreen} options={{ title: "Daily Weight" }} />
            <Stack.Screen name="Insights" component={InsightsScreen} options={{ title: "Weekly Insights" }} />
            <Stack.Screen name="Settings" component={SettingsScreen} options={{ title: "Settings" }} />
          </Stack.Navigator>
        </NavigationContainer>
      </AppProvider>
    </SafeAreaProvider>
  );
}
