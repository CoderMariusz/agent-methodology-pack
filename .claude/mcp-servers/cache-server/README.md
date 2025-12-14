# MCP Cache Server

Production-ready MCP server that exposes the universal cache system to Claude Code agents.

## Purpose

Reduce agent costs by 60-80% through intelligent caching of task results.

**Problem:** Task tool doesn't use cache = £400/month costs
**Solution:** MCP server exposes cache to agents = £85-180/month costs
**Savings:** £240-320/month (60-80% reduction)

## Architecture

```
┌─────────────────┐
│  Claude Agent   │
│  (Research/Test)│
└────────┬────────┘
         │ MCP Protocol (stdio)
         ▼
┌─────────────────┐
│ MCP Cache Server│ (this server)
│   server.py     │
└────────┬────────┘
         │ Python API
         ▼
┌─────────────────┐
│  cache_manager  │ (existing)
│  4-layer cache  │
└─────────────────┘
```

## Installation

### 1. Verify cache_manager.py exists

```bash
ls .claude/cache/cache_manager.py
# Should exist - installed in Phase 1-2
```

### 2. Test MCP server

```bash
cd .claude/mcp-servers/cache-server
python server.py
# Should start without errors
```

### 3. Configure Claude Code (if not using MCP auto-discovery)

Add to `~/.config/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "agent-cache": {
      "command": "python",
      "args": ["-u", "server.py"],
      "cwd": "/path/to/agent-methodology-pack/.claude/mcp-servers/cache-server"
    }
  }
}
```

## Tools Exposed

### 1. cache_get(key: str)

Check cache before executing expensive operations.

**Example:**
```python
# Agent checks cache first
key = "agent:research:task:market-analysis:abc123"
result = cache_get(key)

if result["status"] == "hit":
    print(f"CACHE HIT! Saved {result['savings']['tokens']} tokens")
    return result["data"]
else:
    print("CACHE MISS - executing research...")
    data = execute_research()
    cache_set(key, data, ttl=86400)  # Cache for 24h
    return data
```

### 2. cache_set(key, value, ttl, metadata)

Store results after expensive operations.

**Example:**
```python
# After executing research
cache_set(
    key="agent:research:task:competitor-analysis:xyz789",
    value={
        "competitors": [...],
        "analysis": "...",
        "tokens_used": 25000,
        "cost": 0.45
    },
    ttl=86400,  # 24 hours
    metadata={
        "agent": "RESEARCH-AGENT",
        "quality_score": 0.92,
        "tags": ["competitive-analysis", "market-research"]
    }
)
```

### 3. cache_stats()

Monitor cache performance.

**Example:**
```python
stats = cache_stats()
print(f"Hit rate: {stats['metrics']['overall_hit_rate']}%")
print(f"Cost saved: £{stats['metrics']['cost_saved_gbp']}")
print(f"Tokens saved: {stats['metrics']['tokens_saved']}")
```

### 4. cache_clear(pattern)

Clear cache entries (admin/debugging).

**Example:**
```python
# Clear all research cache
cache_clear("agent:research:*")

# Clear everything (use cautiously)
cache_clear("*")
```

### 5. generate_key(agent_name, task_type, content)

Helper to generate consistent keys.

**Example:**
```python
key_result = generate_key(
    agent_name="research",
    task_type="market-analysis",
    content="Analyze SaaS market in UK 2024"
)
key = key_result["key"]
# Returns: "agent:research:task:market-analysis:a3f9c2d1"
```

## Key Format

Cache keys follow strict format:

```
agent:{agent_name}:task:{task_type}:{hash}
```

**Examples:**
- `agent:research:task:market-analysis:abc123def`
- `agent:test:task:unit-tests:xyz789abc`
- `agent:backend:task:boilerplate-crud:def456ghi`

**Parts:**
- `agent`: Fixed prefix
- `{agent_name}`: research, test, backend, doc, writer
- `task`: Fixed separator
- `{task_type}`: analysis, testing, boilerplate, audit, template
- `{hash}`: 12-char SHA-256 hash of content (for uniqueness)

## TTL Guidelines

Recommended time-to-live by content type:

| Content Type | TTL | Reason |
|--------------|-----|--------|
| Research | 24h (86400s) | Data changes slowly |
| Tests | 1h (3600s) | Code changes frequently |
| Boilerplate | 4h (14400s) | Templates stable |
| Documentation | 12h (43200s) | Specs semi-stable |
| API data | 1h (3600s) | External data volatile |

