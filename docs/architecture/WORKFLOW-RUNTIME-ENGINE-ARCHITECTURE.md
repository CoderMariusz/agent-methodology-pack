# Workflow Runtime Engine Architecture

> **Document Type:** Architecture Overview
> **Version:** 1.0.0
> **Date:** 2025-12-14
> **Author:** ARCHITECT-AGENT
> **Status:** PROPOSED
> **Feature:** #4 - Workflow Runtime Engine

---

## Executive Summary

The Workflow Runtime Engine transforms static YAML workflow definitions into executable pipelines. It is the foundational component for 60% of planned future features, including Auto-Healing Workflows, Agent Collaboration Mode, and CI/CD Integration.

**Core Capabilities:**
- Parse YAML workflow definitions into executable state machines
- Invoke agents in sequence using Claude's Task tool
- Enforce quality gates with real-time validation
- Track progress with persistence and recovery
- Support pause/resume and rollback operations

**Constraints:**
- Must work with existing 20 agents (no modifications required)
- Uses Task tool exclusively (no direct API calls)
- Under 3,000 lines of Python code
- Python stdlib only (no external dependencies)

---

## 1. System Architecture Overview

### 1.1 High-Level Architecture

```
+------------------------------------------------------------------+
|                    WORKFLOW RUNTIME ENGINE                        |
+------------------------------------------------------------------+
|                                                                    |
|  +----------------+     +-----------------+     +---------------+  |
|  |   YAML Parser  |---->|  Workflow       |---->|    Agent      |  |
|  |   & Validator  |     |  Engine         |     |    Invoker    |  |
|  +----------------+     +-----------------+     +-------+-------+  |
|         |                       |                       |          |
|         v                       v                       v          |
|  +----------------+     +-----------------+     +---------------+  |
|  |   Schema       |     |   State         |     |    Task       |  |
|  |   Registry     |     |   Machine       |     |    Tool       |  |
|  +----------------+     +--------+--------+     +---------------+  |
|                                  |                                 |
|                                  v                                 |
|                         +-----------------+                        |
|                         |   Gate Checker  |                        |
|                         +-----------------+                        |
|                                  |                                 |
|  +----------------+     +--------+--------+     +---------------+  |
|  |   Progress     |<----|   Event         |---->|   Pause/      |  |
|  |   Tracker      |     |   Dispatcher    |     |   Resume      |  |
|  +----------------+     +-----------------+     +---------------+  |
|         |                       |                                  |
|         v                       v                                 |
|  +----------------+     +-----------------+                        |
|  |   State        |     |   Rollback      |                        |
|  |   Persistence  |     |   Handler       |                        |
|  +----------------+     +-----------------+                        |
|                                                                    |
+------------------------------------------------------------------+
                                  |
                                  v
+------------------------------------------------------------------+
|                      EXTERNAL INTERFACES                          |
+------------------------------------------------------------------+
|  +----------------+     +-----------------+     +---------------+  |
|  |   MCP Cache    |     |   State Files   |     |   Agent       |  |
|  |   Server       |     |   (Markdown)    |     |   Definitions |  |
|  +----------------+     +-----------------+     +---------------+  |
+------------------------------------------------------------------+
```

### 1.2 Component Interaction Flow

```
User Request
     |
     v
+------------------+
| ORCHESTRATOR.md  |  (entry point - delegates to engine)
+--------+---------+
         |
         v
+------------------+
|  WorkflowEngine  |  (core coordinator)
+--------+---------+
         |
    +----+----+
    |         |
    v         v
+-------+  +-------+
| Parse |  | Load  |
| YAML  |  | State |
+---+---+  +---+---+
    |          |
    +----+-----+
         |
         v
+------------------+
|  Execute Phase   |
+--------+---------+
         |
    +----+----+----+----+
    |         |         |
    v         v         v
+-------+ +-------+ +-------+
| Check | | Invoke| | Update|
| Gate  | | Agent | | State |
+---+---+ +---+---+ +---+---+
    |         |         |
    +----+----+----+----+
         |
         v
+------------------+
|  Event Dispatch  |
+--------+---------+
         |
    +----+----+----+
    |         |    |
    v         v    v
+-------+ +------+ +--------+
|Progress| |Pause | |Rollback|
|Tracker | |Resume| |Handler |
+-------+ +------+ +--------+
```

---

## 2. Core Components Design

### 2.1 YAML Parser & Validator

**Purpose:** Parse YAML workflow definitions and validate against schema.

**Responsibilities:**
- Load YAML files from `.claude/workflows/definitions/`
- Validate structure against workflow schema
- Resolve `extends` and `use_fragment` references
- Build internal workflow representation

**Input:** YAML file path
**Output:** `WorkflowDefinition` object

```python
class YAMLParser:
    """
    Parse and validate YAML workflow definitions.

    Schema validation ensures:
    - Required fields present (name, phases, gates)
    - Agent references valid
    - Gate criteria defined
    - No circular dependencies
    """

    def parse(self, yaml_path: str) -> WorkflowDefinition:
        """Parse YAML file into workflow definition."""

    def validate_schema(self, data: dict) -> ValidationResult:
        """Validate against workflow schema."""

    def resolve_inheritance(self, data: dict) -> dict:
        """Resolve extends and fragment references."""
```

