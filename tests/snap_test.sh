#!/usr/bin/env zsh
#
# snap_test.sh - Test suite for the snap function
# Simple approach: assumes snap function is already loaded in current shell
# Usage: source ~/dotfiles/config/zsh/snap.zsh && ./snap_test.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test utilities
log_info() {
    print -P "%F{blue}[INFO]%f $1"
}

log_success() {
    print -P "%F{green}[PASS]%f $1"
    ((TESTS_PASSED++))
}

log_failure() {
    print -P "%F{red}[FAIL]%f $1"
    ((TESTS_FAILED++))
}

run_test() {
    local test_name="$1"
    ((TESTS_RUN++))
    log_info "Running: $test_name"
}

# Source the snap function
source_snap() {
    local snap_file="$HOME/dotfiles/config/zsh/snap.zsh"
    
    if [[ ! -f "$snap_file" ]]; then
        print -P "%F{red}Error: snap.zsh not found at $snap_file%f"
        return 1
    fi
    
    source "$snap_file"
    
    if (( ! $+functions[snap] )); then
        print -P "%F{red}Error: snap function failed to load%f"
        return 1
    fi
    
    log_info "snap function loaded ✓"
    return 0
}

# Create temporary directory for tests
create_test_dir() {
    local test_name="$1"
    mktemp -d "/tmp/snap_test_${test_name}_XXXXXX"
}

# Cleanup function
cleanup_test_dir() {
    local test_dir="$1"
    [[ -d "$test_dir" ]] && rm -rf "$test_dir"
}

# Check if text exists in file
file_contains() {
    local file="$1"
    local text="$2"
    grep -q "$text" "$file" 2>/dev/null
}

# Test 1: Basic functionality
test_basic() {
    run_test "Basic functionality"
    
    local test_dir=$(create_test_dir "basic")
    local orig_dir=$PWD
    
    cd "$test_dir"
    
    # Create test files
    print "console.log('hello');" > app.js
    print "# README" > README.md  
    print "print('hello')" > script.py
    
    # Run snap and capture both stdout and return code
    local output
    local exit_code
    {
        output=$(snap 2>&1)
        exit_code=$?
    } always {
        # Ensure we return to original directory
        cd "$orig_dir"
    }
    
    # Check results
    if [[ $exit_code -eq 0 ]] && [[ -f "$test_dir/snap.txt" ]] && 
       file_contains "$test_dir/snap.txt" "app.js" && 
       file_contains "$test_dir/snap.txt" "README.md" && 
       file_contains "$test_dir/snap.txt" "script.py"; then
        log_success "Basic functionality works"
    else
        log_failure "Basic functionality failed"
        [[ $exit_code -ne 0 ]] && print "  Exit code: $exit_code"
        [[ ! -f "$test_dir/snap.txt" ]] && print "  snap.txt not created"
    fi
    
    cleanup_test_dir "$test_dir"
}

# Test 2: Default excludes
test_excludes() {
    run_test "Default excludes"
    
    local test_dir=$(create_test_dir "excludes")
    local orig_dir=$PWD
    
    cd "$test_dir"
    
    # Create excluded directories and files
    mkdir -p node_modules/.git dist
    print "module content" > node_modules/package.js
    print "git content" > .git/config
    print "build content" > dist/app.js
    print "log content" > app.log
    print "valid content" > app.py
    
    # Run snap
    local exit_code
    {
        snap >/dev/null 2>&1
        exit_code=$?
    } always {
        cd "$orig_dir"
    }
    
    # Check that excluded content is not present
    if [[ $exit_code -eq 0 ]] && [[ -f "$test_dir/snap.txt" ]] &&
       ! file_contains "$test_dir/snap.txt" "module content" &&
       ! file_contains "$test_dir/snap.txt" "git content" &&
       ! file_contains "$test_dir/snap.txt" "build content" &&
       ! file_contains "$test_dir/snap.txt" "log content" &&
       file_contains "$test_dir/snap.txt" "valid content"; then
        log_success "Default excludes work correctly"
    else
        log_failure "Default excludes failed"
    fi
    
    cleanup_test_dir "$test_dir"
}

