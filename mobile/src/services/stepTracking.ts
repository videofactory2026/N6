import { Pedometer } from "expo-sensors";

export type StepsResult = { steps: number; source: "healthconnect" | "pedometer" };

export async function getTodayStepsFallback(): Promise<StepsResult> {
  const isAvailable = await Pedometer.isAvailableAsync();
  if (!isAvailable) return { steps: 0, source: "pedometer" };
  const start = new Date(); start.setHours(0,0,0,0);
  const end = new Date();
  const res = await Pedometer.getStepCountAsync(start, end);
  return { steps: res.steps || 0, source: "pedometer" };
}

export async function getTodayStepsHealthConnect(): Promise<StepsResult> {
  // Placeholder hook for Health Connect integration later.
  return getTodayStepsFallback();
}