**Schema (Simplified):**
```yaml
# Workflow Schema v1.0
name: string          # Required
description: string   # Required
trigger: string       # Optional
prerequisites: []     # Optional

phases:               # Required, non-empty
  - id: string        # Required, unique
    name: string      # Required
    mandatory: bool   # Default: true
    steps: []         # Or parallel: []
    gate:             # Optional
      name: string
      type: enum      # APPROVAL_GATE, TEST_GATE, QUALITY_GATE, REVIEW_GATE
      criteria: []    # Required if gate present
      next: string    # Phase ID to transition to

error_recovery: {}    # Optional
artifacts: {}         # Optional
```

### 2.2 Workflow Engine

**Purpose:** Central coordinator that executes workflows as state machines.

**Responsibilities:**
- Manage workflow lifecycle (create, start, pause, resume, cancel)
- Coordinate phase transitions
- Handle parallel execution within phases
- Dispatch events to subscribers

```python
class WorkflowEngine:
    """
    Core execution engine for workflows.

    Lifecycle:
    CREATED -> RUNNING -> (PAUSED) -> COMPLETED | FAILED
    """

    def __init__(self, config: EngineConfig):
        self.parser = YAMLParser()
        self.state_machine = StateMachine()
        self.gate_checker = GateChecker()
        self.agent_invoker = AgentInvoker()
        self.progress_tracker = ProgressTracker()
        self.event_dispatcher = EventDispatcher()

    def load(self, workflow_path: str) -> WorkflowInstance:
        """Load workflow definition and create instance."""

    def execute(self, instance: WorkflowInstance,
                callbacks: WorkflowCallbacks) -> ExecutionResult:
        """Execute workflow with event callbacks."""

    def pause(self, instance_id: str) -> bool:
        """Pause running workflow."""

    def resume(self, instance_id: str) -> bool:
        """Resume paused workflow."""

    def cancel(self, instance_id: str) -> bool:
        """Cancel workflow (cannot resume)."""

    def get_status(self, instance_id: str) -> WorkflowStatus:
        """Get current workflow status."""
```

### 2.3 State Machine

**Purpose:** Manage workflow and phase states with transition rules.

**States:**
```
WorkflowState:
  CREATED     -> RUNNING (on start)
  RUNNING     -> PAUSED (on pause request)
  RUNNING     -> COMPLETED (all phases done, all gates passed)
  RUNNING     -> FAILED (unrecoverable error)
  PAUSED      -> RUNNING (on resume)
  PAUSED      -> CANCELLED (on cancel)

PhaseState:
  PENDING     -> ACTIVE (when reached in sequence)
  ACTIVE      -> WAITING_GATE (steps complete, gate check needed)
  WAITING_GATE -> PASSED (gate criteria met)
  WAITING_GATE -> FAILED (gate criteria not met)
  FAILED      -> ACTIVE (on retry after error recovery)
  PASSED      -> [next phase ACTIVE]
```

```python
class StateMachine:
    """
    Finite state machine for workflow execution.

    Tracks:
    - Current workflow state
    - Current phase
    - Phase history
    - Transition timestamps
    """

    def transition(self, from_state: State, event: Event) -> State:
        """Execute state transition if valid."""

    def can_transition(self, from_state: State, event: Event) -> bool:
        """Check if transition is valid."""

    def get_valid_transitions(self, state: State) -> List[Event]:
        """Get list of valid events for current state."""
```

### 2.4 Gate Checker

**Purpose:** Evaluate gate criteria to determine if phase can proceed.

**Gate Types:**
| Type | Enforcer | Validation Method |
|------|----------|-------------------|
| APPROVAL_GATE | Product Owner, Architect | Manual approval flag |
| TEST_GATE | Test Engineer | Test execution results |
| QUALITY_GATE | QA Agent, Senior Dev | Quality metrics check |
| REVIEW_GATE | Code Reviewer | Review approval status |

```python
class GateChecker:
    """
    Evaluate quality gates to control phase transitions.

    Checks:
    - File existence (e.g., docs exist)
    - Test results (via test runner)
    - Manual approval flags
    - Quality metrics thresholds
    """

    def evaluate(self, gate: GateDefinition,
                 context: ExecutionContext) -> GateResult:
        """Evaluate all criteria for a gate."""

    def check_criterion(self, criterion: str,
                       context: ExecutionContext) -> CriterionResult:
        """Evaluate single criterion."""

    def request_approval(self, gate: GateDefinition,
                        approver: str) -> ApprovalRequest:
        """Create approval request for manual gates."""
```

**Criterion Evaluation Examples:**
```python
# File existence check
"@docs/1-BASELINE/product/prd.md exists" -> check file exists

# Test results
"All tests pass" -> run pytest, check exit code 0

# Quality metrics
"Coverage >= 80%" -> parse coverage report

# Manual approval
"Product Owner approved" -> check approval flag in state
```

### 2.5 Agent Invoker

**Purpose:** Invoke agents using Claude's Task tool with proper context.

**Critical Design Decision:** Use Task tool exclusively, never direct API calls.

