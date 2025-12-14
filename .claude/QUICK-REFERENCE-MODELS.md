# Quick Reference: Which Model to Use

## TL;DR - Decision Tree

```
START: What's your task?

1. Simple/Routine (naming, formatting)?
   → HAIKU (fastest, cheapest)

2. Standard implementation (features, tests, docs)?
   → SONNET (balanced, reliable)

3. Need research/analysis/exploration?
   → GEMINI (specialized, fast)

4. Critical/Complex/High-stakes?
   → OPUS (most capable, best quality)

UNSURE? → SONNET (safe default)
```

---

## Model Comparison at a Glance

| Model | Best For | Speed | Cost | Quality | When to Use |
|-------|----------|-------|------|---------|------------|
| **HAIKU** | Trivial tasks | Fastest | Cheapest | 93% | Formatting, simple edits |
| **SONNET** | Standard work | Fast | Low | 90% | Implementation, testing, code review |
| **GEMINI** | Research/analysis | Fast | Very Low | 89% | Docs, exploration, discovery |
| **OPUS** | Critical work | Slower | High | 94% | Architecture, security, critical bugs |

---

## Detailed Model Guide

### Claude Haiku - Fast & Cheap

**Best for:** Code formatting, variable renaming, simple refactoring

**Strengths:**
- Blazingly fast (0.5-1 min per task)
- Cheapest option (£0.01/task)
- 93.2% success rate
- Excellent at well-defined tasks

**Weaknesses:**
- Struggles with ambiguity
- Not suitable for design decisions
- Limited context handling

**Examples:**
```
✓ Remove trailing whitespace
✓ Rename variable across file
✓ Add comments to function
✓ Fix simple type errors
✓ Format code to style guide

✗ Design database schema
✗ Refactor legacy codebase
✗ Architecture decisions
✗ Bug investigation (complex)
```

**When to upgrade:** Task takes >2 minutes, involves decisions, or needs exploration.

**Token Cost:** ~1,200 per task
**Typical Success Rate:** 93%+

---

### Claude Sonnet - Workhorse

**Best for:** Feature implementation, test writing, code review, documentation

**Strengths:**
- Balanced speed and capability
- Excellent at implementation
- Good at following patterns
- 90.3% success rate
- Cost-effective (£0.12/task)

**Weaknesses:**
- May struggle with novel problems
- Can miss subtle architectural issues
- Sometimes over-engineers simple solutions

**Examples:**
```
✓ Implement React component
✓ Write unit tests
✓ Review code changes
✓ Refactor method
✓ Update documentation
✓ Debug standard issues

✗ Design multi-tenant schema
✗ Security vulnerability fix
✗ Novel algorithm design
✗ Critical production issues
```

**When to upgrade:** Task is critical, involves security, or ambiguity > 7.

**Token Cost:** ~4,200 per task
**Typical Success Rate:** 90%+

---

### Gemini 2.0 Flash - Specialist

**Best for:** Research, analysis, documentation, pattern discovery

**Strengths:**
- Excellent at exploration and research
- Very fast analysis (1.8 min average)
- Cheapest complex model (£0.04/task)
- Good at seeing patterns
- 88.9% success rate

**Weaknesses:**
- Sometimes oversimplifies implementation details
- May miss edge cases in coding tasks
- Best for analysis, not execution

**Examples:**
```
✓ Research new library/framework
✓ Analyze codebase patterns
✓ Write technical documentation
✓ Find optimization opportunities
✓ Discover code duplications
✓ Create implementation guides

✗ Core feature implementation
✗ Complex algorithm coding
✗ Security-critical changes
✗ Architecture decisions
```

**When to use:** Need to understand something before building it.

**Token Cost:** ~3,100 per task
**Typical Success Rate:** 89%+

---

### Claude Opus - Premium

**Best for:** Architecture decisions, security reviews, critical bugs, novel problems

**Strengths:**
- Highest quality (94.5% success rate)
- Best at ambiguous problems
- Excellent architecture thinking
- Strong at novel/cutting-edge solutions
- Can handle maximum complexity

**Weaknesses:**
- Slowest (3.2 min average)
- Most expensive (£0.45/task)
- Overkill for routine tasks

**Examples:**
```
✓ Design database schema
✓ Architecture review
✓ Security vulnerability assessment
✓ Legacy system modernization
✓ Critical production debugging
✓ Novel algorithm design
✓ Multi-system integration strategy

✗ Simple formatting
✗ Routine implementation
✗ Standard test writing
```

**When NOT to use:** Task has clear requirements, established patterns, or is well-defined.

**Token Cost:** ~8,400 per task
**Typical Success Rate:** 94%+

---

## Decision Matrix

### By Task Type

