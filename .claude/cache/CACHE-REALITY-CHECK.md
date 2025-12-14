# Cache System Reality Check

**Created:** 2025-12-14
**Priority:** CRITICAL
**Status:** Investigation Complete

---

## CRITICAL FINDING: Cache Not Actually Used

### The Problem

User correctly identified that the Universal Cache System is **NOT being used** during real agent workflows.

**Evidence:**
- access.log: Only 10 entries (all from manual test)
- Real usage: 12+ agent delegations via Task tool = 0 cache hits
- Session costs: $0.40-0.55 for 100+ minutes = **NO cache savings**
- Metrics show savings from test_savings.py only, not from real work

---

## Root Cause Analysis

### How Claude Code Task Tool Works

```
User → Task("backend-dev", context)
       ↓
       Fresh Claude API call (new session)
       ↓
       Agent executes (isolated context)
       ↓
       Response
       ↓
       Session ends (no persistence)

cache_manager.py ← NEVER CALLED
```

**Key Discovery:** Task tool creates **completely isolated agent instances** with:
- Fresh API session every time
- No shared state between calls
- No integration point for custom cache
- Each Task() = new conversation context

### What cache_manager.py Actually Is

A standalone Python library that requires:
1. Explicit import: `from cache_manager import CacheManager`
2. Manual wrapping of API calls
3. Your own code to call `.get()` and `.set()`

**NOT:**
- Automatic middleware for Task tool
- Built into Claude Code
- Accessible to agents via Task()

### The Architectural Gap

```
Expected:
User → Task → Cache Check → (maybe) Claude API → Response
              ↑
            95% hit rate

Actual:
User → Task → Claude API → Response
              ↑
            0% cache usage
```

---

## What IS Working (Partially)

### Layer 1: Claude's Built-in Prompt Caching

Claude API has automatic prompt caching, but:
- Only works within same session
- Task tool creates new sessions each time
- Effectiveness: **~5-10%** (minimal reuse)
- User's costs confirm this is what they're getting

### Layers 2-4: Not Working

| Layer | Status | Reason |
|-------|--------|--------|
| Hot Cache | Inactive | Never called by agents |
| Cold Cache | 3 test files | Only from manual test script |
| Semantic Cache | Not used | No integration with Task tool |

---

## Why Metrics Are Misleading

### Current Metrics (metrics.json)

```json
{
  "hot_hits": 3,
  "total_queries": 6,
  "tokens_saved": 11000,
  "cost_saved": 0.135,
  "overall_hit_rate": 50.0
}
```

**Reality:** All from test_savings.py manual run. Zero from real agent work.

### cache-stats.sh Projections

Shows:
- "Cost Saved: $447/month"
- "Overall Hit Rate: 94%"

**Actually:** Extrapolations assuming cache is integrated (it's not)

---

## Real Cost Analysis

### What User is Paying

- 100+ minutes of agent work
- ~$0.40-0.55 cost
- **This matches non-cached Claude API pricing**

### If Cache Was Working

- Expected: $0.02-0.05 for 100 minutes (95% savings)
- Actual: $0.40-0.55 (minimal savings)
- **Conclusion:** Cache not providing advertised benefit

---

## Technical Solutions

### Option 1: Accept Limitation (FASTEST)

**Status:** User is already getting Claude's basic prompt caching (~5-10%)

**Action:**
1. Update documentation to be honest about limitations
2. Fix cache-stats.sh to show "Not integrated with Task tool"
3. Remove "95% savings" promises
4. Label as "For direct API usage only"

**Time:** 20 minutes
**Pros:** Honest, no dev work
**Cons:** No additional savings

---

### Option 2: MCP Server Integration (PROMISING)

**Create MCP server that exposes cache to agents**

**Architecture:**
```
User → Task("backend-dev", context)
       ↓
       Agent (sees MCP tools)
       ↓
       cache.get(query) [MCP tool call]
       ↓
       cache_manager.py
       ↓
       (maybe) Claude API
```

**Requirements:**
1. Create `.claude/cache/cache-mcp-server.py`
2. Add to `.claude/mcp-profiles/full.json`
3. Update agent prompts to use cache tools
4. Agents must explicitly call cache

**Pros:**
- Real cache hits possible
- Works with existing Task tool
- No Claude Code changes needed

**Cons:**
- Not automatic (agents must call cache tools)
- Requires agent workflow changes
- 2-3 hours implementation

---

### Option 3: Proxy Wrapper (COMPLEX)

Create wrapper function that caches Task results:

```python
def cached_task(agent, context):
    key = hash(f"{agent}:{context}")
    cached = cache.get(key)
    if cached:
        return cached
    result = Task(agent, context)
    cache.set(key, result)
    return result
```

**Pros:**
- Transparent caching
- Real 95% savings possible

**Cons:**
- User must use wrapper instead of Task()
- Context hashing tricky
- May not work with Claude Code UI

**Time:** 8-10 hours

---

### Option 4: Session Persistence (NOT POSSIBLE)

**Ideal:** Make Task tool reuse sessions for related calls

**Problem:** Requires changes to Claude Code internals (not accessible)

---

## Recommended Action Plan

### Phase 1: Fix Documentation (NOW - 20 min)

1. Update cache-stats.sh with reality warning
2. Update CACHE-README.md with limitations section
3. Fix cost projections to be honest
4. Mark as "Manual integration required"

### Phase 2: Optional MCP Integration (2-3 hours)

Only if user wants real cache benefits:
1. Implement cache MCP server
2. Update agent prompts
3. Document how agents use it
4. Test with real workflows

---

## Bottom Line

**Current State:**
- Cache system is technically sound
- Operationally disconnected from workflow
- User paying ~full API costs
- Metrics are misleading

**Path Forward:**
1. Document reality honestly (20 min)
2. OR invest 2-3 hours in MCP integration for real savings
3. Accept ~5-10% savings from Claude's built-in cache

**User Decision:** Choose between honesty and 2-3 hours of integration work.

---

## Files to Update

### Immediate (Option 1):
- `scripts/cache-stats.sh` - Add reality warning
- `CACHE-README.md` - Add limitations section
- `docs/GETTING-STARTED-CACHE.md` - Update savings claims
- `docs/CACHE-QUICK-START.md` - Add "Manual usage only" note

### If MCP Integration (Option 2):
- Create `.claude/cache/cache-mcp-server.py`
- Update `.claude/mcp-profiles/full.json`
- Update agent prompts in `.claude/agents/`
- Add MCP usage guide

---

**Investigation Date:** 2025-12-14
**Investigator:** DEVOPS-AGENT
**Time Spent:** 30 minutes
**Confidence:** 100% (confirmed via log analysis + cost verification)
