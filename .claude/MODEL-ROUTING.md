# Model Routing Strategy

## Overview

Model routing is the strategic assignment of Claude models to agents and tasks based on complexity, quality requirements, and cost optimization. This document defines the 4-tier model strategy, agent-to-model mappings, and decision frameworks for optimal resource allocation across the agent system.

**Core Principle:** Match model capability to task complexity, not task volume.

---

## Part 1: Tier Strategy (4-Tier Model Architecture)

### Tier 1: Maximum Capability (OPUS 4.5)

**Model:** Claude Opus 4.5 (claude-opus-4-5-20251101)
**Capacity:** 200K context window | Best-in-class reasoning
**Cost:** Baseline (1x multiplier) | Premium pricing

#### Use Cases
- Architectural system design and high-level decisions
- Complex multi-domain problem solving
- Code refactoring with significant design changes
- Strategic planning and roadmaps
- Root cause analysis for critical issues
- Cross-team dependency resolution
- Novel algorithm implementation
- Complex requirements analysis and technical feasibility studies

#### Quality Characteristics
- Highest accuracy on ambiguous problems
- Best at handling multiple constraints simultaneously
- Superior at explaining reasoning chains
- Optimal for tasks requiring synthesis of multiple domains

#### When to Use Opus
- First attempt at novel/complex problems
- Tasks affecting multiple system components
- Strategic or architectural decisions
- When quality cannot be compromised
- Escalated issues requiring senior-level reasoning

#### When NOT to Use Opus
- Routine code formatting or linting
- Simple one-off edits
- Known, proven implementations
- High-volume commodity tasks
- When faster turnaround is critical

---

### Tier 2: Balanced Capability (SONNET 4 + ChatGPT-4o + Gemini 2.0)

**Models:**
- Claude Sonnet 4 (claude-sonnet-4-20250514) - Primary [preferred for most tasks]
- OpenAI ChatGPT-4o (gpt-4o) - Secondary [specialized: web research, embeddings]
- Google Gemini 2.0 (gemini-2.0-flash) - Secondary [specialized: research, analysis]

**Capacity:** 200K context (Sonnet) | Varying (GPT-4o, Gemini)
**Cost:** ~0.3x Opus cost (Sonnet is most economical)
**Throughput:** High-speed with solid reasoning

#### Use Cases
- Standard feature implementation and coding
- Test writing and test strategies
- Code review and feedback
- Documentation writing and updates
- Product requirement analysis
- Research and competitive analysis (Gemini/ChatGPT-4o)
- Data analysis and reporting
- Complex bug investigation
- API design and specification
- Refactoring known code patterns

#### Quality Characteristics
- Strong reasoning for moderately complex problems
- Reliable for domain-specific tasks
- Good at creative solutions within bounds
- Excellent at structured output generation
- Fast context processing
- Cost-effective for high-volume work

#### Tier 2 Sub-Assignment
| Model | Primary Strengths | Assign To |
|-------|-------------------|-----------|
| **Sonnet 4** | Coding, reviews, writing | Default for most tasks |
| **ChatGPT-4o** | Web research, integrations, embeddings | RESEARCH-AGENT when web access needed |
| **Gemini 2.0** | Long-form analysis, search, reasoning | RESEARCH-AGENT, backup research |

#### When to Use Sonnet 4
- Feature implementation (backend, frontend, fullstack)
- Code review and architectural feedback
- Documentation and technical writing
- Test strategy and complex test design
- Most agent tasks as default
- Refactoring bounded scope code
- API and protocol design

#### When to Use ChatGPT-4o (Web-Connected)
- Real-time market research
- Current technology landscape analysis
- External API documentation lookup
- Competitor feature research
- Real-time data availability checking

#### When to Use Gemini 2.0
- Long-document analysis (1000+ page specs)
- Large research synthesis
- Pattern finding in large datasets
- Backup when Sonnet capacity exhausted

---

### Tier 3: Efficient Capability (HAIKU)

**Model:** Claude Haiku 4.5 (claude-haiku-4-5-20251001)
**Capacity:** 200K context window | Optimized for speed
**Cost:** ~0.1x Opus cost (most economical)
**Throughput:** Extremely fast

