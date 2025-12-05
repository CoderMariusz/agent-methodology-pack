# Epic Workflow

## Overview

End-to-end process for delivering an epic from conception to completion. This workflow orchestrates multiple agents through discovery, design, planning, development, quality, and documentation phases.

## ASCII Flow Diagram

```
                                    EPIC WORKFLOW
                                         |
                                         v
+=====================================================================================+
|                              PHASE 1: DISCOVERY                                     |
+=====================================================================================+
|                                                                                     |
|   +------------------+     +------------------+     +------------------+            |
|   | RESEARCH-AGENT   |---->| PM-AGENT         |---->| GATE: PRD        |            |
|   | (Opus/Sonnet)    |     | (Sonnet)         |     | Complete?        |            |
|   +------------------+     +------------------+     +--------+---------+            |
|   | - Market research|     | - Create PRD     |              |                      |
|   | - User interviews|     | - Define scope   |         YES  |  NO                  |
|   | - Tech analysis  |     | - User stories   |              |   |                  |
|   +------------------+     +------------------+              |   +---> Iterate      |
|                                                              |                      |
+=====================================================================================+
                                         |
                                         v
+=====================================================================================+
|                              PHASE 2: DESIGN (Parallel)                             |
+=====================================================================================+
|                                                                                     |
|   +--------------------+                    +--------------------+                  |
|   | ARCHITECT-AGENT    |                    | UX-DESIGNER        |                  |
|   | (Opus)             |                    | (Sonnet)           |                  |
|   +--------------------+                    +--------------------+                  |
|   | - System design    |                    | - User flows       |                  |
|   | - ADR creation     |                    | - Wireframes       |                  |
|   | - API design       |                    | - UI specs         |                  |
|   | - DB schema        |                    | - Accessibility    |                  |
|   +--------------------+                    +--------------------+                  |
|            |                                         |                              |
|            +-------------------+---------------------+                              |
|                                |                                                    |
|                                v                                                    |
|                    +---------------------------+                                    |
|                    | GATE: Design Complete?    |                                    |
|                    | - Architecture approved   |                                    |
|                    | - UX specs complete       |                                    |
|                    | - No blocking questions   |                                    |
|                    +-------------+-------------+                                    |
|                                  |                                                  |
+=====================================================================================+
                                   |
                                   v
+=====================================================================================+
|                              PHASE 3: PLANNING                                      |
+=====================================================================================+
|                                                                                     |
|   +------------------+     +------------------+     +------------------+            |
|   | PRODUCT-OWNER    |---->| SCRUM-MASTER     |---->| GATE: Sprint     |            |
|   | (Sonnet)         |     | (Sonnet)         |     | Ready?           |            |
|   +------------------+     +------------------+     +--------+---------+            |
|   | - Review stories |     | - Create sprint  |              |                      |
|   | - Prioritize     |     | - Assign tasks   |         YES  |  NO                  |
|   | - Refine backlog |     | - Set capacity   |              |   |                  |
|   +------------------+     +------------------+              |   +---> Refine       |
|                                                              |                      |
+=====================================================================================+
                                         |
                                         v
+=====================================================================================+
|                         PHASE 4: IMPLEMENTATION LOOP                                |
+=====================================================================================+
|                                                                                     |
|   +-----------------------------------------------------------------------+        |
|   |                         FOR EACH STORY                                 |        |
|   |                                                                        |        |
|   |   +---------+    +---------+    +---------+    +---------+            |        |
|   |   | TEST    |--->| DEV     |--->| DEV     |--->| QA      |            |        |
|   |   | (RED)   |    | (GREEN) |    | (REFAC) |    | AGENT   |            |        |
|   |   +---------+    +---------+    +---------+    +---------+            |        |
|   |        |              |              |              |                  |        |
|   |        v              v              v              v                  |        |
|   |   Write tests    Implement     Refactor      Validate                 |        |
|   |   first          to pass       & clean       quality                  |        |
|   |                                                                        |        |
|   +-----------------------------------------------------------------------+        |
|                            |                                                        |
|                            v                                                        |
|              +---------------------------+                                          |
|              | CODE-REVIEWER             |                                          |
|              | - Review changes          |                                          |
|              | - Approve or request fix  |                                          |
|              +-------------+-------------+                                          |
|                            |                                                        |
|                   APPROVED | CHANGES REQUESTED                                      |
|                            |         |                                              |
|                            v         +-----> Back to DEV                            |
+=====================================================================================+
                                         |
                                         v
+=====================================================================================+
|                              PHASE 5: QUALITY                                       |
+=====================================================================================+
|                                                                                     |
|   +------------------+     +------------------+                                     |
|   | QA-AGENT         |---->| GATE: Quality    |                                     |
|   | (Sonnet)         |     | Approved?        |                                     |
|   +------------------+     +--------+---------+                                     |
|   | - E2E testing    |              |                                               |
|   | - Regression     |         YES  |  NO                                           |
|   | - Performance    |              |   |                                           |
|   | - Security scan  |              |   +---> Back to DEV                           |
|   +------------------+              |                                               |
|                                     |                                               |
+=====================================================================================+
                                         |
                                         v
+=====================================================================================+
|                              PHASE 6: DOCUMENTATION                                 |
+=====================================================================================+
|                                                                                     |
|   +------------------+     +------------------+                                     |
|   | TECH-WRITER      |---->| GATE: Docs       |                                     |
|   | (Sonnet)         |     | Complete?        |                                     |
|   +------------------+     +--------+---------+                                     |
|   | - API docs       |              |                                               |
|   | - User guides    |         YES  |  NO                                           |
|   | - Change log     |              |   |                                           |
|   | - Release notes  |              |   +---> Iterate                               |
|   +------------------+              |                                               |
|                                     |                                               |
+=====================================================================================+
                                         |
                                         v
                            +---------------------------+
                            |      EPIC COMPLETE        |
                            | - Update PROJECT-STATE    |
                            | - Archive to completed/   |
                            | - Update METRICS          |
                            +---------------------------+
```

