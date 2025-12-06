#!/bin/bash
# Interactive Project Setup Wizard
# Guides user through new project creation or existing project migration
#
# Usage:
#   Interactive mode: bash scripts/init-interactive.sh
#   CLI mode: bash scripts/init-interactive.sh --mode {new|existing|audit} [--name PROJECT_NAME] [--path PROJECT_PATH]
#
# Examples:
#   bash scripts/init-interactive.sh --mode new --name my-project
#   bash scripts/init-interactive.sh --mode existing --path /path/to/project
#   bash scripts/init-interactive.sh --mode audit --path .
#
# Author: Agent Methodology Pack
# Version: 1.1 (Fixed stdin handling for non-interactive environments)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(dirname "$SCRIPT_DIR")"

# Helper functions (defined early so they can be used in argument parsing)
print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ ERROR: $1${NC}"
}

print_menu_item() {
    echo -e "${CYAN}  [$1]${NC} $2"
}

# Parse CLI arguments (for non-interactive mode)
# Must be after helper functions are defined
CLI_MODE=""
CLI_NAME=""
CLI_PATH=""
SKIP_DISCOVERY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            CLI_MODE="$2"
            shift 2
            ;;
        --name)
            CLI_NAME="$2"
            shift 2
            ;;
        --path)
            CLI_PATH="$2"
            shift 2
            ;;
        --skip-discovery)
            SKIP_DISCOVERY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Interactive mode (no arguments):"
            echo "  $0"
            echo ""
            echo "CLI mode:"
            echo "  $0 --mode {new|existing|audit} [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --mode MODE        Operation mode: new, existing, or audit"
            echo "  --name NAME        Project name (for new mode)"
            echo "  --path PATH        Project path (for existing/audit mode)"
            echo "  --skip-discovery   Skip DISCOVERY-FLOW (advanced users only)"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --mode new --name my-project"
            echo "  $0 --mode existing --path /path/to/project"
            echo "  $0 --mode audit --path ."
            echo ""
            echo "After initialization, DISCOVERY-FLOW will be triggered to:"
            echo "  - Conduct project interview (DISCOVERY-AGENT)"
            echo "  - Ask clarifying questions"
            echo "  - Build PROJECT-UNDERSTANDING.md"
            exit 0
            ;;
        *)
            print_error "Unknown argument: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if we're in a terminal (for interactive mode)
# NOTE: Git Bash on Windows often reports stdin as NOT a terminal
# even when running interactively, so we need to handle both cases
IS_TERMINAL=false
if [ -t 0 ]; then
    IS_TERMINAL=true
fi

# Show welcome banner
show_welcome() {
    clear
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       AGENT METHODOLOGY PACK - INTERACTIVE SETUP           ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${MAGENTA}Welcome to the Agent Methodology Pack Setup Wizard!${NC}"
    echo ""
    echo -e "This wizard will guide you through:"
    echo -e "  • Setting up a new project"
    echo -e "  • Migrating an existing project"
    echo -e "  • Auditing project structure"
    echo ""
    echo -e "${YELLOW}Note: After initialization, DISCOVERY-FLOW will be triggered${NC}"
    echo -e "${YELLOW}      to ensure complete project understanding.${NC}"
    echo ""
}

# Main menu
show_main_menu() {
    print_header "What would you like to do?"
    echo ""
    print_menu_item "1" "Create NEW project (initialize from scratch)"
    print_menu_item "2" "Migrate EXISTING project (analyze and migrate)"
    print_menu_item "3" "AUDIT ONLY (analyze without changes)"
    print_menu_item "4" "Exit"
    echo ""
}