#### Use Cases
- Code formatting and style cleanup
- Simple bug fixes in known code
- Variable renaming and refactoring small functions
- Running tests and validating output
- Simple documentation updates
- Breaking down complex tasks into steps
- Routine status checks
- Quick lookup and search tasks
- Template filling and boilerplate generation
- Lint error fixes
- Simple data transformation

#### Quality Characteristics
- Excellent at focused, narrow tasks
- Very fast execution (1/3 time of Sonnet for simple tasks)
- Reliable for well-defined problems
- High accuracy on routine tasks
- Ideal for high-frequency, low-complexity work

#### When to Use Haiku
- Validate test results and assertions
- Format code to style guide
- Fix simple syntax errors
- Generate boilerplate (getters, setters, constructors)
- Split complex tasks into subtasks
- Summarize logs and outputs
- Apply known refactoring patterns
- Simple string/variable renaming

#### When NOT to Use Haiku
- Novel design decisions
- Ambiguous requirements
- Complex debugging
- Multi-system interactions
- Algorithm design or selection
- Architectural decisions
- Risk assessment

---

### Tier 4: Specialized External (ChatGPT, Gemini)

**Models:** OpenAI GPT-4o, Google Gemini 2.0
**Use:** Supplement Tier 1-3 for specific capabilities
**Cost:** May vary by integration pricing

#### When to Use External Models
- **ChatGPT-4o:** Web research, real-time data access, external API integration testing
- **Gemini 2.0:** Large document analysis, long-form synthesis, alternative reasoning perspective

#### Constraints
- Only use when Sonnet/Haiku insufficient
- Document reason for external model choice
- Monitor costs closely
- Maintain Sonnet as primary baseline

---

## Part 2: Agent-to-Model Default Assignments (15 Agents)

### Routing Table: Agent → Model Mapping

| Agent Name | Primary Model | Tier | Context | Key Override Rules |
|------------|---------------|------|---------|-------------------|
| **ORCHESTRATOR** | Sonnet 4 | Tier 2 | Task routing, dependency mgmt | Use Opus if >3 agents coordinating |
| **ARCHITECT** | Opus 4.5 | Tier 1 | System design, tech decisions | Never downgrade - escalate complexity |
| **SENIOR-DEV** | Opus 4.5 | Tier 1 | Complex implementation, refactoring | Use Sonnet for straightforward features |
| **BACKEND-DEV** | Sonnet 4 | Tier 2 | API, database, business logic | Use Opus for new paradigm/algorithm |
| **FRONTEND-DEV** | Sonnet 4 | Tier 2 | UI/UX implementation, styling | Use Haiku for CSS/formatting cleanup |
| **TEST-ENGINEER** | Haiku 4.5 | Tier 3 | Test execution, validation, assertions | Use Sonnet for test strategy |
| **QA-AGENT** | Sonnet 4 | Tier 2 | Test planning, quality strategy | Use Haiku for test runs |
| **CODE-REVIEWER** | Sonnet 4 | Tier 2 | Code review, feedback | Use Opus for architectural reviews |
| **RESEARCH-AGENT** | Gemini 2.0 / ChatGPT-4o | Tier 2/4 | Market research, analysis, competitive | Use Sonnet for synthesis |
| **TECH-WRITER** | Sonnet 4 | Tier 2 | Documentation, guides, API docs | Use Haiku for formatting updates |
| **PRODUCT-OWNER** | Sonnet 4 | Tier 2 | Requirements, roadmap, user stories | Use Opus for complex PRD |
| **SCRUM-MASTER** | Haiku 4.5 | Tier 3 | Sprint planning, standups, logistics | Use Sonnet for blocking issues |
| **DEVOPS-AGENT** | Sonnet 4 | Tier 2 | Infrastructure, deployment, monitoring | Use Haiku for routine config |
| **DOC-AUDITOR** | Sonnet 4 | Tier 2 | Documentation review, compliance | Use Haiku for format checks |
| **SKILL-CREATOR** | Opus 4.5 | Tier 1 | Agent skill design, capabilities | Escalate all gaps to Opus |

### Agent Tier Distribution

```
Tier 1 (Opus):        3 agents [ARCHITECT, SENIOR-DEV, SKILL-CREATOR]
Tier 2 (Sonnet):     10 agents [Primary tier for system]
Tier 2/4 (Gemini/GPT): 1 agent [RESEARCH-AGENT]
Tier 3 (Haiku):       2 agents [TEST-ENGINEER, SCRUM-MASTER]

Cost Profile: ~45% Opus, ~50% Sonnet, ~3% Gemini/GPT, ~2% Haiku
```

