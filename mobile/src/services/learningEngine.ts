import { BehaviorProfile, NudgeLog } from "../models/types";

export function defaultBehaviorProfile(): BehaviorProfile {
  return { avgSteps7d: 0, complianceRate: 0.5, ignoreRate: 0.0, dynamicStepTarget: 9000, preferredActiveHour: 18 };
}

export function updateBehaviorProfile(profile: BehaviorProfile, stepsLast7d: number[], nudgesLast7d: NudgeLog[]): BehaviorProfile {
  const avg = stepsLast7d.length ? Math.round(stepsLast7d.reduce((a,b)=>a+b,0) / stepsLast7d.length) : profile.avgSteps7d;

  const sent = nudgesLast7d.filter(n => n.decision === "sent").length;
  const ignored = nudgesLast7d.filter(n => n.userAction === "ignored").length;
  const ignoreRate = sent ? ignored / sent : profile.ignoreRate;

  const met = stepsLast7d.filter(s => s >= profile.dynamicStepTarget).length;
  const complianceRate = stepsLast7d.length ? met / stepsLast7d.length : profile.complianceRate;

  let dynamicStepTarget = profile.dynamicStepTarget;
  if (complianceRate >= 0.7) dynamicStepTarget = Math.min(12000, dynamicStepTarget + 500);
  if (complianceRate <= 0.4) dynamicStepTarget = Math.max(8000, dynamicStepTarget - 500);

  return { ...profile, avgSteps7d: avg, complianceRate: Number(complianceRate.toFixed(2)), ignoreRate: Number(ignoreRate.toFixed(2)), dynamicStepTarget };
}
