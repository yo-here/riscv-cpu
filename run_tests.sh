#!/usr/bin/env bash

# Stop if a command fails unexpectedly
set -euo pipefail

# Move to the project directory
cd "$(dirname "$0")"

# Preserve the current instruction program
backup=$(mktemp)
cp program.hex "$backup"

# Restore the original program when the script exits
trap 'cp "$backup" program.hex; rm -f "$backup"' EXIT

# Track test results
passed=0
failed=0

# Compile and execute one testbench
run_test() {

    # First argument is the testbench name
    local test="$1"

    # Second argument is the instruction program
    local program="$2"

    # Display the current test
    echo "================================"
    echo "Testing: $test"

    # Load the appropriate program when specified
    if [[ -n "$program" ]]; then
        cp "$program" program.hex
    fi

    # Compile the testbench
    if verilator --binary --timing -Wall \
        -Wno-UNUSEDSIGNAL \
        -Wno-BLKSEQ \
        --top-module "$test" \
        rtl/*.sv "tb/${test}.sv" \
        > /tmp/riscv_build.log 2>&1; then

        # Execute the simulation
        if "./obj_dir/V${test}" > /tmp/riscv_test.log 2>&1; then
            echo "PASS: $test"
            ((passed+=1))
        else
            echo "FAIL: $test (simulation)"
            cat /tmp/riscv_test.log
            ((failed+=1))
        fi

    else
        echo "FAIL: $test (compilation)"
        cat /tmp/riscv_build.log
        ((failed+=1))
    fi
}

# Run standalone component tests
run_test alu_tb ""
run_test decoder_tb ""
run_test imm_gen_tb ""
run_test regfile_tb ""

# Run CPU instruction tests
run_test alu_cpu_tb program_alu_full.hex
run_test branch_compare_tb program_branch_compare.hex
run_test branch_not_taken_tb program_branch_not_taken.hex
run_test branch_tb program_branch_taken.hex
run_test immediate_tb program_immediate_passed.hex
run_test immediate_negative_tb program_immediate_negative_passed.hex
run_test jumps_tb program_jumps_passed.hex
run_test loadstore_tb program_loadstore_passed.hex
run_test lui_auipc_tb program_lui_auipc.hex
run_test memory_tb program_memory.hex

# Report final results
echo "================================"
echo "Passed: $passed"
echo "Failed: $failed"
