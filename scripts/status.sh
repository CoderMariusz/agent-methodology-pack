#!/bin/bash
# =============================================================================
# STATUS.SH - Quick Status Command (Feature #24)
# =============================================================================
# Shows active workflows, agent status, and pending tasks in one command.
#
# Usage:
#   bash scripts/status.sh              # Full status
#   bash scripts/status.sh --compact    # One-liner summary
#   bash scripts/status.sh --json       # JSON output for integration
#   bash scripts/status.sh --workflows  # Workflows only
#   bash scripts/status.sh --agents     # Agents only
#   bash scripts/status.sh --tasks      # Tasks only
#
# Exit codes:
#   0 - Success
#   1 - Error (missing files, parse error)
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# State files
AGENT_STATE_FILE="$PROJECT_ROOT/.claude/state/AGENT-STATE.md"
TASK_QUEUE_FILE="$PROJECT_ROOT/.claude/state/TASK-QUEUE.md"
HANDOFFS_FILE="$PROJECT_ROOT/.claude/state/HANDOFFS.md"
PROJECT_STATE_FILE="$PROJECT_ROOT/PROJECT-STATE.md"

# Mode flags
COMPACT_MODE=false
JSON_MODE=false
SHOW_WORKFLOWS=true
SHOW_AGENTS=true
SHOW_TASKS=true

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --compact|-c)
            COMPACT_MODE=true
            shift
            ;;
        --json|-j)
            JSON_MODE=true
            shift
            ;;
        --workflows|-w)
            SHOW_WORKFLOWS=true
            SHOW_AGENTS=false
            SHOW_TASKS=false
            shift
            ;;
        --agents|-a)
            SHOW_WORKFLOWS=false
            SHOW_AGENTS=true
            SHOW_TASKS=false
            shift
            ;;
        --tasks|-t)
            SHOW_WORKFLOWS=false
            SHOW_AGENTS=false
            SHOW_TASKS=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --compact, -c    One-liner summary"
            echo "  --json, -j       JSON output for integration"
            echo "  --workflows, -w  Show workflows only"
            echo "  --agents, -a     Show agents only"
            echo "  --tasks, -t      Show tasks only"
            echo "  --help, -h       Show this help"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# =============================================================================
# Helper Functions
# =============================================================================

# Check if file exists and is readable
check_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        return 1
    fi
    return 0
}