---

## Part 3: Complexity Scoring Reference

### Complexity Score Calculation

Each task receives a score 1-10 based on these factors:

| Factor | Scoring |
|--------|---------|
| **Domain Knowledge Required** | 1-3: Single domain | 4-6: 2-3 domains | 7-10: 4+ domains |
| **State/Context Complexity** | 1-3: Few variables | 4-6: 5-10 variables | 7-10: 10+ variables |
| **Ambiguity Level** | 1-3: Clear requirements | 4-6: Some unknowns | 7-10: High uncertainty |
| **Decision Branching** | 1-3: Linear path | 4-6: 3-4 branches | 7-10: 5+ branches |
| **Error Consequence** | 1-3: Low impact | 4-6: Medium impact | 7-10: Critical impact |
| **Novelty/Prior Experience** | 1-3: Known pattern | 4-6: Variations on known | 7-10: Novel approach |

### Score-to-Model Mapping

| Complexity Score | Recommended Model | Rationale | Examples |
|------------------|-------------------|-----------|----------|
| **1-2** | Haiku | Simple, routine, low stakes | Format fix, lint cleanup, simple rename |
| **3-4** | Haiku → Sonnet | Routine with small variations | Add field to form, style update, config change |
| **5-6** | Sonnet | Moderate complexity, requires reasoning | Feature implementation, test strategy, code review |
| **7-8** | Sonnet → Opus | Complex, multiple considerations | New algorithm, architectural refactor, system integration |
| **9-10** | Opus | Maximum complexity, high stakes | New system design, critical bug, paradigm shift |

### Complexity Scoring Examples

#### Example 1: Simple Lint Fix
```
Domain Knowledge: 1 (CSS only)
State Complexity: 1 (single file)
Ambiguity: 1 (clear rule)
Decision Branching: 1 (apply rule)
Error Consequence: 1 (cosmetic)
Novelty: 1 (known pattern)

TOTAL: 6/60 = Score 1 → USE HAIKU
```

#### Example 2: Feature Implementation with API
```
Domain Knowledge: 4 (backend, frontend, API, DB)
State Complexity: 5 (multiple tables, UI states)
Ambiguity: 4 (some UX unknowns)
Decision Branching: 3 (straightforward flow)
Error Consequence: 6 (affects users)
Novelty: 2 (similar feature exists)

TOTAL: 24/60 = Score 4 → USE SONNET
```

#### Example 3: New System Architecture
```
Domain Knowledge: 8 (multiple systems, external integrations)
State Complexity: 9 (many interdependencies)
Ambiguity: 8 (emerging requirements)
Decision Branching: 8 (multiple architecture styles)
Error Consequence: 9 (affects entire system)
Novelty: 9 (new paradigm)

TOTAL: 51/60 = Score 9 → USE OPUS
```

---

## Part 4: Cost Optimization Guidelines

### Cost Baseline (Relative to Opus = 1x)

| Model | Cost | Speed | Throughput | Quality | Best For |
|-------|------|-------|-----------|---------|----------|
| Opus | 1.0x | 1.0x | 1/task | 1.0x quality | Complex reasoning |
| Sonnet | 0.3x | 1.2x | 1/task | 0.95x quality | Default production |
| Haiku | 0.1x | 0.3x | 1/task | 0.75x quality | Routine tasks |
| Gemini | 0.4x | 1.3x | 1/task | 0.9x quality | Research |
| ChatGPT-4o | 0.35x | 1.1x | 1/task | 0.92x quality | Web research |

### Monthly Cost Scenario (100 tasks/month)

#### Scenario A: All Opus (No Optimization)
```
100 tasks × $0.05/task (Opus avg) = $5.00/month
Quality: Excellent | Cost-Efficiency: Very Poor
```

#### Scenario B: Tiered (Current Recommendation)
```
30 tasks × $0.05 (Opus, Score 8-10)           = $1.50
50 tasks × $0.015 (Sonnet, Score 5-7)         = $0.75
20 tasks × $0.005 (Haiku, Score 1-4)          = $0.10
TOTAL: $2.35/month (53% of Opus-only)
Quality: 97% of Opus-only | Cost-Efficiency: Excellent
```

