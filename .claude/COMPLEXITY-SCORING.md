# Complexity Scoring Algorithm

## Overview

The Complexity Scoring system evaluates tasks on a scale of 0-10 and routes them to appropriate model tiers. This ensures cost-effective resource allocation while maintaining quality standards.

**Purpose:** Automate decision-making for task routing based on objective complexity metrics.

---

## Scoring Algorithm

### Input Factors

Each task is evaluated across 5 dimensions:

| Factor | Weight | Measurement |
|--------|--------|------------|
| **Ambiguity** | 25% | How much interpretation/design decision is needed? |
| **State Dependency** | 25% | How much does output depend on complex context? |
| **Technical Depth** | 20% | How much specialized knowledge is required? |
| **Integration Points** | 20% | How many systems/components must coordinate? |
| **Error Consequences** | 10% | How critical are failure scenarios? |

### Calculation Formula

```
Complexity Score = (A × 0.25) + (S × 0.25) + (T × 0.20) + (I × 0.20) + (E × 0.10)

Where:
A = Ambiguity score (0-10)
S = State Dependency score (0-10)
T = Technical Depth score (0-10)
I = Integration Points score (0-10)
E = Error Consequences score (0-10)

Result: 0.0 - 10.0
```

### Scoring Each Factor (0-10 scale)

#### Ambiguity Factor
- **0-2:** Crystal clear requirements, no interpretation needed
- **3-4:** Minor design choices, established patterns apply
- **5-6:** Multiple valid approaches, trade-offs exist
- **7-8:** Significant unknowns, needs exploration
- **9-10:** Highly ambiguous, requires creative problem-solving

#### State Dependency Factor
- **0-2:** Isolated task, no external context needed
- **3-4:** Uses simple inputs/outputs from one system
- **5-6:** Depends on 2-3 system states, moderate coordination
- **7-8:** Complex state machine, multiple dependencies
- **9-10:** Deeply interdependent systems, state explosion risk

#### Technical Depth Factor
- **0-2:** Standard coding/scripting skills sufficient
- **3-4:** Requires knowledge of one framework/domain
- **5-6:** Multiple technical domains, specialized skills needed
- **7-8:** Deep expertise in 2+ domains required
- **9-10:** Cutting-edge or highly specialized knowledge needed

#### Integration Points Factor
- **0-2:** Self-contained, no external APIs/services
- **3-4:** Integrates with 1-2 external systems
- **5-6:** Coordinates across 3-5 systems
- **7-8:** Complex orchestration across 6+ systems
- **9-10:** All-system integration, high coordination overhead

#### Error Consequences Factor
- **0-2:** Errors are recoverable, low impact
- **3-4:** Errors cause minor service degradation
- **5-6:** Errors affect multiple users temporarily
- **7-8:** Errors cause significant data loss or downtime
- **9-10:** Errors risk critical data loss or security breach

---

## Tier Mapping

### Tier 0-1: Trivial (Haiku)
- **Complexity Score:** 0.0 - 1.0
- **Use Case:** Routine, no thinking needed
- **Examples:** Formatting, renaming, simple edits
- **Model:** Claude Haiku (fastest, cheapest)
- **Expected Quality:** 95%+
- **Token Cost:** ~0.1x reference

### Tier 2-3: Simple (Sonnet/Haiku)
- **Complexity Score:** 1.1 - 3.0
- **Use Case:** Standard implementation tasks
- **Examples:** Feature implementation, test writing, basic refactoring
- **Model:** Claude Sonnet or Haiku
- **Expected Quality:** 92%+
- **Token Cost:** 0.2-0.5x reference

### Tier 4-7: Moderate (Sonnet)
- **Complexity Score:** 3.1 - 7.0
- **Use Case:** Complex logic, design decisions, coordination
- **Examples:** System integration, architecture design, complex debugging
- **Model:** Claude Sonnet (balanced)
- **Expected Quality:** 90%+
- **Token Cost:** 0.5-1.0x reference

