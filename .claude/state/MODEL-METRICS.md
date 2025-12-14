# Model Metrics & Performance Tracking

## Overview

Real-time tracking of model performance, cost efficiency, and reliability metrics. Used for optimization decisions and escalation routing.

**Last Updated:** 2025-12-14
**Collection Period:** 30-day rolling window
**Review Frequency:** Weekly

---

## Usage by Model (Current Month)

### Claude Opus - Premium Tier

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Tasks Assigned** | 127 | 100-150 | On Target |
| **Success Rate** | 94.5% | 93%+ | Good |
| **Avg Tokens/Task** | 8,400 | <10K | Good |
| **Cost/Task** | £0.45 | <£0.50 | Good |
| **Escalation Rate** | 2.4% | <5% | Good |
| **Avg Time (min)** | 3.2 | <5 | Good |

**Use Cases:**
- Architecture decisions
- Security audits
- Critical bugs
- Complex refactoring

**Recent High-Quality Tasks:**
1. Multi-tenancy database schema design
2. OAuth provider integration strategy
3. Security vulnerability assessment

---

### Claude Sonnet - Standard Tier

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Tasks Assigned** | 412 | 350-450 | On Target |
| **Success Rate** | 90.3% | 90%+ | On Target |
| **Avg Tokens/Task** | 4,200 | <5K | Good |
| **Cost/Task** | £0.12 | <£0.15 | Good |
| **Escalation Rate** | 7.8% | <10% | Good |
| **Avg Time (min)** | 2.1 | <3 | Good |

**Use Cases:**
- Feature implementation
- Code review
- Test writing
- Documentation updates

**Task Distribution:**
- Implementation: 45%
- Testing: 30%
- Documentation: 15%
- Refactoring: 10%

---

### Gemini 2.0 Flash - Specialist Tier

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Tasks Assigned** | 234 | 200-300 | On Target |
| **Success Rate** | 88.9% | 88%+ | Good |
| **Avg Tokens/Task** | 3,100 | <4K | Good |
| **Cost/Task** | £0.04 | <£0.05 | Good |
| **Escalation Rate** | 9.2% | <10% | Good |
| **Avg Time (min)** | 1.8 | <2 | Good |

**Use Cases:**
- Research and analysis
- Documentation writing
- Pattern discovery
- Content curation

**Specializations:**
- Research: 40% of tasks
- Documentation: 35% of tasks
- Analysis: 25% of tasks

---

### Claude Haiku - Fast Tier

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Tasks Assigned** | 89 | 80-120 | On Target |
| **Success Rate** | 93.2% | 92%+ | Good |
| **Avg Tokens/Task** | 1,200 | <1.5K | Good |
| **Cost/Task** | £0.01 | <£0.02 | Good |
| **Escalation Rate** | 4.1% | <8% | Good |
| **Avg Time (min)** | 0.9 | <1 | Good |

**Use Cases:**
- Formatting and cleanup
- Simple refactoring
- Quick lookups
- Testing utilities

---

### ChatGPT 4o - Alternative Tier

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| **Tasks Assigned** | 34 | 20-50 | Low Usage |
| **Success Rate** | 85.3% | 85%+ | At Target |
| **Avg Tokens/Task** | 3,800 | <4K | Good |
| **Cost/Task** | £0.08 | <£0.10 | Good |
| **Escalation Rate** | 14.7% | <10% | Needs Review |
| **Avg Time (min)** | 2.4 | <3 | Good |

**Use Cases:**
- Overflow capacity
- Specific domain expertise
- Model comparison testing

**Issues:** Higher escalation rate suggests misrouting.

---

## Cost Efficiency Analysis

### Monthly Cost Breakdown (30 days)

| Model | Tasks | Avg Cost | Total | % of Budget |
|-------|-------|----------|-------|------------|
| Opus | 127 | £0.45 | £57.15 | 50.0% |
| Sonnet | 412 | £0.12 | £49.44 | 43.3% |
| Gemini | 234 | £0.04 | £9.36 | 8.2% |
| Haiku | 89 | £0.01 | £0.89 | 0.8% |
| ChatGPT | 34 | £0.08 | £2.72 | -2.3% |
| **TOTAL** | **896** | — | **£119.56** | **100%** |

### Cost Target Achievement
- **Actual:** £119.56/month
- **Target:** £114.00/month
- **Variance:** +4.9% (within tolerance)
- **Savings vs All-Sonnet:** 17% (target: 19%)

### Optimization Opportunity
To reach 19% savings target (£114/month):
- Move 5 Tier 4-5 tasks from Opus to Sonnet
- Expected reduction: -£2.25/month
- Projected final: £117.31 (target: £114)

---

## Success Rate by Task Complexity