## Detailed Steps

### Phase 1: Discovery

#### Step 1.1: Research (RESEARCH-AGENT)
**Model:** Opus or Sonnet (depending on complexity)
**Duration:** 0.5-1 day

1. Gather initial requirements from stakeholders
2. Research market context and competitors
3. Analyze existing technical constraints
4. Document unknowns and risks
5. Create research report

**Output:** `docs/1-BASELINE/research/research-report.md`

#### Step 1.2: PRD Creation (PM-AGENT)
**Model:** Sonnet
**Duration:** 0.5-1 day

1. Review research report
2. Define product vision and goals
3. Create user personas
4. Define user stories with acceptance criteria
5. Identify success metrics
6. Document assumptions and constraints

**Output:** `docs/1-BASELINE/product/prd.md`

#### Quality Gate 1: PRD Review
- [ ] All user stories have acceptance criteria
- [ ] Success metrics are measurable
- [ ] Scope is clearly defined
- [ ] Dependencies identified
- [ ] Stakeholder approval received

---

### Phase 2: Design (Parallel Execution)

#### Step 2.1: Architecture Design (ARCHITECT-AGENT)
**Model:** Opus
**Duration:** 1-2 days

1. Review PRD and technical requirements
2. Design system architecture
3. Create database schema
4. Define API contracts
5. Document architectural decisions (ADRs)
6. Identify technical risks

**Outputs:**
- `docs/1-BASELINE/architecture/architecture-overview.md`
- `docs/1-BASELINE/architecture/database-schema.md`
- `docs/1-BASELINE/architecture/api-spec.md`
- `docs/1-BASELINE/architecture/decisions/ADR-XXX-*.md`

#### Step 2.2: UX Design (UX-DESIGNER)
**Model:** Sonnet
**Duration:** 1-2 days (parallel with architecture)

1. Create user flow diagrams
2. Design wireframes
3. Define UI specifications
4. Document accessibility requirements
5. Create component specifications

**Outputs:**
- `docs/1-BASELINE/ux/user-flows.md`
- `docs/1-BASELINE/ux/wireframes/`
- `docs/1-BASELINE/ux/ui-spec.md`

#### Quality Gate 2: Design Review
- [ ] Architecture supports all PRD requirements
- [ ] ADRs documented for key decisions
- [ ] UX flows cover all user stories
- [ ] No blocking technical questions
- [ ] Design reviewed and approved

---

### Phase 3: Planning

#### Step 3.1: Backlog Refinement (PRODUCT-OWNER)
**Model:** Sonnet
**Duration:** 0.25 day

1. Review epic breakdown from Architect
2. Prioritize stories using MoSCoW
3. Identify story dependencies
4. Assign complexity estimates
5. Create prioritized backlog

**Output:** `docs/2-MANAGEMENT/epics/current/epic-XX-*.md`