```python
class AgentInvoker:
    """
    Invoke agents via Task tool for workflow execution.

    Responsibilities:
    - Build agent invocation prompt
    - Provide context references (not content)
    - Capture agent output
    - Track execution metrics
    """

    def invoke(self, agent_name: str,
               step: StepDefinition,
               context: ExecutionContext) -> InvocationResult:
        """
        Invoke agent via Task tool.

        Returns InvocationResult with:
        - status: success | failed | blocked | needs_input
        - summary: Agent's response summary
        - deliverables: List of file paths created
        - duration: Execution time
        - tokens_used: Approximate token count
        """

    def build_prompt(self, agent_name: str,
                     step: StepDefinition,
                     context: ExecutionContext) -> str:
        """Build Task tool prompt for agent."""
```

**Task Tool Invocation Pattern:**
```python
def invoke(self, agent_name: str, step: StepDefinition,
           context: ExecutionContext) -> InvocationResult:
    """
    Invoke agent using Task tool.

    NOTE: This method generates the Task tool call structure.
    The actual execution happens through Claude's Task tool.
    """

    prompt = self.build_prompt(agent_name, step, context)

    # Task tool call structure (for ORCHESTRATOR to execute)
    task_call = {
        "tool": "Task",
        "agent": f"@.claude/agents/{agent_name.upper()}.md",
        "prompt": prompt,
        "context_refs": step.input.get("context_refs", []),
        "max_tokens": step.get("max_tokens", 100000)
    }

    return task_call  # ORCHESTRATOR executes this
```

### 2.6 Progress Tracker

**Purpose:** Track and persist workflow progress for recovery and reporting.

```python
class ProgressTracker:
    """
    Track workflow execution progress.

    Persists to:
    - .claude/state/WORKFLOW-STATE.md (human-readable)
    - .claude/state/workflow-state.json (machine-readable)
    """

    def update(self, instance_id: str,
               phase_id: str,
               status: PhaseStatus,
               metrics: Optional[dict] = None):
        """Update progress for a phase."""

    def get_progress(self, instance_id: str) -> WorkflowProgress:
        """Get current progress summary."""

    def save_checkpoint(self, instance_id: str) -> str:
        """Save checkpoint for recovery. Returns checkpoint ID."""

    def restore_checkpoint(self, checkpoint_id: str) -> WorkflowInstance:
        """Restore workflow from checkpoint."""
```

**Progress State File Format (WORKFLOW-STATE.md):**
```markdown
# Workflow State

**Instance:** epic-workflow-2025-12-14-001
**Workflow:** epic-workflow
**Status:** RUNNING
**Started:** 2025-12-14 10:00:00
**Current Phase:** implementation
**Progress:** 45%

## Phase Status

| Phase | Status | Started | Duration | Agent | Gate |
|-------|--------|---------|----------|-------|------|
| discovery | PASSED | 10:00 | 45m | RESEARCH-AGENT | PRD Review: PASSED |
| design | PASSED | 10:45 | 1h 30m | ARCHITECT-AGENT | Design Review: PASSED |
| planning | PASSED | 12:15 | 30m | PRODUCT-OWNER | Sprint Ready: PASSED |
| implementation | ACTIVE | 12:45 | - | BACKEND-DEV | - |
| quality | PENDING | - | - | - | - |
| documentation | PENDING | - | - | - | - |
| deployment | PENDING | - | - | - | - |

## Active Tasks

| Track | Story | Agent | Phase | Started |
|-------|-------|-------|-------|---------|
| A | E1-S1.1 | BACKEND-DEV | GREEN | 12:45 |
| B | E1-S1.2 | TEST-WRITER | RED | 12:45 |

## Checkpoints

| ID | Phase | Timestamp | Reason |
|----|-------|-----------|--------|
| CP-001 | design | 12:15 | Pre-implementation |
```

### 2.7 Pause/Resume Manager

**Purpose:** Handle workflow pause and resume with state preservation.

```python
class PauseResumeManager:
    """
    Manage workflow pause and resume operations.

    On Pause:
    - Save current state checkpoint
    - Mark active tasks as PAUSED
    - Persist to state file
    - Notify callbacks

    On Resume:
    - Restore from checkpoint
    - Resume paused tasks
    - Continue from last position
    """

    def pause(self, instance: WorkflowInstance,
              reason: str) -> PauseResult:
        """Pause workflow execution."""

    def resume(self, instance_id: str) -> ResumeResult:
        """Resume paused workflow."""

    def can_pause(self, instance: WorkflowInstance) -> bool:
        """Check if workflow can be paused."""

    def can_resume(self, instance_id: str) -> bool:
        """Check if workflow can be resumed."""
```

### 2.8 Rollback Handler

**Purpose:** Revert workflow to previous checkpoint on failure.

```python
class RollbackHandler:
    """
    Handle workflow rollback operations.

    Rollback Types:
    - Phase rollback: Return to start of current phase
    - Checkpoint rollback: Return to saved checkpoint
    - Full rollback: Return to workflow start
    """

    def rollback_to_checkpoint(self, instance_id: str,
                               checkpoint_id: str) -> RollbackResult:
        """Rollback to specific checkpoint."""

    def rollback_phase(self, instance_id: str) -> RollbackResult:
        """Rollback current phase to start."""

    def get_rollback_options(self, instance_id: str) -> List[RollbackOption]:
        """Get available rollback points."""
```

### 2.9 Event Dispatcher

**Purpose:** Dispatch workflow events to registered callbacks.

