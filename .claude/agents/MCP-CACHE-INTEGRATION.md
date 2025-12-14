# MCP Cache Integration for Agents

**Purpose:** Add MCP cache integration to cost-heavy agents for 60-80% cost reduction

**Status:** ACTIVE - Use patterns below in agent workflows

**Savings Target:** £240-320/month (from £400 to £85-180)

---

## Integrated Agents

### 1. RESEARCH-AGENT

**Cache Key:** `agent:research:task:{category}:{hash}`
**TTL:** 24h (market), 12h (tech/risk)
**Hit Rate Target:** 70-80%

**Integration Point:** Before step 1 (SCOPE)

```python
# BEFORE executing research workflow
from mcp import cache_get, cache_set, generate_key

# Generate key from research query
category = "market"  # TECH, COMP, USER, MARKET, PRICE, RISK
query = "UK SaaS market analysis 2024"
key = generate_key("research", category, query)["key"]

# Check cache
cached = cache_get(key)
if cached["status"] == "hit":
    print(f"[CACHE HIT] Research retrieved from cache")
    print(f"Tokens saved: {cached['savings']['tokens']}")
    print(f"Cost saved: ${cached['savings']['cost']:.2f}")
    return cached["data"]

# CACHE MISS - proceed with normal workflow (SCOPE → GATHER → ANALYZE → SYNTHESIZE → DOCUMENT)
print("[CACHE MISS] Executing new research...")

# ... execute research workflow ...

research_result = {
    "topic": query,
    "sources": [...],
    "comparison_matrix": {...},
    "recommendation": "...",
    "tokens_used": 25000,
    "cost": 0.45
}

# Cache result
cache_set(
    key=key,
    value=research_result,
    ttl=86400,  # 24 hours for market research
    metadata={
        "agent": "RESEARCH-AGENT",
        "category": category,
        "confidence": "high"
    }
)

return research_result
```

**TTL Guidelines:**
- Market/Competitor/Pricing/User: 24h (86400s)
- Technology/Risk: 12h (43200s)

**Expected Savings:** £225/month (75%)

---

### 2. TEST-ENGINEER

**Cache Key:** `agent:test:file:{filename}:hash:{content_hash}`
**TTL:** 1 hour (3600s)
**Hit Rate Target:** 40-50%

**Integration Point:** Before writing tests (Story level)

```python
# BEFORE writing tests
from mcp import cache_get, cache_set, generate_key
import hashlib

# Hash file content
file_content = read_file(filepath)
content_hash = hashlib.sha256(file_content.encode()).hexdigest()[:12]
filename = Path(filepath).name

# Generate cache key
key = f"agent:test:file:{filename}:hash:{content_hash}"

# Check cache
cached = cache_get(key)
if cached["status"] == "hit":
    # File unchanged - check if tests are still relevant
    similarity = calculate_similarity(cached["data"]["file_content"], file_content)

    if similarity > 0.9:
        print(f"[CACHE HIT] Tests retrieved (similarity: {similarity:.1%})")
        print(f"Tokens saved: {cached['savings']['tokens']}")
        # Adapt cached tests to current context
        tests = adapt_tests(cached["data"]["tests"], file_content)
        return tests
    else:
        print(f"[CACHE MISS] File changed significantly (similarity: {similarity:.1%})")

# CACHE MISS or low similarity - write new tests
print("[CACHE MISS] Writing new tests...")

# ... execute test writing workflow ...

tests = write_unit_tests(file_content)

# Cache tests
cache_set(
    key=key,
    value={
        "tests": tests,
        "file_content": file_content,
        "file_hash": content_hash,
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

**Expected Savings:** £45/month (40%)

---

### 3. BACKEND-DEV (Boilerplate Mode Only)

**Cache Key:** `agent:backend:task:boilerplate:{spec_hash}`
**TTL:** 4 hours (14400s)
**Hit Rate Target:** 80-90% (boilerplate is highly reusable)

**Integration Point:** When `is_boilerplate=true` or `is_crud=true`

```python
# BEFORE generating boilerplate code
from mcp import cache_get, cache_set, generate_key

# Check if this is boilerplate
if task_type == "crud" and is_standard_pattern(spec):
    # Generate spec hash
    spec_hash = hashlib.sha256(json.dumps(spec, sort_keys=True).encode()).hexdigest()[:12]
    key = f"agent:backend:task:boilerplate-crud:{spec_hash}"

    # Check cache
    cached = cache_get(key)
    if cached["status"] == "hit":
        print(f"[CACHE HIT] Boilerplate retrieved from cache")
        print(f"Tokens saved: {cached['savings']['tokens']}")
        # Adapt template to current entity
        code = adapt_template(cached["data"]["template"], entity_name=spec["entity"])
        return code

    # CACHE MISS - generate boilerplate
    print("[CACHE MISS] Generating boilerplate...")
    code = generate_crud_boilerplate(spec)

    # Cache template
    cache_set(
        key=key,
        value={
            "template": code,
            "spec": spec,
            "tokens_used": 12000,
            "cost": 0.18
        },
        ttl=14400,  # 4 hours
        metadata={
            "agent": "BACKEND-DEV",
            "type": "boilerplate",
            "pattern": "crud"
        }
    )

    return code
else:
    # NOT boilerplate - skip cache, execute normally
    return implement_feature(spec)
