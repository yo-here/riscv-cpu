// Define the memory testbench module
module memory_tb;

    // Initialize the CPU clock to 0
    logic clk = 0;

    // Start with reset enabled
    logic reset = 1;

    // Wire carrying the CPU's current 32-bit instruction
    logic [31:0] instruction;

    // Create an instance of the CPU being tested
    cpu dut (

        // Connect the testbench clock to the CPU
        .clk(clk),

        // Connect the testbench reset to the CPU
        .reset(reset),

        // Connect the CPU instruction output
        .instruction(instruction)
    );

    // Generate a clock by toggling every 5 time units
    always #5 clk = ~clk;

    // Begin the simulation
    initial begin

        // Allow reset to initialize the program counter
        #2;

        // Check that the CPU starts at address 0
        if (dut.pc !== 32'd0)
            $fatal(1, "FAIL: PC did not start at 0");

        // Release reset so the CPU can execute instructions
        reset = 0;

        // First rising edge executes ADDI x1, x0, 25
        @(posedge clk);

        // Wait for register updates to settle
        #1;

        // Verify that x1 contains 25
        if (dut.rf.registers[1] !== 32'd25)
            $fatal(1, "FAIL: x1 expected 25");

        // Display successful ADDI execution
        $display("PASS: x1 = 25");

        // Second rising edge executes SW x1, 0(x0)
        @(posedge clk);

        // Wait for memory updates to settle
        #1;

        // Verify that memory address 0 contains 25
        if (dut.dmem.memory[0] !== 32'd25)
            $fatal(1, "FAIL: memory[0] expected 25");

        // Display successful memory write
        $display("PASS: SW stored 25 in memory[0]");

        // Third rising edge executes LW x2, 0(x0)
        @(posedge clk);

        // Wait for register updates to settle
        #1;

        // Verify that x2 contains the loaded value 25
        if (dut.rf.registers[2] !== 32'd25)
            $fatal(1, "FAIL: x2 expected 25");

        // Display successful memory read
        $display("PASS: LW loaded 25 into x2");

        // Display final success message
        $display("ALL MEMORY TESTS PASSED");

        // End the simulation
        $finish;

    // End the simulation block
    end

// End the testbench module
endmodule
