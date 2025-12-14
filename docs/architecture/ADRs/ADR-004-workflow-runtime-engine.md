# ADR-004: Workflow Runtime Engine Design Decisions

## Status

**PROPOSED** - Pending review by PRODUCT-OWNER and SENIOR-DEV

---

## Context

The Agent Methodology Pack currently has 8 YAML workflow definitions that are executed **manually** by following ORCHESTRATOR.md patterns. This works for simple cases but has significant limitations:

1. **Manual execution error-prone** - Humans must remember phase order, gates, and transitions
2. **No state persistence** - Workflow progress lost on session end
3. **No rollback capability** - Mistakes require manual intervention
4. **No parallel coordination** - Manual tracking of multi-track execution
5. **Limited visibility** - No dashboard or progress tracking
6. **No pause/resume** - Cannot interrupt and continue later

Feature #4 (Workflow Runtime Engine) from the roadmap addresses these issues by automating YAML workflow execution. This is the **foundation for 60% of future features** including:
- Auto-Healing Workflows (#5)
- Agent Collaboration Mode (#1)
- CI/CD Integration (#6)
- Workflow Analytics Dashboard (#10)
- Natural Language Workflows (#3)

This ADR documents the key design decisions for the Runtime Engine.

---

## Decision 1: Python with Stdlib-Only (One Exception)

### Decision

Implement the Runtime Engine in **Python 3.10+** using only standard library modules, with one exception: `pyyaml` for YAML parsing.

### Rationale

| Factor | Python + Stdlib | TypeScript | Go |
|--------|-----------------|------------|-----|
| MCP Cache Compatibility | Native (existing server.py) | Requires bridge | Requires bridge |
| Claude Code Integration | Direct execution | Build step needed | Build step needed |
| Development Speed | Highest (no setup) | Medium | Medium |
| Type Safety | Adequate (dataclasses) | Excellent | Excellent |
| Dependency Management | Minimal | npm complexity | Modules |
| Team Familiarity | Known (cache server) | Known | Unknown |

**Why stdlib-only:**
- Eliminates dependency hell
- Works in any Python environment
- Easier to vendor/embed
- Reduces attack surface

**Why pyyaml exception:**
- YAML parsing is core functionality
- Stdlib has no YAML support
- pyyaml is ubiquitous, stable, well-tested
- Can be vendored if needed

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| TypeScript | Type safety, modern | Build step, separate from MCP cache | Added complexity |
| Go | Performance, single binary | Learning curve, harder Claude integration | Over-engineered |
| Pure Python (no pyyaml) | Zero dependencies | Must implement YAML parser | Not worth the effort |
| Rust | Performance, safety | Overkill for workflow engine | Too complex |

### Consequences

**Positive:**
- Single language for cache + runtime
- No build toolchain
- Direct Claude Code execution
- Simple deployment

**Negative:**
- Python performance limitations (acceptable for workflow orchestration)
- Dynamic typing requires discipline
- pyyaml must be available

---

## Decision 2: Task Tool for Agent Invocation (No Direct API)

### Decision

The Runtime Engine invokes agents **exclusively through Claude's Task tool**. It never makes direct API calls to Claude or other LLMs.

### Rationale

The Runtime Engine runs **within** Claude Code sessions. It doesn't have direct API access - that's handled by Claude Code itself. The engine generates Task tool call structures that ORCHESTRATOR executes.

**Flow:**
```
Runtime Engine                  ORCHESTRATOR                    Agent
      |                              |                            |
      | 1. Generate Task call        |                            |
      |----------------------------->|                            |
      |                              | 2. Execute Task tool       |
      |                              |--------------------------->|
      |                              |                            |
      |                              | 3. Return result           |
      |                              |<---------------------------|
      | 4. Process result            |                            |
      |<-----------------------------|                            |
```

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| Direct API calls | Full control | Requires API keys, breaks Claude Code model | Not how Claude Code works |
| MCP tool for agents | Standardized | Requires new MCP server, complexity | Over-engineering |
| Subprocess agents | Isolation | No Claude context, separate sessions | Loses conversation state |

### Consequences

**Positive:**
- Works within existing Claude Code paradigm
- No API key management
- Leverages Claude's multi-agent via Task tool
- Maintains conversation context

**Negative:**
- Dependent on ORCHESTRATOR cooperation
- Cannot run headless (requires Claude Code session)
- Async execution limited by Task tool

---

## Decision 3: File-Based State Persistence (JSON + Markdown)

### Decision

Workflow state persists to **two file formats**:
1. `.claude/state/workflow-state.json` - Machine-readable, for recovery
2. `.claude/state/WORKFLOW-STATE.md` - Human-readable, for visibility

### Rationale

**JSON for machines:**
- Fast parsing
- Precise state representation
- Easy programmatic access
- Atomic updates via temp file + rename

**Markdown for humans:**
- Visible in Claude Code file browser
- Readable without tooling
- Matches existing state file patterns (HANDOFFS.md, AGENT-STATE.md)
- Can be committed to git

**Dual format benefits:**
- Best of both worlds
- Markdown regenerated from JSON (JSON is source of truth)
- Human can inspect progress without running engine

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| JSON only | Simple, fast | Not human-readable | Violates visibility principle |
| Markdown only | Human-readable | Parsing complex, error-prone | Too fragile for recovery |
| SQLite | Queries, transactions | Overkill, binary file | Unnecessary complexity |
| MCP Cache only | Unified storage | Not designed for state | Wrong abstraction |

### Consequences

**Positive:**
- Human visibility via Markdown
- Reliable recovery via JSON
- Git-friendly (both formats)
- Matches existing patterns

**Negative:**
- Two files to maintain
- Potential sync issues (mitigated: JSON is source of truth)
- Slightly more code

---

## Decision 4: Event-Driven Callbacks (Observer Pattern)

### Decision

The Runtime Engine uses an **event-driven callback system** for extensibility. Users register callbacks for events they care about.

```python
runtime.execute(workflow, callbacks={
    "on_phase_start": lambda e: print(f"Starting: {e.phase}"),
    "on_gate_check": lambda e: log_gate(e),
    "on_complete": lambda e: notify_user(e)
})
```

### Rationale

**Benefits:**
- Loose coupling between engine and consumers
- Easy to add new event types
- Optional participation (only handle events you need)
- Familiar pattern (DOM events, React hooks)

**Events defined:**
```python
WORKFLOW_STARTED, WORKFLOW_COMPLETED, WORKFLOW_FAILED, WORKFLOW_PAUSED, WORKFLOW_RESUMED
PHASE_STARTED, PHASE_COMPLETED, PHASE_FAILED
GATE_CHECK_STARTED, GATE_PASSED, GATE_FAILED
AGENT_INVOKED, AGENT_COMPLETED, AGENT_FAILED
CHECKPOINT_CREATED, ROLLBACK_STARTED, ROLLBACK_COMPLETED
```

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| Polling API | Simple implementation | Inefficient, laggy | Poor UX |
| Webhook URLs | Decoupled | Requires HTTP server | Overkill |
| Generator/yield | Pythonic | Complex control flow | Hard to understand |
| Log file monitoring | Decoupled | Parsing overhead, delay | Fragile |

### Consequences

**Positive:**
- Clean separation of concerns
- Easy testing (mock callbacks)
- Extensible for dashboards, CI/CD, Slack integration

**Negative:**
- Callback hell if overused
- Error handling in callbacks can be tricky

---

## Decision 5: Checkpoint-Based Rollback (Not Transaction Log)

### Decision

Rollback uses **checkpoint snapshots** rather than a transaction log. Users can rollback to any checkpoint, not just undo individual operations.

**Checkpoints created:**
- Automatically before each phase
- Manually via API
- On pause

### Rationale

**Checkpoint approach:**
- Simpler implementation
- Clear rollback targets
- Storage-efficient (only store state, not operations)
- Matches mental model (restore to point in time)

**Transaction log approach:**
- More granular (undo individual steps)
- Complex implementation
- Storage grows with operations
- Harder to reason about

For workflow orchestration, **phase-level rollback is sufficient**. Users don't need to undo individual agent calls - they need to return to a known-good state and retry.

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| Transaction log | Fine-grained undo | Complex, storage-heavy | Overkill |
| No rollback | Simple | Poor UX on failures | User requirement |
| Git-based | Full history | Commits pollute history | Wrong abstraction |
| Database transactions | ACID | Requires database | Unnecessary dependency |

### Consequences

**Positive:**
- Simple implementation
- Clear semantics
- Storage-efficient
- Easy to understand

**Negative:**
- Cannot undo individual agent calls
- Checkpoints can grow (mitigated: auto-cleanup)

---

## Decision 6: Gate Evaluation via Criterion Functions

### Decision

Gate evaluation uses a **pluggable criterion function system**. Each criterion type (file exists, tests pass, coverage threshold) maps to a function.

```python
CRITERION_EVALUATORS = {
    "file_exists": evaluate_file_exists,      # Check @path exists
    "tests_pass": evaluate_tests_pass,        # Run pytest, check exit 0
    "coverage": evaluate_coverage,            # Parse coverage, check threshold
    "approval": evaluate_approval,            # Check approval flag
    "custom": evaluate_custom                 # User-defined
}
```

### Rationale

**Benefits:**
- Extensible (add new criterion types)
- Testable (mock individual evaluators)
- Clear responsibility
- Reusable across gates

**Built-in evaluators:**
| Criterion Pattern | Evaluator | Example |
|-------------------|-----------|---------|
| `@path/to/file exists` | file_exists | `@docs/prd.md exists` |
| `All tests pass` | tests_pass | Runs pytest |
| `Coverage >= N%` | coverage | Parses coverage.xml |
| `{Role} approved` | approval | Checks state file |
| `No {type} vulnerabilities` | security_scan | Runs security tool |

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| Regex-only parsing | Flexible | Hard to extend, fragile | Not maintainable |
| Hard-coded gates | Simple | Not extensible | Won't scale |
| External gate service | Decoupled | Over-engineering | Unnecessary complexity |

### Consequences

**Positive:**
- Easy to add new criterion types
- Unit testable
- Clear contracts

**Negative:**
- Must maintain evaluator registry
- Custom criteria need implementation

---

## Decision 7: Parallel Execution via Phase-Level Parallelism

### Decision

Parallelism happens at **step level within phases** (e.g., frontend + backend in parallel), not at **phase level** (phases are sequential).

```yaml
phases:
  - id: implementation
    parallel:                    # Parallel within phase
      - agent: BACKEND-DEV
      - agent: FRONTEND-DEV
    gate:
      criteria:
        - "All tests pass"       # Wait for both before gate
```

### Rationale

**Why not phase-level parallelism:**
- Phases have dependencies (design before implementation)
- Gates enforce this naturally
- Parallel phases would bypass gates

**Why step-level parallelism:**
- Independent work can proceed simultaneously
- Matches real-world patterns (FE/BE parallel after API spec)
- Gates still enforce quality

**Implementation:**
- Engine tracks parallel steps independently
- Gate waits for ALL parallel steps
- If any fails, phase fails

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| Phase-level parallel | Maximum parallelism | Breaks gate model | Dangerous |
| Sequential only | Simple | Slow, doesn't match reality | Poor UX |
| DAG-based | Maximum flexibility | Complex implementation | Overkill for v1 |

### Consequences

**Positive:**
- Safe parallelism
- Gates still meaningful
- Matches existing workflow patterns

**Negative:**
- Less flexible than full DAG
- Cannot run unrelated phases in parallel (future enhancement)

---

## Decision 8: YAML Schema with Backward Compatibility

### Decision

Support **both legacy and enhanced YAML format** with automatic schema detection.

**Schema versioning:**
```yaml
# Explicit version (recommended)
schema_version: "1.0"

# Or detected by feature presence
# (v1.0 features: phases, gates, error_recovery)
```

### Rationale

Existing 8 workflows must continue working without modification. New features (pause/resume, rollback) are additive.

**Approach:**
1. Detect schema version from content
2. Parse accordingly
3. Normalize to internal representation
4. Execute uniformly

### Alternatives Considered

| Alternative | Pros | Cons | Why Not Chosen |
|-------------|------|------|----------------|
| Breaking change | Clean slate | Requires migration | User friction |
| Migration tool | Automated update | Still requires action | Extra step |
| Parallel formats | Clear separation | Maintenance burden | Confusing |

### Consequences

**Positive:**
- Zero migration required
- Existing workflows work immediately
- Gradual enhancement

**Negative:**
- Schema detection complexity
- Must support legacy indefinitely

---

## Implementation Notes

### File Structure

```
.claude/
  runtime/
    __init__.py
    engine.py          # WorkflowEngine
    parser.py          # YAMLParser
    state_machine.py   # StateMachine
    gate_checker.py    # GateChecker
    agent_invoker.py   # AgentInvoker
    progress.py        # ProgressTracker
    pause_resume.py    # PauseResumeManager
    rollback.py        # RollbackHandler
    events.py          # EventDispatcher
    types.py           # Data classes
    api.py             # Public WorkflowRuntime API
    criteria/
      __init__.py
      file_exists.py
      tests_pass.py
      coverage.py
      approval.py
```

### Testing Strategy

1. **Unit tests:** Each component in isolation
2. **Integration tests:** Full workflow execution with mock agents
3. **E2E tests:** Real workflow with actual agent invocation (manual)

### Rollout Plan

1. **Week 1-2:** Core engine + parser + state machine
2. **Week 3:** Gate checker with built-in criteria
3. **Week 4:** Agent invoker + Task tool integration
4. **Week 5:** Pause/Resume + Rollback
5. **Week 6:** Polish, docs, testing

---

## Related Documents

- [WORKFLOW-RUNTIME-ENGINE-ARCHITECTURE.md](../WORKFLOW-RUNTIME-ENGINE-ARCHITECTURE.md) - Full architecture
- [FUTURE-FEATURES-ROADMAP.md](../../FUTURE-FEATURES-ROADMAP.md) - Feature #4 definition
- [TECHNICAL-FEASIBILITY-ANALYSIS.md](../../TECHNICAL-FEASIBILITY-ANALYSIS.md) - Complexity analysis
- [ORCHESTRATOR.md](../../../.claude/agents/ORCHESTRATOR.md) - Integration point

---

## Review Checklist

- [ ] PRODUCT-OWNER: Requirements coverage validated
- [ ] SENIOR-DEV: Technical approach approved
- [ ] ARCHITECT-AGENT: Self-review complete
- [ ] Security considerations reviewed
- [ ] Performance requirements met
- [ ] Backward compatibility confirmed

---

**Document End**

*Created: 2025-12-14*
*Author: ARCHITECT-AGENT*
*Status: PROPOSED*
