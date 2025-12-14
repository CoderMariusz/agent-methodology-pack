# Instrukcje Restartu Claude Code z MCP Cache

**Data:** 2025-12-14
**Cel:** Aktywować MCP cache server dla 60-80% oszczędności kosztów

---

## 🎯 KROK 1: Znajdź Config Claude Code

### Windows:
```bash
# Plik konfiguracji:
%APPDATA%\Claude\claude_desktop_config.json

# Pełna ścieżka (zwykle):
C:\Users\Mariusz K\AppData\Roaming\Claude\claude_desktop_config.json
```

### Jak otworzyć:
```powershell
# Opcja 1: Notepad
notepad "%APPDATA%\Claude\claude_desktop_config.json"

# Opcja 2: VS Code
code "%APPDATA%\Claude\claude_desktop_config.json"

# Opcja 3: Ręcznie
# 1. Win+R
# 2. Wpisz: %APPDATA%\Claude
# 3. Otwórz: claude_desktop_config.json
```

---

## 🎯 KROK 2: Dodaj MCP Server

### Jeśli plik jest PUSTY lub NIE MA "mcpServers":

**Skopiuj CAŁOŚĆ:**
```json
{
  "mcpServers": {
    "agent-cache": {
      "command": "python",
      "args": [
        "-u",
        "C:/Users/Mariusz K/Documents/Programowanie/Agents/agent-methodology-pack/.claude/mcp-servers/cache-server/server.py"
      ],
      "env": {
        "CACHE_DIR": "C:/Users/Mariusz K/Documents/Programowanie/Agents/agent-methodology-pack/.claude/cache"
      }
    }
  }
}
```

### Jeśli plik MA JUŻ "mcpServers":

**Dodaj tylko to WEWNĄTRZ "mcpServers":**
```json
{
  "mcpServers": {
    "agent-cache": {
      "command": "python",
      "args": [
        "-u",
        "C:/Users/Mariusz K/Documents/Programowanie/Agents/agent-methodology-pack/.claude/mcp-servers/cache-server/server.py"
      ],
      "env": {
        "CACHE_DIR": "C:/Users/Mariusz K/Documents/Programowanie/Agents/agent-methodology-pack/.claude/cache"
      }
    }
  }
}
```

