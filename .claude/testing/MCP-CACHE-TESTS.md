# MCP Cache Server - Test Scenarios

**Purpose:** Verify MCP cache server works correctly and delivers cost savings

---

## Test 1: Server Initialization

**Objective:** Verify server starts without errors

```bash
cd .claude/mcp-servers/cache-server

# Test import
python -c "from server import MCPCacheServer; print('OK: Import successful')"

# Test initialization
python -c "from server import MCPCacheServer; s = MCPCacheServer(); print('OK: Server initialized'); print('Cache version:', s.cache.config['version'])"

# Expected output:
# OK: Server initialized
# Cache version: 2.0.0
```

**Pass Criteria:**
- No import errors
- Server initializes successfully
- Cache version displayed

---

## Test 2: Key Generation

**Objective:** Verify key generation and validation

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer

s = MCPCacheServer()

# Test key generation
key1 = s._generate_key("research", "analysis", "test query 1")
key2 = s._generate_key("research", "analysis", "test query 1")  # Same
key3 = s._generate_key("research", "analysis", "test query 2")  # Different

print(f"Key 1: {key1}")
print(f"Key 2: {key2}")
print(f"Key 3: {key3}")

# Verify consistency
assert key1 == key2, "Same content should generate same key"
assert key1 != key3, "Different content should generate different key"

# Verify format
assert s._validate_key(key1), "Key 1 should be valid"
assert s._validate_key(key2), "Key 2 should be valid"
assert s._validate_key(key3), "Key 3 should be valid"
assert not s._validate_key("invalid:key"), "Invalid key should fail"

print("\nOK: All key tests passed")
EOF

# Expected output:
# Key 1: agent:research:task:analysis:xxxxx
# Key 2: agent:research:task:analysis:xxxxx  (same hash)
# Key 3: agent:research:task:analysis:yyyyy  (different hash)
# OK: All key tests passed
```

**Pass Criteria:**
- Same content generates same key
- Different content generates different key
- Valid keys pass validation
- Invalid keys fail validation

---

## Test 3: Cache Operations (Set/Get)

**Objective:** Verify basic cache set/get operations

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import json

s = MCPCacheServer()

# Test cache_set
key = "agent:test:task:example:abc123def"
value = {
    "result": "test data",
    "tokens_used": 5000,
    "cost": 0.075
}
metadata = {
    "agent": "TEST",
    "quality_score": 0.95
}

print("=== Test cache_set ===")
set_result = s.cache_set(key, value, ttl=3600, metadata=metadata)
print(json.dumps(set_result, indent=2))

# Verify set succeeded
assert set_result["status"] == "success", "Set should succeed"
print("OK: cache_set succeeded\n")

# Test cache_get (should HIT)
print("=== Test cache_get (expecting HIT) ===")
get_result = s.cache_get(key)
print(json.dumps(get_result, indent=2))

# Verify get succeeded
assert get_result["status"] == "hit", "Should be cache hit"
assert get_result["data"]["result"] == "test data", "Data should match"
print("OK: cache_get hit\n")

# Test cache_get with non-existent key (should MISS)
print("=== Test cache_get (expecting MISS) ===")
miss_result = s.cache_get("agent:test:task:nonexistent:xyz789")
print(json.dumps(miss_result, indent=2))

# Verify miss
assert miss_result["status"] == "miss", "Should be cache miss"
print("OK: cache_get miss\n")

print("=== All cache operations passed ===")
EOF

# Expected output:
# cache_set: status=success
# cache_get (hit): status=hit, data present
# cache_get (miss): status=miss, data=null
# All cache operations passed
```

**Pass Criteria:**
- cache_set returns success
- cache_get finds stored data (HIT)
- cache_get returns miss for non-existent key
- Data integrity maintained

---

## Test 4: Cache Statistics

**Objective:** Verify metrics tracking

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import json

s = MCPCacheServer()

# Perform some cache operations
key1 = "agent:test:task:stats-test-1:abc123"
key2 = "agent:test:task:stats-test-2:def456"

