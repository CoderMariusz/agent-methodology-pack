# MCP Cache Pattern for Agents

**Purpose:** Guide agents on when and how to use the MCP cache server for cost reduction.

**Expected Savings:** 60-80% cost reduction through intelligent caching

---

## When to Use Cache

### Use Cache For (HIGH ROI):

- Research queries (competitor analysis, market research)
- Expensive API calls (web searches, data fetching)
- Repeated computations (complexity scoring, cost calculations)
- Static content generation (boilerplate code, templates)
- Documentation audits (same doc version)
- Test generation (same file, similar code)

### Skip Cache For (LOW ROI):

- User-specific data (personalized content)
- Time-sensitive information (real-time data, breaking news)
- Unique creative content (novel solutions, creative writing)
- Critical decision-making (architecture decisions, security choices)
- Interactive workflows (requires human input)
- Very small operations (<1000 tokens)

---

## Agent Integration Workflow

### Pattern A: Read-Heavy Tasks (Research, Analysis)

**When:** Task is expensive and results are reusable

**Steps:**
1. Generate cache key from task description
2. Call `cache_get(key)`
3. If HIT: Return cached result, log savings
4. If MISS: Execute task, then `cache_set(key, result, ttl)`

**Example (Research Agent):**
```python
# Before executing research
task_content = "Analyze UK SaaS market 2024"
key = generate_key(
    agent_name="research",
    task_type="market-analysis",
    content=task_content
)
# Returns: agent:research:task:market-analysis:abc123

# Check cache
cached = cache_get(key)

if cached["status"] == "hit":
    print(f"CACHE HIT! Saved {cached['savings']['tokens']} tokens")
    print(f"Cost saved: £{cached['savings']['cost'] * 0.79}")
    return cached["data"]

# CACHE MISS - execute research
print("CACHE MISS - executing research...")
research_result = {
    "competitors": ["Company A", "Company B"],
    "market_size": "£2.4B",
    "growth_rate": "15% YoY",
    "key_trends": [...],
    "tokens_used": 25000,
    "cost": 0.45  # USD
}

# Store in cache
cache_set(
    key=key,
    value=research_result,
    ttl=86400,  # 24 hours - research is stable
    metadata={
        "agent": "RESEARCH-AGENT",
        "quality_score": 0.92,
        "tags": ["market-research", "saas", "uk"]
    }
)

return research_result
```

---

### Pattern B: Boilerplate Generation (Code, Templates)

**When:** Generating repetitive/template-based content

**Steps:**
1. Check if task is cacheable (template? boilerplate?)
2. If yes: Generate key, try `cache_get(key)`
3. If HIT: Adapt cached template to current context
4. If MISS: Generate, then `cache_set(key, result, ttl)`

**Example (Backend Dev - CRUD):**
```python
# Check if this is boilerplate CRUD
if task_type == "crud" and is_standard_pattern(spec):
    # Generate key from spec
    spec_hash = hash_spec(spec)
    key = f"agent:backend:task:boilerplate-crud:{spec_hash}"

    # Check cache
    cached = cache_get(key)

    if cached["status"] == "hit":
        print("CACHE HIT - adapting cached boilerplate")
        # Adapt template to current entity name
        code = adapt_template(
            cached["data"]["template"],
            entity_name=spec["entity"]
        )
        return code

    # Generate new boilerplate
    code = generate_crud_boilerplate(spec)

    # Cache template
    cache_set(
        key=key,
        value={"template": code, "spec": spec},
        ttl=14400,  # 4 hours
        metadata={
            "agent": "BACKEND-DEV",
            "type": "boilerplate",
            "pattern": "crud"
        }
    )

    return code
```

---

### Pattern C: Test Generation (Adaptive Caching)

**When:** Generating tests for code (may change frequently)

**Steps:**
1. Generate content hash of file
2. Check cache with file hash
3. If similar tests exist: Adapt them
4. Else: Write new tests, cache

**Example (Test Engineer):**
```python
# Hash the file content
file_hash = hashlib.sha256(file_content.encode()).hexdigest()[:12]
key = f"agent:test:file:{filename}:hash:{file_hash}"

# Check cache
cached = cache_get(key)

if cached["status"] == "hit":
    # File unchanged - reuse tests
    similarity = calculate_similarity(cached["data"], current_context)

    if similarity > 0.8:
        print(f"CACHE HIT - adapting cached tests (similarity: {similarity})")
        tests = adapt_tests(cached["data"]["tests"], current_context)
        return tests

# Write new tests
print("CACHE MISS - writing new tests")
tests = write_unit_tests(file_content)

# Cache tests
cache_set(
    key=key,
    value={
        "tests": tests,
        "file_hash": file_hash,
        "coverage": 95,
        "tokens_used": 8000,
        "cost": 0.12
    },
    ttl=3600,  # 1 hour - tests change with code
    metadata={
        "agent": "TEST-ENGINEER",
        "file": filename,
        "test_count": len(tests)
    }
)

return tests
```

