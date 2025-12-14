#!/bin/bash
# =============================================================================
# AGENT-HEALTH.SH - Agent Health Check (Feature #19)
# =============================================================================
# Checks agent "health" - validates agent files, frontmatter, and readiness.
#
# Usage:
#   bash scripts/agent-health.sh <agent-name>      # Check specific agent
#   bash scripts/agent-health.sh --all             # Check all agents
#   bash scripts/agent-health.sh --summary         # Quick summary only
#   bash scripts/agent-health.sh --json            # JSON output
#
# Health Status:
#   HEALTHY   - All checks passed
#   DEGRADED  - Warnings present but functional
#   UNHEALTHY - Critical issues, agent not usable
#
# Exit codes:
#   0 - HEALTHY
#   1 - DEGRADED
#   2 - UNHEALTHY
#   3 - Agent not found
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

# Agent directories
AGENTS_DIR="$PROJECT_ROOT/.claude/agents"

# Mode flags
ALL_AGENTS=false
SUMMARY_MODE=false
JSON_MODE=false

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
WARNING_CHECKS=0
FAILED_CHECKS=0

# Parse arguments
AGENT_NAME=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --all|-a)
            ALL_AGENTS=true
            shift
            ;;
        --summary|-s)
            SUMMARY_MODE=true
            shift
            ;;
        --json|-j)
            JSON_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 <agent-name> [OPTIONS]"
            echo "       $0 --all [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --all, -a      Check all agents"
            echo "  --summary, -s  Quick summary only"
            echo "  --json, -j     JSON output"
            echo "  --help, -h     Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 BACKEND-DEV"
            echo "  $0 research-agent"
            echo "  $0 --all --summary"
            echo ""
            echo "Health Status:"
            echo "  HEALTHY   - All checks passed"
            echo "  DEGRADED  - Warnings present but functional"
            echo "  UNHEALTHY - Critical issues, agent not usable"
            exit 0
            ;;
        *)
            if [ -z "$AGENT_NAME" ]; then
                AGENT_NAME="$1"
            else
                echo -e "${RED}Unknown option: $1${NC}"
                exit 3
            fi
            shift
            ;;
    esac
done

# =============================================================================
# Helper Functions
# =============================================================================

# Find agent file by name
find_agent() {
    local name="$1"
    local search_name=$(echo "$name" | tr '[:lower:]' '[:upper:]')

    # Search in agent directories
    local agent_dirs=(
        "$AGENTS_DIR/planning"
        "$AGENTS_DIR/development"
        "$AGENTS_DIR/quality"
        "$AGENTS_DIR/operations"
        "$AGENTS_DIR/skills"
        "$AGENTS_DIR"
    )

    for dir in "${agent_dirs[@]}"; do
        if [ -d "$dir" ]; then
            # Try exact match (case insensitive)
            for file in "$dir"/*.md; do
                if [ -f "$file" ]; then
                    local basename=$(basename "$file" .md | tr '[:lower:]' '[:upper:]')
                    if [ "$basename" = "$search_name" ]; then
                        echo "$file"
                        return 0
                    fi
                fi
            done
        fi
    done

    # Try fuzzy match
    for dir in "${agent_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local found=$(find "$dir" -maxdepth 1 -name "*${name}*" -type f 2>/dev/null | head -1)
            if [ -n "$found" ]; then
                echo "$found"
                return 0
            fi
        fi
    done

    return 1
}

# Record check result
record_check() {
    local status="$1"  # pass, warn, fail
    local message="$2"

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    case $status in
        pass)
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
            [ "$SUMMARY_MODE" = false ] && [ "$JSON_MODE" = false ] && echo -e "  ${GREEN}[OK]${NC} $message"
            ;;
        warn)
            WARNING_CHECKS=$((WARNING_CHECKS + 1))
            [ "$SUMMARY_MODE" = false ] && [ "$JSON_MODE" = false ] && echo -e "  ${YELLOW}[!]${NC} $message"
            ;;
        fail)
            FAILED_CHECKS=$((FAILED_CHECKS + 1))
            [ "$SUMMARY_MODE" = false ] && [ "$JSON_MODE" = false ] && echo -e "  ${RED}[X]${NC} $message"
            ;;
    esac
}

# Extract frontmatter value
extract_frontmatter() {
    local file="$1"
    local field="$2"

    # Extract YAML frontmatter (between first two ---)
    local frontmatter=$(sed -n '/^---$/,/^---$/p' "$file" 2>/dev/null | head -20)
    echo "$frontmatter" | grep -m1 "^${field}:" | sed "s/${field}:\s*//" | tr -d '"' | tr -d "'"
}