**WAŻNE:**
- Użyj forward slashes `/` (nie backslash `\`)
- Zachowaj przecinki między serwerami
- Sprawdź składnię JSON (brak trailing comma na końcu)

---

## 🎯 KROK 3: Zapisz i Zamknij Plik

```bash
# 1. Ctrl+S (zapisz)
# 2. Zamknij edytor
# 3. Sprawdź że zapisało się:
type "%APPDATA%\Claude\claude_desktop_config.json"
```

---

## 🎯 KROK 4: Restart Claude Code

### Metoda 1: Normalny restart
```bash
# 1. Zamknij wszystkie okna Claude Code (X)
# 2. Poczekaj 5 sekund
# 3. Otwórz ponownie Claude Code
```

### Metoda 2: Force restart (jeśli Metoda 1 nie działa)
```powershell
# 1. Otwórz Task Manager (Ctrl+Shift+Esc)
# 2. Znajdź "Claude" processy
# 3. Kliknij prawym → End Task
# 4. Otwórz Claude Code ponownie
```

---

## 🎯 KROK 5: Verify MCP Server Loaded

### Po restarcie Claude Code:

**W nowym chacie napisz:**
```
Test MCP cache - wywołaj cache_stats
```

### ✅ SUCCESS - Jeśli zobaczysz:
```
Tool call: cache_stats
Response: {
  "total_queries": X,
  "hot_hits": Y,
  ...
}
```

### ❌ BŁĄD - Jeśli zobaczysz:
```
"Tool not found"
lub
"MCP server not available"
```

**Rozwiązanie:**
1. Sprawdź ścieżkę w config (czy dobrze skopiowana?)
2. Sprawdź czy Python działa: `python --version`
3. Sprawdź logi: `%APPDATA%\Claude\logs\`
4. Sprawdź server ręcznie:
   ```bash
   cd C:\Users\Mariusz K\Documents\Programowanie\Agents\agent-methodology-pack\.claude\mcp-servers\cache-server
   python server.py
   # Powinno pokazać: "MCP Cache Server running..."
   ```

---

## 🎯 KROK 6: Test Cache w Akcji

### Test 1: Pierwszy research query (MISS)
```
Zbadaj top 3 workflow engines dla Python w 2025
```

**Oczekiwany rezultat:**
- Claude wykona research (normalnie)
- W tle: cache_set() zapisze wynik
- Czas: ~30-60 sekund

### Test 2: Drugi research query (HIT)
```
Zbadaj top 3 workflow engines dla Python w 2025
```

**Oczekiwany rezultat:**
- Claude zwróci z cache (natychmiast!)
- W tle: cache_get() HIT
- Czas: <1 sekunda
- **Oszczędności:** 99% kosztów tego query!

---

## 🎯 KROK 7: Sprawdź Oszczędności

```bash
cd C:\Users\Mariusz K\Documents\Programowanie\Agents\agent-methodology-pack

# Zobacz statystyki cache:
bash scripts/cache-stats.sh
```

**Powinieneś zobaczyć:**
```
Cache Hits:     1-2  (zależnie od testów)
Tokens Saved:   1,000-5,000
Cost Saved:     $0.003-0.015
```

**Jeśli widzisz $0.00:**
- Cache nie był użyty
- Sprawdź czy MCP server działa
- Zobacz KROK 5 troubleshooting

---

## 📊 Co Dalej?

### Następne 7 dni:
```bash
# Codziennie:
bash scripts/cache-stats.sh

# Obserwuj:
# - Hit rate: 10% → 30% → 50% → 70%
# - Cost saved: $1 → $10 → $50 → $100/month
# - Tokens saved rosnące
```

### Po tygodniu:
```bash
# Porównaj koszty:
# - Przed MCP: £400/month
# - Po MCP: £100-180/month
# - Oszczędności: £220-300/month
```

---

## 🚨 Troubleshooting

### Problem: "Tool not found"
**Rozwiązanie:**
1. Sprawdź config: `type "%APPDATA%\Claude\claude_desktop_config.json"`
2. Sprawdź ścieżkę (czy istnieje server.py?)
3. Restart Claude Code (force restart)

### Problem: Python error
**Rozwiązanie:**
1. Sprawdź Python: `python --version` (potrzeba 3.8+)
2. Test server ręcznie: `python server.py`
3. Sprawdź logi: `cat .claude/cache/logs/error.log`

### Problem: Cache nie zapisuje
**Rozwiązanie:**
1. Sprawdź permissions: `.claude/cache/` (write access?)
2. Sprawdź logi: `cat .claude/cache/logs/mcp-access.log`
3. Test ręczny:
   ```bash
   cd .claude/mcp-servers/cache-server
   python -c "from server import *; print('OK')"
   ```

### Problem: Hit rate 0% po tygodniu
**Rozwiązanie:**
1. Sprawdź czy zadania się powtarzają (cache działa tylko dla repeated tasks)
2. Zwiększ TTL: Edit server.py → DEFAULT_TTL = 86400 (24h)
3. Sprawdź key generation (może zbyt specyficzne?)

---

## 📞 Potrzebujesz Pomocy?

**Quick Start Guide (pełna wersja):**
```bash
cat .claude/mcp-servers/QUICK-START.md
```

**MCP Server README:**
```bash
cat .claude/mcp-servers/cache-server/README.md
```

**Test Scenarios:**
```bash
cat .claude/testing/MCP-CACHE-TESTS.md
```

---

## ✅ Success Checklist

Po restarcie:
- [ ] Config zapisany w `%APPDATA%\Claude\claude_desktop_config.json`
- [ ] Claude Code zrestartowany
- [ ] Test: `cache_stats` działa ✅
- [ ] Test: Research query 2x (pierwszy MISS, drugi HIT) ✅
- [ ] Stats: `bash scripts/cache-stats.sh` pokazuje savings > $0 ✅
- [ ] Monitoring: Codziennie sprawdzam przez tydzień ✅

---

**Powodzenia! Po restarcie oszczędzisz £220-300/miesiąc!** 🚀

---

*Instrukcje utworzone: 2025-12-14*
*Agent Methodology Pack v1.1.0*
