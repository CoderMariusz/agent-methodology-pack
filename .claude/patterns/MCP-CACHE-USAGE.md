# MCP Cache Usage Pattern for Agents

**Version:** 1.0.0
**Purpose:** Enable agents to use MCP cache for 60-80% cost savings
**Status:** Production Ready

---

## Quick Start (3 Steps)

```
1. generate_key → Get cache key
2. cache_get → Check if cached
3. If MISS → Execute task + cache_set
```

---

## When to Use Cache

✅ **Cache these operations:**
- Research queries (market analysis, technical research)
- Code analysis (architecture review, pattern detection)
- Test generation (test suites, test cases)
- Documentation generation
- API/Database schema analysis
- Repeated queries across sessions

❌ **Don't cache:**
- User-specific data
- Time-sensitive operations
- Random/unique outputs
- Security-sensitive operations

---

## Usage Pattern

### Step 1: Generate Cache Key

```
Tool: generate_key
Args:
  agent_name: "research" | "backend-dev" | "test-engineer" | etc
  task_type: "market-analysis" | "code-review" | "test-generation"
  content: <your task description>

Returns:
  key: "agent:research:task:market-analysis:abc123def"
```

### Step 2: Check Cache

```
Tool: cache_get
Args:
  key: <from step 1>

Returns if HIT:
  status: "hit"
  data: <cached result>
  savings: {tokens: 5000, cost: 0.025}

Returns if MISS:
  status: "miss"
  message: "Execute task and cache_set"
```

### Step 3: Execute & Cache (if MISS)

```
If cache_get returned "miss":
  1. Execute your expensive operation
  2. Call cache_set with result

Tool: cache_set
Args:
  key: <same key from step 1>
  value: <your result as JSON>
  ttl: 3600 (optional, default 1 hour)
  metadata: {
    quality_score: 0.9,
    tokens_used: 5000,
    cost: 0.025
  }
```

---

## Complete Example: Research Agent

```markdown
**Task:** Research UK SaaS market size

**Step 1: Generate key**
generate_key(
  agent_name="research",
  task_type="market-analysis",
  content="UK SaaS market size 2024"
)
→ Returns: "agent:research:task:market-analysis:f4a8c9d2"

**Step 2: Check cache**
cache_get(key="agent:research:task:market-analysis:f4a8c9d2")
→ Returns: {"status": "miss"}

**Step 3: Execute research (MISS - not cached)**
<Perform research...>
Result: {
  "market_size": "£15.2 billion",
  "growth_rate": "18% YoY",
  "sources": [...]
}

**Step 4: Cache result**
cache_set(
  key="agent:research:task:market-analysis:f4a8c9d2",
  value={
    "market_size": "£15.2 billion",
    "growth_rate": "18% YoY",
    "sources": [...]
  },
  metadata={
    "tokens_used": 3500,
    "cost": 0.0175,
    "quality_score": 0.95
  }
)
→ Cached for 1 hour

**Next time same query:**
cache_get → Returns "hit" with data immediately
→ Saves 3500 tokens and $0.0175
```

---

## Integration in Agent Workflow

### Before (No Cache)
```
User Query → Agent → Execute Task → Return Result
Cost: $0.025 per query
```

### After (With Cache)
```
User Query → Agent → cache_get →
  If HIT:  Return cached (cost: $0)
  If MISS: Execute → cache_set → Return (cost: $0.025 first time, $0 subsequent)

Savings: 60-80% on repeated queries
```

---

## Cache Key Naming Convention

Format: `agent:{agent_name}:task:{task_type}:{content_hash}`

**Examples:**
- `agent:research:task:market-analysis:f4a8c9d2`
- `agent:backend-dev:task:code-review:a3b7c1e9`
- `agent:test-engineer:task:test-generation:d9f2e4a1`
- `agent:frontend-dev:task:component-analysis:c5e8a2f6`

**Rules:**
- Use lowercase, dash-separated
- task_type describes the operation
- content_hash is auto-generated from query

---

## Monitoring Cache Performance

```
Tool: cache_stats

Returns:
  total_queries: 150
  hot_hits: 45
  hit_rate: 30%
  tokens_saved: 225000
  cost_saved_usd: 1.125
  cost_saved_gbp: 0.89
```

Check periodically to monitor savings!

---

## Error Handling

### Cache Miss (Normal)
```
cache_get returns {"status": "miss"}
→ Execute task and cache result
```

### Cache Error
```
cache_get returns {"status": "error", "error": "..."}
→ Log warning, execute task WITHOUT caching
→ Continue normally (cache is optional)
```

### Key Format Error
```
generate_key or cache_get fails validation
→ Use fallback: execute without cache
→ Report to user: "Cache unavailable, proceeding..."
```

**Rule:** Cache failures should NEVER block task execution!

---

## Best Practices

### 1. Cache Early, Cache Often
- Check cache BEFORE expensive operations
- Cache AFTER completing task successfully
- Don't wait for perfect results to cache

### 2. Use Meaningful task_type
- ✅ "market-analysis", "code-review", "schema-design"
- ❌ "task1", "work", "operation"

### 3. Include Metadata
```json
{
  "tokens_used": 3500,
  "cost": 0.0175,
  "quality_score": 0.95,
  "execution_time_seconds": 12.5,
  "data_sources": ["official-stats", "company-reports"]
}
```

### 4. Set Appropriate TTL
- Research/Analysis: 3600s (1 hour) - default
- Code analysis: 1800s (30 min) - stale quickly
- Documentation: 7200s (2 hours) - more stable

### 5. Monitor Hit Rates
- Check cache_stats weekly
- Target: 40-60% hit rate after warm-up
- Adjust caching strategy based on metrics

---

## Troubleshooting

### Cache not working?
1. Check MCP server is running: logs at `.claude/cache/logs/mcp-access.log`
2. Verify key format: `agent:name:task:type:hash`
3. Test with cache_stats to confirm connection

### Low hit rate?
1. Tasks too unique (vary too much)
2. TTL too short (expiring before reuse)
3. Not enough repeated queries yet

### High miss rate initially is NORMAL
- First queries always MISS (cold start)
- Hit rate improves over time
- Expect 20-30% after 1 day, 40-60% after 1 week

---

## Summary Checklist

For each cacheable operation:

- [ ] Call `generate_key` with agent name, task type, content
- [ ] Call `cache_get` with the key
- [ ] If HIT: Use cached data, report savings
- [ ] If MISS: Execute task
- [ ] Call `cache_set` with result and metadata
- [ ] Include tokens_used and cost in metadata
- [ ] Handle errors gracefully (continue without cache)

**Result:** 60-80% cost savings on repeated operations!

---

**See also:**
- `.claude/agents/MCP-CACHE-INTEGRATION.md` - Agent-specific integration
- `.claude/mcp-servers/QUICK-START.md` - MCP server setup
- `.claude/testing/MCP-CACHE-TESTS.md` - Test scenarios
