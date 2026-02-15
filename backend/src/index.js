import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { mealsRouter } from "./routes/meals.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json({ limit: "1mb" }));

app.get("/health", (_, res) => res.json({ ok: true, name: "nutriwalk-backend" }));
app.use("/v1/meals", mealsRouter);

const port = process.env.PORT || 4000;
app.listen(port, () => console.log(`[backend] listening on :${port}`));
