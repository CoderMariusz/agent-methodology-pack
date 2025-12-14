# MCP Cache Server - Quick Start Guide

**Goal:** Get MCP cache server running and save £250-315/month in 2 hours

---

## Prerequisites

- Python 3.8+ installed (you have 3.13 ✓)
- Existing cache_manager.py working (✓)
- Claude Code desktop app

---

## Step 1: Verify Installation (2 min)

```bash
cd "C:/Users/Mariusz K/Documents/Programowanie/Agents/agent-methodology-pack/.claude/mcp-servers/cache-server"

# Test server initialization
python -c "from server import MCPCacheServer; s = MCPCacheServer(); print('OK: Server ready')"

# Expected output: "OK: Server ready" (with some log lines)
```

If this works, you're ready for Step 2.

---

## Step 2: Configure Claude Code (5 min)

### Option A: Auto-discovery (Easiest)

If Claude Code supports MCP auto-discovery, it may automatically detect the server in `.claude/mcp-servers/`.

1. Restart Claude Code
2. Check if "agent-cache" tools appear
3. If yes, skip to Step 3

### Option B: Manual Configuration

1. **Find Claude config location:**

   **Windows:**
   ```
   C:\Users\Mariusz K\AppData\Roaming\Claude\claude_desktop_config.json
   ```

   **macOS:**
   ```
   ~/Library/Application Support/Claude/claude_desktop_config.json
   ```

   **Linux:**
   ```
   ~/.config/Claude/claude_desktop_config.json
   ```