| Task Type | Model | Alternative | Reason |
|-----------|-------|------------|--------|
| Code formatting | HAIKU | Sonnet | Speed & cost |
| Simple refactoring | HAIKU | Sonnet | Well-defined |
| Feature implementation | SONNET | Opus | Standard patterns |
| Test writing | SONNET | Haiku | Repeatable patterns |
| Code review | SONNET | Opus | Balance quality/cost |
| Documentation | GEMINI | Sonnet | Analysis strength |
| Research/exploration | GEMINI | Opus | Discovery phase |
| Architecture design | OPUS | Sonnet | Critical complexity |
| Security review | OPUS | — | High stakes |
| Bug investigation | SONNET | Opus | Depends on complexity |
| Legacy refactoring | OPUS | Sonnet | State dependency |

### By Complexity Score

| Score | Model | Why |
|-------|-------|-----|
| 0.0-1.0 | HAIKU | Trivial, no thinking |
| 1.1-3.0 | SONNET | Simple, clear path |
| 3.1-7.0 | SONNET | Standard complexity |
| 7.1-8.5 | OPUS | High complexity |
| 8.6-10.0 | OPUS | Critical/novel |

### By Urgency

| Urgency | Model | Reason |
|---------|-------|--------|
| Quick (< 1 min) | HAIKU | Fastest |
| Normal (1-5 min) | SONNET | Good balance |
| Deep analysis | GEMINI | Specialized |
| Critical | OPUS | Best quality |

---

## Agent Model Configuration

### Planning Agents
```
ARCHITECT          → Opus (architecture expertise)
PM-AGENT           → Sonnet (balanced communication)
PRODUCT-OWNER      → Opus (critical decisions)
RESEARCH-AGENT     → Gemini (exploration, discovery)
```

### Development Agents
```
SENIOR-DEV         → Opus (complex problems)
BACKEND-DEV        → Sonnet + Gemini (standard + research)
FRONTEND-DEV       → Sonnet + Gemini (UI + exploration)
TEST-ENGINEER      → Haiku (test writing, fast)
```

### Quality Agents
```
CODE-REVIEWER      → Sonnet (code analysis)
QA-AGENT           → Haiku (test execution, quick checks)
TECH-WRITER        → Gemini (documentation expertise)
DOC-AUDITOR        → Gemini (analysis)
```

### Operations Agents
```
ORCHESTRATOR       → Sonnet (routing decisions)
DEVOPS-AGENT       → Sonnet (standard infrastructure)
```

---

## Cost Per 1M Tokens

| Model | Cost | Relative | Use Case Impact |
|-------|------|----------|-----------------|
| Haiku | £1.60 | 1.0x | Reference baseline |
| Gemini | £2.50 | 1.6x | Slightly more expensive |
| Sonnet | £7.50 | 4.7x | Standard model cost |
| Opus | £60.00 | 37.5x | Premium tier cost |

**Strategic Use:**
- Use HAIKU as much as possible (1x cost)
- GEMINI for specialized tasks (1.6x cost)
- SONNET for standard work (4.7x cost)
- OPUS only when necessary (37.5x cost, but 4% quality improvement)

---

## Escalation Paths

### When Haiku Fails

```
HAIKU task fails (error rate > 5%)
    ↓
Re-evaluate complexity
    ↓
If simple (0-2): Try HAIKU again with clearer instructions
If moderate (2-4): Escalate to SONNET
If complex (4+): Escalate to OPUS
```

### When Sonnet Fails

```
SONNET task fails (error rate > 10%)
    ↓
Check complexity score
    ↓
If < 5: Try clearer specification, retry SONNET
If 5-7: Check if GEMINI specialty applies
If 7+: Escalate to OPUS
```

### When Gemini Fails

```
GEMINI task fails for research (error rate > 5%)
    ↓
Is it implementation-heavy?
    ├─ YES: Should have been SONNET
    └─ NO: Try again or escalate to OPUS
```

### When Opus is Needed

```
Task meets ANY of:
- Complexity score > 8
- Security/data integrity at risk
- Novel/cutting-edge problem
- Multiple escalations from lower tier
    ↓
USE OPUS
```

---

## Quality vs Cost Trade-Off

### Conservative Approach (Maximize Quality)
**Target:** 92%+ overall success

```
Use OPUS for: Tier 8-10
Use SONNET for: Tier 4-7
Use HAIKU for: Tier 0-3
Savings: 17% vs all-Opus
```

### Balanced Approach (Default - Recommended)
**Target:** 90%+ overall success

```
Use OPUS for: Tier 8-10 + critical work
Use SONNET for: Tier 2-7
Use GEMINI for: Tier 2-4 research/docs
Use HAIKU for: Tier 0-1
Savings: 19% vs all-Sonnet
```

### Aggressive Approach (Maximize Savings)
**Target:** 88%+ overall success (higher escalation)