#### Scenario C: Aggressive (Not Recommended)
```
10 tasks × $0.05 (Opus)                       = $0.50
40 tasks × $0.015 (Sonnet)                    = $0.60
50 tasks × $0.005 (Haiku)                     = $0.25
TOTAL: $1.35/month (27% of Opus-only)
Quality: 85% of Opus-only | Cost-Efficiency: Too risky
```

### Cost Optimization Rules

1. **Default to Sonnet:** Sonnet is the economic sweet spot (3x cheaper than Opus, negligible quality loss)

2. **Use Opus Strategically:** Only when:
   - Task complexity score ≥ 8
   - Failure cost is high
   - Sonnet has failed on similar task
   - Architectural decision required

3. **Push to Haiku Aggressively:** When:
   - Task is routine/known pattern
   - Task complexity score ≤ 4
   - Input is small (<5K tokens)
   - Output is simple/structured

4. **Batch Decisions:** Aggregate low-complexity tasks and route to Haiku together

5. **Monitor Cost-Quality Ratio:**
   ```
   Efficiency = Quality Score / Cost

   If Efficiency < 0.8 across tier, re-evaluate assignment
   ```

---

## Part 5: Quality Thresholds and Escalation Triggers

### Quality Scoring System

| Metric | Measurement | Threshold | Action |
|--------|------------|-----------|--------|
| **Accuracy** | Correct output on first attempt | < 90% | Escalate to higher tier |
| **Completeness** | All requirements met | < 95% | Escalate to higher tier |
| **Coherence** | Output is logical/consistent | < 85% | Escalate to higher tier |
| **Efficiency** | Tokens used / quality achieved | > 1.5x expected | Downgrade to lower tier |
| **Reasoning Depth** | Explanation sufficiency | Failing for >3 attempts | Escalate to higher tier |

### Escalation Triggers (Hard Rules)

Automatically escalate to next tier if any trigger occurs:

#### Tier 3 (Haiku) → Tier 2 (Sonnet)
- Error in output and retry needed (failure = instant escalate)
- Task requires explanation/reasoning
- Attempting same task 2nd time
- Output quality score < 85%
- Task complexity during execution > 4

#### Tier 2 (Sonnet) → Tier 1 (Opus)
- Sonnet produces conflicting answers when retried
- Ambiguity in requirements discovered mid-task
- Multiple domains need integration
- Architectural decision required
- Task complexity during execution > 8
- Quality score < 90% on second attempt

#### Tier 2 (Sonnet) → Tier 4 (Specialized External)
- Web/real-time data required
- Unique capability gap identified
- Research synthesis required
- Alternative reasoning perspective needed

### De-escalation Rules

Scale down to lower tier if conditions met:

#### Tier 1 (Opus) → Tier 2 (Sonnet)
- After successful completion, identify routine parts that could use Sonnet
- If task complexity drops below 8 during execution
- For follow-up/repetitive work on same problem

#### Tier 2 (Sonnet) → Tier 3 (Haiku)
- Task completion requires only formatting/cleanup
- Validation/testing phase (no new reasoning needed)
- Routine code generation from templates
- Simple variable/naming refactors

### Quality Assurance Checkpoints

#### Before Task Assignment
```
Is previous work documented?
├─ No: Request summary from previous agent
├─ Yes: Is quality score available?
    ├─ Score < 90%: Escalate tier
    ├─ Score 90-95%: Same tier, request review
    └─ Score > 95%: Proceed with same/lower tier
```

#### During Task Execution (Every 500 tokens)
```
Quality check at intervals:
- Is output tracking to requirements?
- Is complexity increasing unexpectedly?
- Is model struggling (verbose, uncertain)?

If YES to any: Stop and escalate
If NO to all: Continue
```

#### Post-Task
```
Calculate Quality Score:
= (Accuracy × 0.5) + (Completeness × 0.3) + (Coherence × 0.2)

If < 90%: Tag for escalation in future similar tasks
If 90-95%: Flag for second review
If > 95%: Reuse model tier for similar tasks
```

---

## Part 6: Performance Tracking Examples

### Performance Metric Collection

#### Metric 1: Quality vs. Cost Trade-off

**Example Dataset (Monthly):**

