import * as FileSystem from "expo-file-system";
import Constants from "expo-constants";

export type AnalyzedMealItem = { name: string; calories: number; confidence: number };

export async function analyzeMealPhoto(uri: string): Promise<{ items: AnalyzedMealItem[]; raw?: any }> {
  const baseUrl =
    (process.env.EXPO_PUBLIC_API_BASE_URL as string) ||
    ((Constants.expoConfig as any)?.extra?.EXPO_PUBLIC_API_BASE_URL as string) ||
    "";

  if (!baseUrl) throw new Error("EXPO_PUBLIC_API_BASE_URL not set");

  const url = `${baseUrl.replace(/\/$/, "")}/v1/meals/analyze-upload`;

  const info = await FileSystem.getInfoAsync(uri);
  if (!info.exists) throw new Error("Image file missing");

  const formData = new FormData();
  // @ts-ignore
  formData.append("image", { uri, name: "meal.jpg", type: "image/jpeg" });

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 5500);

  const resp = await fetch(url, { method: "POST", body: formData, signal: controller.signal as any }).finally(() => clearTimeout(timeout));
  if (!resp.ok) {
    const text = await resp.text().catch(() => "");
    throw new Error(`Analyze failed (${resp.status}): ${text.slice(0, 200)}`);
  }
  return await resp.json();
}
