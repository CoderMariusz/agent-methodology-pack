# Migration Guide: Update to v1.1.0 (Multi-Model Routing)

**Version:** 1.0.0 → 1.1.0
**Date:** 2025-12-14
**Migration Type:** Feature Update (Non-breaking)
**Estimated Time:** 20-30 minutes per project

## What's New in v1.1.0

### Major Features

- **Multi-model routing** across all 20 agents
- **Cost optimization** (19% savings: £144→£114/month estimated)
- **Speed improvements** (2-3x faster for research, 3x for tests)
- **Cache metrics tracking** (fixed - now shows actual savings)
- **Complexity scoring** algorithm (0-10 scale)
- **Automatic escalation** logic (Sonnet→ChatGPT→Opus)

### New Files (8)

1. `PROJECT-STATE.md` - Project tracking dashboard
2. `.claude/COMPLEXITY-SCORING.md` - Algorithm and examples
3. `.claude/MODEL-METRICS.md` - Performance tracking
4. `.claude/QUICK-REFERENCE-MODELS.md` - Decision guide
5. `.claude/testing/MODEL-ROUTING-TESTS.md` - Test scenarios
6. `.claude/testing/REAL-WORLD-TEST-RESULTS.md` - Validation
7. `.claude/cache/FIX_SAVINGS_TRACKING.md` - Cache fix documentation
8. `.claude/cache/test_savings.py` - Test suite

### Updated Files (26)

- `MODEL-ROUTING.md` (64 lines → 666 lines)
- 20 agent definitions (model configurations added)
- 3 state files (HANDOFFS, AGENT-MEMORY, METRICS)
- `ONBOARDING-GUIDE.md` (+336 lines)
- `cache_manager.py` (savings tracking fix)

---

## Pre-Migration Checklist

### Step 1: Backup Your Projects

```bash
# For each project:
cd /path/to/your-project
git checkout -b pre-v1.1.0-backup
git commit -am "Backup before v1.1.0 migration"
```

### Step 2: Check Current Version

```bash
# Check if you have these files (old version):
ls .claude/MODEL-ROUTING.md     # Should be ~64 lines
ls .claude/agents/*/            # Agents without model configs
ls PROJECT-STATE.md             # Should NOT exist
```

### Step 3: Verify Git Status

```bash
git status
# Make sure working directory is clean
```

---

## Migration Steps (3 Methods)

### Method 1: Automated Migration (Recommended)

**Time required:** 5 minutes
**Best for:** Projects with standard structure, minimal customization

```bash
# 1. Navigate to your project
cd /path/to/your-project

# 2. Pull latest agent-methodology-pack
cd /path/to/agent-methodology-pack
git pull origin master

# 3. Run automated update script
bash scripts/update-project-to-v1.1.0.sh /path/to/your-project
```

The script will:

- Copy 8 new files
- Update 26 existing files
- Merge agent configurations
- Preserve your customizations
- Create backup of modified files
- Generate MIGRATION-REPORT.md

---

### Method 2: Manual File-by-File

**Time required:** 20-30 minutes
**Best for:** Heavily customized projects, want full control

#### Phase 1: Copy New Files (5 minutes)

```bash
# From agent-methodology-pack repo:
cd /path/to/agent-methodology-pack

# To your project:
cp PROJECT-STATE.md /path/to/your-project/
cp .claude/COMPLEXITY-SCORING.md /path/to/your-project/.claude/
cp .claude/MODEL-METRICS.md /path/to/your-project/.claude/state/
cp .claude/QUICK-REFERENCE-MODELS.md /path/to/your-project/.claude/
cp -r .claude/testing /path/to/your-project/.claude/
cp .claude/cache/FIX_SAVINGS_TRACKING.md /path/to/your-project/.claude/cache/
cp .claude/cache/test_savings.py /path/to/your-project/.claude/cache/
```

#### Phase 2: Update Existing Files (10 minutes)

**Option A: Overwrite (if no customizations)**

```bash
# Overwrite MODEL-ROUTING.md
cp .claude/MODEL-ROUTING.md /path/to/your-project/.claude/

# Overwrite all agents
cp -r .claude/agents/* /path/to/your-project/.claude/agents/

# Overwrite state files
cp .claude/state/HANDOFFS.md /path/to/your-project/.claude/state/
cp .claude/state/AGENT-MEMORY.md /path/to/your-project/.claude/state/
cp .claude/state/METRICS.md /path/to/your-project/.claude/state/

# Overwrite docs
cp docs/ONBOARDING-GUIDE.md /path/to/your-project/docs/
```

**Option B: Merge (if customizations exist)**