| Agent | Task Count | Avg Tier | Avg Cost/Task | Avg Quality | Escalations |
|-------|-----------|----------|---------------|------------|-------------|
| BACKEND-DEV | 15 | Sonnet | $0.015 | 94% | 2 |
| FRONTEND-DEV | 12 | Sonnet | $0.014 | 92% | 3 |
| TEST-ENGINEER | 20 | Haiku | $0.004 | 88% | 8 |
| TECH-WRITER | 8 | Sonnet | $0.016 | 96% | 0 |

**Analysis:**
- TEST-ENGINEER over-escalating (8/20 = 40% escalation rate)
- TECH-WRITER: High quality, low escalation - optimal assignment
- FRONTEND-DEV: Higher escalations suggest task complexity misunderstanding

**Action:** Re-evaluate TEST-ENGINEER task complexity scoring or use Sonnet baseline

#### Metric 2: Model Tier Distribution Over Time

**Example Tracking (3-Month Trend):**

```
Month 1:
- Opus:  25% (over-allocated)
- Sonnet: 60%
- Haiku: 15%
- Cost:  $3.20/month

Month 2 (After optimization):
- Opus:  18%
- Sonnet: 68%
- Haiku: 14%
- Cost:  $2.10/month (34% reduction)

Month 3 (Steady State):
- Opus:  20%
- Sonnet: 65%
- Haiku: 15%
- Cost:  $2.25/month (Target achieved)
Quality maintained: 96% (vs 98% Month 1)
```

#### Metric 3: Escalation Rate by Category

**Sample Report:**

| Category | Initial Tier | Escalation Count | Escalation Rate | Recommended Change |
|----------|--------------|------------------|-----------------|-------------------|
| Feature Implementation | Sonnet | 8/40 | 20% | OK (target: <15%) |
| Code Review | Sonnet | 3/25 | 12% | OK (below target) |
| Test Validation | Haiku | 12/35 | 34% | Consider Sonnet baseline |
| Documentation | Sonnet | 2/18 | 11% | Optimize, reduce overhead |
| Research | Gemini | 6/12 | 50% | Add Sonnet fallback |

**Action:** Investigate why Research has 50% escalation; consider Sonnet as primary

#### Metric 4: Cost Efficiency Calculation

**Formula:**
```
Efficiency Score = (Quality Score × 100) / (Actual Cost / Baseline Cost)

Baseline Cost = average Sonnet task ($0.015)
```

**Example Calculations:**

| Agent Task | Quality | Cost | Baseline | Efficiency | Status |
|-----------|---------|------|----------|-----------|--------|
| Haiku: Simple lint | 92% | $0.004 | $0.015 | (92 × 100) / 0.27 = 341 | EXCELLENT |
| Sonnet: Feature | 94% | $0.015 | $0.015 | (94 × 100) / 1.0 = 94 | GOOD |
| Opus: Architecture | 98% | $0.05 | $0.015 | (98 × 100) / 3.33 = 29 | EXPECTED |
| Haiku: Complex debug | 71% | $0.004 | $0.015 | (71 × 100) / 0.27 = 263 | POOR (escalate) |

**Interpretation:**
- Scores > 100 indicate good value
- Scores < 30 suggest model tier mismatch
- Track trends month-over-month

#### Metric 5: Task Completion Time by Tier

**Example Data (Time in Minutes):**

| Task Type | Haiku | Sonnet | Opus |
|-----------|-------|--------|------|
| Simple Fix | 2.1 | 3.2 | 5.1 |
| Feature Implementation | 8.5 | 9.2 | 10.5 |
| Architecture Design | N/A | 18.3 | 16.8 |
| Bug Analysis | 5.2 | 4.8 | 3.9 |

**Insights:**
- Haiku fastest for simple tasks, not suitable for complex
- Sonnet good overall throughput
- Opus slower but fewer mistakes = fewer re-attempts
- Consider actual completion time vs. cost trade-off

### Dashboard Template (Monthly Review)