# Get user choice
# Handles both interactive terminal and non-interactive (piped) input
# In non-interactive mode, provides clear error message
get_choice() {
    local prompt="$1"
    local choice

    # IMPORTANT: Prompt goes to stderr (>&2) so it's not captured by command substitution
    echo -n -e "${YELLOW}${prompt}${NC} " >&2

    # Try to read from stdin
    # IMPORTANT: Using 'read -r' requires stdin to be a terminal
    # If stdin is redirected/piped, read will fail or hang
    if read -r choice 2>/dev/null; then
        # IMPORTANT: Remove Windows CR (carriage return) and trim whitespace
        # Git Bash on Windows may include \r in input
        choice="${choice%$'\r'}"      # Remove trailing CR
        choice="${choice#"${choice%%[![:space:]]*}"}"  # Trim leading whitespace
        choice="${choice%"${choice##*[![:space:]]}"}"  # Trim trailing whitespace
        echo "$choice"
    else
        # stdin is not available (piped input, non-interactive mode)
        echo ""
        print_error "Cannot read input in non-interactive mode"
        print_info "Use CLI arguments instead:"
        print_info "  bash $0 --mode {new|existing|audit} [--name PROJECT_NAME] [--path PATH]"
        print_info "  See --help for more details"
        exit 1
    fi
}

# New project flow (CLI version)
new_project_flow_cli() {
    local project_name="$1"

    print_header "NEW PROJECT SETUP (CLI MODE)"
    echo ""

    # Validate project name
    if [ -z "$project_name" ]; then
        print_error "Project name is required in CLI mode"
        print_info "Usage: $0 --mode new --name PROJECT_NAME"
        exit 1
    fi

    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Project name can only contain letters, numbers, hyphens, and underscores"
        exit 1
    fi

    print_info "Project name: ${project_name}"

    # Run init-project.sh
    print_header "INITIALIZING PROJECT"
    echo ""

    if [ -f "$PACK_ROOT/scripts/init-project.sh" ]; then
        bash "$PACK_ROOT/scripts/init-project.sh" "$project_name"
        print_success "Project initialized successfully!"

        # Show DISCOVERY-FLOW info with project data
        show_discovery_flow_info "." "new" "$project_name"
    else
        print_error "init-project.sh not found"
        exit 1
    fi
}

# New project flow (Interactive version)
new_project_flow() {
    print_header "NEW PROJECT SETUP"
    echo ""

    # Get project name
    local project_name
    while true; do
        project_name=$(get_choice "Enter project name (e.g., my-awesome-app):")

        if [ -z "$project_name" ]; then
            print_error "Project name cannot be empty"
            continue
        fi

        if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            print_error "Project name can only contain letters, numbers, hyphens, and underscores"
            continue
        fi

        break
    done

    # Confirm
    echo ""
    print_info "Project name: ${project_name}"
    local confirm=$(get_choice "Proceed with initialization? (y/n):")

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_warning "Initialization cancelled"
        return
    fi

    # Run init-project.sh
    print_header "INITIALIZING PROJECT"
    echo ""

    if [ -f "$PACK_ROOT/scripts/init-project.sh" ]; then
        bash "$PACK_ROOT/scripts/init-project.sh" "$project_name"

        # Show DISCOVERY-FLOW info with project data
        show_discovery_flow_info "." "new" "$project_name"
    else
        print_error "init-project.sh not found"
        exit 1
    fi
}

# Existing project flow (CLI version)
existing_project_flow_cli() {
    local project_path="$1"

    print_header "EXISTING PROJECT MIGRATION (CLI MODE)"
    echo ""

    # Default to current directory if not provided
    if [ -z "$project_path" ]; then
        project_path="."
    fi

    # Validate path
    if [ ! -d "$project_path" ]; then
        print_error "Directory does not exist: $project_path"
        exit 1
    fi

    # Show info
    print_info "Project path: $(cd "$project_path" && pwd)"
    print_info "Analyzing project structure..."
    echo ""

    # Run analyze-project.sh
    print_header "ANALYZING PROJECT"
    echo ""

    if [ -f "$PACK_ROOT/scripts/analyze-project.sh" ]; then
        bash "$PACK_ROOT/scripts/analyze-project.sh" "$project_path"

        # Show results
        local audit_file="$project_path/.claude/migration/AUDIT-REPORT.md"
        if [ -f "$audit_file" ]; then
            echo ""
            print_header "ANALYSIS COMPLETE"
            echo ""
            print_success "Audit report generated: $audit_file"
            echo ""

            # Show summary
            print_info "Summary:"
            echo ""
            grep -A 10 "^## Summary" "$audit_file" 2>/dev/null || echo "No summary available"
            echo ""
            print_info "Migration features coming soon!"
            print_info "Please review $audit_file for recommendations"

            # Show DISCOVERY-FLOW info with project data
            show_discovery_flow_info "$project_path" "migrate" "$(basename "$(cd "$project_path" && pwd)")"
        fi
    else
        print_error "analyze-project.sh not found"
        exit 1
    fi
}

# Existing project flow (Interactive version)
existing_project_flow() {
    print_header "EXISTING PROJECT MIGRATION"
    echo ""

    # Get project path
    local project_path
    project_path=$(get_choice "Enter path to existing project (or press Enter for current directory):")

    if [ -z "$project_path" ]; then
        project_path="."
    fi

    # Validate path
    if [ ! -d "$project_path" ]; then
        print_error "Directory does not exist: $project_path"
        return
    fi

    # Show info
    echo ""
    print_info "Project path: $(cd "$project_path" && pwd)"
    print_info "This will analyze your project structure"
    echo ""

    local confirm=$(get_choice "Start analysis? (y/n):")

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        print_warning "Analysis cancelled"
        return
    fi

    # Run analyze-project.sh
    print_header "ANALYZING PROJECT"
    echo ""

    if [ -f "$PACK_ROOT/scripts/analyze-project.sh" ]; then
        bash "$PACK_ROOT/scripts/analyze-project.sh" "$project_path"

        # Show results
        local audit_file="$project_path/.claude/migration/AUDIT-REPORT.md"
        if [ -f "$audit_file" ]; then
            echo ""
            print_header "ANALYSIS COMPLETE"
            echo ""
            print_success "Audit report generated: $audit_file"
            echo ""

            # Show summary
            print_info "Summary:"
            echo ""
            grep -A 10 "^## Summary" "$audit_file" 2>/dev/null || echo "No summary available"
            echo ""

            # Ask about migration
            local migrate=$(get_choice "Would you like to migrate documentation now? (y/n):")

            if [[ "$migrate" == "y" || "$migrate" == "Y" ]]; then
                echo ""
                print_header "MIGRATION"
                echo ""
                print_info "Migration features coming soon!"
                print_info "For now, please review $audit_file"
                print_info "And manually organize files according to recommendations"
            fi

            # Show DISCOVERY-FLOW info
            show_discovery_flow_info
        fi
    else
        print_error "analyze-project.sh not found"
        exit 1
    fi
}

# Audit only flow (CLI version)
audit_only_flow_cli() {
    local project_path="$1"

    print_header "PROJECT AUDIT (CLI MODE)"
    echo ""

    # Default to current directory if not provided
    if [ -z "$project_path" ]; then
        project_path="."
    fi

    # Validate path
    if [ ! -d "$project_path" ]; then
        print_error "Directory does not exist: $project_path"
        exit 1
    fi

    print_info "Project path: $(cd "$project_path" && pwd)"
    print_info "Starting audit..."
    echo ""

    # Run analyze-project.sh with audit flag
    print_header "AUDITING PROJECT"
    echo ""

    if [ -f "$PACK_ROOT/scripts/analyze-project.sh" ]; then
        bash "$PACK_ROOT/scripts/analyze-project.sh" "$project_path" --output "$project_path/.claude/audit"

        # Show results
        local audit_file="$project_path/.claude/audit/AUDIT-REPORT.md"
        if [ -f "$audit_file" ]; then
            echo ""
            print_header "AUDIT COMPLETE"
            echo ""
            print_success "Audit report: $audit_file"
            echo ""
            print_info "Review the audit report for project analysis"
        fi
    else
        print_error "analyze-project.sh not found"
        exit 1
    fi
}

# Audit only flow (Interactive version)
audit_only_flow() {
    print_header "PROJECT AUDIT"
    echo ""

    # Get project path
    local project_path
    project_path=$(get_choice "Enter path to project (or press Enter for current directory):")

    if [ -z "$project_path" ]; then
        project_path="."
    fi

    # Validate path
    if [ ! -d "$project_path" ]; then
        print_error "Directory does not exist: $project_path"
        return
    fi

    # Run analyze-project.sh with audit flag
    print_header "AUDITING PROJECT"
    echo ""

    if [ -f "$PACK_ROOT/scripts/analyze-project.sh" ]; then
        bash "$PACK_ROOT/scripts/analyze-project.sh" "$project_path" --output "$project_path/.claude/audit"

        # Show results
        local audit_file="$project_path/.claude/audit/AUDIT-REPORT.md"
        if [ -f "$audit_file" ]; then
            echo ""
            print_header "AUDIT COMPLETE"
            echo ""
            print_success "Audit report: $audit_file"
            echo ""

            # Ask to view
            local view=$(get_choice "Open audit report? (y/n):")

            if [[ "$view" == "y" || "$view" == "Y" ]]; then
                if command -v less &> /dev/null; then
                    less "$audit_file"
                elif command -v more &> /dev/null; then
                    more "$audit_file"
                else
                    cat "$audit_file"
                fi
            fi
        fi
    else
        print_error "analyze-project.sh not found"
        exit 1
    fi
}

# Show progress indicator
show_progress() {
    local message="$1"
    local duration="${2:-3}"

    print_step "$message"
    for i in $(seq 1 $duration); do
        echo -n "."
        sleep 0.3
    done
    echo ""
}

# Create startup prompt file for Claude
# This file contains all collected data and instructions to start the right flow
create_claude_startup() {
    local project_path="$1"
    local flow_type="$2"  # "new" or "migrate" or "audit"
    local project_name="$3"

    local startup_file="$project_path/.claude/STARTUP-PROMPT.md"
    mkdir -p "$project_path/.claude"

    cat > "$startup_file" << EOF
# Claude Startup Prompt

## Auto-generated by init-interactive.sh
**Date:** $(date +%Y-%m-%d)
**Flow Type:** $flow_type
**Project:** $project_name
**Path:** $(cd "$project_path" && pwd)

---

## Instructions for Claude

@ORCHESTRATOR.md

### Context
This is a ${flow_type} project initialization.

### Required Flow
Start with **DISCOVERY-FLOW** to ensure complete project understanding.

### Flow Steps
1. **DISCOVERY-AGENT** - Conduct project interview
2. **Domain agents** - Ask specific questions (ARCHITECT, PM, RESEARCH)
3. **DOC-AUDITOR** - Scan and validate documentation
4. **Gap Analysis** - Identify missing information
5. **Confirmation** - Get user approval

### Project Data Collected
- **Project Name:** $project_name
- **Project Path:** $(cd "$project_path" && pwd)
- **Flow Type:** $flow_type
- **Initialized:** $(date)

### Start Command
\`\`\`
Start DISCOVERY-FLOW for this ${flow_type} project.
Project name: $project_name
\`\`\`

---

**To use:** Copy this file content or reference @.claude/STARTUP-PROMPT.md
EOF

    echo "$startup_file"
}

# Show DISCOVERY-FLOW information and create startup file
show_discovery_flow_info() {
    local project_path="${1:-.}"
    local flow_type="${2:-new}"
    local project_name="${3:-$(basename "$(cd "$project_path" && pwd)")}"

    if [ "$SKIP_DISCOVERY" = false ]; then
        # Create startup file
        local startup_file
        startup_file=$(create_claude_startup "$project_path" "$flow_type" "$project_name")

        echo ""
        print_header "DISCOVERY FLOW"
        print_info "Before starting development, DISCOVERY-FLOW will be triggered."
        print_info "This ensures complete project understanding."
        echo ""
        print_info "DISCOVERY-FLOW phases:"
        echo "  1. Initial Scan (DOC-AUDITOR)"
        echo "  2. Discovery Interview (DISCOVERY-AGENT)"
        echo "  3. Domain Questions (ARCHITECT + PM + RESEARCH)"
        echo "  4. Gap Analysis"
        echo "  5. Confirmation"
        echo ""

        # Show startup file location
        print_success "Startup file created: $startup_file"
        echo ""
        print_header "HOW TO START CLAUDE"
        echo ""
        echo -e "  ${GREEN}Option 1:${NC} Open Claude Code in this directory and say:"
        echo -e "           ${YELLOW}Read @.claude/STARTUP-PROMPT.md and start the flow${NC}"
        echo ""
        echo -e "  ${GREEN}Option 2:${NC} Copy this command:"
        echo -e "           ${YELLOW}@ORCHESTRATOR.md Start DISCOVERY-FLOW for $flow_type project${NC}"
        echo ""

        # Try to copy to clipboard (cross-platform)
        local startup_content="Read @.claude/STARTUP-PROMPT.md and start DISCOVERY-FLOW"
        if command -v clip.exe &> /dev/null; then
            echo "$startup_content" | clip.exe
            print_success "Command copied to clipboard!"
        elif command -v pbcopy &> /dev/null; then
            echo "$startup_content" | pbcopy
            print_success "Command copied to clipboard!"
        elif command -v xclip &> /dev/null; then
            echo "$startup_content" | xclip -selection clipboard
            print_success "Command copied to clipboard!"
        fi

        echo ""
        # Ask if user wants to auto-start Claude
        echo -n -e "${YELLOW}Start Claude Code automatically? (y/n):${NC} " >&2
        read -r auto_start
        auto_start="${auto_start%$'\r'}"

        if [[ "$auto_start" == "y" || "$auto_start" == "Y" ]]; then
            if command -v claude &> /dev/null; then
                echo ""
                print_info "Starting Claude Code..."
                echo ""

                # Change to project directory and start Claude with prompt
                cd "$project_path" 2>/dev/null || true

                # Start Claude with the startup prompt (interactive session)
                claude "Read @.claude/STARTUP-PROMPT.md and start DISCOVERY-FLOW for this $flow_type project. Project: $project_name"
            else
                print_error "Claude CLI not found. Please start Claude manually."
                print_info "Install: npm install -g @anthropic-ai/claude-code"
            fi
        fi
    fi
}

# Main function - handles both CLI and interactive modes
main() {
    # CLI MODE: If --mode argument provided
    if [ -n "$CLI_MODE" ]; then
        case "$CLI_MODE" in
            new)
                new_project_flow_cli "$CLI_NAME"
                ;;
            existing)
                existing_project_flow_cli "$CLI_PATH"
                ;;
            audit)
                audit_only_flow_cli "$CLI_PATH"
                ;;
            *)
                print_error "Invalid mode: $CLI_MODE"
                print_info "Valid modes: new, existing, audit"
                print_info "Use --help for more information"
                exit 1
                ;;
        esac
        exit 0
    fi

    # INTERACTIVE MODE: Check if stdin is available
    # NOTE: In Git Bash on Windows, stdin might not be detected as terminal
    # even when running interactively. We'll try to proceed and let get_choice()
    # handle the error if stdin is truly unavailable.

    if [ "$IS_TERMINAL" = false ]; then
        print_warning "Warning: stdin is not detected as a terminal"
        print_info "If you encounter issues, use CLI mode instead:"
        print_info "  bash $0 --mode {new|existing|audit} [OPTIONS]"
        print_info "  Use --help for details"
        echo ""
        print_info "Attempting to continue in interactive mode..."
        echo ""
        sleep 2
    fi

    # Show welcome screen
    show_welcome

    # Interactive menu loop
    while true; do
        show_main_menu

        local choice
        choice=$(get_choice "Select option [1-4]:")

        case "$choice" in
            1)
                new_project_flow
                ;;
            2)
                existing_project_flow
                ;;
            3)
                audit_only_flow
                ;;
            4)
                echo ""
                print_info "Thank you for using Agent Methodology Pack!"
                echo ""
                exit 0
                ;;
            *)
                print_error "Invalid option. Please select 1-4."
                sleep 1
                ;;
        esac

        # Pause before showing menu again
        echo ""
        echo -e "${YELLOW}Press Enter to return to main menu...${NC}"
        read -r
        clear
    done
}

# Run main function
main
