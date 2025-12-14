# 🚀 Szybka Migracja - 3 Kroki

## 1️⃣ Skopiuj folder

```bash
cp -r agent-methodology-pack /path/to/new-project/
cd /path/to/new-project
```

---

## 2️⃣ Uruchom Claude Code i wklej TO:

```
@agent-methodology-pack/ORCHESTRATOR-MIGRATION-TASK.md
@agent-methodology-pack/.claude/agents/ORCHESTRATOR.md

Jestem ORCHESTRATOR. Wykonaj pełną migrację Agent Methodology Pack zgodnie z ORCHESTRATOR-MIGRATION-TASK.md.

Deleguj wszystkie fazy (1-5) do odpowiednich agentów w trybie semi-auto.
```

---

## 3️⃣ Czekaj ~2 godziny

ORCHESTRATOR:
- ✅ Setup środowiska (devops-agent)
- ✅ Inicjalizacja cache (senior-dev)
- ✅ Review agentów (architect-agent)
- ✅ Update agentów (backend/frontend-dev)
- ✅ Testy (test-engineer + qa-agent)
- ✅ Dokumentacja (tech-writer + doc-auditor)
- ✅ Final summary

---

## Po zakończeniu:

```bash
# Sprawdź cache
bash scripts/cache-stats.sh

# Zrestartuj Claude Code (dla MCP tools)
# Testuj agentów!
```

---

**To wszystko!**

Szczegóły: `START-MIGRATION.md` lub `ORCHESTRATOR-MIGRATION-TASK.md`