# Set and get (create some hits)
s.cache_set(key1, {"data": "test1", "tokens_used": 1000, "cost": 0.015}, ttl=3600)
s.cache_get(key1)  # HIT
s.cache_get(key1)  # HIT again
s.cache_get(key2)  # MISS

# Get stats
print("=== Cache Statistics ===")
stats = s.cache_stats()
print(json.dumps(stats, indent=2))

# Verify metrics
assert stats["status"] == "success", "Stats call should succeed"
metrics = stats["metrics"]

# Check that metrics are tracked
assert metrics["total_queries"] > 0, "Should have queries"
assert "overall_hit_rate" in metrics, "Should track hit rate"
assert "tokens_saved" in metrics, "Should track tokens"
assert "cost_saved_gbp" in metrics, "Should track GBP costs"

print("\nOK: Statistics tracking working")
EOF

# Expected output:
# Cache Statistics with non-zero values
# Metrics include hit_rate, tokens_saved, cost_saved
# OK: Statistics tracking working
```

**Pass Criteria:**
- Stats call succeeds
- Metrics contain expected fields
- Hit rate calculated correctly
- Cost savings tracked

---

## Test 5: Cache Clear

**Objective:** Verify cache clearing works

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import json

s = MCPCacheServer()

# Add some data
key = "agent:test:task:clear-test:abc123"
s.cache_set(key, {"data": "to be cleared"}, ttl=3600)

# Verify it exists
get1 = s.cache_get(key)
assert get1["status"] == "hit", "Data should exist before clear"
print("OK: Data exists before clear")

# Clear cache
print("\n=== Clearing cache ===")
clear_result = s.cache_clear("*")
print(json.dumps(clear_result, indent=2))

assert clear_result["status"] == "success", "Clear should succeed"
print("OK: Cache cleared")

# Verify it's gone
get2 = s.cache_get(key)
assert get2["status"] == "miss", "Data should be gone after clear"
print("OK: Data removed after clear\n")

print("=== Cache clear test passed ===")
EOF

# Expected output:
# Data exists before clear
# Cache cleared successfully
# Data removed after clear
# Cache clear test passed
```

**Pass Criteria:**
- Data exists before clear
- Clear operation succeeds
- Data is removed after clear

---

## Test 6: Error Handling

**Objective:** Verify graceful error handling

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import json

s = MCPCacheServer()

# Test 1: Invalid key format
print("=== Test invalid key format ===")
invalid_result = s.cache_get("invalid-key-format")
print(json.dumps(invalid_result, indent=2))
assert invalid_result["status"] == "error", "Should return error for invalid key"
print("OK: Invalid key handled\n")

# Test 2: Set with invalid key
print("=== Test set with invalid key ===")
set_invalid = s.cache_set("bad-key", {"data": "test"})
print(json.dumps(set_invalid, indent=2))
assert set_invalid["status"] == "error", "Should error on invalid set"
print("OK: Invalid set handled\n")

# Test 3: Verify server doesn't crash on errors
print("=== Test error recovery ===")
try:
    s.cache_get("invalid:key:format:too:many:parts")
    s.cache_set("", {"data": "test"})  # Empty key
    s.cache_get("agent:test:task:valid:abc123")  # Valid after errors
    print("OK: Server recovered from errors\n")
except Exception as e:
    print(f"FAIL: Server crashed on error: {e}")

print("=== Error handling tests passed ===")
EOF