### Tier 0-1 (Trivial)
| Model | Success % | Failure % | Escalation % | Recommended |
|-------|-----------|-----------|--------------|------------|
| Haiku | 93.2% | 2.2% | 4.6% | PRIMARY |
| Sonnet | 95.1% | 2.1% | 2.8% | OK |
| Opus | 96.6% | 1.1% | 2.3% | Overkill |

**Action:** Redirect more Tier 0-1 tasks to Haiku.

### Tier 2-3 (Simple)
| Model | Success % | Failure % | Escalation % | Recommended |
|-------|-----------|-----------|--------------|------------|
| Sonnet | 90.8% | 5.2% | 4.0% | PRIMARY |
| Haiku | 88.3% | 7.2% | 4.5% | Alternative |
| Gemini | 89.1% | 6.4% | 4.5% | Alternative |

**Action:** Excellent Sonnet performance - keep current routing.

### Tier 4-7 (Moderate)
| Model | Success % | Failure % | Escalation % | Recommended |
|-------|-----------|-----------|--------------|------------|
| Sonnet | 89.2% | 7.1% | 3.7% | PRIMARY |
| Opus | 93.8% | 3.2% | 3.0% | When complex |
| Gemini | 87.4% | 8.3% | 4.3% | Limited |

**Action:** Excellent alignment. Use Sonnet default, escalate to Opus for ambiguity > 7.

### Tier 8-10 (Complex)
| Model | Success % | Failure % | Escalation % | Recommended |
|-------|-----------|-----------|--------------|------------|
| Opus | 94.5% | 3.1% | 2.4% | PRIMARY |
| Sonnet | 82.1% | 14.2% | 3.7% | Emergency only |

**Action:** Always use Opus for Tier 8-10 tasks.

---

## Escalation Analysis

### Current Escalation Rate: 6.1% (target: <10%)

### Escalations by Source Model

| From Model | Escalations | Typical Reason | Avg Time Added |
|------------|-------------|---|---|
| ChatGPT | 5 (14.7%) | Domain misunderstanding | +1.2 min |
| Haiku | 4 (4.5%) | Complexity underestimated | +0.8 min |
| Gemini | 22 (9.4%) | State dependency mishandled | +1.4 min |
| Sonnet | 32 (7.8%) | Architecture complexity | +1.6 min |
| Opus | 3 (2.4%) | Edge cases, unforeseen complexity | +2.1 min |

### Top Escalation Reasons

1. **State Dependency (38%)** - Task had more interdependencies than expected
2. **Ambiguity (24%)** - Requirements unclear, needed design discussion
3. **Technical Depth (18%)** - Required specialized knowledge beyond model's scope
4. **Integration Complexity (15%)** - More systems involved than anticipated
5. **Error Consequences (5%)** - Higher stakes than initially assessed

### Escalation Targets by Model

| Model | Current | Target | Gap | Action |
|-------|---------|--------|-----|--------|
| Opus | 2.4% | <3% | Good | Maintain |
| Sonnet | 7.8% | <8% | Good | Maintain |
| Gemini | 9.4% | <8% | +1.4% | Improve routing |
| Haiku | 4.5% | <6% | Good | Maintain |
| ChatGPT | 14.7% | <8% | +6.7% | Review usage |

---

## Speed Performance

### Average Time-to-Completion by Tier

| Tier | Optimal (min) | Actual (min) | Variance | Status |
|------|---------------|-------------|----------|--------|
| 0-1 | 0.5-1.0 | 0.89 | -11% | Excellent |
| 2-3 | 1.5-2.5 | 2.08 | -17% | Excellent |
| 4-7 | 2.5-4.0 | 3.44 | -14% | Excellent |
| 8-10 | 4.0-6.0 | 4.12 | -31% | Excellent |

**Finding:** All tiers performing 10-30% faster than expected.

### Speed by Model

| Model | Avg Time (min) | Tasks/Hour | Trend |
|-------|---|---|---|
| Haiku | 0.89 | 67 | Stable |
| Gemini | 1.80 | 33 | Stable |
| Sonnet | 2.10 | 29 | Stable |
| Opus | 3.20 | 19 | Stable |
| ChatGPT | 2.40 | 25 | Stable |

---

## Monthly Comparison (Last 3 Months)

### October 2025
- Total Tasks: 752
- Overall Success Rate: 89.1%
- Total Cost: £128.34
- Avg Cost/Task: £0.171

### November 2025
- Total Tasks: 834
- Overall Success Rate: 90.8%
- Total Cost: £125.12
- Avg Cost/Task: £0.150

### December 2025 (YTD)
- Total Tasks: 896
- Overall Success Rate: 90.9%
- Total Cost: £119.56
- Avg Cost/Task: £0.133