2. **Edit config file** (create if doesn't exist):

   ```json
   {
     "mcpServers": {
       "agent-cache": {
         "command": "python",
         "args": ["-u", "C:/Users/Mariusz K/Documents/Programowanie/Agents/agent-methodology-pack/.claude/mcp-servers/cache-server/server.py"],
         "env": {
           "PYTHONUNBUFFERED": "1"
         }
       }
     }
   }
   ```

   **IMPORTANT:** Use absolute path to server.py

3. **Restart Claude Code**

4. **Verify MCP tools available:**
   - cache_get
   - cache_set
   - cache_stats
   - cache_clear
   - generate_key

---

## Step 3: Test with Real Task (10 min)

### Test 1: Research Query (CACHE MISS)

Run a research task via Claude Code:

```
"Research the UK SaaS market size and growth rate for 2024"
```

**What should happen:**
- Agent executes research normally
- NO cache hit (first time)
- Result logged to `.claude/cache/logs/mcp-access.log`

### Test 2: Same Query (CACHE HIT)

Run the SAME research task again:

```
"Research the UK SaaS market size and growth rate for 2024"
```

**What should happen:**
- Agent checks cache FIRST
- CACHE HIT detected
- Returns cached result instantly
- Log shows savings

**Expected log:**
```
2025-12-14 11:00:00 - CACHE HIT: agent:research:task:market:abc123...
```

### Test 3: Check Statistics

```bash
cd .claude/mcp-servers/cache-server
python -c "from server import MCPCacheServer; import json; s = MCPCacheServer(); print(json.dumps(s.cache_stats(), indent=2))"
```

**Expected output:**
```json
{
  "status": "success",
  "metrics": {
    "total_queries": 2,
    "hot_hits": 1,
    "cold_hits": 0,
    "overall_hit_rate": 50.0,
    "tokens_saved": 25000,
    "cost_saved_usd": 0.45,
    "cost_saved_gbp": 0.36
  }
}
```

If you see 50% hit rate and cost savings, IT'S WORKING!

---

## Step 4: Integration Patterns (20 min)

### For Agents

Reference: `.claude/agents/MCP-CACHE-INTEGRATION.md`

**Pattern for any agent:**

```python
# 1. Generate cache key
from mcp import generate_key, cache_get, cache_set

key = generate_key("research", "market", query)["key"]

# 2. Check cache
cached = cache_get(key)
if cached["status"] == "hit":
    print(f"[CACHE HIT] Saved {cached['savings']['tokens']} tokens")
    return cached["data"]

# 3. Execute task (cache miss)
result = execute_expensive_task(query)

# 4. Cache result
cache_set(key, result, ttl=86400, metadata={"agent": "RESEARCH-AGENT"})
```

### TTL Quick Reference

| Task Type | TTL | Code |
|-----------|-----|------|
| Research | 24h | `ttl=86400` |
| Tests | 1h | `ttl=3600` |
| Boilerplate | 4h | `ttl=14400` |
| Doc audit | 12h | `ttl=43200` |
| Templates | 24h | `ttl=86400` |

---

## Step 5: Monitor Savings (Ongoing)

### Daily Check

```bash
# View cache statistics
cd .claude/mcp-servers/cache-server
python -c "from server import MCPCacheServer; import json; s = MCPCacheServer(); stats = s.cache_stats()['metrics']; print(f\"Hit rate: {stats['overall_hit_rate']:.1f}%\"); print(f\"Saved: £{stats['cost_saved_gbp']:.2f}\")"
```

### Weekly Review

```bash
# View access logs
tail -100 .claude/cache/logs/mcp-access.log

# View metrics file
cat .claude/cache/logs/metrics.json
```

### Monthly Report

1. Check total cost saved (GBP)
2. Calculate monthly savings projection
3. Adjust TTL values if needed
4. Clear old cache if needed: `python -c "from server import MCPCacheServer; s = MCPCacheServer(); s.cache_clear('*')"`

---

## Troubleshooting

### Problem: "Cannot import cache_manager"

**Solution:**
```bash
cd .claude/mcp-servers/cache-server
python -c "import sys; sys.path.insert(0, '../../cache'); from cache_manager import CacheManager; print('OK')"
```

If this fails, check that `.claude/cache/cache_manager.py` exists.

### Problem: "MCP server not responding"

**Solution:**
1. Check if server.py runs manually:
   ```bash
   cd .claude/mcp-servers/cache-server
   python server.py
   ```
   (Press Ctrl+C to stop)

2. Check logs:
   ```bash
   tail -20 .claude/cache/logs/mcp-access.log
   ```

3. Restart Claude Code

### Problem: "Cache always MISS, never HIT"

**Possible causes:**
1. Cache keys not consistent (check key generation)
2. TTL too short (cache expiring too fast)
3. Content hash changing (even with same query)

**Debug:**
```bash
# Check what keys are being generated
python -c "from server import MCPCacheServer; s = MCPCacheServer(); k1 = s._generate_key('research', 'market', 'test'); k2 = s._generate_key('research', 'market', 'test'); print(f'Key 1: {k1}'); print(f'Key 2: {k2}'); print(f'Match: {k1 == k2}')"
```

Keys should match for same content.

### Problem: "High cost, low savings"

**Possible causes:**
1. Hit rate too low (<40%)
2. Caching wrong tasks (unique/non-repeatable)
3. TTL too short

**Solutions:**
1. Review cache patterns (see `.claude/patterns/MCP-CACHE-PATTERN.md`)
2. Increase TTL for stable content
3. Check if tasks are actually repeated

---

## Expected Results

### Week 1

- Hit rate: 30-40%
- Cost reduction: 30-40%
- Learning agent patterns

### Week 2-4

- Hit rate: 50-70%
- Cost reduction: 60-80%
- Stable cache patterns

### Steady State (Month 2+)

- Hit rate: 70-80%
- Cost reduction: 75-85%
- Monthly cost: £85-150 (from £400)
- Monthly savings: £250-315

---

## Success Checklist

After setup:

- [ ] MCP server starts without errors
- [ ] Claude Code recognizes agent-cache tools
- [ ] First research query executes (MISS)
- [ ] Second research query uses cache (HIT)
- [ ] cache_stats shows hit rate > 0%
- [ ] Logs show CACHE HIT entries
- [ ] Cost savings calculated in GBP

After 1 week:

- [ ] Hit rate > 30%
- [ ] At least 3 different agent types using cache
- [ ] No cache-related errors
- [ ] Measurable cost reduction

After 1 month:

- [ ] Hit rate > 60%
- [ ] Cost reduction > 60%
- [ ] Monthly cost < £160
- [ ] Cache patterns optimized

---

## Quick Command Reference

```bash
# Check server works
python -c "from server import MCPCacheServer; s = MCPCacheServer(); print('OK')"

# Get statistics
python -c "from server import MCPCacheServer; import json; s = MCPCacheServer(); print(json.dumps(s.cache_stats(), indent=2))"

# View logs
tail -f .claude/cache/logs/mcp-access.log

# Clear cache (use cautiously)
python -c "from server import MCPCacheServer; s = MCPCacheServer(); s.cache_clear('*'); print('Cache cleared')"

# Test cache operations
python << 'EOF'
from server import MCPCacheServer
s = MCPCacheServer()
s.cache_set("agent:test:task:example:123", {"data": "test"}, ttl=3600)
result = s.cache_get("agent:test:task:example:123")
print(f"Status: {result['status']}")
EOF
```

---

## Next Steps

1. Complete Step 1-3 (verify, configure, test)
2. Monitor hit rate for 1 week
3. Review savings vs projections
4. Optimize TTL values if needed
5. Celebrate £250-315/month savings!

---

## Support

- **Server README:** `.claude/mcp-servers/cache-server/README.md`
- **Integration Patterns:** `.claude/patterns/MCP-CACHE-PATTERN.md`
- **Agent Integration:** `.claude/agents/MCP-CACHE-INTEGRATION.md`
- **Test Scenarios:** `.claude/testing/MCP-CACHE-TESTS.md`
- **Implementation Status:** `.claude/mcp-servers/IMPLEMENTATION-STATUS.md`

---

**Estimated Time:** 2 hours to production
**Expected Savings:** £3,000-3,780/year
**ROI:** Immediate (first cache hit)

Let's save some money!
