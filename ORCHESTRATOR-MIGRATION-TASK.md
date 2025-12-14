# Agent Methodology Pack - Full System Migration & Integration

**Epic Type:** System Migration
**Priority:** P0 - Critical
**Estimated Effort:** 2-3 hours (automated)
**Target:** New project setup with complete Agent Methodology Pack v1.1.0

---

## OBJECTIVE

Deploy complete Agent Methodology Pack system to a new project, including:
- All 20 agents (planning, development, quality)
- 8 workflows
- 10 patterns (including MCP Cache)
- MCP Server integration
- Cache system (60-80% savings)
- Skills library
- State management
- Automation scripts

---

## ORCHESTRATOR: READ THIS FIRST

**Your role:** Coordinate 6 agents in parallel tracks to complete full system migration

**Execution mode:** Semi-Auto (Level 2)
- Launch 2-3 agents in parallel when possible
- Report progress after each major phase
- Handle blockers autonomously

**Success criteria:**
- All agents operational in new project
- MCP Server configured and verified
- Cache system working with metrics tracking
- At least 1 test workflow executed successfully
- Documentation updated for new project

---

## PRE-FLIGHT CHECKLIST

Before starting, verify:

```
[ ] New project directory exists
[ ] Agent Methodology Pack copied to new location
[ ] Claude Code is running
[ ] Python 3.8+ available
[ ] Git initialized (optional but recommended)
[ ] User has admin rights (for MCP config)
```

**If any item fails:** Report to user and STOP

---

## PHASE 1: Environment Setup & Validation

**Duration:** 15-20 minutes
**Agents:** devops-agent, senior-dev (parallel)

### TRACK A: devops-agent

**Task:** Verify environment and configure MCP Server

**Deliverables:**
1. Environment check report (Python, Git, Claude Code)
2. MCP Server configuration in `claude_desktop_config.json`
3. Directory structure validation
4. Permissions check

**Instructions for devops-agent:**
```markdown
@.claude/agents/operations/DEVOPS-AGENT.md

## Task: Environment Setup for Agent Methodology Pack

### Step 1: Verify Prerequisites
- Check Python version (3.8+)
- Check Git (optional)
- Verify directory structure exists

### Step 2: Configure MCP Server
- Read: .claude/mcp-servers/QUICK-START.md
- Update: %APPDATA%\Claude\claude_desktop_config.json
- Add agent-cache MCP server configuration
- Use ABSOLUTE path to server.py in new project location

### Step 3: Validate Structure
- Verify all required directories exist:
  - .claude/agents/
  - .claude/cache/
  - .claude/workflows/
  - .claude/patterns/
  - scripts/
  - docs/

### Step 4: Test Scripts
- Run: bash scripts/validate-docs.sh
- Report any missing files

**Output:** ENVIRONMENT-SETUP-REPORT.md
```

---

### TRACK B: senior-dev

**Task:** Initialize cache system and verify integrity

**Deliverables:**
1. Cache system initialized
2. Metrics baseline created
3. Test cache operations
4. Integrity check report

**Instructions for senior-dev:**
```markdown
@.claude/agents/development/SENIOR-DEV.md

## Task: Initialize Cache System

### Step 1: Verify cache_manager.py
- Read: .claude/cache/cache_manager.py
- Confirm recent fixes present:
  - _load_metrics() method exists
  - _auto_save_metrics() with try/finally
  - Correct path handling (no duplicates)

### Step 2: Initialize Cache
- Run Python test:
```python
from cache_manager import CacheManager
cache = CacheManager(".claude/cache/config.json")
print("Cache initialized:", cache.metrics_file.exists())
```

### Step 3: Create Baseline Metrics
- Execute 5 test queries
- Verify metrics.json created
- Confirm auto-save works

### Step 4: Run cache-stats.sh
- Execute: bash scripts/cache-stats.sh
- Verify output shows metrics
- Take screenshot/copy output

**Output:** CACHE-INITIALIZATION-REPORT.md
```

