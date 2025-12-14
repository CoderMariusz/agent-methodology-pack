#!/bin/bash
# =============================================================================
# VISUALIZE-WORKFLOW.SH - Workflow Visualization (Feature #17)
# =============================================================================
# Generates Mermaid diagrams from workflow YAML files.
#
# Usage:
#   bash scripts/visualize-workflow.sh <workflow-file>
#   bash scripts/visualize-workflow.sh .claude/workflows/definitions/engineering/epic-workflow.yaml
#   bash scripts/visualize-workflow.sh --all             # Visualize all workflows
#   bash scripts/visualize-workflow.sh --output diagram.md  # Custom output file
#   bash scripts/visualize-workflow.sh --stdout          # Output to stdout only
#
# Features:
#   - Reads YAML workflow definitions
#   - Generates Mermaid flowchart diagrams
#   - Shows phases, gates, and agents
#   - Supports parallel execution visualization
#   - Saves to .md file or outputs to console
#
# Exit codes:
#   0 - Success
#   1 - Error (file not found, parse error)
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Defaults
OUTPUT_FILE=""
STDOUT_ONLY=false
ALL_WORKFLOWS=false

# Parse arguments
INPUT_FILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --output|-o)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --stdout|-s)
            STDOUT_ONLY=true
            shift
            ;;
        --all|-a)
            ALL_WORKFLOWS=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 <workflow-file> [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --output, -o FILE  Save diagram to specified file"
            echo "  --stdout, -s       Output to stdout only (no file)"
            echo "  --all, -a          Visualize all workflows"
            echo "  --help, -h         Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 .claude/workflows/definitions/engineering/epic-workflow.yaml"
            echo "  $0 --all"
            echo "  $0 epic-workflow.yaml --output docs/diagrams/epic-flow.md"
            exit 0
            ;;
        *)
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            else
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
            fi
            shift
            ;;
    esac
done

# =============================================================================
# Helper Functions
# =============================================================================

# Find workflow file by name or path
find_workflow() {
    local input="$1"

    # Check if it's an absolute path
    if [ -f "$input" ]; then
        echo "$input"
        return 0
    fi

    # Check in project root
    if [ -f "$PROJECT_ROOT/$input" ]; then
        echo "$PROJECT_ROOT/$input"
        return 0
    fi

    # Search in workflow definitions
    local search_dirs=(
        "$PROJECT_ROOT/.claude/workflows/definitions/engineering"
        "$PROJECT_ROOT/.claude/workflows/definitions/product"
        "$PROJECT_ROOT/.claude/workflows/definitions/skills"
        "$PROJECT_ROOT/.claude/workflows/definitions"
    )

    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            # Try exact match
            if [ -f "$dir/$input" ]; then
                echo "$dir/$input"
                return 0
            fi
            # Try with .yaml extension
            if [ -f "$dir/$input.yaml" ]; then
                echo "$dir/$input.yaml"
                return 0
            fi
            # Try fuzzy match
            local found=$(find "$dir" -name "*$input*" -type f 2>/dev/null | head -1)
            if [ -n "$found" ]; then
                echo "$found"
                return 0
            fi
        fi
    done

    return 1
}

# Extract workflow name from YAML
extract_name() {
    local file="$1"
    grep -m1 "^name:" "$file" 2>/dev/null | sed 's/name:\s*//' | tr -d '"' | tr -d "'"
}

# Extract workflow description
extract_description() {
    local file="$1"
    grep -m1 "^description:" "$file" 2>/dev/null | sed 's/description:\s*//' | tr -d '"' | tr -d "'"
}

# Extract phases from YAML
extract_phases() {
    local file="$1"
    # Look for phase IDs
    grep -E "^\s+-\s*id:" "$file" 2>/dev/null | sed 's/.*id:\s*//' | tr -d '"' | tr -d "'"
}

