#!/usr/bin/env python3
"""
Test script to verify cache savings calculation
Tests multiple response formats
"""

import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

from cache_manager import CacheManager

def test_savings_calculation():
    """Test that savings are calculated correctly"""
    print("Testing Cache Savings Calculation\n")
    print("=" * 60)

    # Initialize cache
    cache = CacheManager()

    # Clear existing cache
    cache.clear_cache()
    cache.metrics = {
        "hot_hits": 0,
        "hot_misses": 0,
        "cold_hits": 0,
        "cold_misses": 0,
        "semantic_hits": 0,
        "semantic_misses": 0,
        "total_queries": 0,
        "cost_saved": 0.0,
        "tokens_saved": 0
    }

    # Test 1: Simple tokens_used format
    print("\n1. Testing simple 'tokens_used' format...")
    query1 = "How to implement JWT in Node.js?"
    response1 = {
        "answer": "Install jsonwebtoken package...",
        "tokens_used": 3000
    }

    # Store and retrieve
    cache.set(query1, response1)
    result1 = cache.get(query1)

    if result1:
        print(f"   Cache HIT!")
        print(f"   Tokens saved: {cache.metrics['tokens_saved']}")
        print(f"   Cost saved: ${cache.metrics['cost_saved']:.4f}")
        assert cache.metrics['tokens_saved'] == 3000, "Tokens should be 3000"
        assert cache.metrics['cost_saved'] > 0, "Cost should be > 0"
        print("   ✓ Test 1 PASSED")
    else:
        print("   ✗ Test 1 FAILED - No cache hit")

    # Test 2: input_tokens + output_tokens format
    print("\n2. Testing 'input_tokens + output_tokens' format...")
    query2 = "Explain React hooks"
    response2 = {
        "answer": "React hooks are functions...",
        "input_tokens": 2000,
        "output_tokens": 1000
    }

    cache.set(query2, response2)
    before_tokens = cache.metrics['tokens_saved']
    before_cost = cache.metrics['cost_saved']

    result2 = cache.get(query2)

    if result2:
        print(f"   Cache HIT!")
        tokens_delta = cache.metrics['tokens_saved'] - before_tokens
        cost_delta = cache.metrics['cost_saved'] - before_cost
        print(f"   Tokens saved: {tokens_delta} (3000 total)")
        print(f"   Cost saved: ${cost_delta:.4f}")
        assert tokens_delta == 3000, f"Expected 3000, got {tokens_delta}"
        assert cost_delta > 0, "Cost delta should be > 0"
        print("   ✓ Test 2 PASSED")
    else:
        print("   ✗ Test 2 FAILED - No cache hit")

    # Test 3: No token data (fallback to estimate)
    print("\n3. Testing response without token data (fallback)...")
    query3 = "What is Python?"
    response3 = {
        "answer": "Python is a programming language..."
    }

    cache.set(query3, response3)
    before_tokens = cache.metrics['tokens_saved']
    before_cost = cache.metrics['cost_saved']

    result3 = cache.get(query3)

    if result3:
        print(f"   Cache HIT!")
        tokens_delta = cache.metrics['tokens_saved'] - before_tokens
        cost_delta = cache.metrics['cost_saved'] - before_cost
        print(f"   Tokens saved (estimated): {tokens_delta}")
        print(f"   Cost saved: ${cost_delta:.4f}")
        assert tokens_delta == 5000, f"Expected 5000 default, got {tokens_delta}"
        assert cost_delta > 0, "Cost delta should be > 0"
        print("   ✓ Test 3 PASSED")
    else:
        print("   ✗ Test 3 FAILED - No cache hit")

    # Summary
    print("\n" + "=" * 60)
    print("FINAL METRICS:")
    print("=" * 60)
    metrics = cache.get_metrics()
    print(f"Total Queries:    {metrics['total_queries']}")
    print(f"Cache Hits:       {metrics['hot_hits'] + metrics['cold_hits']}")
    print(f"Tokens Saved:     {metrics['tokens_saved']:,} tokens")
    print(f"Cost Saved:       ${metrics['cost_saved']:.4f}")
    print(f"Hit Rate:         {metrics['overall_hit_rate']:.1f}%")

    # Verify final totals
    expected_tokens = 3000 + 3000 + 5000  # 11,000 total
    assert metrics['tokens_saved'] == expected_tokens, \
        f"Expected {expected_tokens} tokens, got {metrics['tokens_saved']}"

    print("\n✅ ALL TESTS PASSED!")
    print("   Cache savings calculation is working correctly.")

    # Save metrics
    cache.save_metrics()
    print(f"\n✅ Metrics saved to: {cache.logs_dir}/metrics.json")

if __name__ == "__main__":
    test_savings_calculation()