**Events:**
```python
class WorkflowEvent(Enum):
    WORKFLOW_STARTED = "workflow_started"
    WORKFLOW_COMPLETED = "workflow_completed"
    WORKFLOW_FAILED = "workflow_failed"
    WORKFLOW_PAUSED = "workflow_paused"
    WORKFLOW_RESUMED = "workflow_resumed"

    PHASE_STARTED = "phase_started"
    PHASE_COMPLETED = "phase_completed"
    PHASE_FAILED = "phase_failed"

    GATE_CHECK_STARTED = "gate_check_started"
    GATE_PASSED = "gate_passed"
    GATE_FAILED = "gate_failed"

    AGENT_INVOKED = "agent_invoked"
    AGENT_COMPLETED = "agent_completed"
    AGENT_FAILED = "agent_failed"

    CHECKPOINT_CREATED = "checkpoint_created"
    ROLLBACK_STARTED = "rollback_started"
    ROLLBACK_COMPLETED = "rollback_completed"
```

```python
class EventDispatcher:
    """
    Dispatch events to registered callbacks.

    Usage:
    dispatcher.on(WorkflowEvent.PHASE_STARTED, my_callback)
    dispatcher.emit(WorkflowEvent.PHASE_STARTED, phase_data)
    """

    def on(self, event: WorkflowEvent,
           callback: Callable[[EventData], None]):
        """Register callback for event."""

    def off(self, event: WorkflowEvent,
            callback: Callable[[EventData], None]):
        """Unregister callback."""

    def emit(self, event: WorkflowEvent, data: EventData):
        """Emit event to all registered callbacks."""
```

---

## 3. API Design

### 3.1 Public API Surface

```python
# Main entry point
class WorkflowRuntime:
    """
    Public API for Workflow Runtime Engine.

    Usage:
        runtime = WorkflowRuntime()

        # Load and execute workflow
        workflow = runtime.load("epic-workflow.yaml")
        result = runtime.execute(workflow, callbacks={
            "on_phase_start": handle_phase_start,
            "on_gate_check": handle_gate_check,
            "on_agent_invoke": handle_agent_invoke,
            "on_complete": handle_complete
        })

        # Real-time status
        status = runtime.get_status(workflow.id)
        # -> { phase: "implementation", progress: 65, agents: [...] }

        # Control operations
        runtime.pause(workflow.id)
        runtime.resume(workflow.id)
        runtime.rollback(workflow.id, checkpoint="CP-001")
    """

    # Workflow Management
    def load(self, workflow_path: str) -> Workflow
    def execute(self, workflow: Workflow, callbacks: dict) -> ExecutionResult
    def get_status(self, workflow_id: str) -> WorkflowStatus

    # Control Operations
    def pause(self, workflow_id: str) -> bool
    def resume(self, workflow_id: str) -> bool
    def cancel(self, workflow_id: str) -> bool
    def rollback(self, workflow_id: str, checkpoint: str) -> RollbackResult

    # Checkpoints
    def create_checkpoint(self, workflow_id: str, name: str) -> str
    def list_checkpoints(self, workflow_id: str) -> List[Checkpoint]
    def delete_checkpoint(self, checkpoint_id: str) -> bool

    # Dry Run
    def dry_run(self, workflow_path: str) -> DryRunResult
```

### 3.2 Callback Interface

```python
class WorkflowCallbacks:
    """
    Callback interface for workflow events.

    All callbacks are optional. Provide only those you need.
    """

    # Workflow lifecycle
    on_workflow_start: Callable[[WorkflowStartEvent], None]
    on_workflow_complete: Callable[[WorkflowCompleteEvent], None]
    on_workflow_fail: Callable[[WorkflowFailEvent], None]
    on_workflow_pause: Callable[[WorkflowPauseEvent], None]
    on_workflow_resume: Callable[[WorkflowResumeEvent], None]

    # Phase lifecycle
    on_phase_start: Callable[[PhaseStartEvent], None]
    on_phase_complete: Callable[[PhaseCompleteEvent], None]
    on_phase_fail: Callable[[PhaseFailEvent], None]

    # Gate checking
    on_gate_check: Callable[[GateCheckEvent], None]
    on_gate_pass: Callable[[GatePassEvent], None]
    on_gate_fail: Callable[[GateFailEvent], None]

    # Agent invocation
    on_agent_invoke: Callable[[AgentInvokeEvent], None]
    on_agent_complete: Callable[[AgentCompleteEvent], None]
    on_agent_fail: Callable[[AgentFailEvent], None]

    # Progress updates
    on_progress_update: Callable[[ProgressUpdateEvent], None]

    # Checkpoint/Rollback
    on_checkpoint_create: Callable[[CheckpointCreateEvent], None]
    on_rollback: Callable[[RollbackEvent], None]
```

### 3.3 Data Types