# Count occurrences in file
count_pattern() {
    local file="$1"
    local pattern="$2"
    if check_file "$file"; then
        grep -c "$pattern" "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Extract value after pattern (first match)
extract_value() {
    local file="$1"
    local pattern="$2"
    if check_file "$file"; then
        grep -m1 "$pattern" "$file" 2>/dev/null | sed "s/.*$pattern\s*//" | tr -d '|' | xargs
    fi
}

# Get active agents count
get_active_agents() {
    if check_file "$AGENT_STATE_FILE"; then
        grep -E "^\| [A-Z]" "$AGENT_STATE_FILE" 2>/dev/null | grep -c "Active" || echo "0"
    else
        echo "0"
    fi
}

# Get agent status summary
get_agent_summary() {
    if ! check_file "$AGENT_STATE_FILE"; then
        echo "0:0:0:0"
        return
    fi

    local active waiting blocked ready
    active=$(grep -E "^\| [A-Z]" "$AGENT_STATE_FILE" 2>/dev/null | grep -c "Active") || active=0
    waiting=$(grep -E "^\| [A-Z]" "$AGENT_STATE_FILE" 2>/dev/null | grep -c "Waiting") || waiting=0
    blocked=$(grep -E "^\| [A-Z]" "$AGENT_STATE_FILE" 2>/dev/null | grep -c "Blocked") || blocked=0
    ready=$(grep -E "^\| [A-Z]" "$AGENT_STATE_FILE" 2>/dev/null | grep -c "Ready") || ready=0

    echo "$active:$waiting:$blocked:$ready"
}

# Get active workflows (extract from PROJECT-STATE or detect from epics)
get_active_workflows() {
    local workflows=()

    # Try PROJECT-STATE.md first
    if check_file "$PROJECT_STATE_FILE"; then
        # Look for Current Phase or Active Epic patterns
        local current_phase=$(grep -E "^(Current Phase|Phase):" "$PROJECT_STATE_FILE" 2>/dev/null | head -1 | sed 's/.*:\s*//')
        local current_epic=$(grep -E "^(Current Epic|Epic):" "$PROJECT_STATE_FILE" 2>/dev/null | head -1 | sed 's/.*:\s*//')

        if [ -n "$current_epic" ]; then
            workflows+=("$current_epic")
        fi
    fi

    # Check epics directory for active epics
    local epics_dir="$PROJECT_ROOT/docs/2-MANAGEMENT/epics/current"
    if [ -d "$epics_dir" ]; then
        for epic_file in "$epics_dir"/epic-*.md; do
            if [ -f "$epic_file" ]; then
                local epic_name=$(basename "$epic_file" .md)
                # Check if not already in list
                local found=false
                for w in "${workflows[@]}"; do
                    if [[ "$w" == *"$epic_name"* ]]; then
                        found=true
                        break
                    fi
                done
                if [ "$found" = false ]; then
                    workflows+=("$epic_name")
                fi
            fi
        done
    fi

    echo "${#workflows[@]}"
}

# Get pending tasks count
get_pending_tasks() {
    if check_file "$TASK_QUEUE_FILE"; then
        # Count rows in Queued Tasks table (excluding header and separator)
        grep -E "^\| P[0-3]" "$TASK_QUEUE_FILE" 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Get blocked tasks count
get_blocked_tasks() {
    local count
    if check_file "$TASK_QUEUE_FILE"; then
        count=$(grep -E "^\| P[0-3]" "$TASK_QUEUE_FILE" 2>/dev/null | grep -c "Blocked") || count=0
        echo "$count"
    else
        echo "0"
    fi
}

# Get pending handoffs count
get_pending_handoffs() {
    if check_file "$HANDOFFS_FILE"; then
        grep -E "^\| H-[0-9]" "$HANDOFFS_FILE" 2>/dev/null | grep -E "(Pending|Queued)" | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Get agents with current tasks
get_active_agent_details() {
    if ! check_file "$AGENT_STATE_FILE"; then
        return
    fi

    # Extract active agents with their tasks
    grep -E "^\| [A-Z]" "$AGENT_STATE_FILE" 2>/dev/null | grep "Active" | while read -r line; do
        local agent=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        local task=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        local story=$(echo "$line" | awk -F'|' '{print $5}' | xargs)
        if [ -n "$agent" ] && [ "$agent" != "-" ]; then
            echo "  - $agent: $task ($story)"
        fi
    done
}

# Get pending task details
get_pending_task_details() {
    if ! check_file "$TASK_QUEUE_FILE"; then
        return
    fi

    # Extract queued tasks
    grep -E "^\| P[0-3]" "$TASK_QUEUE_FILE" 2>/dev/null | head -5 | while read -r line; do
        local priority=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
        local task=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
        local story=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
        if [ -n "$task" ] && [ "$task" != "-" ]; then
            echo "  - [$priority] $task ($story)"
        fi
    done
}

# =============================================================================
# Output Functions
# =============================================================================

# Compact one-liner output
print_compact() {
    local agent_summary=$(get_agent_summary)
    local active=$(echo "$agent_summary" | cut -d: -f1)
    local waiting=$(echo "$agent_summary" | cut -d: -f2)
    local blocked=$(echo "$agent_summary" | cut -d: -f3)
    local ready=$(echo "$agent_summary" | cut -d: -f4)

    local workflows=$(get_active_workflows)
    local pending=$(get_pending_tasks)
    local handoffs=$(get_pending_handoffs)
    local blocked_tasks=$(get_blocked_tasks)

    local status_icon=""
    if [ "$blocked" -gt 0 ] || [ "$blocked_tasks" -gt 0 ]; then
        status_icon="[!]"
    else
        status_icon="[OK]"
    fi

    echo -e "${CYAN}STATUS${NC} $status_icon Workflows:$workflows | Agents: ${GREEN}$active active${NC}, ${YELLOW}$waiting waiting${NC}, ${RED}$blocked blocked${NC}, $ready ready | Tasks: $pending pending | Handoffs: $handoffs pending"
}

# JSON output
print_json() {
    local agent_summary=$(get_agent_summary)
    local active_agents=$(echo "$agent_summary" | cut -d: -f1)
    local waiting_agents=$(echo "$agent_summary" | cut -d: -f2)
    local blocked_agents=$(echo "$agent_summary" | cut -d: -f3)
    local ready_agents=$(echo "$agent_summary" | cut -d: -f4)

    local workflows=$(get_active_workflows)
    local pending=$(get_pending_tasks)
    local handoffs=$(get_pending_handoffs)
    local blocked_tasks=$(get_blocked_tasks)

    cat << EOF
{
  "timestamp": "$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)",
  "workflows": {
    "active": $workflows
  },
  "agents": {
    "active": $active_agents,
    "waiting": $waiting_agents,
    "blocked": $blocked_agents,
    "ready": $ready_agents
  },
  "tasks": {
    "pending": $pending,
    "blocked": $blocked_tasks
  },
  "handoffs": {
    "pending": $handoffs
  },
  "health": "$([ "$blocked_agents" -gt 0 ] || [ "$blocked_tasks" -gt 0 ] && echo "degraded" || echo "healthy")"
}
EOF
}

# Full status output
print_full_status() {
    echo ""
    echo -e "${CYAN}${BOLD}STATUS${NC}"
    echo -e "${CYAN}======================================${NC}"
    echo ""

    local agent_summary=$(get_agent_summary)
    local active_agents=$(echo "$agent_summary" | cut -d: -f1)
    local waiting_agents=$(echo "$agent_summary" | cut -d: -f2)
    local blocked_agents=$(echo "$agent_summary" | cut -d: -f3)
    local ready_agents=$(echo "$agent_summary" | cut -d: -f4)

    local workflows=$(get_active_workflows)
    local pending=$(get_pending_tasks)
    local handoffs=$(get_pending_handoffs)
    local blocked_tasks=$(get_blocked_tasks)

    # Health status
    local health_status=""
    local health_color=""
    if [ "$blocked_agents" -gt 0 ] || [ "$blocked_tasks" -gt 0 ]; then
        health_status="DEGRADED"
        health_color="$YELLOW"
    else
        health_status="HEALTHY"
        health_color="$GREEN"
    fi

    echo -e "Health: ${health_color}${BOLD}$health_status${NC}"
    echo ""

    # Workflows section
    if [ "$SHOW_WORKFLOWS" = true ]; then
        echo -e "${BLUE}Active Workflows:${NC} $workflows"

        # Try to show workflow details
        local epics_dir="$PROJECT_ROOT/docs/2-MANAGEMENT/epics/current"
        if [ -d "$epics_dir" ] && [ "$(ls -A "$epics_dir" 2>/dev/null)" ]; then
            for epic_file in "$epics_dir"/epic-*.md; do
                if [ -f "$epic_file" ]; then
                    local epic_name=$(basename "$epic_file" .md | tr '-' ' ' | sed 's/epic /Epic-/')
                    # Try to extract status from file
                    local status=$(grep -m1 "Status:" "$epic_file" 2>/dev/null | sed 's/.*Status:\s*//' | head -c 20)
                    if [ -z "$status" ]; then
                        status="In Progress"
                    fi
                    echo -e "  - ${CYAN}$epic_name${NC}: $status"
                fi
            done
        fi
        echo ""
    fi

    # Agents section
    if [ "$SHOW_AGENTS" = true ]; then
        echo -e "${BLUE}Active Agents:${NC} ${GREEN}$active_agents${NC}"
        get_active_agent_details
        echo ""

        echo -e "${BLUE}Agent Summary:${NC}"
        echo -e "  - Active:  ${GREEN}$active_agents${NC}"
        echo -e "  - Waiting: ${YELLOW}$waiting_agents${NC}"
        echo -e "  - Blocked: ${RED}$blocked_agents${NC}"
        echo -e "  - Ready:   $ready_agents"
        echo ""
    fi

    # Tasks section
    if [ "$SHOW_TASKS" = true ]; then
        echo -e "${BLUE}Pending Tasks:${NC} $pending"
        get_pending_task_details
        echo ""

        if [ "$blocked_tasks" -gt 0 ]; then
            echo -e "${YELLOW}Blocked Tasks:${NC} $blocked_tasks"
            echo ""
        fi

        echo -e "${BLUE}Pending Handoffs:${NC} $handoffs"
        echo ""
    fi

    # Alerts
    local alerts=false
    if [ "$blocked_agents" -gt 0 ]; then
        echo -e "${YELLOW}[!] ALERT: $blocked_agents agent(s) blocked${NC}"
        alerts=true
    fi
    if [ "$blocked_tasks" -gt 0 ]; then
        echo -e "${YELLOW}[!] ALERT: $blocked_tasks task(s) blocked${NC}"
        alerts=true
    fi
    if [ "$handoffs" -gt 0 ]; then
        echo -e "${CYAN}[i] INFO: $handoffs handoff(s) pending${NC}"
        alerts=true
    fi

    if [ "$alerts" = false ]; then
        echo -e "${GREEN}[OK] No alerts${NC}"
    fi

    echo ""
    echo -e "${CYAN}Last Updated:${NC} $(date '+%Y-%m-%d %H:%M')"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

# Check if any state files exist
files_exist=false
for file in "$AGENT_STATE_FILE" "$TASK_QUEUE_FILE" "$HANDOFFS_FILE"; do
    if check_file "$file"; then
        files_exist=true
        break
    fi
done

if [ "$files_exist" = false ]; then
    if [ "$JSON_MODE" = true ]; then
        echo '{"error": "No state files found", "path": "'"$PROJECT_ROOT/.claude/state/"'"}'
    else
        echo -e "${YELLOW}Warning: No state files found in $PROJECT_ROOT/.claude/state/${NC}"
        echo "Run 'bash scripts/init-project.sh' to initialize project structure."
    fi
    exit 1
fi

# Output based on mode
if [ "$JSON_MODE" = true ]; then
    print_json
elif [ "$COMPACT_MODE" = true ]; then
    print_compact
else
    print_full_status
fi

exit 0