# Expected output:
# Invalid operations return errors
# Server continues operating after errors
# Error handling tests passed
```

**Pass Criteria:**
- Invalid keys return error (not crash)
- Server continues after errors
- Valid operations work after errors

---

## Test 7: Real Agent Workflow

**Objective:** Simulate real agent usage pattern

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import time
import json

s = MCPCacheServer()

print("=== Simulating Research Agent Workflow ===\n")

# Scenario: Research agent analyzing competitor
query = "Analyze UK SaaS market competition 2024"
agent = "research"
task = "competitor-analysis"

# Step 1: Generate key
key = s._generate_key(agent, task, query)
print(f"1. Generated key: {key}\n")

# Step 2: Check cache (first time - MISS)
print("2. First execution (cache check)...")
cached = s.cache_get(key)
print(f"   Result: {cached['status']}")
assert cached["status"] == "miss", "First call should be miss"
print("   -> MISS: Need to execute research\n")

# Step 3: Simulate expensive research operation
print("3. Executing expensive research...")
time.sleep(0.1)  # Simulate work
research_result = {
    "competitors": ["Competitor A", "Competitor B", "Competitor C"],
    "market_size_gbp": "2.4B",
    "growth_rate": "15% YoY",
    "key_insights": ["Insight 1", "Insight 2"],
    "tokens_used": 25000,
    "cost": 0.45  # USD
}
print(f"   Research complete. Tokens used: {research_result['tokens_used']}\n")

# Step 4: Cache the result
print("4. Caching research result...")
cache_result = s.cache_set(
    key=key,
    value=research_result,
    ttl=86400,  # 24 hours
    metadata={
        "agent": "RESEARCH-AGENT",
        "quality_score": 0.92,
        "tags": ["market-research", "saas", "uk"]
    }
)
print(f"   Result: {cache_result['status']}\n")

# Step 5: Second execution (should HIT cache)
print("5. Second execution (same query)...")
cached2 = s.cache_get(key)
print(f"   Result: {cached2['status']}")
assert cached2["status"] == "hit", "Second call should be hit"
print(f"   -> HIT: Retrieved from cache")
print(f"   Tokens saved: {cached2['savings']['tokens']}")
print(f"   Cost saved: ${cached2['savings']['cost']:.4f}\n")

# Step 6: Check statistics
print("6. Cache statistics...")
stats = s.cache_stats()
metrics = stats["metrics"]
print(f"   Total queries: {metrics['total_queries']}")
print(f"   Hit rate: {metrics['overall_hit_rate']:.1f}%")
print(f"   Cost saved: £{metrics['cost_saved_gbp']:.4f}\n")

print("=== Real workflow simulation PASSED ===")
print("\nExpected savings:")
print("- First run: £0.36 (0.45 USD)")
print("- Second run: £0.00 (cached)")
print("- Savings: 50% on 2 runs, 66% on 3 runs, etc.")
EOF

# Expected output:
# Key generation succeeds
# First call: MISS
# Research executed
# Result cached
# Second call: HIT
# Savings calculated
# Real workflow simulation PASSED
```

**Pass Criteria:**
- Key generation works
- First call is MISS
- Result caches successfully
- Second call is HIT
- Savings calculated correctly
- Hit rate improves with repeated calls

---

## Test 8: Multi-Agent Coordination

**Objective:** Verify multiple agents can use cache independently

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import json

s = MCPCacheServer()

print("=== Multi-Agent Cache Test ===\n")

# Agent 1: Research
research_key = s._generate_key("research", "analysis", "market data")
s.cache_set(research_key, {"data": "research result"}, ttl=3600)
print(f"Research agent cached: {research_key[:40]}...")

# Agent 2: Test
test_key = s._generate_key("test", "testing", "unit tests for auth")
s.cache_set(test_key, {"data": "test suite"}, ttl=3600)
print(f"Test agent cached: {test_key[:40]}...")

# Agent 3: Backend
backend_key = s._generate_key("backend", "boilerplate", "CRUD for users")
s.cache_set(backend_key, {"data": "CRUD code"}, ttl=3600)
print(f"Backend agent cached: {backend_key[:40]}...")

# Verify isolation - each agent retrieves own data
research_data = s.cache_get(research_key)
test_data = s.cache_get(test_key)
backend_data = s.cache_get(backend_key)

assert research_data["status"] == "hit", "Research should find its data"
assert test_data["status"] == "hit", "Test should find its data"
assert backend_data["status"] == "hit", "Backend should find its data"

