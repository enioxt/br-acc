import { useEffect, useState } from "react";

interface TimelineEntry {
  date: string;
  title: string;
  description: string;
  tags?: string[];
}

const TAG_COLORS: Record<string, string> = {
  feature: "#22c55e",
  infrastructure: "#3b82f6",
  data: "#f59e0b",
  ai: "#a855f7",
  governance: "#ef4444",
  security: "#ef4444",
  foundation: "#6366f1",
  frontend: "#06b6d4",
  api: "#14b8a6",
};

export function UpdatesTimeline() {
  const [entries, setEntries] = useState<TimelineEntry[]>([]);
  const [showAll, setShowAll] = useState(false);

  useEffect(() => {
    fetch("/updates/timeline.json")
      .then((r) => (r.ok ? r.json() : []))
      .then((data: TimelineEntry[]) => {
        setEntries(data.sort((a, b) => b.date.localeCompare(a.date)));
      })
      .catch(() => setEntries([]));
  }, []);

  if (entries.length === 0) return null;

  const visible = showAll ? entries : entries.slice(0, 5);

  return (
    <section style={{ padding: "3rem 1.5rem", maxWidth: 900, margin: "0 auto" }}>
      <span style={{ display: "block", fontSize: "0.75rem", textTransform: "uppercase", letterSpacing: "0.1em", color: "#94a3b8", marginBottom: "0.5rem" }}>
        Historico Completo
      </span>
      <h2 style={{ fontSize: "1.5rem", fontWeight: 700, color: "#f1f5f9", marginBottom: "0.25rem" }}>
        Linha do Tempo
      </h2>
      <p style={{ fontSize: "0.8125rem", color: "#64748b", marginBottom: "1.5rem" }}>
        {entries.length} marcos desde o fork do Bruno ({entries[entries.length - 1]?.date})
      </p>

      <div style={{ position: "relative", paddingLeft: "1.5rem" }}>
        {/* Vertical line */}
        <div style={{ position: "absolute", left: 5, top: 8, bottom: 8, width: 2, background: "rgba(71,85,105,0.3)" }} />

        {visible.map((e, i) => (
          <div key={`${e.date}-${i}`} style={{ position: "relative", marginBottom: "1.25rem" }}>
            {/* Dot */}
            <div style={{ position: "absolute", left: "-1.5rem", top: 6, width: 12, height: 12, borderRadius: "50%", background: i === 0 ? "#3b82f6" : "rgba(71,85,105,0.5)", border: i === 0 ? "2px solid #60a5fa" : "2px solid rgba(71,85,105,0.3)" }} />

            <div style={{ background: i === 0 ? "rgba(30,58,95,0.4)" : "rgba(30,41,59,0.5)", border: i === 0 ? "1px solid rgba(59,130,246,0.3)" : "1px solid rgba(71,85,105,0.2)", borderRadius: 8, padding: "0.75rem 1rem" }}>
              <span style={{ fontSize: "0.625rem", color: "#64748b" }}>{e.date}</span>
              <h3 style={{ fontSize: "0.875rem", fontWeight: 600, color: "#e2e8f0", margin: "0.125rem 0 0.25rem" }}>{e.title}</h3>
              <p style={{ fontSize: "0.75rem", color: "#94a3b8", margin: 0, lineHeight: 1.4 }}>{e.description}</p>
              {e.tags && (
                <div style={{ display: "flex", gap: "0.25rem", flexWrap: "wrap", marginTop: "0.375rem" }}>
                  {e.tags.map((tag) => (
                    <span key={tag} style={{ fontSize: "0.5625rem", padding: "0.0625rem 0.375rem", borderRadius: 999, background: `${TAG_COLORS[tag] || "#475569"}20`, color: TAG_COLORS[tag] || "#94a3b8", border: `1px solid ${TAG_COLORS[tag] || "#475569"}30` }}>
                      {tag}
                    </span>
                  ))}
                </div>
              )}
            </div>
          </div>
        ))}
      </div>

      {entries.length > 5 && (
        <button onClick={() => setShowAll(!showAll)} style={{ fontSize: "0.75rem", color: "#3b82f6", background: "none", border: "none", cursor: "pointer", marginTop: "0.5rem", padding: 0 }}>
          {showAll ? "Mostrar menos \u25B2" : `Ver todos os ${entries.length} marcos \u25BC`}
        </button>
      )}
    </section>
  );
}