```

**Cache Only For:**
- CRUD operations
- REST endpoints (< 50 lines)
- Database models
- Basic validation

**Do NOT Cache:**
- Complex business logic
- Security-critical code
- Unique implementations

**Expected Savings:** £60/month (65%) on boilerplate tasks

---

### 4. DOC-AUDITOR

**Cache Key:** `agent:doc:audit:{doc_path}:version:{version_hash}`
**TTL:** 12 hours (43200s)
**Hit Rate Target:** 60-70%

**Integration Point:** Before audit execution

```python
# BEFORE auditing document
from mcp import cache_get, cache_set, generate_key
import hashlib

# Read document and hash content
doc_content = read_file(doc_path)
version_hash = hashlib.sha256(doc_content.encode()).hexdigest()[:12]
doc_name = Path(doc_path).name

# Generate cache key
key = f"agent:doc:audit:{doc_name}:version:{version_hash}"

# Check cache
cached = cache_get(key)
if cached["status"] == "hit":
    print(f"[CACHE HIT] Document unchanged - returning previous audit")
    print(f"Tokens saved: {cached['savings']['tokens']}")
    print(f"Cached at: {cached['cached_at']}")
    return cached["data"]

# CACHE MISS - document changed or new
print("[CACHE MISS] Auditing document...")

# ... execute audit workflow ...

audit_result = {
    "doc_path": doc_path,
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
        "doc_version": version_hash,
        "audit_date": datetime.now().isoformat()
    }
)

return audit_result
```

**Expected Savings:** £40/month (60%)

---

### 5. TECH-WRITER (Template Mode)

**Cache Key:** `agent:writer:template:{template_type}:{spec_hash}`
**TTL:** 24 hours (86400s)
**Hit Rate Target:** 50-60%

**Integration Point:** When writing template-based documentation

```python
# BEFORE writing documentation
from mcp import cache_get, cache_set, generate_key

# Check if this is template-based
if is_template_based(doc_type):
    # API docs, README, guides often follow templates
    spec_hash = hashlib.sha256(json.dumps(spec, sort_keys=True).encode()).hexdigest()[:12]
    key = f"agent:writer:template:{doc_type}:{spec_hash}"

    # Check cache
    cached = cache_get(key)
    if cached["status"] == "hit":
        print(f"[CACHE HIT] Template retrieved from cache")
        print(f"Tokens saved: {cached['savings']['tokens']}")
        # Adapt template to current spec
        doc = adapt_template(cached["data"]["template"], spec)
        return doc

    # CACHE MISS - write new documentation
    print("[CACHE MISS] Writing documentation...")

    # ... execute writing workflow ...

    doc_content = write_documentation(spec)

    # Cache template
    cache_set(
        key=key,
        value={
            "template": doc_content,
            "spec": spec,
            "tokens_used": 6000,
            "cost": 0.09
        },
        ttl=86400,  # 24 hours
        metadata={
            "agent": "TECH-WRITER",
            "doc_type": doc_type,
            "template": True
        }
    )

    return doc_content
else:
    # NOT template-based (ADR, architecture docs) - skip cache
    return write_documentation(spec)
```

**Cache For:**
- API documentation
- README updates
- User guides (template-based)
- Standard doc types

**Do NOT Cache:**
- ADR documents (unique decisions)
- Architecture docs (unique designs)
- Creative content

**Expected Savings:** £30/month (50%)

---

## Cache Usage Summary

| Agent | Hit Rate | Savings/Month | Integration Effort |
|-------|----------|---------------|-------------------|
| RESEARCH-AGENT | 70-80% | £225 | Easy |
| TEST-ENGINEER | 40-50% | £45 | Medium |
| BACKEND-DEV (boilerplate) | 80-90% | £60 | Easy |
| DOC-AUDITOR | 60-70% | £40 | Easy |
| TECH-WRITER (templates) | 50-60% | £30 | Easy |

**Total Expected Savings:** £400/month

**Combined Hit Rate:** 60-70% average

**Total Cost Reduction:** 75-80%

---

## General Pattern (All Agents)

```python
# 1. Generate cache key
key = generate_key(
    agent_name="your-agent",
    task_type="your-task-type",
    content=unique_content
)["key"]

# 2. Check cache BEFORE expensive operation
cached = cache_get(key)
if cached["status"] == "hit":
    log_savings(cached["savings"])
    return cached["data"]

# 3. Execute expensive operation (cache miss)
result = expensive_operation()

# 4. Cache result with appropriate TTL
cache_set(
    key=key,
    value=result,
    ttl=appropriate_ttl,
    metadata={"agent": "YOUR-AGENT", ...}
)

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
    # Log error but continue
    log(f"Cache error (non-blocking): {e}")
    # Fall through to normal execution

# Normal execution
result = execute_task()
return result
```

---

## Monitoring Cache Effectiveness

At end of each agent task:

```python
# Get cache statistics
stats = cache_stats()
print(f"\n=== Cache Performance ===")
print(f"Hit rate: {stats['metrics']['overall_hit_rate']}%")
print(f"Tokens saved: {stats['metrics']['tokens_saved']}")
print(f"Cost saved: £{stats['metrics']['cost_saved_gbp']}")
```

---

## Next Steps

1. Read `.claude/patterns/MCP-CACHE-PATTERN.md` for detailed patterns
2. Test with real workload
3. Monitor savings in `.claude/cache/logs/metrics.json`
4. Adjust TTL values based on actual usage
5. Optimize cache keys for better hit rates

---

## References

- MCP Server: `.claude/mcp-servers/cache-server/README.md`
- Cache Patterns: `.claude/patterns/MCP-CACHE-PATTERN.md`
- Test Scenarios: `.claude/testing/MCP-CACHE-TESTS.md`
- Cache Logs: `.claude/cache/logs/mcp-access.log`
- Metrics: `.claude/cache/logs/metrics.json`