# Check if frontmatter exists
has_frontmatter() {
    local file="$1"
    head -1 "$file" 2>/dev/null | grep -q "^---"
}

# =============================================================================
# Health Check Functions
# =============================================================================

# Check 1: File exists and is readable
check_file_exists() {
    local file="$1"
    if [ -f "$file" ] && [ -r "$file" ]; then
        record_check "pass" "File exists and is readable"
        return 0
    else
        record_check "fail" "File not found or not readable"
        return 1
    fi
}

# Check 2: Has valid YAML frontmatter
check_frontmatter() {
    local file="$1"
    if has_frontmatter "$file"; then
        record_check "pass" "YAML frontmatter present"
        return 0
    else
        record_check "fail" "Missing YAML frontmatter (must start with ---)"
        return 1
    fi
}

# Check 3: Has required name field
check_name_field() {
    local file="$1"
    local name=$(extract_frontmatter "$file" "name")

    if [ -n "$name" ]; then
        record_check "pass" "Name field: $name"
        return 0
    else
        record_check "fail" "Missing 'name' field in frontmatter"
        return 1
    fi
}

# Check 4: Has required tools field
check_tools_field() {
    local file="$1"
    local tools=$(extract_frontmatter "$file" "tools")

    if [ -n "$tools" ]; then
        record_check "pass" "Tools field defined: $tools"
        return 0
    else
        record_check "warn" "Missing 'tools' field in frontmatter"
        return 1
    fi
}

# Check 5: Has required model field
check_model_field() {
    local file="$1"
    local model=$(extract_frontmatter "$file" "model")

    if [ -z "$model" ]; then
        record_check "warn" "Missing 'model' field in frontmatter"
        return 1
    elif [[ "$model" =~ ^(sonnet|opus|haiku)$ ]]; then
        record_check "pass" "Model field: $model"
        return 0
    else
        record_check "warn" "Invalid model value: $model (expected: sonnet|opus|haiku)"
        return 1
    fi
}

# Check 6: Has description field
check_description_field() {
    local file="$1"
    local description=$(extract_frontmatter "$file" "description")

    if [ -n "$description" ]; then
        record_check "pass" "Description: $(echo "$description" | head -c 50)..."
        return 0
    else
        record_check "warn" "Missing 'description' field in frontmatter"
        return 1
    fi
}

# Check 7: Has workflow section
check_workflow_section() {
    local file="$1"
    if grep -q "## Workflow" "$file" 2>/dev/null; then
        record_check "pass" "Workflow section present"
        return 0
    else
        record_check "warn" "Missing '## Workflow' section"
        return 1
    fi
}

# Check 8: Has interface section
check_interface_section() {
    local file="$1"
    if grep -q "## Interface" "$file" 2>/dev/null; then
        record_check "pass" "Interface section present"
        return 0
    else
        record_check "warn" "Missing '## Interface' section"
        return 1
    fi
}

# Check 9: File size is reasonable
check_file_size() {
    local file="$1"
    local line_count=$(wc -l < "$file" 2>/dev/null | tr -d ' ')

    if [ "$line_count" -lt 50 ]; then
        record_check "warn" "File seems too short ($line_count lines, expected 100+)"
        return 1
    elif [ "$line_count" -gt 1000 ]; then
        record_check "warn" "File very large ($line_count lines, consider splitting)"
        return 1
    else
        record_check "pass" "File size OK ($line_count lines)"
        return 0
    fi
}

# Check 10: No TODO placeholders
check_no_todos() {
    local file="$1"
    local todo_count
    todo_count=$(grep -c "{{TODO" "$file" 2>/dev/null) || todo_count=0

    if [ "$todo_count" -eq 0 ]; then
        record_check "pass" "No unfilled {{TODO}} placeholders"
        return 0
    else
        record_check "warn" "Found $todo_count unfilled {{TODO}} placeholders"
        return 1
    fi
}

# Check 11: Has handoff protocols
check_handoff_protocols() {
    local file="$1"
    if grep -qE "(## Handoff|handoff)" "$file" 2>/dev/null; then
        record_check "pass" "Handoff protocols present"
        return 0
    else
        record_check "warn" "Missing handoff protocols section"
        return 1
    fi
}

