import { MealLog } from "../models/types";

export function weeklyDeficitGate(weeklyTargetSum: number, weeklyCaloriesIn: number) {
  const weeklyDeficit = weeklyTargetSum - weeklyCaloriesIn;
  return {
    weeklyDeficit,
    isSufficient: weeklyDeficit >= 500,
    advisory:
      weeklyDeficit >= 500
        ? "Weekly deficit looks fine. No aggressive compensation needed."
        : "Weekly deficit is low. Gentle extra movement might help."
  };
}

export function getWeekStartISO(date = new Date()): string {
  const d = new Date(date);
  const day = d.getDay();
  const diff = (day === 0 ? -6 : 1) - day;
  d.setDate(d.getDate() + diff);
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}

export function caloriesInWeek(meals: MealLog[], weekStartISO: string): number {
  const start = new Date(weekStartISO + "T00:00:00");
  const end = new Date(start); end.setDate(end.getDate() + 7);
  return meals.filter(m => {
    const d = new Date(m.dateISO + "T00:00:00");
    return d >= start && d < end;
  }).reduce((a,b)=>a+(b.calories||0),0);
}
