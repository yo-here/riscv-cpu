// Testbench for signed and unsigned branch instructions
module branch_compare_tb;

    // Initialize clock to 0
    logic clk = 0;

    // Start with reset enabled
    logic reset = 1;

    // Holds the current CPU instruction
    logic [31:0] instruction;

    // Instantiate the CPU
    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    // Generate a clock with a period of 10 time units
    always #5 clk = ~clk;

    // Check the program counter against an expected address
    task automatic check_pc(input logic [31:0] expected);

        // Stop the simulation if the PC is incorrect
        if (dut.pc !== expected)
            $fatal(1, "FAIL: PC expected %h, got %h",
                   expected, dut.pc);

        // Display the successful PC comparison
        $display("PASS: PC = %h", dut.pc);

    endtask

    // Execute one CPU instruction and check the next PC
    task automatic step_and_check(input logic [31:0] expected);

        // Wait for the next rising clock edge
        @(posedge clk);

        // Allow sequential updates to complete
        #1;

        // Verify the resulting program counter
        check_pc(expected);

    endtask

    // Begin the test
    initial begin

        // Allow reset to initialize the PC
        #2;

        // Confirm the starting address
        check_pc(32'h00000000);

        // Release reset
        reset = 0;

        // ADDI x1, x0, -1
        step_and_check(32'h00000004);

        // ADDI x2, x0, 1
        step_and_check(32'h00000008);

        // BLT: -1 < 1, branch taken to address 0x10
        step_and_check(32'h00000010);

        // BGE: -1 >= 1, branch not taken
        step_and_check(32'h00000014);

        // ADDI x4, x0, 100
        step_and_check(32'h00000018);

        // BLTU: 0xFFFFFFFF < 1, branch not taken
        step_and_check(32'h0000001C);

        // ADDI x5, x0, 101
        step_and_check(32'h00000020);

        // BGEU: 0xFFFFFFFF >= 1, branch taken
        step_and_check(32'h00000028);

        // Verify instructions skipped or executed
        if (dut.rf.registers[4] !== 32'd100)
            $fatal(1, "FAIL: x4 expected 100");

        if (dut.rf.registers[5] !== 32'd101)
            $fatal(1, "FAIL: x5 expected 101");

        $display("ALL BRANCH COMPARISON TESTS PASSED");

        // End the simulation
        $finish;

    end

endmodule