# Check 12: Has error recovery
check_error_recovery() {
    local file="$1"
    if grep -qE "(## Error Recovery|error recovery|Error Handling)" "$file" 2>/dev/null; then
        record_check "pass" "Error recovery section present"
        return 0
    else
        record_check "warn" "Missing error recovery section"
        return 1
    fi
}

# =============================================================================
# Run Health Check on Single Agent
# =============================================================================

run_health_check() {
    local agent_input="$1"

    # Reset counters
    TOTAL_CHECKS=0
    PASSED_CHECKS=0
    WARNING_CHECKS=0
    FAILED_CHECKS=0

    # Find agent file
    local agent_file=$(find_agent "$agent_input")

    if [ -z "$agent_file" ]; then
        if [ "$JSON_MODE" = true ]; then
            echo '{"agent": "'"$agent_input"'", "status": "NOT_FOUND", "error": "Agent file not found"}'
        else
            echo -e "${RED}[X] Agent not found: $agent_input${NC}"
            echo ""
            echo "Available agents:"
            list_agents
        fi
        return 3
    fi

    local agent_name=$(basename "$agent_file" .md)

    if [ "$JSON_MODE" = false ] && [ "$SUMMARY_MODE" = false ]; then
        echo ""
        echo -e "${CYAN}${BOLD}Agent Health Check: $agent_name${NC}"
        echo -e "${CYAN}========================================${NC}"
        echo -e "File: $agent_file"
        echo ""
    fi

    # Run all checks
    check_file_exists "$agent_file"
    check_frontmatter "$agent_file"
    check_name_field "$agent_file"
    check_tools_field "$agent_file"
    check_model_field "$agent_file"
    check_description_field "$agent_file"
    check_workflow_section "$agent_file"
    check_interface_section "$agent_file"
    check_file_size "$agent_file"
    check_no_todos "$agent_file"
    check_handoff_protocols "$agent_file"
    check_error_recovery "$agent_file"

    # Determine health status
    local health_status=""
    local exit_code=0

    if [ "$FAILED_CHECKS" -gt 0 ]; then
        health_status="UNHEALTHY"
        exit_code=2
    elif [ "$WARNING_CHECKS" -gt 0 ]; then
        health_status="DEGRADED"
        exit_code=1
    else
        health_status="HEALTHY"
        exit_code=0
    fi

    # Output results
    if [ "$JSON_MODE" = true ]; then
        cat << EOF
{
  "agent": "$agent_name",
  "file": "$agent_file",
  "status": "$health_status",
  "checks": {
    "total": $TOTAL_CHECKS,
    "passed": $PASSED_CHECKS,
    "warnings": $WARNING_CHECKS,
    "failed": $FAILED_CHECKS
  },
  "frontmatter": {
    "name": "$(extract_frontmatter "$agent_file" "name")",
    "model": "$(extract_frontmatter "$agent_file" "model")",
    "type": "$(extract_frontmatter "$agent_file" "type")"
  }
}
EOF
    elif [ "$SUMMARY_MODE" = true ]; then
        case $health_status in
            HEALTHY)
                echo -e "${GREEN}[OK]${NC} $agent_name - HEALTHY ($PASSED_CHECKS/$TOTAL_CHECKS checks passed)"
                ;;
            DEGRADED)
                echo -e "${YELLOW}[!]${NC} $agent_name - DEGRADED ($WARNING_CHECKS warnings)"
                ;;
            UNHEALTHY)
                echo -e "${RED}[X]${NC} $agent_name - UNHEALTHY ($FAILED_CHECKS critical failures)"
                ;;
        esac
    else
        echo ""
        echo -e "${CYAN}----------------------------------------${NC}"
        echo -e "Results: $PASSED_CHECKS passed, $WARNING_CHECKS warnings, $FAILED_CHECKS failed"
        echo ""

        case $health_status in
            HEALTHY)
                echo -e "${GREEN}${BOLD}[OK] $agent_name - HEALTHY${NC}"
                echo -e "${GREEN}All checks passed. Agent is ready for use.${NC}"
                ;;
            DEGRADED)
                echo -e "${YELLOW}${BOLD}[!] $agent_name - DEGRADED${NC}"
                echo -e "${YELLOW}Agent is functional but has warnings. Review recommended.${NC}"
                ;;
            UNHEALTHY)
                echo -e "${RED}${BOLD}[X] $agent_name - UNHEALTHY${NC}"
                echo -e "${RED}Agent has critical issues and may not work correctly.${NC}"
                ;;
        esac
        echo ""
    fi

    return $exit_code
}