---

## PHASE 2: Agent Integration

**Duration:** 30-40 minutes
**Agents:** architect-agent, backend-dev, frontend-dev (parallel)

### TRACK C: architect-agent

**Task:** Review and adapt agent definitions for new project

**Deliverables:**
1. Agent compatibility report
2. Recommended customizations
3. Updated agent descriptions (if needed)

**Instructions for architect-agent:**
```markdown
@.claude/agents/planning/ARCHITECT-AGENT.md

## Task: Agent System Architecture Review

### Step 1: Review Agent Registry
- Read: .claude/agents/ORCHESTRATOR.md
- Count total agents (should be 20)
- Verify all agent files exist

### Step 2: Check MCP Integration
- Read: .claude/agents/planning/RESEARCH-AGENT.md
- Verify "MCP Cache Integration" section exists
- Check: TEST-ENGINEER.md, SENIOR-DEV.md
- Confirm cache integration documented

### Step 3: Project-Specific Customization
- Read: CLAUDE.md (if exists in new project)
- Identify project-specific needs
- Recommend any agent customizations

### Step 4: Agent Communication Paths
- Verify: .claude/state/HANDOFFS.md
- Check all handoff patterns documented
- Ensure state management files present

**Output:** AGENT-ARCHITECTURE-REVIEW.md
```

---

### TRACK D: backend-dev

**Task:** Add MCP Cache to backend-dev agent (if not present)

**Deliverables:**
1. Updated BACKEND-DEV.md with MCP cache section
2. Cache integration examples

**Instructions for backend-dev:**
```markdown
@.claude/agents/development/BACKEND-DEV.md (if exists)

## Task: Add MCP Cache Integration

### Step 1: Read Pattern Guide
- Read: .claude/patterns/MCP-CACHE-USAGE.md
- Understand 3-step workflow

### Step 2: Add MCP Cache Section
- Find appropriate location in BACKEND-DEV.md
- Add section similar to RESEARCH-AGENT.md:
  - Cache workflow
  - Cache key patterns (api-design, schema-design)
  - Examples
  - Link to full guide

### Step 3: Document Use Cases
- API endpoint design caching
- Database schema patterns
- Common CRUD operations

**Output:** Updated BACKEND-DEV.md
```

---

### TRACK E: frontend-dev

**Task:** Add MCP Cache to frontend-dev agent (if not present)

**Deliverables:**
1. Updated FRONTEND-DEV.md with MCP cache section
2. Cache integration examples

**Instructions for frontend-dev:**
```markdown
@.claude/agents/development/FRONTEND-DEV.md (if exists)

## Task: Add MCP Cache Integration

### Step 1: Read Pattern Guide
- Read: .claude/patterns/MCP-CACHE-USAGE.md

### Step 2: Add MCP Cache Section
- Add to FRONTEND-DEV.md:
  - Cache workflow
  - Cache key patterns (component-design, ui-patterns)
  - Examples for UI components
  - Link to guide

### Step 3: Document Use Cases
- Component structure patterns
- UI/UX solutions
- Form validation patterns
- Common layouts

**Output:** Updated FRONTEND-DEV.md
```

---

## PHASE 3: Testing & Verification

**Duration:** 20-30 minutes
**Agents:** test-engineer, qa-agent (sequential)

### TRACK F: test-engineer

**Task:** Create and execute integration tests

**Deliverables:**
1. Integration test suite
2. Test execution report
3. Bug/issue list (if any)

