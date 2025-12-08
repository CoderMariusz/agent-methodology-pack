# Architect Question Protocol

## Overview
This protocol defines how ARCHITECT-AGENT generates and asks clarifying questions during architecture design.

## Question Generation Rules

### 1. Dynamic Generation
Questions MUST be generated based on detected gaps, not from static lists.

```
WRONG: Always ask "What database will you use?"
RIGHT: "PRD mentions 10M users but no database preference.
        Given the read-heavy workload (90% reads), would you
        prefer PostgreSQL for ACID or MongoDB for flexibility?"
```

### 2. Context-Aware
Every question must reference specific context from:
- PRD requirements
- Discovery output
- Existing codebase
- Previous answers

### 3. Batching Protocol

```
╔════════════════════════════════════════════════════════════════════════╗
║                    ARCHITECT QUESTION PROTOCOL                         ║
╠════════════════════════════════════════════════════════════════════════╣
║                                                                        ║
║   1. Analyze PRD and discovery output                                  ║
║   2. Identify architectural decisions needed                           ║
║   3. Categorize: BLOCKING / IMPORTANT / DEFERRABLE                     ║
║   4. Generate MAX 5 questions per round                                ║
║   5. Present with context and options                                  ║
║   6. Wait for answers                                                  ║
║   7. Show progress: "Architecture Clarity: X%"                         ║
║   8. Ask: "Continue? [Y/n/focus on area]"                              ║
║   9. Repeat until clarity >= 80%                                       ║
║                                                                        ║
╚════════════════════════════════════════════════════════════════════════╝
```

## Question Categories

### System Architecture
- Monolith vs microservices
- Synchronous vs asynchronous
- Event-driven patterns
- API design (REST/GraphQL/gRPC)

### Data Architecture
- Database selection
- Caching strategy
- Data partitioning
- Consistency requirements

### Infrastructure
- Cloud provider
- Containerization
- CI/CD pipeline
- Monitoring/observability

### Security
- Authentication method
- Authorization model
- Data encryption
- Compliance requirements

### Scalability
- Expected load
- Scaling strategy
- Performance targets
- Bottleneck analysis

## Question Format

```markdown
### Question {N}: {Topic}

**Context:** {What in PRD/discovery triggered this question}

**Decision Needed:** {What architectural choice must be made}

**Options:**
A) {Option A} — {pros/cons summary}
B) {Option B} — {pros/cons summary}
C) {Option C} — {pros/cons summary}

**Recommendation:** {If architect has a preference, state it with reasoning}

**Impact:** {What this decision affects}
```

## Progress Tracking

```
ARCHITECTURE CLARITY

Questions asked: 5 (this round)
Total questions: 10

Clarity Score: 65%
█████████████░░░░░░░░

Areas covered:
✓ System architecture
✓ Database selection
◐ API design (partial)
○ Security model
○ Infrastructure

Remaining decisions: 3 blocking

Continue with next 5 questions? [Y/n/focus on specific area]
```

## Clarity Thresholds

| Score | Status | Action |
|-------|--------|--------|
| 0-40% | Critical gaps | Cannot proceed with design |
| 41-60% | Significant gaps | Recommend continuing |
| 61-80% | Good coverage | Can start high-level design |
| 81-100% | Excellent | Ready for detailed design |

## Output Requirements

After questions are answered:
1. Document all decisions in ADR format
2. Update architecture document
3. Create component diagram
4. List remaining open questions
5. Prepare handoff notes

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Better Approach |
|--------------|----------------|-----------------|
| Generic questions | Wastes time | Context-specific questions |
| Too many questions | Overwhelms stakeholder | Max 5 per round |
| No options provided | Puts burden on stakeholder | Offer 2-3 options with analysis |
| No recommendations | Abdicates expertise | State preference with reasoning |
| Skip progress check | No visibility | Show clarity score after each round |