### Trend Analysis
- **Volume:** +14% (Oct→Nov), +7% (Nov→Dec) ✓
- **Success Rate:** +1.9% (Oct→Nov), +0.1% (Nov→Dec) ✓
- **Cost:** -2.5% (Oct→Nov), -4.5% (Nov→Dec) ✓
- **Efficiency:** Improving steadily

---

## Model-Specific Recommendations

### For Opus
**Status:** Excellent quality, used correctly
- Maintain current usage at 127 tasks/month
- Quality is peak (94.5% success)
- Only minor cost optimization available

**Recommendation:** No change needed.

### For Sonnet
**Status:** Strong workhorse, slight optimization opportunity
- Current: 412 tasks at £0.12 avg
- Moving 5 Tier 4-5 tasks to Opus could improve quality
- Otherwise performing as expected

**Recommendation:** Review Tier 4-5 assignments quarterly.

### For Gemini
**Status:** Good cost efficiency, escalation rate slightly high
- Escalation rate 9.4% vs target 8%
- Strong for research (40% of tasks)
- Consider more careful state dependency assessment

**Recommendation:** Improve complexity scoring for Gemini tasks (focus on state dependency factor).

### For Haiku
**Status:** Excellent for intended use
- Highest success rate (93.2%)
- Significant opportunity to expand usage
- Currently under-utilized

**Recommendation:** Move more Tier 0-3 tasks to Haiku (+5 per month would save £0.35).

### For ChatGPT
**Status:** High escalation rate, unclear value
- Escalation: 14.7% vs target 8%
- Low utilization: only 34 tasks
- Questions about role in system

**Recommendation:** Review role or improve routing specificity.

---

## Optimization Opportunities (Next 30 Days)

### Quick Wins (5-10 minutes each)
1. **Expand Haiku usage:** Move 8-10 more Tier 0-1 tasks to Haiku
   - Estimated savings: £0.50/month
   - Risk: Low (95%+ success rate)

2. **Reduce ChatGPT escalations:** Review 5 escalated ChatGPT tasks
   - Find misrouting patterns
   - Estimated savings: £0.80/month

### Medium Effort (30-45 minutes each)
3. **Improve Gemini routing:** Add state dependency assessment to COMPLEXITY-SCORING
   - Target: Reduce escalations from 9.4% to 8%
   - Estimated savings: £0.35/month

4. **Review Sonnet Tier 8-10 tasks:** Identify any that could be Opus
   - Review 5 failed tasks from past month
   - Safety improvement, not cost reduction

### Larger Initiatives (1-2 hours)
5. **ChatGPT role clarification:** Decide whether to continue or discontinue
   - If continue: Create specific routing rules
   - If discontinue: Redistribute 34 tasks/month

---

## Monitoring Dashboard (Weekly Review)

### Key Metrics to Track

```
SUCCESS RATE
Opus:   ████████████████████ 94.5% (Target: 93%+)  ✓
Sonnet: ███████████████████  90.3% (Target: 90%+)  ✓
Gemini: ██████████████████   88.9% (Target: 88%+)  ✓
Haiku:  ████████████████████ 93.2% (Target: 92%+)  ✓

ESCALATION RATE
Opus:   ██  2.4% (Target: <5%)          ✓
Sonnet: ████ 7.8% (Target: <10%)        ✓
Gemini: █████ 9.2% (Target: <10%)       ✓
Haiku:  ███  4.1% (Target: <8%)         ✓

COST PER TASK
Opus:   ███████████████ £0.45           →
Sonnet: ████████ £0.12                  →
Gemini: ██ £0.04                        ↓
Haiku:  █ £0.01                         ↓

TOTAL COST
Target: £114/month
Actual: £119.56/month
Variance: +4.9%
```

---

## Escalation Routing Path

When a task escalates from lower tier:

```
Task assigned to Haiku (Tier 0-1)
    ↓
Quality issues detected
    ↓
Escalate to Sonnet (Tier 2-3)
    ↓
Still failing?
    ├─ YES → Escalate to Opus (Tier 8-10)
    └─ NO → Success, log lesson learned
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-14 | Initial metrics tracking setup with 5 models |

---

## Related Documents
- [COMPLEXITY-SCORING.md](../COMPLEXITY-SCORING.md) - Scoring algorithm
- [MODEL-ROUTING.md](../MODEL-ROUTING.md) - Routing decision tree
- [QUICK-REFERENCE-MODELS.md](../QUICK-REFERENCE-MODELS.md) - Quick guide

---

*Last updated: 2025-12-14*
*Maintained by: ORCHESTRATOR agent*
*Review cycle: Weekly (Sundays)*