# Extract phase name
extract_phase_name() {
    local file="$1"
    local phase_id="$2"
    # Find the name after the id
    awk -v id="$phase_id" '
        /id:/ && $0 ~ id { found=1 }
        found && /name:/ { gsub(/.*name:\s*/, ""); gsub(/"/, ""); print; found=0 }
    ' "$file" | head -1
}

# Check if phase has parallel execution
is_parallel_phase() {
    local file="$1"
    local phase_id="$2"
    awk -v id="$phase_id" '
        /id:/ && $0 ~ id { found=1 }
        found && /parallel:/ { print "yes"; exit }
        found && /^\s+-\s*id:/ && !($0 ~ id) { found=0 }
    ' "$file" | grep -q "yes"
}

# Extract agents from phase
extract_phase_agents() {
    local file="$1"
    local phase_id="$2"
    awk -v id="$phase_id" '
        /id:/ && $0 ~ id { found=1; depth=0 }
        found && /agent:/ { gsub(/.*agent:\s*/, ""); gsub(/"/, ""); print }
        found && /^\s+-\s*id:/ && !($0 ~ id) { found=0 }
    ' "$file" | sort -u
}

# Extract gate name from phase
extract_gate_name() {
    local file="$1"
    local phase_id="$2"
    awk -v id="$phase_id" '
        /id:/ && $0 ~ id { found=1 }
        found && /gate:/ { in_gate=1 }
        found && in_gate && /name:/ { gsub(/.*name:\s*/, ""); gsub(/"/, ""); print; in_gate=0; found=0 }
        found && /^\s+-\s*id:/ && !($0 ~ id) { found=0 }
    ' "$file" | head -1
}

# Extract gate type
extract_gate_type() {
    local file="$1"
    local phase_id="$2"
    awk -v id="$phase_id" '
        /id:/ && $0 ~ id { found=1 }
        found && /gate:/ { in_gate=1 }
        found && in_gate && /type:/ { gsub(/.*type:\s*/, ""); gsub(/"/, ""); print; in_gate=0; found=0 }
        found && /^\s+-\s*id:/ && !($0 ~ id) { found=0 }
    ' "$file" | head -1
}

# Extract next phase from gate
extract_next_phase() {
    local file="$1"
    local phase_id="$2"
    awk -v id="$phase_id" '
        /id:/ && $0 ~ id { found=1 }
        found && /gate:/ { in_gate=1 }
        found && in_gate && /next:/ { gsub(/.*next:\s*/, ""); gsub(/"/, ""); print; in_gate=0; found=0 }
        found && /^\s+-\s*id:/ && !($0 ~ id) { found=0 }
    ' "$file" | head -1
}

# Generate node ID from name
to_node_id() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -cd '[:alnum:]_'
}

# =============================================================================
# Mermaid Generation
# =============================================================================

generate_mermaid() {
    local file="$1"
    local name=$(extract_name "$file")
    local description=$(extract_description "$file")

    # Start Mermaid diagram
    echo "# $name - Workflow Diagram"
    echo ""
    echo "> $description"
    echo ""
    echo '```mermaid'
    echo "flowchart TD"
    echo ""

    # Subgraph title
    echo "    subgraph WORKFLOW[\"$name\"]"
    echo "    direction TB"
    echo ""

    # Extract all phases
    local phases=($(extract_phases "$file"))
    local prev_phase=""
    local phase_count=0

    for phase_id in "${phases[@]}"; do
        phase_count=$((phase_count + 1))
        local phase_name=$(extract_phase_name "$file" "$phase_id")
        local node_id=$(to_node_id "$phase_id")
        local agents=$(extract_phase_agents "$file" "$phase_id" | tr '\n' ', ' | sed 's/,$//')
        local gate_name=$(extract_gate_name "$file" "$phase_id")
        local gate_type=$(extract_gate_type "$file" "$phase_id")
        local next_phase=$(extract_next_phase "$file" "$phase_id")
        local is_parallel=$(is_parallel_phase "$file" "$phase_id" && echo "yes" || echo "no")

        # Use different shapes based on phase type
        if [ -z "$phase_name" ]; then
            phase_name="$phase_id"
        fi

        # Create phase node
        if [ "$is_parallel" = "yes" ]; then
            # Parallel phase - use double brackets
            echo "    ${node_id}[[\"Phase $phase_count: $phase_name\"]]"
        elif [[ "$phase_id" == "complete" ]]; then
            # Completion - use rounded rectangle
            echo "    ${node_id}(\"$phase_name\")"
        else
            # Regular phase - use rectangle with rounded corners
            echo "    ${node_id}[\"Phase $phase_count: $phase_name\"]"
        fi

        # Add agent annotations
        if [ -n "$agents" ] && [ "$agents" != "," ]; then
            echo "    ${node_id}_agents>\"$agents\"]"
            echo "    ${node_id} --- ${node_id}_agents"
        fi

        # Add gate if present
        if [ -n "$gate_name" ]; then
            local gate_id="${node_id}_gate"
            echo "    ${gate_id}{\"$gate_name\"}"
            echo "    ${node_id} --> ${gate_id}"

            # Connect gate to next phase
            if [ -n "$next_phase" ]; then
                local next_id=$(to_node_id "$next_phase")
                echo "    ${gate_id} -->|PASS| ${next_id}"
                echo "    ${gate_id} -.->|FAIL| ${node_id}"
            fi
        else
            # Direct connection to next phase (if no gate)
            if [ -n "$next_phase" ]; then
                local next_id=$(to_node_id "$next_phase")
                echo "    ${node_id} --> ${next_id}"
            elif [ -n "$prev_phase" ] && [ "$phase_id" != "complete" ]; then
                # Connect to previous if no explicit next
                local prev_id=$(to_node_id "$prev_phase")
                local prev_gate="${prev_id}_gate"
                # Check if prev had a gate (don't double connect)
                if ! grep -q "$prev_gate" <<< "$(extract_gate_name "$file" "$prev_phase")"; then
                    : # Gate already connected
                fi
            fi
        fi

        echo ""
        prev_phase="$phase_id"
    done

    echo "    end"
    echo ""

    # Add styling
    echo "    %% Styling"
    echo "    classDef phase fill:#e1f5fe,stroke:#01579b,stroke-width:2px"
    echo "    classDef gate fill:#fff3e0,stroke:#e65100,stroke-width:2px"
    echo "    classDef agent fill:#f3e5f5,stroke:#4a148c,stroke-width:1px"
    echo "    classDef complete fill:#c8e6c9,stroke:#2e7d32,stroke-width:2px"
    echo ""

    # Apply styles
    for phase_id in "${phases[@]}"; do
        local node_id=$(to_node_id "$phase_id")
        if [[ "$phase_id" == "complete" ]]; then
            echo "    class ${node_id} complete"
        else
            echo "    class ${node_id} phase"
        fi

        # Style gates
        local gate_name=$(extract_gate_name "$file" "$phase_id")
        if [ -n "$gate_name" ]; then
            echo "    class ${node_id}_gate gate"
        fi

        # Style agents
        local agents=$(extract_phase_agents "$file" "$phase_id")
        if [ -n "$agents" ]; then
            echo "    class ${node_id}_agents agent"
        fi
    done

    echo '```'
    echo ""
    echo "---"
    echo ""
    echo "## Phases Summary"
    echo ""
    echo "| # | Phase | Agents | Gate | Type |"
    echo "|---|-------|--------|------|------|"

    phase_count=0
    for phase_id in "${phases[@]}"; do
        phase_count=$((phase_count + 1))
        local phase_name=$(extract_phase_name "$file" "$phase_id")
        local agents=$(extract_phase_agents "$file" "$phase_id" | tr '\n' ', ' | sed 's/,$//')
        local gate_name=$(extract_gate_name "$file" "$phase_id")
        local gate_type=$(extract_gate_type "$file" "$phase_id")

        [ -z "$phase_name" ] && phase_name="$phase_id"
        [ -z "$agents" ] && agents="-"
        [ -z "$gate_name" ] && gate_name="-"
        [ -z "$gate_type" ] && gate_type="-"

        echo "| $phase_count | $phase_name | $agents | $gate_name | $gate_type |"
    done

    echo ""
    echo "---"
    echo "*Generated by visualize-workflow.sh on $(date '+%Y-%m-%d %H:%M')*"
}

# =============================================================================
# Process Single Workflow
# =============================================================================

process_workflow() {
    local input="$1"
    local output="$2"

    # Find the workflow file
    local workflow_file=$(find_workflow "$input")

    if [ -z "$workflow_file" ] || [ ! -f "$workflow_file" ]; then
        echo -e "${RED}Error: Workflow file not found: $input${NC}" >&2
        echo "Searched in:" >&2
        echo "  - $input" >&2
        echo "  - $PROJECT_ROOT/$input" >&2
        echo "  - .claude/workflows/definitions/engineering/" >&2
        echo "  - .claude/workflows/definitions/product/" >&2
        return 1
    fi

    local name=$(extract_name "$workflow_file")
    [ -z "$name" ] && name=$(basename "$workflow_file" .yaml)

    if [ "$STDOUT_ONLY" = true ]; then
        generate_mermaid "$workflow_file"
    else
        # Determine output file
        if [ -z "$output" ]; then
            # Default: same location as workflow, with .md extension
            local dir=$(dirname "$workflow_file")
            local base=$(basename "$workflow_file" .yaml)
            output="$dir/${base}-diagram.md"
        fi

        echo -e "${CYAN}Generating diagram for: ${BOLD}$name${NC}"
        echo -e "  Source: $workflow_file"
        echo -e "  Output: $output"

        # Generate and save
        generate_mermaid "$workflow_file" > "$output"

        echo -e "${GREEN}[OK] Diagram saved to: $output${NC}"
        echo ""
    fi

    return 0
}

# =============================================================================
# Main
# =============================================================================

if [ "$ALL_WORKFLOWS" = true ]; then
    echo -e "${CYAN}${BOLD}Visualizing All Workflows${NC}"
    echo ""

    # Find all workflow files
    workflow_dirs=(
        "$PROJECT_ROOT/.claude/workflows/definitions/engineering"
        "$PROJECT_ROOT/.claude/workflows/definitions/product"
        "$PROJECT_ROOT/.claude/workflows/definitions/skills"
    )

    count=0
    errors=0

    for dir in "${workflow_dirs[@]}"; do
        if [ -d "$dir" ]; then
            for file in "$dir"/*.yaml; do
                if [ -f "$file" ]; then
                    if process_workflow "$file" ""; then
                        count=$((count + 1))
                    else
                        errors=$((errors + 1))
                    fi
                fi
            done
        fi
    done

    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "Total: ${GREEN}$count workflows${NC} visualized"
    if [ $errors -gt 0 ]; then
        echo -e "Errors: ${RED}$errors${NC}"
    fi
    exit 0
fi

# Single workflow mode
if [ -z "$INPUT_FILE" ]; then
    echo -e "${RED}Error: No workflow file specified${NC}"
    echo "Usage: $0 <workflow-file> [OPTIONS]"
    echo "       $0 --all"
    echo ""
    echo "Available workflows:"

    # List available workflows
    workflow_dirs=(
        "$PROJECT_ROOT/.claude/workflows/definitions/engineering"
        "$PROJECT_ROOT/.claude/workflows/definitions/product"
        "$PROJECT_ROOT/.claude/workflows/definitions/skills"
    )

    for dir in "${workflow_dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "  $(basename "$dir")/"
            for file in "$dir"/*.yaml; do
                if [ -f "$file" ]; then
                    local name=$(extract_name "$file")
                    [ -z "$name" ] && name=$(basename "$file" .yaml)
                    echo "    - $(basename "$file"): $name"
                fi
            done
        fi
    done

    exit 1
fi

process_workflow "$INPUT_FILE" "$OUTPUT_FILE"
exit $?