---

### Pattern D: Documentation Audit (Version-based)

**When:** Auditing documentation for quality/completeness

**Steps:**
1. Generate version hash of document
2. Check cache with doc path + version
3. If HIT and version unchanged: Return previous audit
4. If MISS: Execute audit, cache results

**Example (Doc Auditor):**
```python
# Hash doc content
doc_content = read_file(doc_path)
version_hash = hashlib.sha256(doc_content.encode()).hexdigest()[:12]
key = f"agent:doc:audit:{doc_path}:version:{version_hash}"

# Check cache
cached = cache_get(key)

if cached["status"] == "hit":
    print(f"CACHE HIT - doc unchanged, returning previous audit")
    return cached["data"]

# Execute audit
print("CACHE MISS - auditing document")
audit_result = {
    "score": 85,
    "issues": [
        {"type": "missing-examples", "severity": "medium"},
        {"type": "outdated-link", "severity": "low"}
    ],
    "recommendations": [...],
    "tokens_used": 12000,
    "cost": 0.18
}

# Cache audit
cache_set(
    key=key,
    value=audit_result,
    ttl=43200,  # 12 hours
    metadata={
        "agent": "DOC-AUDITOR",
        "doc_path": doc_path,
        "audit_date": datetime.now().isoformat()
    }
)

return audit_result
```

---

## Key Generation Guidelines

### Use generate_key Tool

Always use the MCP `generate_key` tool for consistency:

```python
key_result = generate_key(
    agent_name="research",      # your agent name
    task_type="market-analysis", # what you're doing
    content=query_string        # unique content to hash
)
key = key_result["key"]
```

### Key Format

```
agent:{agent_name}:task:{task_type}:{hash}
```

**Agent Names:**
- research
- test
- backend
- frontend
- doc
- writer
- qa
- devops

**Task Types:**
- analysis (research, audit)
- testing (unit tests, integration)
- boilerplate (CRUD, templates)
- audit (documentation, code)
- template (documentation templates)
- optimization (performance analysis)

---

## TTL Strategy by Content Type

| Content Type | TTL | Reason |
|--------------|-----|--------|
| Market research | 24h (86400s) | Data changes slowly |
| Competitor analysis | 24h (86400s) | Companies don't change daily |
| Unit tests | 1h (3600s) | Code changes frequently |
| Boilerplate code | 4h (14400s) | Templates are stable |
| Documentation audit | 12h (43200s) | Specs are semi-stable |
| API data | 1h (3600s) | External data can be volatile |
| Cost calculations | 6h (21600s) | Rates don't change often |
| Complexity scores | 4h (14400s) | Analysis patterns stable |

**Rule of Thumb:**
- Static content: 12-24h
- Semi-dynamic: 4-8h
- Dynamic: 1-2h
- Real-time: Don't cache

---

## Cache Hit Response Handling

### On HIT

```python
cached = cache_get(key)

if cached["status"] == "hit":
    # Log savings
    print(f"[CACHE HIT]")
    print(f"  Tokens saved: {cached['savings']['tokens']}")
    print(f"  Cost saved: ${cached['savings']['cost']}")
    print(f"  Cached at: {cached['cached_at']}")

    # Return data directly
    return cached["data"]
```

### On MISS

```python
if cached["status"] == "miss":
    # Execute expensive operation
    result = expensive_operation()

    # Track usage for caching
    result_with_metadata = {
        **result,
        "tokens_used": calculate_tokens(result),
        "cost": calculate_cost(tokens_used)
    }

    # Cache it
    cache_set(key, result_with_metadata, ttl=appropriate_ttl)

    return result
```

---

## Error Handling

Cache should NEVER block operations:

```python
try:
    cached = cache_get(key)
    if cached["status"] == "hit":
        return cached["data"]
except Exception as e:
    # Log error, continue without cache
    print(f"Cache error (non-blocking): {e}")
    # Fall through to normal execution

# Normal execution path
result = execute_task()
return result
```

---

## Monitoring Cache Effectiveness