# =============================================================================
# List Available Agents
# =============================================================================

list_agents() {
    local agent_dirs=(
        "$AGENTS_DIR/planning"
        "$AGENTS_DIR/development"
        "$AGENTS_DIR/quality"
        "$AGENTS_DIR/operations"
        "$AGENTS_DIR/skills"
        "$AGENTS_DIR"
    )

    for dir in "${agent_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local category=$(basename "$dir")
            [ "$category" = "agents" ] && category="root"

            local found=false
            for file in "$dir"/*.md; do
                if [ -f "$file" ]; then
                    if [ "$found" = false ]; then
                        echo "  $category/"
                        found=true
                    fi
                    local name=$(basename "$file" .md)
                    echo "    - $name"
                fi
            done
        fi
    done
}

# =============================================================================
# Check All Agents
# =============================================================================

check_all_agents() {
    local agent_files=()

    # Find all agent files
    local agent_dirs=(
        "$AGENTS_DIR/planning"
        "$AGENTS_DIR/development"
        "$AGENTS_DIR/quality"
        "$AGENTS_DIR/operations"
        "$AGENTS_DIR/skills"
        "$AGENTS_DIR"
    )

    for dir in "${agent_dirs[@]}"; do
        if [ -d "$dir" ]; then
            for file in "$dir"/*.md; do
                if [ -f "$file" ]; then
                    agent_files+=("$file")
                fi
            done
        fi
    done

    if [ ${#agent_files[@]} -eq 0 ]; then
        echo -e "${RED}No agent files found in $AGENTS_DIR${NC}"
        exit 3
    fi

    local total_agents=${#agent_files[@]}
    local healthy_count=0
    local degraded_count=0
    local unhealthy_count=0

    if [ "$JSON_MODE" = true ]; then
        echo '{"agents": ['
    else
        echo ""
        echo -e "${CYAN}${BOLD}Agent Health Check - All Agents${NC}"
        echo -e "${CYAN}========================================${NC}"
        echo -e "Found $total_agents agent(s)"
        echo ""
    fi

    local first=true
    for file in "${agent_files[@]}"; do
        local agent_name=$(basename "$file" .md)

        if [ "$JSON_MODE" = true ]; then
            [ "$first" = false ] && echo ","
            first=false
        fi

        run_health_check "$agent_name"
        local result=$?

        case $result in
            0) healthy_count=$((healthy_count + 1)) ;;
            1) degraded_count=$((degraded_count + 1)) ;;
            2) unhealthy_count=$((unhealthy_count + 1)) ;;
        esac
    done

    if [ "$JSON_MODE" = true ]; then
        echo '],'
        echo '"summary": {'
        echo "  \"total\": $total_agents,"
        echo "  \"healthy\": $healthy_count,"
        echo "  \"degraded\": $degraded_count,"
        echo "  \"unhealthy\": $unhealthy_count"
        echo '}}'
    else
        echo ""
        echo -e "${CYAN}========================================${NC}"
        echo -e "${BOLD}Summary${NC}"
        echo -e "  Total:     $total_agents"
        echo -e "  ${GREEN}Healthy:${NC}   $healthy_count"
        echo -e "  ${YELLOW}Degraded:${NC}  $degraded_count"
        echo -e "  ${RED}Unhealthy:${NC} $unhealthy_count"
        echo ""

        if [ "$unhealthy_count" -gt 0 ]; then
            echo -e "${RED}${BOLD}[!] $unhealthy_count agent(s) have critical issues${NC}"
            exit 2
        elif [ "$degraded_count" -gt 0 ]; then
            echo -e "${YELLOW}${BOLD}[!] $degraded_count agent(s) have warnings${NC}"
            exit 1
        else
            echo -e "${GREEN}${BOLD}[OK] All agents are healthy${NC}"
            exit 0
        fi
    fi
}

# =============================================================================
# Main
# =============================================================================

if [ "$ALL_AGENTS" = true ]; then
    check_all_agents
    exit $?
fi

if [ -z "$AGENT_NAME" ]; then
    echo -e "${RED}Error: No agent specified${NC}"
    echo ""
    echo "Usage: $0 <agent-name>"
    echo "       $0 --all"
    echo ""
    echo "Available agents:"
    list_agents
    exit 3
fi

run_health_check "$AGENT_NAME"
exit $?
