# Project Metrics

**Last Updated:** {auto-updated}

## Context Budget

```
╔══════════════════════════════════════════════════════════════╗
║              CONTEXT BUDGET MONITOR                          ║
╠══════════════════════════════════════════════════════════════╣
║ ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  40%     ║
╠══════════════════════════════════════════════════════════════╣
║ Used:                    80,000 tokens                       ║
║ Remaining:              120,000 tokens                       ║
║ Limit:                  200,000 tokens                       ║
╠══════════════════════════════════════════════════════════════╣
║ Status: OK - Plenty of context available                     ║
╚══════════════════════════════════════════════════════════════╝
```

## Today's Session

| Metric | Value |
|--------|-------|
| Sessions | 0 |
| Total Tokens | 0 |
| Agents Called | 0 |
| Files Modified | 0 |
| Estimated Cost | $0.00 |

## Agent Usage (This Project)

| Agent | Calls | Avg Tokens | Total Tokens |
|-------|-------|------------|--------------|
| DISCOVERY-AGENT | 0 | 0 | 0 |
| DOC-AUDITOR | 0 | 0 | 0 |
| PM-AGENT | 0 | 0 | 0 |
| ARCHITECT-AGENT | 0 | 0 | 0 |
| TEST-ENGINEER | 0 | 0 | 0 |
| BACKEND-DEV | 0 | 0 | 0 |
| FRONTEND-DEV | 0 | 0 | 0 |
| CODE-REVIEWER | 0 | 0 | 0 |

## Recent Sessions

| Date | Session ID | Duration | Tokens | Cost |
|------|------------|----------|--------|------|
| - | - | - | - | - |

---

## How to Update

```bash
# Update session metrics
bash scripts/session-logger.sh metrics

# Check context budget
bash scripts/context-monitor.sh check

# View agent sizes
bash scripts/context-monitor.sh agents
```

---

*Auto-generated template - will be updated by monitoring scripts*

---

## Model Performance Tracking

**Purpose:** Track multi-model routing effectiveness
**Status:** Active monitoring
**Review:** Weekly

### Current Week Metrics

**Usage Distribution:**
- [ ] Opus 4.5: ___% (target: 10%)
- [ ] Sonnet 4.5: ___% (target: 40%)
- [ ] ChatGPT-4o: ___% (target: 5%)
- [ ] Gemini 2.0: ___% (target: 30%)
- [ ] Haiku 4.5: ___% (target: 15%)

**Quality Metrics:**
- [ ] Opus success rate: ___%  (target: >95%)
- [ ] Sonnet success rate: ___% (target: >90%)
- [ ] ChatGPT success rate: ___% (target: >85%)
- [ ] Gemini success rate: ___% (target: >90%)
- [ ] Haiku success rate: ___% (target: >90%)

**Escalation Tracking:**
- [ ] Tier 1 escalations: ___% (Sonnet→ChatGPT→Opus) (target: <10%)
- [ ] Tier 2 escalations: ___% (Gemini→Sonnet) (target: <10%)
- [ ] Tier 3 escalations: ___% (Haiku→Sonnet) (target: <5%)

**Cost Tracking:**
- [ ] Total spend this week: £___
- [ ] Budget target: £___ (<£30/week, £120/month)
- [ ] Savings vs all-Sonnet: £___
- [ ] Cost per agent type: ___

**Speed Analysis:**
- [ ] Average task duration: ___ seconds
- [ ] Gemini speed: ___ sec (target: <10s)
- [ ] Haiku speed: ___ sec (target: <8s)
- [ ] vs Sonnet baseline: ___% faster

### Model Performance by Agent

| Agent | Model | Tasks | Success Rate | Avg Cost | Escalations |
|-------|-------|-------|--------------|----------|-------------|
| RESEARCH-AGENT | Gemini | 0 | -% | $- | 0 |
| TEST-ENGINEER | Haiku | 0 | -% | $- | 0 |
| BACKEND-DEV | Sonnet | 0 | -% | $- | 0 |
| ARCHITECT | Opus | 0 | -% | $- | 0 |
| CODE-REVIEWER | Sonnet | 0 | -% | $- | 0 |

### Alerts & Actions

**Healthy:**
- (None yet - monitoring started 2025-12-14)

**Watch:**
- (Track first week of multi-model usage)

**Issues:**
- (None yet)

### Weekly Review Checklist

- [ ] Review usage distribution (within targets?)
- [ ] Check quality scores (meeting minimums?)
- [ ] Analyze escalation patterns (which agents/tasks?)
- [ ] Validate cost savings (19% target met?)
- [ ] Speed improvements confirmed (18% target?)
- [ ] Update agent configurations if needed
- [ ] Document lessons learned in DECISION-LOG.md

### Monthly Optimization

**Review Date:** Last review: 2025-12-14 | Next: 2025-01-14

**Questions:**
1. Which agents escalate most? Why?
2. Is Gemini quality acceptable for research/docs?
3. Is Haiku quality acceptable for tests?
4. Are cost savings matching projections?
5. Any model configuration adjustments needed?

**Actions:**
- Adjust complexity thresholds if escalations >10%
- Switch agent primary models if success rate <90%
- Update cost targets based on actual usage
- Refine model selection logic in agents

---

## How to Update Metrics

```bash
# After each sprint/week, manually update:
# 1. Usage percentages per model
# 2. Success rates from task outcomes
# 3. Escalation counts from logs
# 4. Cost data from billing
# 5. Speed metrics from task timings

# View cache performance (proxy for model usage)
bash scripts/cache-stats.sh

# Check agent session data
cat .claude/state/AGENT-MEMORY.md

# Review handoff logs for model transitions
cat .claude/state/HANDOFFS.md
```

---

*Auto-updated: Model performance tracking active from 2025-12-14*
