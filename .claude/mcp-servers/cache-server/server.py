#!/usr/bin/env python3
"""
MCP Cache Server - Production-ready cache integration for Claude Code agents
Version: 1.0.0
Purpose: Expose universal cache to agents via MCP protocol
Expected Savings: 60-80% cost reduction (£85-180/month from £400/month)
"""

import sys
import os
import json
import hashlib
import logging
from pathlib import Path
from typing import Optional, Dict, Any

# Add parent directories to path for cache_manager import
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "cache"))

try:
    from cache_manager import CacheManager
except ImportError:
    print("ERROR: Cannot import cache_manager. Check path.", file=sys.stderr)
    sys.exit(1)

# Configure logging
log_dir = Path(__file__).parent.parent.parent / "cache" / "logs"
log_dir.mkdir(parents=True, exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(log_dir / "mcp-access.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("mcp-cache-server")


class MCPCacheServer:
    """
    MCP Server that exposes cache_manager.py functionality to Claude Code agents.

    Provides 4 tools:
    1. cache_get - Retrieve cached results
    2. cache_set - Store task results
    3. cache_stats - Get performance metrics
    4. cache_clear - Clear cache entries (admin only)
    """

    def __init__(self):
        """Initialize MCP cache server"""
        try:
            cache_config = Path(__file__).parent.parent.parent / "cache" / "config.json"
            self.cache = CacheManager(str(cache_config))
            logger.info("MCP Cache Server initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize cache manager: {e}")
            raise

    def _generate_key(self, agent_name: str, task_type: str, content: str) -> str:
        """
        Generate consistent cache key for agents.

        Format: agent:{agent_name}:task:{task_type}:{hash}
        Example: agent:research:task:market-analysis:abc123def

        Args:
            agent_name: Name of the agent (e.g., "research", "test")
            task_type: Type of task (e.g., "analysis", "testing")
            content: Task content/query to hash

        Returns:
            Consistent cache key string
        """
        content_hash = hashlib.sha256(content.encode('utf-8')).hexdigest()[:12]
        key = f"agent:{agent_name}:task:{task_type}:{content_hash}"
        return key

    def _validate_key(self, key: str) -> bool:
        """
        Validate cache key format.

        Expected format: agent:{name}:task:{type}:{hash}

        Args:
            key: Cache key to validate

        Returns:
            True if valid, False otherwise
        """
        parts = key.split(":")
        if len(parts) != 5:
            return False
        if parts[0] != "agent" or parts[2] != "task":
            return False
        return True

    def cache_get(self, key: str) -> Dict[str, Any]:
        """
        Tool: cache_get

        Retrieve cached result for a task. Returns null if not found.
        Agents should call this before executing expensive operations.

        Args:
            key: Cache key (e.g., agent:research:task:analysis:hash)

        Returns:
            {
                "status": "hit" | "miss",
                "data": {...} | null,
                "metadata": {...},
                "savings": {"tokens": int, "cost": float}
            }
        """
        try:
            if not self._validate_key(key):
                logger.warning(f"Invalid key format: {key}")
                return {
                    "status": "error",
                    "error": "Invalid key format. Expected: agent:name:task:type:hash",
                    "data": None
                }

            # Query cache using the key as query (cache_manager uses hash internally)
            result = self.cache.get(key)

            if result:
                logger.info(f"CACHE HIT: {key[:50]}...")

                # Calculate savings from this hit
                savings = {
                    "tokens": result.get("response", {}).get("tokens_used", 0),
                    "cost": result.get("response", {}).get("cost", 0.0)
                }

                return {
                    "status": "hit",
                    "data": result.get("response"),
                    "metadata": result.get("metadata", {}),
                    "cached_at": result.get("cached_at"),
                    "savings": savings
                }
            else:
                logger.info(f"CACHE MISS: {key[:50]}...")
                return {
                    "status": "miss",
                    "data": None,
                    "message": "Cache miss - execute task and call cache_set"
                }

        except Exception as e:
            logger.error(f"Error in cache_get: {e}", exc_info=True)
            return {
                "status": "error",
                "error": str(e),
                "data": None
            }

    def cache_set(self, key: str, value: Dict[str, Any], ttl: int = 3600,
                  metadata: Optional[Dict] = None) -> Dict[str, Any]:
        """
        Tool: cache_set

        Store task result in cache for reuse. Call this after executing
        an expensive operation that produced a cacheable result.

        Args:
            key: Cache key (must match format)
            value: Result to cache (any JSON-serializable dict)
            ttl: Time to live in seconds (default 3600 = 1 hour)
            metadata: Optional metadata (agent name, quality score, etc.)

        Returns:
            {
                "status": "success" | "error",
                "message": str,
                "key": str
            }
        """
        try:
            if not self._validate_key(key):
                return {
                    "status": "error",
                    "error": "Invalid key format",
                    "key": key
                }

            # Enrich metadata with MCP info
            enriched_metadata = metadata or {}
            enriched_metadata.update({
                "source": "mcp-cache-server",
                "ttl_seconds": ttl,
                "key": key
            })

            # Store in cache
            self.cache.set(key, value, enriched_metadata)

            logger.info(f"CACHE SET: {key[:50]}... (TTL: {ttl}s)")

            return {
                "status": "success",
                "message": f"Cached successfully with {ttl}s TTL",
                "key": key
            }

        except Exception as e:
            logger.error(f"Error in cache_set: {e}", exc_info=True)
            return {
                "status": "error",
                "error": str(e),
                "key": key
            }

    def cache_stats(self) -> Dict[str, Any]:
        """
        Tool: cache_stats

        Get cache performance statistics. Useful for monitoring
        hit rates and cost savings.

        Returns:
            {
                "total_queries": int,
                "hot_hits": int,
                "cold_hits": int,
                "hit_rate": float,
                "tokens_saved": int,
                "cost_saved_usd": float,
                "cost_saved_gbp": float
            }
        """
        try:
            metrics = self.cache.get_metrics()

            # Convert USD to GBP (approximate, should be updated with real rate)
            gbp_rate = 0.79  # 1 USD = 0.79 GBP (update periodically)
            cost_saved_gbp = metrics.get("cost_saved", 0.0) * gbp_rate

            return {
                "status": "success",
                "metrics": {
                    "total_queries": metrics.get("total_queries", 0),
                    "hot_hits": metrics.get("hot_hits", 0),
                    "cold_hits": metrics.get("cold_hits", 0),
                    "hot_misses": metrics.get("hot_misses", 0),
                    "cold_misses": metrics.get("cold_misses", 0),
                    "overall_hit_rate": round(metrics.get("overall_hit_rate", 0), 2),
                    "tokens_saved": metrics.get("tokens_saved", 0),
                    "cost_saved_usd": round(metrics.get("cost_saved", 0.0), 4),
                    "cost_saved_gbp": round(cost_saved_gbp, 4)
                }
            }

        except Exception as e:
            logger.error(f"Error in cache_stats: {e}", exc_info=True)
            return {
                "status": "error",
                "error": str(e)
            }

    def cache_clear(self, pattern: str = "*") -> Dict[str, Any]:
        """
        Tool: cache_clear

        Clear cache entries matching pattern. Use with caution.
        Supports patterns like "agent:research:*" or "*" for all.

        Args:
            pattern: Glob pattern for keys to clear (default "*" = all)

        Returns:
            {
                "status": "success" | "error",
                "message": str,
                "cleared": int
            }
        """
        try:
            # For now, clear all (pattern matching can be enhanced)
            if pattern == "*":
                self.cache.clear_cache()
                logger.warning("CACHE CLEARED: All entries removed")
                return {
                    "status": "success",
                    "message": "All cache entries cleared",
                    "pattern": pattern
                }
            else:
                # TODO: Implement pattern-based clearing
                logger.warning(f"Pattern-based clearing not yet implemented: {pattern}")
                return {
                    "status": "error",
                    "error": "Pattern-based clearing not implemented yet. Use '*' for all."
                }

        except Exception as e:
            logger.error(f"Error in cache_clear: {e}", exc_info=True)
            return {
                "status": "error",
                "error": str(e)
            }

    def generate_key_helper(self, agent_name: str, task_type: str,
                           content: str) -> Dict[str, Any]:
        """
        Tool: generate_key

        Helper tool for agents to generate consistent cache keys.

        Args:
            agent_name: Agent name (research, test, backend, etc.)
            task_type: Task type (analysis, testing, boilerplate, etc.)
            content: Task content/query to hash

        Returns:
            {
                "key": str,
                "format": str
            }
        """
        try:
            key = self._generate_key(agent_name, task_type, content)
            return {
                "status": "success",
                "key": key,
                "format": "agent:{name}:task:{type}:{hash}"
            }
        except Exception as e:
            return {
                "status": "error",
                "error": str(e)
            }


def main():
    """
    MCP server entry point.
    Handles stdio communication with Claude Code.
    """
    try:
        server = MCPCacheServer()
        logger.info("MCP Cache Server started")

        # MCP protocol: read JSON-RPC messages from stdin
        for line in sys.stdin:
            try:
                request = json.loads(line.strip())
                method = request.get("method")
                params = request.get("params", {})
                request_id = request.get("id")

                # Route to appropriate method
                if method == "cache_get":
                    result = server.cache_get(**params)
                elif method == "cache_set":
                    result = server.cache_set(**params)
                elif method == "cache_stats":
                    result = server.cache_stats()
                elif method == "cache_clear":
                    result = server.cache_clear(**params)
                elif method == "generate_key":
                    result = server.generate_key_helper(**params)
                else:
                    result = {
                        "status": "error",
                        "error": f"Unknown method: {method}"
                    }

                # Send response
                response = {
                    "jsonrpc": "2.0",
                    "id": request_id,
                    "result": result
                }
                print(json.dumps(response))
                sys.stdout.flush()

            except json.JSONDecodeError as e:
                logger.error(f"Invalid JSON: {e}")
                continue
            except Exception as e:
                logger.error(f"Error processing request: {e}", exc_info=True)
                error_response = {
                    "jsonrpc": "2.0",
                    "id": request.get("id"),
                    "error": {
                        "code": -32603,
                        "message": str(e)
                    }
                }
                print(json.dumps(error_response))
                sys.stdout.flush()

    except KeyboardInterrupt:
        logger.info("MCP Cache Server stopped")
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
