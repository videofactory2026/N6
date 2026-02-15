export type ActivityLevel = "sedentary" | "light" | "moderate" | "active";

export type UserProfile = {
  age: number;
  heightCm: number;
  weightKg: number;
  goalWeightKg?: number;
  activityLevel: ActivityLevel;
};

export type MealItem = {
  name: string;
  calories: number;
  confidence?: number;
  protein?: number;
  carbs?: number;
  fat?: number;
};

export type MealLog = {
  id: string;
  dateISO: string; // YYYY-MM-DD
  items: MealItem[];
  calories: number;
};

export type WeightLog = { dateISO: string; weightKg: number; };

export type BehaviorProfile = {
  avgSteps7d: number;
  complianceRate: number;
  ignoreRate: number;
  dynamicStepTarget: number;
  preferredActiveHour: number;
};

export type NudgeLog = {
  id: string;
  dateISO: string;
  decision: "sent" | "suppressed" | "skipped";
  userAction: "opened" | "ignored" | "unknown";
};