```python
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from typing import List, Dict, Optional, Any

class WorkflowState(Enum):
    CREATED = "created"
    RUNNING = "running"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

class PhaseState(Enum):
    PENDING = "pending"
    ACTIVE = "active"
    WAITING_GATE = "waiting_gate"
    PASSED = "passed"
    FAILED = "failed"
    SKIPPED = "skipped"

class GateType(Enum):
    APPROVAL_GATE = "approval"
    TEST_GATE = "test"
    QUALITY_GATE = "quality"
    REVIEW_GATE = "review"

@dataclass
class WorkflowStatus:
    """Real-time workflow status."""
    id: str
    name: str
    state: WorkflowState
    current_phase: str
    progress_percent: float
    started_at: datetime
    elapsed_time: str
    active_agents: List[str]
    completed_phases: List[str]
    pending_phases: List[str]
    last_gate_result: Optional[str]
    checkpoints: List[str]

@dataclass
class ExecutionResult:
    """Final workflow execution result."""
    success: bool
    workflow_id: str
    state: WorkflowState
    total_duration: str
    phases_completed: int
    phases_total: int
    gates_passed: int
    gates_failed: int
    agents_invoked: int
    deliverables: List[str]
    errors: List[str]
    metrics: Dict[str, Any]

@dataclass
class DryRunResult:
    """Result of workflow dry run (simulation)."""
    valid: bool
    phases: List[str]
    gates: List[str]
    agents: List[str]
    estimated_duration: str
    estimated_cost: float
    potential_blockers: List[str]
    validation_errors: List[str]
```

---

## 4. State Machine Design

### 4.1 Workflow State Diagram

```
                    +---------------+
                    |    CREATED    |
                    +-------+-------+
                            |
                            | start()
                            v
+----------+        +-------+-------+        +-----------+
|  PAUSED  |<-------|    RUNNING    |------->| COMPLETED |
+----+-----+  pause |               | success+-----------+
     |              +-------+-------+
     | resume()             |
     |                      | error (unrecoverable)
     v                      v
+----------+        +-------+-------+
|  PAUSED  |------->|    FAILED     |
+----------+ cancel +---------------+
     |
     | cancel()
     v
+-----------+
| CANCELLED |
+-----------+
```

### 4.2 Phase State Diagram

```
+----------+
|  PENDING |
+----+-----+
     |
     | (previous phase PASSED)
     v
+----------+     steps complete     +-------------+
|  ACTIVE  |----------------------->| WAITING_GATE|
+----+-----+                        +------+------+
     ^                                     |
     |                           +---------+---------+
     |                           |                   |
     | retry                     | gate passed       | gate failed
     |                           v                   v
     |                    +------+------+     +------+------+
     +--------------------+   PASSED    |     |   FAILED    |
          (error recovery)+-------------+     +------+------+
                                                     |
                                                     | (if mandatory)
                                                     v
                                              [Workflow FAILED]
```

### 4.3 Gate Evaluation Logic

```python
def evaluate_gate(gate: GateDefinition, context: ExecutionContext) -> GateResult:
    """
    Evaluate gate criteria.

    Returns:
    - PASSED: All criteria met, can proceed
    - FAILED: Criteria not met, cannot proceed
    - PENDING: Waiting for manual approval
    """

    results = []
    for criterion in gate.criteria:
        result = evaluate_criterion(criterion, context)
        results.append(result)

        # Short-circuit on failure (unless all criteria needed for reporting)
        if not result.passed and gate.fail_fast:
            return GateResult(
                status=GateStatus.FAILED,
                criterion_results=results,
                message=f"Failed: {criterion}"
            )

    # Check if all passed
    if all(r.passed for r in results):
        return GateResult(
            status=GateStatus.PASSED,
            criterion_results=results,
            message="All criteria met"
        )

    # Check for pending approvals
    pending = [r for r in results if r.status == CriterionStatus.PENDING]
    if pending:
        return GateResult(
            status=GateStatus.PENDING,
            criterion_results=results,
            message=f"Waiting for: {', '.join(p.criterion for p in pending)}"
        )

    # Some failed
    failed = [r for r in results if not r.passed]
    return GateResult(
        status=GateStatus.FAILED,
        criterion_results=results,
        message=f"Failed criteria: {', '.join(f.criterion for f in failed)}"
    )
```

### 4.4 Error Recovery Paths

```
Error Detected
     |
     v
+----+----+
| Classify|
| Error   |
+----+----+
     |
     +------------------+------------------+
     |                  |                  |
     v                  v                  v
[RECOVERABLE]     [NEEDS_INPUT]      [FATAL]
     |                  |                  |
     v                  v                  v
+----------+      +----------+      +----------+
| Execute  |      | Route to |      | Rollback |
| Recovery |      | Agent    |      | & Fail   |
| Action   |      | Discovery|      +----------+
+----+-----+      +----+-----+
     |                  |
     v                  v
[Retry Phase]    [Wait for Input]
```

**Error Classification:**
```python
ERROR_RECOVERY_MAP = {
    "unclear_requirements": {
        "action": "return_to_discovery",
        "agent": "RESEARCH-AGENT",
        "recoverable": True
    },
    "architecture_conflict": {
        "action": "create_adr",
        "agent": "ARCHITECT-AGENT",
        "recoverable": True
    },
    "tests_failing": {
        "action": "return_to_implementation",
        "agent": "TEST-ENGINEER",
        "recoverable": True
    },
    "security_vulnerability": {
        "action": "immediate_fix",
        "agent": "SENIOR-DEV",
        "recoverable": True,
        "priority": "P0"
    },
    "deployment_failed": {
        "action": "rollback_and_investigate",
        "agent": "DEVOPS-AGENT",
        "recoverable": True
    },
    "unrecoverable_error": {
        "action": "fail_workflow",
        "agent": None,
        "recoverable": False
    }
}
```

