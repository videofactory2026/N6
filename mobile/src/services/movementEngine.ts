import { UserProfile } from "../models/types";

export function calcBMR(profile: UserProfile, sex: "male" | "female" = "male"): number {
  const w = profile.weightKg;
  const h = profile.heightCm;
  const a = profile.age;
  const s = sex === "male" ? 5 : -161;
  return 10 * w + 6.25 * h - 5 * a + s;
}

export function activityMultiplier(level: UserProfile["activityLevel"]): number {
  switch (level) {
    case "sedentary": return 1.2;
    case "light": return 1.375;
    case "moderate": return 1.55;
    case "active": return 1.725;
    default: return 1.2;
  }
}

export function kcalPerKm(weightKg: number): number {
  return 0.7 * weightKg;
}

export function stepsPerKm(heightCm: number): number {
  const base = 1450;
  const adjust = (170 - heightCm) * 3;
  const val = base + adjust;
  return Math.min(1800, Math.max(1100, Math.round(val)));
}

export function calorieToMovement(profile: UserProfile, caloriesIn: number, sex: "male" | "female" = "male") {
  const bmr = calcBMR(profile, sex);
  const tdee = bmr * activityMultiplier(profile.activityLevel);
  const target = tdee - 500;

  const surplus = Math.max(0, caloriesIn - target);
  const km = surplus / kcalPerKm(profile.weightKg);
  const steps = Math.round(km * stepsPerKm(profile.heightCm));
  const minutes = Math.round(km * 12);

  return {
    bmr: Math.round(bmr),
    tdee: Math.round(tdee),
    calorieTarget: Math.round(target),
    surplus: Math.round(surplus),
    km: Number(km.toFixed(2)),
    steps,
    minutes
  };
}