**Instructions for test-engineer:**
```markdown
@.claude/agents/development/TEST-ENGINEER.md

## Task: Integration Test Suite

### Step 1: Cache System Tests
- Test: cache_manager.py initialization
- Test: Metrics loading from file
- Test: Auto-save after 5 operations
- Test: Cache HIT and MISS scenarios

### Step 2: MCP Server Tests
- Test: MCP server initialization
- Test: generate_key tool
- Test: cache_get tool
- Test: cache_set tool
- Verify: logs/mcp-access.log has entries

### Step 3: Agent Integration Tests
- Test: RESEARCH-AGENT with MCP cache instructions
- Test: ORCHESTRATOR can read and delegate
- Test: At least 1 workflow end-to-end

### Step 4: Scripts Tests
- Test: cache-stats.sh runs without errors
- Test: validate-docs.sh passes
- Test: All scripts have execute permissions

**Expected Results:**
- All cache tests: PASS
- MCP server: INITIALIZED (may need restart to test tools)
- Agent reads: SUCCESS
- Scripts: EXECUTABLE

**Output:** INTEGRATION-TEST-REPORT.md
```

---

### TRACK G: qa-agent

**Task:** Manual validation and UAT

**Deliverables:**
1. UAT checklist completed
2. Final validation report
3. PASS/FAIL decision

**Instructions for qa-agent:**
```markdown
@.claude/agents/quality/QA-AGENT.md

## Task: User Acceptance Testing

### Test 1: Documentation Completeness
- [ ] CACHE-USER-GUIDE.md present
- [ ] All agent files readable
- [ ] MCP-CACHE-USAGE.md present
- [ ] PROJECT-STATE.md reflects current state

### Test 2: Cache System
- [ ] Run cache-stats.sh - shows metrics
- [ ] metrics.json file exists and has data
- [ ] Recent activity shows in logs
- [ ] No error messages in output

### Test 3: MCP Configuration
- [ ] claude_desktop_config.json updated
- [ ] MCP server path is ABSOLUTE
- [ ] Path points to new project location
- [ ] No typos in configuration

### Test 4: Agent Accessibility
- [ ] Can read ORCHESTRATOR.md
- [ ] Can read RESEARCH-AGENT.md
- [ ] Can read at least 3 other agents
- [ ] All agent files have proper frontmatter

### Test 5: Workflow Execution
- [ ] Choose 1 workflow (e.g., RESEARCH-AGENT task)
- [ ] Execute manually
- [ ] Verify agent understands instructions
- [ ] Check cache instructions are clear

**Decision:**
- If ALL tests PASS → Mark as READY
- If ANY test FAILS → Create bug report and mark BLOCKED

**Output:** UAT-REPORT.md with PASS/FAIL decision
```

---

## PHASE 4: Documentation & Handoff

**Duration:** 15-20 minutes
**Agents:** tech-writer, doc-auditor (sequential)

### TRACK H: tech-writer

**Task:** Update project-specific documentation

**Deliverables:**
1. Updated PROJECT-STATE.md for new project
2. Updated CLAUDE.md (if exists)
3. Quick start guide for new project

**Instructions for tech-writer:**
```markdown
@.claude/agents/quality/TECH-WRITER.md

## Task: Project Documentation Update

### Step 1: Update PROJECT-STATE.md
- Update project name/path
- Update installation date
- Note: "Migrated from agent-methodology-pack v1.1.0"
- Update any project-specific sections

### Step 2: Create/Update CLAUDE.md
- If exists: Review and update
- If not exists: Create from template
- Include:
  - Project name
  - Tech stack
  - Current phase
  - Link to PROJECT-STATE.md
  - Link to ORCHESTRATOR.md

### Step 3: Create QUICK-START-{PROJECT}.md
- Customize QUICK-START.md for this project
- Include project-specific examples
- Update file paths to match new location
- Add "Getting Started" section

**Output:**
- Updated PROJECT-STATE.md
- Updated/Created CLAUDE.md
- Created QUICK-START-{PROJECT}.md
```

---

### TRACK I: doc-auditor

**Task:** Final documentation audit

**Deliverables:**
1. Documentation audit report
2. List of issues (if any)
3. Final approval or action items