---

## 5. Integration Strategy

### 5.1 Integration with ORCHESTRATOR.md

The Runtime Engine integrates with ORCHESTRATOR as a delegation target:

```
User Request: "Execute epic-workflow for authentication feature"
     |
     v
ORCHESTRATOR
     |
     | (recognizes workflow execution request)
     v
WorkflowRuntime.load("epic-workflow.yaml")
     |
     v
WorkflowRuntime.execute(workflow, callbacks)
     |
     | (for each step)
     v
AgentInvoker -> Task tool -> Target Agent
     |
     v
ORCHESTRATOR (continues with next agent in workflow)
```

**ORCHESTRATOR Integration Pattern:**
```python
# In ORCHESTRATOR context
def handle_workflow_request(workflow_name: str, params: dict):
    """
    Handle workflow execution request.

    This is called when user requests workflow execution.
    ORCHESTRATOR delegates to Runtime Engine.
    """

    runtime = WorkflowRuntime()
    workflow = runtime.load(f"{workflow_name}.yaml")

    # Execute with callbacks that report back to user
    result = runtime.execute(workflow, callbacks={
        "on_phase_start": lambda e: report_to_user(f"Starting: {e.phase}"),
        "on_gate_check": lambda e: report_gate_status(e),
        "on_agent_invoke": lambda e: report_agent_activity(e),
        "on_complete": lambda e: report_completion(e)
    })

    return result
```

### 5.2 Task Tool Integration

Agent invocation uses Task tool exclusively:

```python
def invoke_agent_via_task(agent_name: str, step: StepDefinition,
                          context: ExecutionContext) -> str:
    """
    Build Task tool invocation for ORCHESTRATOR.

    The Runtime Engine does NOT execute Task tool directly.
    It generates the Task call structure for ORCHESTRATOR.
    """

    # Build context references (paths only, not content)
    context_refs = step.input.get("context_refs", [])

    # Build prompt for agent
    prompt = f"""
## Task: {step.description}

**Workflow:** {context.workflow_name}
**Phase:** {context.current_phase}
**Step:** {step.id}

### Context Files
{chr(10).join(f'- {ref}' for ref in context_refs)}

### Checkpoint Requirements
{chr(10).join(f'- {cp}' for cp in step.checkpoint)}

### Expected Output
{chr(10).join(f'- {d}' for d in step.output.get('deliverables', []))}

### Instructions
Execute according to your agent definition. Report status when complete.
"""

    # Return Task call structure
    return {
        "tool": "Task",
        "parameters": {
            "agent": f"@.claude/agents/{agent_name}.md",
            "prompt": prompt
        }
    }
```

### 5.3 MCP Cache Integration

Leverage existing MCP cache for performance:

```python
class CacheIntegration:
    """
    Integrate with MCP Cache Server for:
    - Caching expensive agent results
    - Storing workflow state
    - Checkpoint persistence
    """

    def cache_agent_result(self, agent: str, task: str, result: dict):
        """Cache agent result for reuse."""
        key = f"agent:{agent}:task:{task}:{hash(result)}"
        # Uses existing MCP cache server

    def get_cached_result(self, agent: str, task: str) -> Optional[dict]:
        """Check for cached result before agent invocation."""

    def cache_workflow_state(self, instance_id: str, state: dict):
        """Persist workflow state for recovery."""
```

### 5.4 State File Updates

The engine updates these state files:

| File | Updates | Frequency |
|------|---------|-----------|
| `.claude/state/WORKFLOW-STATE.md` | Workflow progress | Every phase transition |
| `.claude/state/AGENT-STATE.md` | Agent activity | Every agent invocation |
| `.claude/state/HANDOFFS.md` | Handoff records | Every agent-to-agent transition |
| `.claude/state/TASK-QUEUE.md` | Pending tasks | When tasks queued/completed |
| `PROJECT-STATE.md` | Project status | On workflow completion |

---

## 6. Technology Stack

### 6.1 Language Choice: Python

**Decision:** Python 3.10+ (stdlib only)

**Rationale:**
1. **Compatibility:** MCP Cache Server already uses Python
2. **Simplicity:** No build step, direct execution
3. **Stdlib sufficiency:**
   - `yaml` parsing via `pyyaml` (single exception - widely available)
   - `json` for data serialization
   - `dataclasses` for type definitions
   - `enum` for state enums
   - `pathlib` for file operations
   - `datetime` for timestamps
   - `hashlib` for checksums
   - `logging` for diagnostics
4. **Claude Code Integration:** Python scripts execute directly

**Single External Dependency:**
- `pyyaml`: Required for YAML parsing (consider vendoring)

### 6.2 File Structure

```
.claude/
  runtime/                          # NEW - Runtime Engine
    __init__.py
    engine.py                       # WorkflowEngine (main)
    parser.py                       # YAMLParser
    state_machine.py                # StateMachine
    gate_checker.py                 # GateChecker
    agent_invoker.py                # AgentInvoker
    progress_tracker.py             # ProgressTracker
    pause_resume.py                 # PauseResumeManager
    rollback.py                     # RollbackHandler
    events.py                       # EventDispatcher + Events
    types.py                        # Data types
    api.py                          # WorkflowRuntime (public API)

    schemas/
      workflow_schema.yaml          # YAML validation schema
      gate_schema.yaml              # Gate definition schema

    state/
      instances/                    # Active workflow instances
        {instance_id}.json
      checkpoints/                  # Saved checkpoints
        {checkpoint_id}.json

  workflows/
    definitions/                    # Existing YAML workflows
      engineering/
        epic-workflow.yaml
        story-delivery.yaml
        feature-flow.yaml
        ...
```

