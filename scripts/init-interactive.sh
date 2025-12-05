#!/bin/bash
# Interactive Project Setup Wizard
# Guides user through new project creation or existing project migration
#
# Usage: bash scripts/init-interactive.sh
#
# Author: Agent Methodology Pack
# Version: 1.0

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

# Helper functions
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
get_choice() {
    local prompt="$1"
    local choice
    echo -n -e "${YELLOW}${prompt}${NC} "
    read -r choice
    echo "$choice"
}

# New project flow
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
    else
        print_error "init-project.sh not found"
        exit 1
    fi
}

# Existing project flow
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
        fi
    else
        print_error "analyze-project.sh not found"
        exit 1
    fi
}

# Audit only flow
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

# Main function
main() {
    show_welcome

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