#### Step 3.2: Sprint Planning (SCRUM-MASTER)
**Model:** Sonnet
**Duration:** 0.25 day

1. Calculate team capacity
2. Select stories for sprint
3. Create sprint backlog
4. Update task queue
5. Identify sprint risks

**Outputs:**
- `.claude/state/TASK-QUEUE.md` (updated)
- `docs/2-MANAGEMENT/sprints/sprint-XX.md`

#### Quality Gate 3: Sprint Ready
- [ ] Stories are INVEST compliant
- [ ] Dependencies resolved or planned
- [ ] Capacity matches commitment
- [ ] All stories have clear acceptance criteria
- [ ] Sprint goal defined

---

### Phase 4: Implementation Loop

For each story in the sprint:

#### Step 4.1: UX Detail (UX-DESIGNER) - If UI Story
**Model:** Sonnet
**Duration:** Varies

1. Create detailed component designs
2. Define interaction specifications
3. Provide assets and specifications

#### Step 4.2: Test First (TEST-ENGINEER) - RED Phase
**Model:** Sonnet
**Duration:** Varies by story size

1. Review story acceptance criteria
2. Design test strategy
3. Write failing tests
4. Document test coverage requirements

**Output:** Test files (failing)

#### Step 4.3: Implementation (DEV) - GREEN Phase
**Model:** Sonnet (SENIOR-DEV uses Opus for complex)
**Duration:** Varies by story size

1. Implement minimal code to pass tests
2. Follow coding standards
3. Handle errors appropriately
4. Ensure all tests pass

**Output:** Implementation code (tests passing)

#### Step 4.4: Refactoring (DEV) - REFACTOR Phase
**Model:** Sonnet
**Duration:** 15-30% of implementation time

1. Clean up code
2. Remove duplication
3. Improve naming
4. Optimize if needed
5. Ensure tests still pass

**Output:** Clean, refactored code

#### Step 4.5: Quality Validation (QA-AGENT)
**Model:** Sonnet
**Duration:** Varies

1. Execute test suite
2. Perform manual testing
3. Validate acceptance criteria
4. Report any issues

#### Step 4.6: Code Review (CODE-REVIEWER)
**Model:** Sonnet (Haiku for simple fixes)
**Duration:** 0.5-2 hours per story

1. Review code changes
2. Check standards compliance
3. Assess security
4. Verify test coverage
5. Approve or request changes

**Output:** Review feedback, approval status

#### Quality Gate 4: Story Done
- [ ] All tests pass
- [ ] Code review approved
- [ ] Acceptance criteria met
- [ ] No critical issues
- [ ] Documentation updated

---

### Phase 5: Quality Assurance

#### Step 5.1: Integration Testing (QA-AGENT)
**Model:** Sonnet
**Duration:** 1-2 days

1. Execute E2E test suite
2. Perform regression testing
3. Validate cross-story integration
4. Performance testing
5. Security scanning

#### Quality Gate 5: Quality Approved
- [ ] All E2E tests pass
- [ ] No regression issues
- [ ] Performance meets SLAs
- [ ] Security scan passed
- [ ] Accessibility validated

---

### Phase 6: Documentation

#### Step 6.1: Documentation (TECH-WRITER)
**Model:** Sonnet
**Duration:** 0.5-1 day

1. Update API documentation
2. Create/update user guides
3. Write release notes
4. Update change log
5. Archive completed work

**Outputs:**
- `docs/3-IMPLEMENTATION/api/`
- `docs/4-RELEASE/release-notes.md`
- `docs/4-RELEASE/changelog.md`

#### Quality Gate 6: Documentation Complete
- [ ] API docs up to date
- [ ] User guides accurate
- [ ] Release notes written
- [ ] All changes documented

---

## Parallel Work Opportunities

```
PHASE         PARALLEL OPPORTUNITIES
------        ----------------------
Discovery     Research can inform PM incrementally
Design        Architecture + UX can work in parallel
Planning      PO and SM work sequentially (fast)
Development   Multiple stories can run in parallel
              - Story A: TEST -> DEV -> REVIEW
              - Story B:        TEST -> DEV -> REVIEW
              - Story C:               TEST -> DEV
Quality       Can overlap with late development
Documentation Can start as stories complete
```

## Handoff Points