**Instructions for doc-auditor:**
```markdown
@.claude/agents/quality/DOC-AUDITOR.md

## Task: Documentation Quality Audit

### Audit 1: Completeness Check
- All required files present
- No broken links in documentation
- All @references valid
- README.md reflects new project

### Audit 2: Accuracy Check
- File paths correct for new location
- MCP server path absolute and correct
- Agent descriptions accurate
- Cache instructions clear

### Audit 3: Consistency Check
- Terminology consistent across docs
- Version numbers match (v1.1.0)
- Formatting consistent
- No outdated information

### Audit 4: Usability Check
- User can follow CACHE-USER-GUIDE.md
- ORCHESTRATOR instructions clear
- Agent definitions understandable
- Examples work as written

**Output:** DOCUMENTATION-AUDIT-REPORT.md

**Decision:**
- If audit PASSES → APPROVE for production
- If issues found → List action items
```

---

## PHASE 5: Final Validation & User Handoff

**Duration:** 10 minutes
**Agent:** orchestrator (you!)

### Final Steps

1. **Collect all reports:**
   - Environment setup report
   - Cache initialization report
   - Agent architecture review
   - Integration test report
   - UAT report
   - Documentation audit report

2. **Create summary:**
   - Total agents available
   - Cache system status
   - MCP Server status
   - Any issues found
   - Recommended next steps

3. **User handoff:**
   - Report completion status
   - List deliverables
   - Note any blockers
   - Provide next steps

---

## SUCCESS CRITERIA

### Must Have (Blocker if missing)
- [x] All 20 agent files readable
- [x] Cache system initialized
- [x] MCP Server configured
- [x] cache-stats.sh shows metrics
- [x] At least 1 test workflow passes
- [x] No critical errors in any phase

### Should Have (Warning if missing)
- [x] All agents have MCP cache integration
- [x] Documentation updated for new project
- [x] Integration tests all pass
- [x] UAT approved

### Nice to Have (Optional)
- [ ] Claude Code restarted (user must do)
- [ ] MCP tools verified in agent
- [ ] First real task executed with cache

---

## EXECUTION COMMANDS FOR ORCHESTRATOR

**To start this migration, orchestrator should:**

```markdown
## Phase 1: Parallel Environment Setup

Launch in PARALLEL (same message):
- devops-agent: Environment setup & MCP config
- senior-dev: Cache system initialization

Wait for both to complete.

## Phase 2: Parallel Agent Integration

Launch in PARALLEL:
- architect-agent: Architecture review
- backend-dev: Add MCP cache to BACKEND-DEV
- frontend-dev: Add MCP cache to FRONTEND-DEV

Wait for all to complete.

## Phase 3: Sequential Testing

Launch SEQUENTIALLY:
1. test-engineer: Create and run integration tests
2. WAIT for completion
3. qa-agent: Manual UAT validation
4. WAIT for PASS/FAIL decision

## Phase 4: Sequential Documentation

Launch SEQUENTIALLY:
1. tech-writer: Update documentation
2. WAIT for completion
3. doc-auditor: Final audit
4. WAIT for approval

## Phase 5: Summary

Collect all reports and present to user.
```

---

## ROLLBACK PLAN

If migration fails at any stage:

1. **Identify failure point:** Which phase/agent failed?
2. **Assess impact:** What is broken?
3. **Rollback options:**
   - Phase 1 fail → Fix environment, retry
   - Phase 2 fail → Agents still usable, continue manually
   - Phase 3 fail → Tests failed, but system might work
   - Phase 4 fail → Docs incomplete, but system works

**No destructive operations** - Original files preserved

---

## MONITORING & REPORTING

### After Each Phase

Report to user:
```
✅ Phase X Complete
   - Agent A: ✅ SUCCESS
   - Agent B: ✅ SUCCESS
   - Agent C: ⚠️  WARNING (non-blocking)

Next: Phase Y (estimated 20 min)
```

### Final Report Format

