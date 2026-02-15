import express from "express";
import multer from "multer";
import { z } from "zod";
import fetch from "node-fetch";
import FormData from "form-data";

const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 6 * 1024 * 1024 } });

export const mealsRouter = express.Router();

mealsRouter.post("/analyze-upload", upload.single("image"), async (req, res) => {
  try {
    const key = process.env.LOGMEAL_API_KEY;
    if (!key) return res.status(400).json({ error: "LOGMEAL_API_KEY missing" });
    if (!req.file) return res.status(400).json({ error: "image is required" });

    const url = "https://api.logmeal.es/v2/image/segmentation/complete";

    const form = new FormData();
    form.append("image", req.file.buffer, { filename: req.file.originalname || "meal.jpg", contentType: req.file.mimetype });

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    const resp = await fetch(url, {
      method: "POST",
      headers: { "Authorization": `Bearer ${key}`, ...form.getHeaders() },
      body: form,
      signal: controller.signal
    }).finally(() => clearTimeout(timeout));

    if (!resp.ok) {
      const text = await resp.text().catch(() => "");
      return res.status(502).json({ error: "LogMeal error", status: resp.status, detail: text.slice(0, 500) });
    }

    const data = await resp.json();

    const items = (data?.foodName || data?.foods || data?.recognized || []).map((it) => {
      const name = it?.name || it?.foodName || it?.label || "Unknown";
      const calories = Number(it?.calories || it?.kcal || it?.nutritional_info?.calories || 0);
      const confidence = Number(it?.confidence || it?.score || 0);
      return { name, calories, confidence };
    });

    res.json({
      raw: data,
      items: items.length ? items : [{ name: "Unknown item", calories: 0, confidence: 0.0 }]
    });
  } catch (e) {
    const msg = (e && e.name === "AbortError") ? "LogMeal timeout (>5s)" : (e?.message || "Unknown error");
    res.status(500).json({ error: msg });
  }
});

mealsRouter.post("/normalize", async (req, res) => {
  const schema = z.object({ items: z.array(z.object({ name: z.string().min(1) })).min(1) });
  const parsed = schema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json({ error: "invalid body", detail: parsed.error.flatten() });

  res.json({
    items: parsed.data.items.map(i => ({
      name: i.name, calories: 0, protein: 0, carbs: 0, fat: 0, source: "stub"
    }))
  });
});