### Tier 8-10: Complex (Opus)
- **Complexity Score:** 7.1 - 10.0
- **Use Case:** Critical decisions, novel problems, high-stakes work
- **Examples:** Critical architecture, security reviews, novel algorithms
- **Model:** Claude Opus (most capable)
- **Expected Quality:** 93%+
- **Token Cost:** 1.0-1.5x reference

---

## Tier Examples

### Tier 0-1: Trivial Examples

**Example 1: Fix formatting**
```
Task: "Remove trailing whitespace from src/utils.js"

Ambiguity: 0 (requirement is explicit)
State Dependency: 0 (isolated change)
Technical Depth: 0 (no technical knowledge needed)
Integration Points: 0 (single file)
Error Consequences: 1 (easily verified)

Score: (0 + 0 + 0 + 0 + 1) / 5 = 0.2
Tier: 0-1 (HAIKU)
```

**Example 2: Simple rename**
```
Task: "Rename variable 'x' to 'itemCount' throughout component.js"

Ambiguity: 1 (clear what needs changing)
State Dependency: 0 (refactoring only)
Technical Depth: 0 (simple text replacement)
Integration Points: 0 (single file)
Error Consequences: 2 (easy to verify by testing)

Score: (1 + 0 + 0 + 0 + 2) × (weights) ≈ 0.6
Tier: 0-1 (HAIKU)
```

### Tier 2-3: Simple Examples

**Example 3: Implement button component**
```
Task: "Create a Button component with loading state in React"

Ambiguity: 2 (standard pattern, minor design choices)
State Dependency: 3 (depends on parent props)
Technical Depth: 3 (React knowledge needed)
Integration Points: 2 (uses design system only)
Error Consequences: 2 (easily testable)

Score: (2×0.25) + (3×0.25) + (3×0.20) + (2×0.20) + (2×0.10) = 2.4
Tier: 2-3 (SONNET/HAIKU)
```

**Example 4: Write unit tests**
```
Task: "Write unit tests for UserService class with 80% coverage"

Ambiguity: 2 (tests follow clear pattern)
State Dependency: 2 (mocked dependencies)
Technical Depth: 4 (testing framework, patterns)
Integration Points: 3 (mocks multiple services)
Error Consequences: 3 (test failures caught in CI)

Score: (2×0.25) + (2×0.25) + (4×0.20) + (3×0.20) + (3×0.10) = 2.7
Tier: 2-3 (SONNET/HAIKU)
```

### Tier 4-7: Moderate Examples

**Example 5: Refactor authentication flow**
```
Task: "Refactor OAuth 2.0 flow to support multiple providers (Google, GitHub, Microsoft)"

Ambiguity: 6 (multiple valid approaches, migration path unclear)
State Dependency: 7 (depends on session state, user persistence)
Technical Depth: 6 (OAuth specs, provider SDKs, security)
Integration Points: 6 (auth service, DB, multiple providers)
Error Consequences: 7 (authentication failure blocks all users)

Score: (6×0.25) + (7×0.25) + (6×0.20) + (6×0.20) + (7×0.10) = 6.4
Tier: 4-7 (SONNET)
```

**Example 6: Design database schema**
```
Task: "Design schema for multi-tenant SaaS with time-series analytics data"

Ambiguity: 8 (multiple schema patterns possible, scaling unknown)
State Dependency: 5 (depends on future access patterns)
Technical Depth: 7 (database optimization, multi-tenancy patterns)
Integration Points: 4 (ORM integration, analytics pipeline)
Error Consequences: 9 (bad schema causes cascading issues)

Score: (8×0.25) + (5×0.25) + (7×0.20) + (4×0.20) + (9×0.10) = 6.9
Tier: 4-7 (SONNET - borderline, consider OPUS)
```

### Tier 8-10: Complex Examples