```bash
# Use git to see differences
cd /path/to/your-project
git diff .claude/MODEL-ROUTING.md /path/to/agent-methodology-pack/.claude/MODEL-ROUTING.md

# Manually merge changes, keeping your customizations
```

#### Phase 3: Fix Cache (2 minutes)

```bash
# Copy fixed cache_manager.py
cp /path/to/agent-methodology-pack/.claude/cache/cache_manager.py /path/to/your-project/.claude/cache/

# Test cache fix
cd /path/to/your-project
python3 .claude/cache/test_savings.py

# Expected output: All 3 tests PASSED
```

#### Phase 4: Update PROJECT-STATE.md (3 minutes)

```bash
# Edit PROJECT-STATE.md with your project details:
cd /path/to/your-project

# Update these fields:
# - Project name
# - Current phase
# - Agents used
# - Recent accomplishments
# - Next steps
```

---

### Method 3: Selective Update (Cherry-Pick)

**Time required:** 10-15 minutes
**Best for:** Only want specific features

#### Option 1: Only Cache Fix

```bash
cp /path/to/agent-methodology-pack/.claude/cache/cache_manager.py /path/to/your-project/.claude/cache/
cp /path/to/agent-methodology-pack/.claude/cache/test_savings.py /path/to/your-project/.claude/cache/
cp /path/to/agent-methodology-pack/.claude/cache/FIX_SAVINGS_TRACKING.md /path/to/your-project/.claude/cache/

# Test
python3 .claude/cache/test_savings.py
bash scripts/cache-stats.sh
```

#### Option 2: Only Model Routing Docs (No Agent Changes)

```bash
cp /path/to/agent-methodology-pack/.claude/COMPLEXITY-SCORING.md /path/to/your-project/.claude/
cp /path/to/agent-methodology-pack/.claude/QUICK-REFERENCE-MODELS.md /path/to/your-project/.claude/
cp /path/to/agent-methodology-pack/.claude/MODEL-ROUTING.md /path/to/your-project/.claude/

# Read the docs, don't update agents yet
```

#### Option 3: Only Specific Agents

```bash
# Example: Only update RESEARCH-AGENT and TEST-ENGINEER
cp /path/to/agent-methodology-pack/.claude/agents/planning/RESEARCH-AGENT.md /path/to/your-project/.claude/agents/planning/
cp /path/to/agent-methodology-pack/.claude/agents/development/TEST-ENGINEER.md /path/to/your-project/.claude/agents/development/
```

---

## Post-Migration Validation

### Step 1: Verify Files Copied

```bash
cd /path/to/your-project

# Check new files exist:
ls PROJECT-STATE.md
ls .claude/COMPLEXITY-SCORING.md
ls .claude/MODEL-METRICS.md
ls .claude/QUICK-REFERENCE-MODELS.md
ls .claude/testing/MODEL-ROUTING-TESTS.md

# Check agents updated:
grep "Model Configuration" .claude/agents/ORCHESTRATOR.md
grep "Model Configuration" .claude/agents/planning/RESEARCH-AGENT.md
```

### Step 2: Test Cache

```bash
# Run cache test
python3 .claude/cache/test_savings.py

# Check cache stats
bash scripts/cache-stats.sh

# Expected: Tokens Saved > 0, Cost Saved > $0
```

### Step 3: Validate Documentation

```bash
# Run validation (if you have the script)
bash scripts/validate-docs.sh

# Manual check:
ls .claude/agents/*/  # All agents should have files
wc -l .claude/MODEL-ROUTING.md  # Should be ~666 lines
```

### Step 4: Test Agent Routing (Optional)

```bash
# Open Claude Code in your project
cd /path/to/your-project

# Try a research task (should use Gemini/Haiku)
# Try a test task (should use Haiku)
# Check AGENT-MEMORY.md for model assignments
```

---

## Troubleshooting

### Issue 1: Cache Stats Show $0 Savings

**Symptom:** `bash scripts/cache-stats.sh` shows Tokens Saved: 0

**Solution:**

```bash
# Verify cache_manager.py was updated
grep "_calculate_savings" .claude/cache/cache_manager.py

# If not found, copy again:
cp /path/to/agent-methodology-pack/.claude/cache/cache_manager.py .claude/cache/

# Test:
python3 .claude/cache/test_savings.py
```

### Issue 2: Agent Definitions Missing Model Config

**Symptom:** Agents don't have "Model Configuration" section

**Solution:**

```bash
# Check which agents are missing:
for agent in .claude/agents/**/*.md; do
    if ! grep -q "Model Configuration" "$agent"; then
        echo "Missing: $agent"
    fi
done

# Copy missing agents from source:
cp /path/to/agent-methodology-pack/.claude/agents/[agent-name].md .claude/agents/
```