```
MODEL ROUTING PERFORMANCE DASHBOARD - [MONTH]

Overall Cost Metrics:
  Previous Month Cost:    $2.80
  Current Month Cost:     $2.35
  Savings:                $0.45 (16%)
  Quality Change:         96% → 95% (-1%, acceptable)

Tier Distribution:
  Opus:    18% (↓2%)  ✓
  Sonnet:  67% (↑3%)  ✓
  Haiku:   15% (unchanged)  ✓

Top Escalations This Month:
  TEST-ENGINEER:  8 escalations (40%)  ⚠ Action: Review task assignment
  FRONTEND-DEV:   3 escalations (25%)  ~ Monitor
  RESEARCH-AGENT: 2 escalations (17%)  ✓

Quality by Agent:
  TECH-WRITER:    96% ✓✓ (Keep Sonnet)
  BACKEND-DEV:    94% ✓ (OK with Sonnet)
  FRONTEND-DEV:   92% ✓ (OK but increasing escalations)
  SCRUM-MASTER:   88% (Haiku OK for role)

Efficiency Anomalies:
  None - all agents within target range

Recommendations:
  1. Shift TEST-ENGINEER to Sonnet baseline
  2. Monitor FRONTEND-DEV escalations
  3. Consider Sonnet for RESEARCH-AGENT (high escalation)
  4. Continue current OPUS allocation for ARCHITECT
```

---

## Part 7: Decision Framework Quick Reference

### Use This Flow for Task Assignment

```
START: New task arrives
│
├─ Step 1: Calculate Complexity Score (1-10)
│  ├─ Score 1-2:  Haiku
│  ├─ Score 3-4:  Haiku (or Sonnet if uncertain)
│  ├─ Score 5-6:  Sonnet
│  ├─ Score 7-8:  Sonnet (or Opus if high stakes)
│  └─ Score 9-10: Opus
│
├─ Step 2: Check Context
│  ├─ Previous similar task?
│  │  ├─ Yes, quality > 95%: Same tier
│  │  ├─ Yes, quality < 90%: Escalate
│  │  └─ No: Use score from Step 1
│  └─ Special requirements?
│     ├─ Web research: Use ChatGPT-4o or Gemini
│     ├─ Long document: Use Gemini
│     └─ Standard: Continue
│
├─ Step 3: Check Constraints
│  ├─ Budget critical: Prefer Haiku/Sonnet
│  ├─ Quality critical: Prefer Opus/Sonnet
│  ├─ Speed critical: Prefer Haiku
│  └─ None: Use score-based assignment
│
└─ ASSIGN: Model selection complete
   └─ After task: Log quality score for future decisions
```

### Quick Lookup: Common Tasks

| Task | Default Model | Rationale |
|------|---------------|-----------|
| Implement new API endpoint | Sonnet | Score 5-6, proven pattern |
| Review code PR | Sonnet | Needs reasoning, standard practice |
| Fix CSS formatting | Haiku | Score 1-3, no reasoning needed |
| Design new system | Opus | Score 9-10, high stakes |
| Write unit tests | Sonnet | Score 5-6, moderate reasoning |
| Run test suite | Haiku | Score 1-2, validation only |
| Write documentation | Sonnet | Score 5-6, requires clarity |
| Refactor legacy code | Sonnet | Score 6-7, may find patterns |
| Debug production issue | Opus | High stakes, needs deep reasoning |
| Generate boilerplate | Haiku | Score 1-3, template application |
| Market research | Gemini/ChatGPT | Specialized capability |

---

## Implementation Checklist

When implementing model routing:

- [ ] Communicate tier strategy to all agents
- [ ] Set default models per agent (use Table from Part 2)
- [ ] Implement complexity scoring calculator
- [ ] Set up escalation triggers in task processing
- [ ] Create cost tracking dashboard
- [ ] Log quality scores after each task completion
- [ ] Monthly review of escalation patterns
- [ ] Quarterly cost-benefit analysis
- [ ] Document agent-specific override rules
- [ ] Train team on when to escalate manually

---

## Appendix: Cost Reference Data

### Actual Token Pricing (as of knowledge cutoff)

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Avg Task Cost |
|-------|----------------------|------------------------|---------------|
| Opus | $15 | $45 | ~$0.05 |
| Sonnet | $3 | $15 | ~$0.015 |
| Haiku | $0.80 | $4 | ~$0.005 |
| ChatGPT-4o | $5 | $15 | ~$0.018 |
| Gemini 2.0 | $0.075 | $0.30 | ~$0.004 |

(Note: Pricing subject to change. Update this table quarterly.)

### Revision History

| Date | Change | Author | Status |
|------|--------|--------|--------|
| 2025-12-14 | Initial 4-tier expansion | Diana | Current |
| | | | |

---

**Document Version:** 2.0 (Expanded)
**Last Updated:** 2025-12-14
**Next Review:** 2025-03-14 (Quarterly)