# Test 3: Include rescue patterns
test_include_rescue() {
    run_test "Include patterns rescue files"
    
    local test_dir=$(create_test_dir "include")
    local orig_dir=$PWD
    
    cd "$test_dir"
    
    # Create files in excluded directory
    mkdir -p vendor/package
    print "important license" > vendor/package/LICENSE
    print "vendor code" > vendor/package/main.go  
    print "regular file" > main.py
    
    # Run snap with include pattern
    local exit_code
    {
        snap --include "vendor/**/LICENSE" >/dev/null 2>&1
        exit_code=$?
    } always {
        cd "$orig_dir"
    }
    
    # Check that only rescued files and regular files are included
    if [[ $exit_code -eq 0 ]] && [[ -f "$test_dir/snap.txt" ]] &&
       file_contains "$test_dir/snap.txt" "important license" &&
       ! file_contains "$test_dir/snap.txt" "vendor code" &&
       file_contains "$test_dir/snap.txt" "regular file"; then
        log_success "Include patterns rescue files correctly"
    else
        log_failure "Include patterns rescue failed"
        # Debug output
        print "  Exit code: $exit_code"
        [[ -f "$test_dir/snap.txt" ]] && print "  snap.txt exists" || print "  snap.txt missing"
        file_contains "$test_dir/snap.txt" "important license" && print "  ✓ License found" || print "  ✗ License missing"
        file_contains "$test_dir/snap.txt" "vendor code" && print "  ✗ Vendor code found (should be excluded)" || print "  ✓ Vendor code excluded"  
        file_contains "$test_dir/snap.txt" "regular file" && print "  ✓ Regular file found" || print "  ✗ Regular file missing"
        print "  Snap contents preview:"
        [[ -f "$test_dir/snap.txt" ]] && head -20 "$test_dir/snap.txt" | sed 's/^/    /'
    fi
    
    cleanup_test_dir "$test_dir"
}

# Test 4: Binary files
test_binary_files() {
    run_test "Binary file handling"
    
    local test_dir=$(create_test_dir "binary")
    local orig_dir=$PWD
    
    cd "$test_dir"
    
    # Create binary and text files
    print -n '\x89PNG\r\n' > image.png  # PNG header
    print "text content" > document.txt
    
    # Run snap
    local exit_code
    {
        snap >/dev/null 2>&1
        exit_code=$?
    } always {
        cd "$orig_dir"
    }
    
    # Check binary file handling
    if [[ $exit_code -eq 0 ]] && [[ -f "$test_dir/snap.txt" ]] &&
       file_contains "$test_dir/snap.txt" "image.png" &&
       file_contains "$test_dir/snap.txt" "Binary file - content omitted" &&
       file_contains "$test_dir/snap.txt" "text content"; then
        log_success "Binary files handled correctly"
    else
        log_failure "Binary file handling failed"
    fi
    
    cleanup_test_dir "$test_dir"
}

# Test 5: Custom output
test_custom_output() {
    run_test "Custom output file"
    
    local test_dir=$(create_test_dir "output")
    local orig_dir=$PWD
    
    cd "$test_dir"
    
    print "test content" > test.txt
    
    # Run snap with custom output
    local exit_code
    {
        snap --output custom.txt >/dev/null 2>&1
        exit_code=$?
    } always {
        cd "$orig_dir"
    }
    
    # Check custom output file
    if [[ $exit_code -eq 0 ]] && [[ -f "$test_dir/custom.txt" ]] &&
       [[ ! -f "$test_dir/snap.txt" ]] &&
       file_contains "$test_dir/custom.txt" "test content"; then
        log_success "Custom output file works"
    else
        log_failure "Custom output file failed"
    fi
    
    cleanup_test_dir "$test_dir"
}

# Test 6: Snap exclusion
test_snap_exclusion() {
    run_test "Snap file exclusion"
    
    local test_dir=$(create_test_dir "snap_exclude")
    local orig_dir=$PWD
    
    cd "$test_dir"
    
    # Create existing snap files and subdirectory
    print "old snap content" > snap.txt
    mkdir -p subdir
    print "sub snap content" > subdir/snap.txt
    print "valid content" > valid.py
    
    # Run snap (will overwrite existing snap.txt)
    local exit_code
    {
        snap >/dev/null 2>&1
        exit_code=$?
    } always {
        cd "$orig_dir"
    }
    
    # Check that snap files are excluded from content
    if [[ $exit_code -eq 0 ]] && [[ -f "$test_dir/snap.txt" ]] &&
       ! file_contains "$test_dir/snap.txt" "old snap content" &&
       ! file_contains "$test_dir/snap.txt" "sub snap content" &&
       file_contains "$test_dir/snap.txt" "valid content"; then
        log_success "Snap file exclusion works"
    else
        log_failure "Snap file exclusion failed"
    fi
    
    cleanup_test_dir "$test_dir"
}

# Main test runner
main() {
    log_info "Starting snap function tests..."
    print
    
    # Load snap function
    if ! source_snap; then
        return 1
    fi
    
    print
    
    # Run tests
    test_basic
    test_excludes
    test_include_rescue
    test_binary_files
    test_custom_output
    test_snap_exclusion
    
    # Print summary
    print
    log_info "Test Summary:"
    print "  Tests run: $TESTS_RUN"
    print -P "  %F{green}Passed: $TESTS_PASSED%f"
    print -P "  %F{red}Failed: $TESTS_FAILED%f"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        print -P "\n%F{green}All tests passed! 🎉%f"
        return 0
    else
        print -P "\n%F{red}Some tests failed. Please review the output above.%f"
        return 1
    fi
}

# Run main function
main "$@"