### 6.3 Lines of Code Estimate

| Component | Estimated LOC |
|-----------|---------------|
| engine.py | 250 |
| parser.py | 200 |
| state_machine.py | 180 |
| gate_checker.py | 220 |
| agent_invoker.py | 150 |
| progress_tracker.py | 200 |
| pause_resume.py | 120 |
| rollback.py | 150 |
| events.py | 100 |
| types.py | 200 |
| api.py | 180 |
| schemas/ | 150 |
| **Total** | **2,100** |

**Buffer:** 900 LOC for edge cases, tests, utilities

**Total projected:** ~2,100 LOC (under 3,000 limit)

---

## 7. Data Flow Diagrams

### 7.1 Workflow Execution Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW EXECUTION FLOW                          │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. LOAD PHASE                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                      │
│  │  YAML    │───>│  Parse   │───>│ Validate │                      │
│  │  File    │    │  YAML    │    │ Schema   │                      │
│  └──────────┘    └──────────┘    └────┬─────┘                      │
│                                       │                             │
│                                       v                             │
│  2. INITIALIZE                  ┌──────────┐                        │
│                                 │ Create   │                        │
│                                 │ Instance │                        │
│                                 └────┬─────┘                        │
│                                      │                              │
│                                      v                              │
│  3. EXECUTE LOOP            ┌────────────────┐                      │
│                             │  For Each      │                      │
│                             │  Phase         │                      │
│                             └───────┬────────┘                      │
│                                     │                               │
│         ┌───────────────────────────┼───────────────────────────┐  │
│         │                           │                           │  │
│         v                           v                           v  │
│    ┌─────────┐              ┌──────────────┐             ┌────────┐│
│    │ Check   │              │ Execute      │             │ Check  ││
│    │ Pre-    │──────────────│ Steps        │─────────────│ Gate   ││
│    │ reqs    │              │ (parallel?)  │             │        ││
│    └─────────┘              └──────────────┘             └───┬────┘│
│                                                              │     │
│                                      ┌───────────────────────┤     │
│                                      │                       │     │
│                                      v                       v     │
│                              ┌──────────────┐        ┌───────────┐ │
│                              │   PASSED     │        │  FAILED   │ │
│                              │ (next phase) │        │ (recover) │ │
│                              └──────────────┘        └───────────┘ │
│                                                                     │
│  4. COMPLETE                                                        │
│                             ┌──────────────┐                        │
│                             │   Update     │                        │
│                             │   State      │                        │
│                             └──────────────┘                        │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

### 7.2 Agent Invocation Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                    AGENT INVOCATION FLOW                           │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Runtime Engine                    ORCHESTRATOR                     │
│       │                                 │                           │
│       │  1. Generate Task Call          │                           │
│       │─────────────────────────────────>                           │
│       │                                 │                           │
│       │                                 │  2. Execute Task Tool     │
│       │                                 │───────────────────────┐   │
│       │                                 │                       │   │
│       │                                 │                       v   │
│       │                                 │                 ┌─────────┐
│       │                                 │                 │  Agent  │
│       │                                 │                 │  (e.g.  │
│       │                                 │                 │ BACKEND │
│       │                                 │                 │  -DEV)  │
│       │                                 │                 └────┬────┘
│       │                                 │                      │    │
│       │                                 │  3. Agent Response   │    │
│       │                                 │<─────────────────────┘    │
│       │                                 │                           │
│       │  4. Return Result               │                           │
│       │<─────────────────────────────────                           │
│       │                                 │                           │
│       │  5. Update State                │                           │
│       │────────────────────────┐        │                           │
│       │                        │        │                           │
│       v                        v        │                           │
│  ┌─────────┐            ┌──────────┐    │                           │
│  │Progress │            │ State    │    │                           │
│  │Tracker  │            │ Files    │    │                           │
│  └─────────┘            └──────────┘    │                           │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

### 7.3 Gate Evaluation Flow