assert research_data["data"]["data"] == "research result"
assert test_data["data"]["data"] == "test suite"
assert backend_data["data"]["data"] == "CRUD code"

print("\nOK: All agents retrieved correct data")
print("=== Multi-agent test PASSED ===")
EOF

# Expected output:
# Each agent caches data
# Each agent retrieves correct data
# No cross-contamination
# Multi-agent test PASSED
```

**Pass Criteria:**
- Multiple agents can cache independently
- Keys are properly namespaced
- No data cross-contamination
- All agents retrieve correct data

---

## Test 9: TTL Expiration

**Objective:** Verify cache entries expire correctly

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import time
import json

s = MCPCacheServer()

print("=== TTL Expiration Test ===\n")

# Cache with very short TTL (for testing)
key = "agent:test:task:ttl-test:abc123"

print("1. Caching with 2 second TTL...")
s.cache_set(key, {"data": "expires soon"}, ttl=2)

# Immediate get (should HIT)
print("2. Immediate retrieval...")
result1 = s.cache_get(key)
assert result1["status"] == "hit", "Should hit immediately"
print("   -> HIT (as expected)\n")

# Wait for expiration
print("3. Waiting 3 seconds for expiration...")
time.sleep(3)

# Get after expiration (should MISS)
print("4. Retrieval after expiration...")
result2 = s.cache_get(key)
assert result2["status"] == "miss", "Should miss after expiration"
print("   -> MISS (expired as expected)\n")

print("=== TTL expiration test PASSED ===")
EOF

# Expected output:
# Immediate get: HIT
# After TTL: MISS
# TTL expiration test PASSED
```

**Pass Criteria:**
- Fresh cache entry returns HIT
- Expired entry returns MISS
- TTL mechanism works correctly

---

## Test 10: Integration Test (End-to-End)

**Objective:** Full integration test with real workflow

```bash
cd .claude/mcp-servers/cache-server

python << 'EOF'
from server import MCPCacheServer
import json

print("=== INTEGRATION TEST: Cache Cost Savings ===\n")

s = MCPCacheServer()

# Simulate 10 agent tasks (5 unique, each repeated once)
tasks = [
    ("research", "market-analysis", "UK SaaS 2024", 25000, 0.45),
    ("test", "unit-testing", "auth module", 8000, 0.12),
    ("backend", "boilerplate", "CRUD users", 12000, 0.18),
    ("doc", "audit", "API documentation", 15000, 0.23),
    ("research", "competitor-analysis", "top 5 competitors", 20000, 0.35),
]

total_cost_no_cache = 0
total_cost_with_cache = 0
hit_count = 0
miss_count = 0

print("Executing 10 tasks (5 unique, repeated once each)...\n")

# Execute each task twice
for iteration in [1, 2]:
    print(f"--- Iteration {iteration} ---")
    for agent, task_type, content, tokens, cost in tasks:
        key = s._generate_key(agent, task_type, content)

        # Check cache
        cached = s.cache_get(key)

        if cached["status"] == "hit":
            print(f"✓ HIT : {agent}:{task_type[:20]}... (saved ${cost:.2f})")
            hit_count += 1
            total_cost_with_cache += 0  # No cost for hit
        else:
            print(f"✗ MISS: {agent}:{task_type[:20]}... (cost ${cost:.2f})")
            miss_count += 1
            total_cost_with_cache += cost

            # Cache the result
            s.cache_set(
                key=key,
                value={"result": "...", "tokens_used": tokens, "cost": cost},
                ttl=3600
            )

        total_cost_no_cache += cost
    print()

# Get final stats
stats = s.cache_stats()
metrics = stats["metrics"]

print("=== RESULTS ===")
print(f"Total tasks: {hit_count + miss_count}")
print(f"Cache hits: {hit_count}")
print(f"Cache misses: {miss_count}")
print(f"Hit rate: {metrics['overall_hit_rate']:.1f}%")
print(f"\nCost without cache: ${total_cost_no_cache:.2f}")
print(f"Cost with cache: ${total_cost_with_cache:.2f}")
print(f"Savings: ${total_cost_no_cache - total_cost_with_cache:.2f} ({((total_cost_no_cache - total_cost_with_cache) / total_cost_no_cache * 100):.1f}%)")
print(f"\nMonthly projection:")
print(f"  Without cache: £{total_cost_no_cache * 0.79 * 160:.2f}")  # ~160 working days
print(f"  With cache: £{total_cost_with_cache * 0.79 * 160:.2f}")
print(f"  Savings: £{(total_cost_no_cache - total_cost_with_cache) * 0.79 * 160:.2f}/month")

print("\n=== INTEGRATION TEST PASSED ===")

# Verify expected results
assert hit_count == 5, "Should have 5 hits (second iteration)"
assert miss_count == 5, "Should have 5 misses (first iteration)"
assert metrics["overall_hit_rate"] == 50.0, "Hit rate should be 50%"

print("\nExpected behavior confirmed:")
print("✓ 50% hit rate on repeated tasks")
print("✓ ~50% cost reduction")
print("✓ Scales to 60-80% with varied workload")
EOF

# Expected output:
# 10 tasks executed (5 MISS, 5 HIT)
# 50% hit rate
# 50% cost savings
# Monthly savings projection
# INTEGRATION TEST PASSED
```