```
Use OPUS for: Only critical Tier 9-10
Use SONNET for: Tier 4-8
Use GEMINI for: Tier 2-5 research/docs
Use HAIKU for: Tier 0-3
Savings: 25% vs all-Sonnet
Risk: 12% escalation rate
```

**Recommendation:** Use Balanced Approach (current system).

---

## Common Scenarios

### Scenario 1: Bug Investigation

**Given:** Production bug, customer impact, unclear root cause

**Analysis:**
- Complexity: 6-7 (depends on system)
- State dependency: 7-8 (production context)
- Technical depth: 5-6

**Decision:**
```
If simple bug (obvious cause)
→ SONNET (standard debugging)

If subtle bug (investigation needed)
→ OPUS (deep analysis needed)

If root cause unknown
→ OPUS (ambiguous, high stakes)
```

### Scenario 2: Feature Implementation

**Given:** New feature, clear requirements, established patterns

**Analysis:**
- Complexity: 3-4 (standard patterns)
- Ambiguity: 1-2 (clear spec)
- Technical depth: 3-4

**Decision:**
```
→ SONNET (standard implementation)
```

### Scenario 3: Database Schema Design

**Given:** Multi-tenant SaaS, future analytics, scaling unknown

**Analysis:**
- Complexity: 7-8 (high)
- Ambiguity: 7-8 (multiple valid approaches)
- State dependency: 6 (future dependent)

**Decision:**
```
→ OPUS (critical architecture)
→ Then SONNET for implementation
```

### Scenario 4: Documentation Writing

**Given:** API documentation for new endpoint

**Analysis:**
- Complexity: 2-3 (standard)
- Research needed: Yes
- Patterns: Established

**Decision:**
```
→ GEMINI (documentation strength)
   or
→ SONNET (reliable alternative)
```

### Scenario 5: Code Review

**Given:** 200-line PR, standard implementation, needs feedback

**Analysis:**
- Complexity: 4-5 (balanced)
- Judgment needed: Yes
- Critical: Maybe

**Decision:**
```
→ SONNET (standard code review)

If security-critical:
→ OPUS (security expertise)

If simple PR:
→ HAIKU (quick verification)
```

---

## Performance Targets

### Success Rate Targets by Model

| Model | Target | Current | Gap | Status |
|-------|--------|---------|-----|--------|
| OPUS | 93%+ | 94.5% | +1.5% | Excellent |
| SONNET | 90%+ | 90.3% | +0.3% | Excellent |
| GEMINI | 88%+ | 88.9% | +0.9% | Excellent |
| HAIKU | 92%+ | 93.2% | +1.2% | Excellent |

### Cost Targets by Model

| Model | Target | Current | Gap | Status |
|-------|--------|---------|-----|--------|
| OPUS | <£0.50/task | £0.45 | -9% | Good |
| SONNET | <£0.15/task | £0.12 | -20% | Excellent |
| GEMINI | <£0.05/task | £0.04 | -20% | Excellent |
| HAIKU | <£0.02/task | £0.01 | -50% | Excellent |

---

## Troubleshooting

### Problem: High escalation rate (>10%)

**Possible causes:**
- Misrouting to wrong model
- Complexity underestimated
- Insufficient context provided

**Solutions:**
1. Review last 10 escalated tasks
2. Check complexity scores
3. Identify pattern in failures
4. Adjust routing rules

### Problem: Tasks taking too long

**Possible causes:**
- Wrong model chosen (too capable)
- Complexity overestimated
- Task context missing

**Solutions:**
1. Try lower tier model
2. Reduce task scope
3. Add more context/examples

### Problem: Low success rate (<85%)

**Possible causes:**
- Wrong model chosen (not capable enough)
- Ambiguous requirements
- Too much context (token limits)

**Solutions:**
1. Try higher tier model
2. Clarify requirements
3. Reduce context, add summaries

---

## Quick Decision Checklist

Before assigning a task, ask:

- [ ] Is task well-defined? (No → Increase complexity)
- [ ] Are requirements clear? (No → Increase complexity)
- [ ] Is it high-stakes/critical? (Yes → Use Opus)
- [ ] Does it need research/exploration? (Yes → Consider Gemini)
- [ ] Is it routine/standard? (Yes → Use Sonnet)
- [ ] Is it trivial formatting? (Yes → Use Haiku)
- [ ] Is complexity > 7? (Yes → Use Opus)
- [ ] Can you test easily? (No → Use higher tier)

---

## Related Documents

- [COMPLEXITY-SCORING.md](./COMPLEXITY-SCORING.md) - Detailed scoring algorithm
- [MODEL-ROUTING.md](./MODEL-ROUTING.md) - Full routing guide
- [MODEL-METRICS.md](./state/MODEL-METRICS.md) - Performance metrics

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-14 | Initial quick reference guide |

---

*Last updated: 2025-12-14*
*Used by: All agents for model selection*
*Review frequency: Monthly*