**Example 7: Implement distributed caching strategy**
```
Task: "Design and implement distributed caching layer (Redis) for high-traffic API with cache invalidation strategy"

Ambiguity: 9 (many pattern options, trade-offs between consistency and performance)
State Dependency: 9 (complex state machine: cache hits, misses, invalidations)
Technical Depth: 8 (Redis, distributed systems, cache patterns)
Integration Points: 8 (API, database, cache service, monitoring)
Error Consequences: 8 (stale data, cache poisoning risks)

Score: (9×0.25) + (9×0.25) + (8×0.20) + (8×0.20) + (8×0.10) = 8.6
Tier: 8-10 (OPUS)
```

**Example 8: Security vulnerability remediation**
```
Task: "Audit and fix SQL injection vulnerabilities across 40+ ORM queries while maintaining backward compatibility"

Ambiguity: 7 (clear what's wrong, unclear how to fix without breaking clients)
State Dependency: 10 (complex interdependencies across multiple queries)
Technical Depth: 9 (ORM internals, SQL injection patterns, security)
Integration Points: 9 (affects entire data access layer, multiple client apps)
Error Consequences: 10 (security breach if not fixed properly)

Score: (7×0.25) + (10×0.25) + (9×0.20) + (9×0.20) + (10×0.10) = 8.9
Tier: 8-10 (OPUS)
```

---

## Quick Reference Table

| Score | Tier | Model | Task Type | Example | Est. Quality |
|-------|------|-------|-----------|---------|--------------|
| 0.0-1.0 | 0-1 | Haiku | Trivial | Format code, rename var | 95% |
| 1.1-3.0 | 2-3 | Sonnet/Haiku | Simple | Implement button, write tests | 92% |
| 3.1-7.0 | 4-7 | Sonnet | Moderate | Refactor flow, design schema | 90% |
| 7.1-10.0 | 8-10 | Opus | Complex | Distributed systems, security | 93% |

---

## Usage Guide

### Step 1: Score Each Factor
For each of the 5 factors, assign a score from 0-10 based on the criteria above.

### Step 2: Apply Weights
Multiply each score by its weight:
- Ambiguity × 0.25
- State Dependency × 0.25
- Technical Depth × 0.20
- Integration Points × 0.20
- Error Consequences × 0.10

### Step 3: Sum and Map to Tier
Add weighted scores to get final complexity score (0.0-10.0), then use tier mapping.

### Step 4: Route to Model
Use tier mapping to determine model assignment.

### Step 5: Monitor Results
Track whether routing decision was correct. Adjust scoring factors if needed.

---

## Decision Rules

### Override Rules
1. **Always use OPUS if:**
   - Security or data integrity at risk
   - Error consequences score ≥ 9
   - Task is first-time implementation of critical system
   - Escalation triggered by quality issues

2. **Can downgrade from OPUS if:**
   - Task is refactoring existing, stable code
   - Clear specification provided
   - Good test coverage exists
   - Complexity score drops below 6.0

3. **Can upgrade from SONNET to OPUS if:**
   - Quality issues persist (error rate > 10%)
   - Ambiguity score ≥ 8
   - State dependency score ≥ 8
   - Task is critical path for project

### Cost Optimization
- Start with lower tier, upgrade if quality drops
- For Tier 4-7 tasks, use SONNET not OPUS unless criteria above met
- For Tier 2-3 tasks, prefer HAIKU if technical depth < 3
- Monitor success rate per tier monthly

---

## Monitoring & Adjustment

### Track These Metrics
- **Success Rate by Tier:** Target 92%+
- **Escalations:** Should be < 10% of tasks
- **Cost per Tier:** Monitor for optimization
- **Time-to-completion:** Ensure quality not sacrificed for speed

### Adjustment Triggers
| Issue | Adjustment |
|-------|-----------|
| Tier 0-1 > 5% error rate | Lower threshold to 0.8 |
| Tier 2-3 < 90% success | Review ambiguity scoring |
| Tier 4-7 too slow | Consider OPUS for subset |
| Tier 8-10 over budget | Reduce ambiguity through specs |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-14 | Initial algorithm design with 5 factors and 4 tiers |

---

*Last updated: 2025-12-14*
*Used by: MODEL-ROUTING system, ORCHESTRATOR agent*