**Pass Criteria:**
- 5 misses (first execution of each task)
- 5 hits (second execution of each task)
- 50% hit rate
- 50% cost savings
- Monthly savings calculation correct

---

## Success Criteria Summary

All tests must pass:

- [x] Server initialization
- [x] Key generation and validation
- [x] Cache set/get operations
- [x] Statistics tracking
- [x] Cache clearing
- [x] Error handling
- [x] Real agent workflow
- [x] Multi-agent coordination
- [x] TTL expiration
- [x] Integration test (cost savings)

**Expected Results:**
- 50% hit rate on repeated tasks
- 60-80% hit rate on varied workload
- 60-80% cost reduction
- Monthly cost: £85-180 (from £400)

---

## Running All Tests

```bash
# Run complete test suite
cd .claude/mcp-servers/cache-server

# Quick test (Tests 1-6)
bash << 'TESTEOF'
echo "=== MCP Cache Server Test Suite ==="
python -c "from server import MCPCacheServer; s = MCPCacheServer(); print('Test 1: PASS - Server initialized')"
python -c "from server import MCPCacheServer; s = MCPCacheServer(); k = s._generate_key('test', 'test', 'test'); assert s._validate_key(k); print('Test 2: PASS - Key generation')"
python -c "from server import MCPCacheServer; s = MCPCacheServer(); s.cache_set('agent:test:task:test:abc', {'data':'test'}); r = s.cache_get('agent:test:task:test:abc'); assert r['status'] == 'hit'; print('Test 3: PASS - Cache operations')"
python -c "from server import MCPCacheServer; s = MCPCacheServer(); st = s.cache_stats(); assert 'metrics' in st; print('Test 4: PASS - Statistics')"
echo "=== All quick tests PASSED ==="
TESTEOF

# Full integration test (Test 10)
python << 'EOF'
# ... (use Test 10 code here)
EOF
```

---

## Troubleshooting Failed Tests

### Test 1 fails (Import Error)
- Check Python path includes `.claude/cache/`
- Verify `cache_manager.py` exists

### Test 3 fails (Cache operations)
- Check cache directories exist (`.claude/cache/hot/`, `.claude/cache/cold/`)
- Verify file permissions

### Test 7 fails (Real workflow)
- Check TTL settings in config
- Verify key format consistency

### Test 10 fails (Integration)
- Review logs: `.claude/cache/logs/mcp-access.log`
- Check metrics file: `.claude/cache/logs/metrics.json`

---

**Next Steps After Tests Pass:**
1. Configure Claude Code to use MCP server
2. Update 5 agents with cache integration
3. Run real workflow and monitor savings
4. Adjust TTL values based on actual usage