```
┌────────────────────────────────────────────────────────────────────┐
│                    GATE EVALUATION FLOW                            │
├────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │                        Gate Definition                         │ │
│  │  type: QUALITY_GATE                                           │ │
│  │  criteria:                                                     │ │
│  │    - "All tests pass"                                         │ │
│  │    - "Coverage >= 80%"                                        │ │
│  │    - "No security vulnerabilities"                            │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                              │                                      │
│                              v                                      │
│                    ┌──────────────────┐                            │
│                    │  For Each        │                            │
│                    │  Criterion       │                            │
│                    └────────┬─────────┘                            │
│                             │                                       │
│           ┌─────────────────┼─────────────────┐                    │
│           │                 │                 │                    │
│           v                 v                 v                    │
│    ┌────────────┐    ┌────────────┐    ┌────────────┐             │
│    │ Evaluate   │    │ Evaluate   │    │ Evaluate   │             │
│    │ "All tests │    │ "Coverage  │    │ "No        │             │
│    │  pass"     │    │  >= 80%"   │    │ security"  │             │
│    └─────┬──────┘    └─────┬──────┘    └─────┬──────┘             │
│          │                 │                 │                     │
│          v                 v                 v                     │
│    ┌────────────┐    ┌────────────┐    ┌────────────┐             │
│    │ Run pytest │    │ Parse      │    │ Run        │             │
│    │ check exit │    │ coverage   │    │ security   │             │
│    │ code       │    │ report     │    │ scan       │             │
│    └─────┬──────┘    └─────┬──────┘    └─────┬──────┘             │
│          │                 │                 │                     │
│          └─────────────────┼─────────────────┘                     │
│                            │                                        │
│                            v                                        │
│                    ┌──────────────────┐                            │
│                    │  Aggregate       │                            │
│                    │  Results         │                            │
│                    └────────┬─────────┘                            │
│                             │                                       │
│              ┌──────────────┼──────────────┐                       │
│              │              │              │                       │
│              v              v              v                       │
│        ┌─────────┐    ┌─────────┐    ┌─────────┐                  │
│        │ PASSED  │    │ PENDING │    │ FAILED  │                  │
│        │ (all OK)│    │ (manual)│    │ (any    │                  │
│        │         │    │         │    │  fail)  │                  │
│        └─────────┘    └─────────┘    └─────────┘                  │
│                                                                     │
└────────────────────────────────────────────────────────────────────┘
```

---

## 8. Risk Assessment

### 8.1 Technical Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Task tool integration complexity | Medium | High | Build adapter layer, test extensively |
| State persistence corruption | Low | High | Checksums, atomic writes, backups |
| Parallel execution conflicts | Medium | Medium | File locking, conflict detection |
| Gate evaluation accuracy | Medium | Medium | Clear criterion specifications, manual override |
| Performance with large workflows | Low | Medium | Lazy evaluation, streaming |

### 8.2 Integration Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| YAML format changes break existing workflows | Medium | High | Schema versioning, migration tools |
| Agent definition changes | Low | Medium | Loose coupling, interface contracts |
| MCP cache unavailable | Low | Low | Graceful degradation, local fallback |

### 8.3 Operational Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Workflow stuck in PAUSED state | Medium | Low | Timeout handling, manual resume |
| Checkpoint storage full | Low | Low | Auto-cleanup old checkpoints |
| Event callback failures | Low | Low | Error isolation, continue execution |

---

## 9. Success Metrics

### 9.1 Functional Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Workflow parse success rate | 100% | Valid workflows parse without error |
| Gate evaluation accuracy | 95% | Gates correctly pass/fail |
| State recovery success | 99% | Resume from checkpoint works |
| Agent invocation success | 95% | Agents invoked correctly |

### 9.2 Performance Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Workflow load time | < 500ms | Time to parse and validate YAML |
| State persistence latency | < 100ms | Time to save state |
| Gate evaluation time | < 2s | Time per gate check |
| Event dispatch latency | < 10ms | Time to notify callbacks |

### 9.3 Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Code coverage | 80% | Unit test coverage |
| Cyclomatic complexity | < 10 | Per function |
| Documentation coverage | 100% | All public APIs documented |

---

## 10. Implementation Phases

### Phase 1: Core Engine (Week 1-2)
- YAML Parser + Validator
- State Machine
- Basic workflow execution (sequential)
- Progress Tracker
- State persistence

### Phase 2: Gate System (Week 3)
- Gate Checker implementation
- Criterion evaluators
- Manual approval handling
- Gate result persistence

### Phase 3: Agent Integration (Week 4)
- Agent Invoker
- Task tool integration
- Context building
- Result capture

### Phase 4: Control Operations (Week 5)
- Pause/Resume Manager
- Rollback Handler
- Checkpoint system
- Event Dispatcher

### Phase 5: Polish & Testing (Week 6)
- Integration testing
- Documentation
- Error handling refinement
- Performance optimization

---

## Appendix A: Existing Workflow Analysis

### Workflows to Support

| Workflow | Phases | Gates | Complexity |
|----------|--------|-------|------------|
| epic-workflow.yaml | 7 | 7 | High |
| story-delivery.yaml | 7 | 5 | Medium |
| feature-flow.yaml | 6 | 6 | Medium |
| bug-workflow.yaml | 4 | 3 | Low |
| sprint-workflow.yaml | 5 | 4 | Medium |
| discovery-flow.yaml | 3 | 2 | Low |
| quick-fix.yaml | 3 | 2 | Low |
| ad-hoc-flow.yaml | 2 | 1 | Low |

### Common Patterns Identified

1. **Sequential phases** with gates between
2. **Parallel steps** within phases (frontend/backend)
3. **Conditional phases** (UI components only if needed)
4. **Loop constructs** (for each story in sprint)
5. **Error recovery paths** (return to previous phase)
6. **Auto state updates** (on phase completion)

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| Workflow | Complete YAML definition of an execution pipeline |
| Phase | Major step in workflow with entry/exit gates |
| Step | Individual action within a phase |
| Gate | Quality checkpoint between phases |
| Checkpoint | Saved state for recovery |
| Instance | Running execution of a workflow |

---

**Document End**

*Last Updated: 2025-12-14*
*Author: ARCHITECT-AGENT*
*Status: PROPOSED - Pending review by PRODUCT-OWNER*
