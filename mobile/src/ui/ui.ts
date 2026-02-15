import { StyleSheet } from "react-native";

export const ui = StyleSheet.create({
  screen: { flexGrow: 1, padding: 16, gap: 12 },
  row: { flexDirection: "row", gap: 10, alignItems: "center", flexWrap: "wrap" },
  card: { padding: 12, borderRadius: 12, borderWidth: 1, borderColor: "#ddd", backgroundColor: "#fff" },
  h1: { fontSize: 22, fontWeight: "700" },
  h2: { fontSize: 16, fontWeight: "700" },
  text: { fontSize: 14 },
  small: { fontSize: 12, color: "#666" },
  button: { paddingVertical: 10, paddingHorizontal: 12, borderRadius: 10, borderWidth: 1, borderColor: "#222", alignSelf: "flex-start" },
  btnText: { fontWeight: "700" },
  input: { borderWidth: 1, borderColor: "#ccc", borderRadius: 10, padding: 10, fontSize: 14, backgroundColor: "#fff" }
});
