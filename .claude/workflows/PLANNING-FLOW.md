# Planning Flow - Quick Reference

## Overview

Quick reference for the planning phase (Phases 1-3 of Epic Workflow). From initial discovery through design to sprint-ready backlog.

## Flow Diagram

```
PLANNING FLOW
     |
     v
+------------------+
| PHASE 1          |
| DISCOVERY        |
+------------------+
| RESEARCH-AGENT   |---> Research Report
| PM-AGENT         |---> PRD
+--------+---------+
         |
         v
    [PRD Complete?]
         |
         v
+------------------+
| PHASE 2          |
| DESIGN           |
| (Parallel)       |
+------------------+
| ARCHITECT-AGENT  |---> Architecture, ADRs, DB Schema, API Spec
| UX-DESIGNER      |---> User Flows, Wireframes, UI Spec
+--------+---------+
         |
         v
    [Design Complete?]
         |
         v
+------------------+
| PHASE 3          |
| SPRINT PLANNING  |
+------------------+
| PRODUCT-OWNER    |---> Prioritized Backlog
| SCRUM-MASTER     |---> Sprint Plan, Task Queue
+--------+---------+
         |
         v
   READY FOR DEV
```

## Phase 1: Discovery

### RESEARCH-AGENT (Opus/Sonnet)
**Input:** Initial requirements
**Duration:** 0.5-1 day

Activities:
- Market research and competitor analysis
- User interviews and requirements gathering
- Technical constraint analysis
- Risk and unknown documentation

**Output:** `docs/1-BASELINE/research/research-report.md`

### PM-AGENT (Sonnet)
**Input:** Research report
**Duration:** 0.5-1 day

Activities:
- Define product vision and goals
- Create user personas
- Write user stories with acceptance criteria
- Identify success metrics
- Document assumptions

**Output:** `docs/1-BASELINE/product/prd.md`

### Quality Gate: PRD Complete
- [ ] All user stories have acceptance criteria
- [ ] Success metrics are measurable
- [ ] Scope clearly defined
- [ ] Dependencies identified
- [ ] Stakeholder approval

## Phase 2: Design (Parallel)

### ARCHITECT-AGENT (Opus)
**Input:** PRD
**Duration:** 1-2 days

Activities:
- System architecture design
- Database schema definition
- API contract design
- Architectural Decision Records (ADRs)
- Technical risk identification

**Outputs:**
- `docs/1-BASELINE/architecture/architecture-overview.md`
- `docs/1-BASELINE/architecture/database-schema.md`
- `docs/1-BASELINE/architecture/api-spec.md`
- `docs/1-BASELINE/architecture/decisions/ADR-XXX-*.md`

### UX-DESIGNER (Sonnet)
**Input:** PRD
**Duration:** 1-2 days (parallel with Architecture)

Activities:
- User flow diagrams
- Wireframes and mockups
- UI specifications
- Accessibility requirements
- Component specifications

**Outputs:**
- `docs/1-BASELINE/ux/user-flows.md`
- `docs/1-BASELINE/ux/wireframes/`
- `docs/1-BASELINE/ux/ui-spec.md`

### Quality Gate: Design Complete
- [ ] Architecture supports all PRD requirements
- [ ] ADRs documented for key decisions
- [ ] UX flows cover all user stories
- [ ] No blocking technical questions
- [ ] Design reviewed and approved

## Phase 3: Sprint Planning

### PRODUCT-OWNER (Sonnet)
**Input:** PRD, Architecture, UX Design
**Duration:** 0.25 day

Activities:
- Review epic breakdown from Architect
- Prioritize stories using MoSCoW method
- Identify story dependencies
- Assign complexity estimates (S/M/L)
- Create prioritized backlog

**Output:** `docs/2-MANAGEMENT/epics/current/epic-XX-*.md`

### SCRUM-MASTER (Sonnet)
**Input:** Prioritized backlog
**Duration:** 0.25 day

Activities:
- Calculate team capacity
- Select stories for sprint
- Break stories into tasks
- Estimate task hours
- Assign tasks to agents
- Identify sprint risks

**Outputs:**
- `.claude/state/TASK-QUEUE.md` (updated)
- `docs/2-MANAGEMENT/sprints/sprint-XX.md`

### Quality Gate: Sprint Ready
- [ ] Stories are INVEST compliant
- [ ] Dependencies resolved or planned
- [ ] Capacity matches commitment
- [ ] All stories have clear acceptance criteria
- [ ] Sprint goal defined
- [ ] Tasks assigned to agents

## Agent Responsibilities

| Agent | Primary Role | Key Output |
|-------|--------------|------------|
| RESEARCH-AGENT | Market/tech analysis | Research report |
| PM-AGENT | Requirements definition | PRD |
| ARCHITECT-AGENT | System design | Architecture docs, ADRs |
| UX-DESIGNER | User experience design | Wireframes, UI specs |
| PRODUCT-OWNER | Prioritization | Prioritized backlog |
| SCRUM-MASTER | Sprint planning | Sprint plan, task queue |

## Handoff Points

1. RESEARCH-AGENT → PM-AGENT: Research report
2. PM-AGENT → ARCHITECT-AGENT: PRD
3. PM-AGENT → UX-DESIGNER: PRD
4. ARCHITECT-AGENT → PRODUCT-OWNER: Epic breakdown
5. UX-DESIGNER → PRODUCT-OWNER: UX specs
6. PRODUCT-OWNER → SCRUM-MASTER: Prioritized backlog
7. SCRUM-MASTER → Development Team: Sprint plan

Record all handoffs in `.claude/state/HANDOFFS.md`

## Common Issues & Recovery

### Issue: Unclear Requirements
**Recovery:**
1. RESEARCH-AGENT gathers more information
2. Update research report
3. PM-AGENT refines PRD
4. Continue from updated PRD

### Issue: Architecture Conflicts
**Recovery:**
1. ARCHITECT-AGENT creates ADR with alternatives
2. Document trade-offs
3. Escalate to stakeholders if needed
4. Update architecture based on decision

### Issue: UX Not Technically Feasible
**Recovery:**
1. Joint session: ARCHITECT + UX-DESIGNER
2. Find technical alternatives
3. Update both UX specs and architecture
4. Re-validate with PM-AGENT

### Issue: Stories Not INVEST Compliant
**Recovery:**
1. PRODUCT-OWNER breaks down large stories
2. SCRUM-MASTER provides feedback
3. Iterate until stories meet criteria
4. Re-prioritize if needed

## Success Metrics

- Planning phase duration: 2-4 days total
- PRD approval on first review: >80%
- Design approval on first review: >80%
- Stories ready for sprint: 100%
- Dependencies identified early: >90%