### Issue 3: Git Conflicts After Update

**Symptom:** Git shows conflicts in updated files

**Solution:**

```bash
# Option 1: Accept all incoming changes
git checkout --theirs .claude/MODEL-ROUTING.md
git add .claude/MODEL-ROUTING.md

# Option 2: Manually resolve
git mergetool

# Option 3: Revert and try again
git checkout pre-v1.1.0-backup
# Start migration again
```

### Issue 4: Custom Agent Configurations Lost

**Symptom:** Your custom agent settings overwritten

**Solution:**

```bash
# Restore from backup
git checkout pre-v1.1.0-backup -- .claude/agents/YOUR-CUSTOM-AGENT.md

# Manually add Model Configuration section:
# (Copy from template agent, add to your custom agent)
```

---

## Expected Results After Migration

### Cost Savings

- **Before:** Your current cost (e.g., £144/month)
- **After:** ~19% reduction (e.g., £114/month)
- **Tracking:** View in `bash scripts/cache-stats.sh`

### Speed Improvements

- Research tasks: 2-3x faster (Gemini)
- Test writing: 3x faster (Haiku)
- Overall: ~18% faster average

### New Capabilities

- Complexity-based routing
- Automatic escalation (Sonnet→ChatGPT→Opus)
- Cost tracking per agent
- Performance metrics dashboard

---

## Rolling Back (If Needed)

If migration causes issues:

```bash
# Revert to backup branch
git checkout pre-v1.1.0-backup

# Or specific file
git checkout pre-v1.1.0-backup -- .claude/agents/AGENT-NAME.md

# Or full rollback
git reset --hard pre-v1.1.0-backup
```

---

## Migration Checklist

Use this checklist for each project:

**Project 1:** _______________

- [ ] Backup created (`pre-v1.1.0-backup` branch)
- [ ] Git status clean
- [ ] New files copied (8 files)
- [ ] Existing files updated (26 files)
- [ ] Cache fix verified (`test_savings.py` passes)
- [ ] Cache stats show savings ($X.XX)
- [ ] Agent model configs present (20/20)
- [ ] PROJECT-STATE.md customized
- [ ] Documentation validated
- [ ] Test agent routing (optional)
- [ ] Git committed (e.g., "feat: Update to v1.1.0")
- [ ] Working correctly in production

**Project 2:** _______________

- [ ] Backup created (`pre-v1.1.0-backup` branch)
- [ ] Git status clean
- [ ] New files copied (8 files)
- [ ] Existing files updated (26 files)
- [ ] Cache fix verified (`test_savings.py` passes)
- [ ] Cache stats show savings ($X.XX)
- [ ] Agent model configs present (20/20)
- [ ] PROJECT-STATE.md customized
- [ ] Documentation validated
- [ ] Test agent routing (optional)
- [ ] Git committed (e.g., "feat: Update to v1.1.0")
- [ ] Working correctly in production

---

## Next Steps After Migration

### Week 1: Monitor

```bash
# Daily: Check cache savings
bash scripts/cache-stats.sh

# Weekly: Review model performance
cat .claude/state/MODEL-METRICS.md
```

### Week 2-4: Optimize

1. Review escalation patterns (which agents escalate most?)
2. Adjust complexity thresholds if needed
3. Update agent model assignments based on results
4. Track actual cost savings vs projections

### Month 1: Report

1. Document actual savings in PROJECT-STATE.md
2. Update METRICS.md with real data
3. Share results with team
4. Plan optimizations for month 2

---

## Support

### Issues?

- Check troubleshooting section above
- Review: `.claude/testing/REAL-WORLD-TEST-RESULTS.md`
- Check: `PROJECT-STATE.md` for known issues

### Questions?

- Read: `.claude/QUICK-REFERENCE-MODELS.md`
- Read: `.claude/COMPLEXITY-SCORING.md`
- Read: `docs/ONBOARDING-GUIDE.md` (examples added)

---

## Success Criteria

Migration is successful when:

1. All 34 files updated/created
2. Cache shows savings > $0
3. All agents have Model Configuration
4. PROJECT-STATE.md exists and customized
5. No git conflicts
6. Tests pass (`cache-stats.sh`, `test_savings.py`)
7. Agent routing working (check AGENT-MEMORY.md)

**Ready to use v1.1.0!**

---

**Migration Guide Version:** 1.0
**Compatible with:** Agent Methodology Pack v1.1.0
**Last Updated:** 2025-12-14