## Security

- **Read-only for agents**: Agents can only read/write their own namespace
- **Key namespacing**: `agent:{name}:*` prevents cross-agent access
- **No system access**: Cannot access cache system files or config
- **Graceful degradation**: Cache miss = proceed without cache (no blocking)
- **Logging**: All operations logged to `.claude/cache/logs/mcp-access.log`

## Error Handling

Server handles errors gracefully:

- **Invalid key format**: Returns error, suggests correct format
- **Cache unavailable**: Returns miss, allows operation to proceed
- **Serialization error**: Logs error, returns miss
- **All errors logged**: Check `mcp-access.log` for diagnostics

## Monitoring

### Access Logs

```bash
tail -f .claude/cache/logs/mcp-access.log
```

Example log entry:
```json
{
  "timestamp": "2025-12-14T10:30:45.123Z",
  "layer": "hot",
  "key": "agent:research:t...",
  "status": "HIT"
}
```

### Metrics

```bash
cat .claude/cache/logs/metrics.json
```

Example metrics:
```json
{
  "total_queries": 150,
  "hot_hits": 68,
  "cold_hits": 35,
  "overall_hit_rate": 68.67,
  "tokens_saved": 1250000,
  "cost_saved_usd": 48.75,
  "cost_saved_gbp": 38.51
}
```

## Troubleshooting

### Server won't start

```bash
# Check Python path
python --version  # Should be 3.8+

# Check cache_manager import
cd .claude/mcp-servers/cache-server
python -c "import sys; sys.path.insert(0, '../../cache'); from cache_manager import CacheManager; print('OK')"
```

### Cache not working

```bash
# Check cache directories
ls -la .claude/cache/hot/
ls -la .claude/cache/cold/

# Check logs
tail -20 .claude/cache/logs/mcp-access.log

# Test manually
python
>>> from server import MCPCacheServer
>>> s = MCPCacheServer()
>>> s.cache_get("agent:test:task:example:abc123")
```

### High miss rate

Check:
- Are agents using correct key format?
- Is TTL too short for content type?
- Is content changing between calls?
- Check logs for key variations

## Performance

**Expected Performance:**
- Hot cache lookup: <1ms
- Cold cache lookup: <10ms
- Cache set: <5ms
- Hit rate target: 50-70% (first week)
- Cost reduction: 60-80% (after optimization)

## Testing

See `.claude/testing/MCP-CACHE-TESTS.md` for test scenarios.

Quick test:
```bash
cd .claude/mcp-servers/cache-server

# Test 1: Start server
python server.py &
SERVER_PID=$!

# Test 2: Send cache_set request (via echo/stdin)
echo '{"jsonrpc":"2.0","id":1,"method":"cache_set","params":{"key":"agent:test:task:example:abc123","value":{"result":"test"}}}' | python server.py

# Test 3: Send cache_get request
echo '{"jsonrpc":"2.0","id":2,"method":"cache_get","params":{"key":"agent:test:task:example:abc123"}}' | python server.py

# Test 4: Check stats
echo '{"jsonrpc":"2.0","id":3,"method":"cache_stats","params":{}}' | python server.py

# Cleanup
kill $SERVER_PID
```

## Integration with Agents

See `.claude/patterns/MCP-CACHE-PATTERN.md` for detailed agent integration patterns.

## Maintenance

### Clear old cache entries

```bash
# Clear hot cache (in-memory, auto-cleared on restart)
# Clear cold cache (files older than 24h auto-expire)

# Manual clear all
cd .claude/mcp-servers/cache-server
python -c "from server import MCPCacheServer; s = MCPCacheServer(); s.cache_clear('*')"
```

### Monitor costs

```bash
# Daily cost check
python -c "from server import MCPCacheServer; import json; s = MCPCacheServer(); print(json.dumps(s.cache_stats(), indent=2))"
```

## Roadmap

- [x] Phase 1: Basic MCP server with 4 tools
- [x] Phase 2: Key generation and validation
- [x] Phase 3: Logging and metrics
- [ ] Phase 4: Pattern-based clearing
- [ ] Phase 5: Semantic cache integration
- [ ] Phase 6: Multi-agent coordination

## Support

- Logs: `.claude/cache/logs/mcp-access.log`
- Metrics: `.claude/cache/logs/metrics.json`
- Config: `.claude/cache/config.json`
- Issues: Check logs first, then review key format and TTL settings

## License

MIT - Part of Agent Methodology Pack