```
🎉 MIGRATION COMPLETE

✅ Environment Setup: DONE
✅ Agent Integration: DONE
✅ Testing: PASSED
✅ Documentation: APPROVED

📊 Results:
- 20 agents operational
- Cache system: WORKING (13 queries tracked)
- MCP Server: CONFIGURED (requires restart)
- Tests: 15/15 passed

📝 User Actions Required:
1. Restart Claude Code (for MCP tools)
2. Test first research query
3. Monitor cache-stats.sh

📚 Documentation:
- CACHE-USER-GUIDE.md - Quick start
- PROJECT-STATE.md - Current state
- ORCHESTRATOR.md - Agent coordination

🎯 Next Steps:
1. Run: bash scripts/cache-stats.sh
2. Test: @.claude/agents/planning/RESEARCH-AGENT.md
3. Verify: MCP tools available after restart

System is READY FOR USE! 🚀
```

---

## ESTIMATED TIMELINE

| Phase | Duration | Agents | Parallelism |
|-------|----------|--------|-------------|
| Phase 1: Environment | 15-20 min | 2 | Parallel |
| Phase 2: Integration | 30-40 min | 3 | Parallel |
| Phase 3: Testing | 20-30 min | 2 | Sequential |
| Phase 4: Documentation | 15-20 min | 2 | Sequential |
| Phase 5: Summary | 10 min | 1 | Single |

**Total: 1.5-2 hours** (automated)

---

## TROUBLESHOOTING

### Common Issues

**Issue:** MCP Server path incorrect
**Fix:** devops-agent should use ABSOLUTE path, verify manually

**Issue:** Cache metrics show 0
**Fix:** senior-dev runs test queries to initialize

**Issue:** Agent file not found
**Fix:** Verify .claude/agents/ structure, may need copy

**Issue:** Scripts not executable
**Fix:** Run `chmod +x scripts/*.sh`

**Issue:** Python import error
**Fix:** Check PYTHONPATH, verify cache_manager.py location

---

## APPENDIX A: File Structure Verification

Expected structure after migration:

```
new-project/
├── .claude/
│   ├── agents/
│   │   ├── planning/ (6 agents)
│   │   ├── development/ (4 agents)
│   │   ├── quality/ (3 agents)
│   │   ├── operations/ (1 agent)
│   │   └── ORCHESTRATOR.md
│   ├── cache/
│   │   ├── cache_manager.py ✅
│   │   ├── config.json
│   │   └── logs/
│   │       └── metrics.json ✅
│   ├── mcp-servers/
│   │   └── cache-server/
│   │       └── server.py
│   ├── patterns/
│   │   ├── MCP-CACHE-USAGE.md ✅
│   │   └── ... (10 total)
│   ├── workflows/ (8 workflows)
│   ├── state/ (7 state files)
│   └── testing/
├── scripts/
│   ├── cache-stats.sh ✅
│   └── ... (11 total)
├── docs/
│   └── ... (migration guides)
├── CACHE-USER-GUIDE.md ✅
├── PROJECT-STATE.md
├── README.md
└── CLAUDE.md (optional)
```

---

## APPENDIX B: Agent Capabilities Matrix

| Agent | MCP Cache | Parallel | Critical |
|-------|-----------|----------|----------|
| ORCHESTRATOR | No | N/A | ⭐ |
| RESEARCH-AGENT | ✅ Yes | Yes (4x) | ⭐ |
| TEST-ENGINEER | ✅ Yes | No | ⭐ |
| SENIOR-DEV | ✅ Yes | No | ⭐ |
| BACKEND-DEV | ⚠️  Add | No | - |
| FRONTEND-DEV | ⚠️  Add | No | - |
| ARCHITECT-AGENT | No | No | ⭐ |
| QA-AGENT | No | No | ⭐ |
| DEVOPS-AGENT | No | No | ⭐ |
| DOC-AUDITOR | No | No | - |
| TECH-WRITER | No | No | - |

---

**END OF MIGRATION TASK**

**Version:** 1.0.0
**Created:** 2025-12-14
**For:** Agent Methodology Pack v1.1.0 Migration

**Usage:**
```
Load this file and tell orchestrator:
"Execute the migration task defined in ORCHESTRATOR-MIGRATION-TASK.md"
```