| From | To | Artifact | Handoff Record |
|------|-----|----------|----------------|
| RESEARCH-AGENT | PM-AGENT | Research report | HANDOFFS.md |
| PM-AGENT | ARCHITECT-AGENT | PRD | HANDOFFS.md |
| PM-AGENT | UX-DESIGNER | PRD | HANDOFFS.md |
| ARCHITECT-AGENT | PRODUCT-OWNER | Epic breakdown | HANDOFFS.md |
| UX-DESIGNER | PRODUCT-OWNER | UX specs | HANDOFFS.md |
| PRODUCT-OWNER | SCRUM-MASTER | Prioritized backlog | HANDOFFS.md |
| SCRUM-MASTER | TEST-ENGINEER | Sprint tasks | TASK-QUEUE.md |
| TEST-ENGINEER | DEV | Failing tests | HANDOFFS.md |
| DEV | CODE-REVIEWER | Implementation | HANDOFFS.md |
| CODE-REVIEWER | QA-AGENT | Approved code | HANDOFFS.md |
| QA-AGENT | TECH-WRITER | Validated feature | HANDOFFS.md |

## Error Handling

### Discovery Phase Errors
| Error | Recovery |
|-------|----------|
| Unclear requirements | RESEARCH-AGENT gathers more info |
| Scope creep detected | PM-AGENT defines boundaries, gets approval |
| Missing stakeholder input | Escalate to ORCHESTRATOR |

### Design Phase Errors
| Error | Recovery |
|-------|----------|
| Architecture conflict | ARCHITECT-AGENT creates ADR with alternatives |
| UX infeasible technically | Joint session: ARCHITECT + UX-DESIGNER |
| Missing PRD details | Return to PM-AGENT for clarification |

### Development Phase Errors
| Error | Recovery |
|-------|----------|
| Tests cannot be written | Clarify acceptance criteria with PO |
| Implementation blocked | Document in DEPENDENCIES.md, alert SCRUM-MASTER |
| Code review rejection | DEV addresses feedback, resubmit |
| Performance issues | SENIOR-DEV optimization review |

### Quality Phase Errors
| Error | Recovery |
|-------|----------|
| Critical bugs found | Create bug tickets, prioritize fix |
| Regression detected | Root cause analysis, fix and retest |
| Security vulnerability | Immediate fix, ARCHITECT review |

## Example Scenarios

### Scenario 1: New Feature Epic
```
Input: "Add user authentication"

Flow:
1. RESEARCH-AGENT: Analyze auth requirements, security standards
2. PM-AGENT: Create PRD with auth user stories
3. ARCHITECT-AGENT: Design auth architecture, choose OAuth provider
4. UX-DESIGNER: Create login/signup flows and screens
5. PRODUCT-OWNER: Prioritize stories (login first, then signup, then SSO)
6. SCRUM-MASTER: Plan Sprint 1 with login story
7. Implementation Loop for each story
8. QA validates complete auth flow
9. TECH-WRITER documents auth for users and developers
```

### Scenario 2: Technical Debt Epic
```
Input: "Refactor legacy payment module"

Flow:
1. RESEARCH-AGENT: Analyze current implementation, identify issues
2. PM-AGENT: Define refactoring scope and success criteria
3. ARCHITECT-AGENT: Design target architecture, migration strategy
4. UX-DESIGNER: (minimal involvement, internal changes)
5. PRODUCT-OWNER: Prioritize by risk and impact
6. SCRUM-MASTER: Plan incremental refactoring sprints
7. Implementation with extra focus on test coverage
8. QA extensive regression testing
9. TECH-WRITER updates internal documentation
```

## State Updates

Update the following at each phase transition:

```markdown
## PROJECT-STATE.md Updates

After Discovery:
- Phase: Design
- Last Activity: PRD completed
- Next: Architecture design

After Design:
- Phase: Planning
- Last Activity: Design complete
- Next: Sprint planning

After Planning:
- Phase: Development
- Current Sprint: Sprint N
- Next: Story implementation

After Development:
- Phase: Quality
- Stories Completed: X/Y
- Next: Final QA

After Quality:
- Phase: Documentation
- Quality Status: Approved
- Next: Release prep

After Documentation:
- Phase: Complete
- Epic Status: Done
- Archive to completed/
```

## Metrics Tracking

Track the following throughout the epic:

| Metric | When | Location |
|--------|------|----------|
| Discovery duration | Phase 1 complete | METRICS.md |
| Design duration | Phase 2 complete | METRICS.md |
| Stories completed | Each story done | METRICS.md |
| Bugs found | During QA | METRICS.md |
| Code review cycles | Each review | METRICS.md |
| Total epic duration | Epic complete | METRICS.md |
