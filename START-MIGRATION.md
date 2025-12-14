# START HERE - Pełna Migracja Agent Methodology Pack

**Czas:** 1.5-2 godziny (automatycznie przez ORCHESTRATOR)
**Cel:** Pełny system agentów + cache w nowym projekcie

---

## KROK 1: Skopiuj Agent Methodology Pack

```bash
# Przykład
cp -r agent-methodology-pack /path/to/your-new-project/.claude
cd /path/to/your-new-project
```

Lub po prostu skopiuj cały folder `agent-methodology-pack` do nowego projektu.

---

## KROK 2: Uruchom Claude Code w Nowym Projekcie

```bash
cd /path/to/your-new-project
# Uruchom Claude Code tutaj
```

---

## KROK 3: Zlecenie ORCHESTRATOR

Skopiuj i wklej dokładnie to do Claude Code:

```
@agent-methodology-pack/ORCHESTRATOR-MIGRATION-TASK.md
@agent-methodology-pack/.claude/agents/ORCHESTRATOR.md
@agent-methodology-pack/PROJECT-STATE.md

Jestem ORCHESTRATOR. Przeczytaj ORCHESTRATOR-MIGRATION-TASK.md i wykonaj pełną migrację Agent Methodology Pack v1.1.0 do tego projektu.

Wykonaj wszystkie fazy (1-5):
- Phase 1: Environment Setup (devops-agent + senior-dev, parallel)
- Phase 2: Agent Integration (architect + backend-dev + frontend-dev, parallel)
- Phase 3: Testing (test-engineer → qa-agent, sequential)
- Phase 4: Documentation (tech-writer → doc-auditor, sequential)
- Phase 5: Final Summary

Deleguj zadania do odpowiednich agentów zgodnie z instrukcjami w pliku ORCHESTRATOR-MIGRATION-TASK.md.

Raportuj postęp po każdej fazie.
```

---

## KROK 4: Czekaj na Zakończenie

ORCHESTRATOR będzie:
1. ✅ Uruchamiał agentów równolegle (2-3 jednocześnie)
2. ✅ Raportował postęp po każdej fazie
3. ✅ Zbierał raporty od agentów
4. ✅ Przedstawił finalny summary

**Typowy output:**
```
✅ Phase 1 Complete (15 min)
   - devops-agent: Environment configured
   - senior-dev: Cache initialized

✅ Phase 2 Complete (35 min)
   - architect-agent: 20 agents reviewed
   - backend-dev: MCP cache added
   - frontend-dev: MCP cache added

✅ Phase 3 Complete (25 min)
   - test-engineer: 15/15 tests PASS
   - qa-agent: UAT APPROVED

✅ Phase 4 Complete (20 min)
   - tech-writer: Docs updated
   - doc-auditor: Audit PASSED

🎉 MIGRATION COMPLETE!
```

---

## KROK 5: Post-Migration (Ty musisz)

### 5.1 Restart Claude Code

```
1. Zamknij Claude Code całkowicie
2. Uruchom ponownie
3. MCP Server załaduje się automatycznie
```

### 5.2 Weryfikacja

```bash
# Test 1: Cache stats
bash scripts/cache-stats.sh

# Test 2: Validate docs
bash scripts/validate-docs.sh
```

### 5.3 Pierwszy Test Agenta

```
@.claude/agents/planning/RESEARCH-AGENT.md

Research: [Twoje pytanie badawcze]
```

Agent powinien:
- Sprawdzić cache przed research
- Wykonać research jeśli MISS
- Zapisać do cache

---

## CO DOSTANIESZ

### ✅ 20 Agentów Operacyjnych

**Planning (6):**
- discovery-agent, pm-agent, architect-agent
- ux-designer, product-owner, scrum-master

**Development (4):**
- frontend-dev, backend-dev, senior-dev, test-engineer

**Quality (3):**
- qa-agent, code-reviewer, tech-writer

**Operations (1):**
- devops-agent

**+ więcej w /skills**

### ✅ Cache System (60-80% oszczędności)

- cache_manager.py (naprawiony!)
- MCP Server (skonfigurowany)
- Auto-save metryk
- Akumulacja między sesjami

### ✅ Kompletna Dokumentacja

- CACHE-USER-GUIDE.md
- MCP-CACHE-USAGE.md (pattern)
- All agent definitions
- Workflows & patterns

### ✅ Automation Scripts

- cache-stats.sh - Monitorowanie
- validate-docs.sh - Walidacja
- init-project.sh - Inicjalizacja
- + 8 więcej

---

## TROUBLESHOOTING

### "ORCHESTRATOR nie deleguje, sam wykonuje"

Przypomnienie:
```
Jesteś ORCHESTRATOR. Twoja rola to tylko ROUTING i DELEGACJA.

NIGDY nie wykonuj zadań sam. Zawsze deleguj do:
- devops-agent dla setupu
- senior-dev dla kodu
- test-engineer dla testów
- qa-agent dla walidacji
- tech-writer dla dokumentacji
```

### "Agent nie widzi plików"

Sprawdź ścieżki:
```
# Powinno być:
@agent-methodology-pack/.claude/agents/ORCHESTRATOR.md

# NIE:
@.claude/agents/ORCHESTRATOR.md (jeśli folder się nazywa agent-methodology-pack)
```

### "MCP tools nie działają"

To normalne PRZED restartem Claude Code. Agenci powinni:
- Mieć instrukcje użycia MCP cache
- Wiedzieć że tools będą dostępne PO restarcie
- Dokumentować jak ich używać

---

## FINALNY CHECKLIST

Po zakończeniu migracji powinieneś mieć:

**Pliki:**
- [x] ORCHESTRATOR-MIGRATION-TASK.md (ten plik był czytany)
- [x] CACHE-USER-GUIDE.md (user documentation)
- [x] Wszystkie agenci w .claude/agents/
- [x] cache_manager.py z fixami
- [x] MCP Server skonfigurowany

**Funkcjonalność:**
- [x] cache-stats.sh pokazuje metryki
- [x] Można czytać definicje agentów
- [x] ORCHESTRATOR może delegować
- [ ] MCP tools działają (po restarcie)

**Raporty utworzone:**
- [ ] ENVIRONMENT-SETUP-REPORT.md
- [ ] CACHE-INITIALIZATION-REPORT.md
- [ ] AGENT-ARCHITECTURE-REVIEW.md
- [ ] INTEGRATION-TEST-REPORT.md
- [ ] UAT-REPORT.md
- [ ] DOCUMENTATION-AUDIT-REPORT.md

---

## 🚀 GOTOWE?

**Skopiuj to do nowej sesji Claude Code:**

```
@agent-methodology-pack/ORCHESTRATOR-MIGRATION-TASK.md
@agent-methodology-pack/.claude/agents/ORCHESTRATOR.md
@agent-methodology-pack/PROJECT-STATE.md

Wykonaj pełną migrację Agent Methodology Pack zgodnie z ORCHESTRATOR-MIGRATION-TASK.md.

Deleguj wszystkie fazy do odpowiednich agentów w trybie semi-auto (Level 2).
```

**I TO WSZYSTKO!** ORCHESTRATOR zajmie się resztą.

---

**Powodzenia!** 🎉

---

**Version:** 1.0.0
**Created:** 2025-12-14
**Updated:** 2025-12-14
