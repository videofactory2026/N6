import * as Notifications from "expo-notifications";
import { NudgeLog } from "../models/types";

Notifications.setNotificationHandler({
  handleNotification: async () => ({ shouldShowAlert: true, shouldPlaySound: false, shouldSetBadge: false })
});

export async function configureNotifications() {
  const { status } = await Notifications.getPermissionsAsync();
  if (status !== "granted") await Notifications.requestPermissionsAsync();
}

export type NudgeDecisionInput = {
  now: Date;
  caloriesIn: number;
  calorieTarget: number;
  stepsToday: number;
  stepTarget: number;
  weeklyDeficitSufficient: boolean;
  nudgesLast7d: NudgeLog[];
};

export function shouldSendEveningNudge(input: NudgeDecisionInput) {
  const hour = input.now.getHours();
  if (hour < 20 || hour >= 21) return { send: false as const, reason: "outside_window" };

  const overCalories = input.caloriesIn > input.calorieTarget;
  const underSteps = input.stepsToday < input.stepTarget;
  if (!overCalories && !underSteps) return { send: false as const, reason: "no_need" };

  if (input.weeklyDeficitSufficient) return { send: false as const, reason: "weekly_gate_ok" };

  const todayISO = toISODate(input.now);
  const todaySent = input.nudgesLast7d.some(n => n.dateISO === todayISO && n.decision === "sent");
  if (todaySent) return { send: false as const, reason: "already_sent_today" };

  const ignored = input.nudgesLast7d.filter(n => n.userAction === "ignored").length;
  if (ignored >= 3) return { send: false as const, reason: "suppressed_ignored" };

  return { send: true as const, reason: "conditions_met" };
}

export async function fireNudge(title: string, body: string) {
  await Notifications.scheduleNotificationAsync({ content: { title, body }, trigger: null });
}

function toISODate(d: Date) {
  const yyyy = d.getFullYear();
  const mm = String(d.getMonth() + 1).padStart(2, "0");
  const dd = String(d.getDate()).padStart(2, "0");
  return `${yyyy}-${mm}-${dd}`;
}