### Check Stats Regularly

```python
# At end of task or periodically
stats = cache_stats()

print("\n=== Cache Performance ===")
print(f"Hit rate: {stats['metrics']['overall_hit_rate']}%")
print(f"Tokens saved: {stats['metrics']['tokens_saved']}")
print(f"Cost saved: £{stats['metrics']['cost_saved_gbp']}")
```

### Log Cache Decisions

```python
# When checking cache
if cache_hit:
    log_to_metrics("cache_decision", {
        "key": key,
        "decision": "hit",
        "savings_tokens": savings,
        "agent": agent_name
    })
else:
    log_to_metrics("cache_decision", {
        "key": key,
        "decision": "miss",
        "reason": "not_found",
        "agent": agent_name
    })
```

---

## Cache Quality Metadata

Store quality metadata to help with cache prioritization:

```python
cache_set(
    key=key,
    value=result,
    ttl=ttl,
    metadata={
        "agent": "RESEARCH-AGENT",
        "quality_score": 0.92,        # 0.0-1.0
        "confidence": 0.88,            # 0.0-1.0
        "tags": ["market", "saas"],
        "source": "web-search",
        "verified": True,
        "review_status": "approved"
    }
)
```

---

## Anti-Patterns (DON'T DO THIS)

### Don't Cache User-Specific Data
```python
# BAD - each user needs unique data
key = f"agent:research:task:analysis:user123"
cache_set(key, user_specific_data)  # WRONG!
```

### Don't Use Too-Short TTL
```python
# BAD - cache expires too fast, no benefit
cache_set(key, result, ttl=60)  # Only 1 minute!
```

### Don't Cache Errors
```python
# BAD - caching failed results
if api_call_failed:
    cache_set(key, {"error": "API failed"})  # WRONG!
```

### Don't Skip Error Handling
```python
# BAD - cache error blocks execution
cached = cache_get(key)  # If this fails, whole task fails!
return cached["data"]    # WRONG - no fallback!
```

### Don't Cache Everything
```python
# BAD - caching trivial operations
tiny_calc = 2 + 2
cache_set("agent:math:task:add:abc", tiny_calc)  # Overhead > benefit!
```

---

## Cache Decision Tree

```
START: Should I cache this result?

1. Is result expensive? (>5000 tokens OR >5s execution)
   NO → Skip cache
   YES → Continue

2. Is result reusable? (same input = same output)
   NO → Skip cache
   YES → Continue

3. Is result time-sensitive? (needs real-time data)
   YES → Skip cache
   NO → Continue

4. Is result user-specific?
   YES → Skip cache
   NO → Continue

5. Is result deterministic? (predictable output)
   NO → Skip cache
   YES → USE CACHE!
```

---

## Integration Checklist

Before using cache in your agent:

- [ ] Identified cacheable operations (expensive + reusable)
- [ ] Defined appropriate TTL for content type
- [ ] Implemented key generation (using generate_key tool)
- [ ] Added cache_get check before operation
- [ ] Added cache_set after operation with metadata
- [ ] Implemented error handling (non-blocking)
- [ ] Added logging for cache hits/misses
- [ ] Tested with real workload
- [ ] Verified savings in cache_stats

---

## Expected Results

### Week 1 (Learning Phase)
- Hit rate: 30-40%
- Cost reduction: 30-40%
- Agent learning optimal patterns

### Week 2-4 (Optimization Phase)
- Hit rate: 50-70%
- Cost reduction: 60-80%
- Stable cache patterns established

### Ongoing (Steady State)
- Hit rate: 60-80%
- Cost reduction: 70-85%
- Monthly cost: £85-180 (from £400)

---

## Support

- MCP Server Logs: `.claude/cache/logs/mcp-access.log`
- Cache Metrics: `.claude/cache/logs/metrics.json`
- Server README: `.claude/mcp-servers/cache-server/README.md`
- Configuration: `.claude/cache/config.json`

---

## Quick Reference

```python
# 1. Generate key
key = generate_key("research", "analysis", query)["key"]

# 2. Check cache
cached = cache_get(key)
if cached["status"] == "hit":
    return cached["data"]

# 3. Execute & cache
result = expensive_operation()
cache_set(key, result, ttl=86400, metadata={...})

# 4. Monitor
stats = cache_stats()
print(f"Hit rate: {stats['metrics']['overall_hit_rate']}%")
```

---

**Remember:** Cache is an optimization, not a requirement. If unsure, skip cache and focus on correctness first.
