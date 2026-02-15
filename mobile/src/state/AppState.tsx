import React, { createContext, useContext, useEffect, useMemo, useState } from "react";
import { BehaviorProfile, MealLog, NudgeLog, UserProfile, WeightLog } from "../models/types";
import { getEncryptedJSON, setEncryptedJSON, deleteEncryptedKey } from "../services/encryptedStorage";
import { defaultBehaviorProfile, updateBehaviorProfile } from "../services/learningEngine";

type AppStateShape = {
  profile: UserProfile;
  setProfile: (p: UserProfile) => void;

  meals: MealLog[];
  addMeal: (m: MealLog) => void;
  updateMeal: (m: MealLog) => void;

  weights: WeightLog[];
  addWeight: (w: WeightLog) => void;

  behavior: BehaviorProfile;
  refreshBehavior: (stepsLast7d: number[]) => void;

  nudges: NudgeLog[];
  addNudgeLog: (n: NudgeLog) => void;

  settings: { aiLoggingEnabled: boolean };
  setSettings: (s: { aiLoggingEnabled: boolean }) => void;

  resetAll: () => Promise<void>;
};

const AppStateCtx = createContext<AppStateShape | null>(null);

const K_PROFILE = "profile";
const K_MEALS = "meals";
const K_WEIGHTS = "weights";
const K_BEHAVIOR = "behavior";
const K_NUDGES = "nudges";
const K_SETTINGS = "settings";

const defaultProfile: UserProfile = { age: 30, heightCm: 170, weightKg: 80, goalWeightKg: 75, activityLevel: "light" };

export function AppProvider({ children }: { children: React.ReactNode }) {
  const [profile, setProfile] = useState<UserProfile>(defaultProfile);
  const [meals, setMeals] = useState<MealLog[]>([]);
  const [weights, setWeights] = useState<WeightLog[]>([]);
  const [behavior, setBehavior] = useState<BehaviorProfile>(defaultBehaviorProfile());
  const [nudges, setNudges] = useState<NudgeLog[]>([]);
  const [settings, setSettings] = useState({ aiLoggingEnabled: true });

  useEffect(() => {
    (async () => {
      setProfile(await getEncryptedJSON(K_PROFILE, defaultProfile));
      setMeals(await getEncryptedJSON(K_MEALS, []));
      setWeights(await getEncryptedJSON(K_WEIGHTS, []));
      setBehavior(await getEncryptedJSON(K_BEHAVIOR, defaultBehaviorProfile()));
      setNudges(await getEncryptedJSON(K_NUDGES, []));
      setSettings(await getEncryptedJSON(K_SETTINGS, { aiLoggingEnabled: true }));
    })();
  }, []);

  useEffect(() => { setEncryptedJSON(K_PROFILE, profile); }, [profile]);
  useEffect(() => { setEncryptedJSON(K_MEALS, meals); }, [meals]);
  useEffect(() => { setEncryptedJSON(K_WEIGHTS, weights); }, [weights]);
  useEffect(() => { setEncryptedJSON(K_BEHAVIOR, behavior); }, [behavior]);
  useEffect(() => { setEncryptedJSON(K_NUDGES, nudges); }, [nudges]);
  useEffect(() => { setEncryptedJSON(K_SETTINGS, settings); }, [settings]);

  function addMeal(m: MealLog) { setMeals(prev => [m, ...prev]); }
  function updateMeal(m: MealLog) { setMeals(prev => prev.map(x => x.id === m.id ? m : x)); }
  function addWeight(w: WeightLog) { setWeights(prev => [...prev.filter(x => x.dateISO !== w.dateISO), w].sort((a,b)=>a.dateISO.localeCompare(b.dateISO))); }
  function addNudgeLog(n: NudgeLog) { setNudges(prev => [n, ...prev]); }

  function refreshBehavior(stepsLast7d: number[]) {
    const nudgesLast7d = nudges.slice(0, 7);
    setBehavior(prev => updateBehaviorProfile(prev, stepsLast7d, nudgesLast7d));
  }

  async function resetAll() {
    setProfile(defaultProfile);
    setMeals([]);
    setWeights([]);
    setBehavior(defaultBehaviorProfile());
    setNudges([]);
    setSettings({ aiLoggingEnabled: true });

    await deleteEncryptedKey(K_PROFILE);
    await deleteEncryptedKey(K_MEALS);
    await deleteEncryptedKey(K_WEIGHTS);
    await deleteEncryptedKey(K_BEHAVIOR);
    await deleteEncryptedKey(K_NUDGES);
    await deleteEncryptedKey(K_SETTINGS);
  }

  const value = useMemo(() => ({
    profile, setProfile,
    meals, addMeal, updateMeal,
    weights, addWeight,
    behavior, refreshBehavior,
    nudges, addNudgeLog,
    settings, setSettings,
    resetAll
  }), [profile, meals, weights, behavior, nudges, settings]);

  return <AppStateCtx.Provider value={value}>{children}</AppStateCtx.Provider>;
}

export function useAppState() {
  const ctx = useContext(AppStateCtx);
  if (!ctx) throw new Error("AppState not mounted");
  return ctx;
}
