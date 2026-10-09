module immediate_negative_tb;

    // Initialize the clock to zero
    logic clk = 0;

    // Start with reset enabled
    logic reset = 1;

    // Hold the instruction fetched by the CPU
    logic [31:0] instruction;

    // Instantiate the CPU
    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    // Toggle the clock every 5 time units
    always #5 clk <= ~clk;

    // Begin simulation
    initial begin

        // Allow reset to initialize the CPU
        #2;

        // Verify execution begins at address zero
        if (dut.pc !== 32'd0)
            $fatal(1, "FAIL: Initial PC");

        // Release reset
        reset = 0;

        // Execute ADDI x1, x0, -5
        @(posedge clk);
        #1;

        // Verify -5 is represented in two's complement
        if (dut.rf.registers[1] !== 32'hFFFFFFFB)
            $fatal(1, "FAIL: ADDI negative");

        // Report successful negative addition
        $display("PASS: ADDI negative");

        // Execute ADDI x2, x1, 3
        @(posedge clk);
        #1;

        // Verify -5 + 3 equals -2
        if (dut.rf.registers[2] !== 32'hFFFFFFFE)
            $fatal(1, "FAIL: ADDI negative result");

        // Report successful negative arithmetic
        $display("PASS: ADDI negative result");

        // Execute SLTI x3, x1, 1
        @(posedge clk);
        #1;

        // Signed comparison: -5 is less than 1
        if (dut.rf.registers[3] !== 32'd1)
            $fatal(1, "FAIL: SLTI signed");

        // Report successful signed comparison
        $display("PASS: SLTI signed");

        // Execute SLTIU x4, x1, 1
        @(posedge clk);
        #1;

        // Unsigned comparison: 0xFFFFFFFB is greater than 1
        if (dut.rf.registers[4] !== 32'd0)
            $fatal(1, "FAIL: SLTIU unsigned");

        // Report successful unsigned comparison
        $display("PASS: SLTIU unsigned");

        // Execute SLTI x5, x1, -1
        @(posedge clk);
        #1;

        // Signed comparison: -5 is less than -1
        if (dut.rf.registers[5] !== 32'd1)
            $fatal(1, "FAIL: SLTI negative immediate");

        // Report successful signed negative comparison
        $display("PASS: SLTI negative immediate");

        // Execute SLTIU x6, x1, -1
        @(posedge clk);
        #1;

        // Unsigned comparison: 0xFFFFFFFB is less than 0xFFFFFFFF
        if (dut.rf.registers[6] !== 32'd1)
            $fatal(1, "FAIL: SLTIU negative immediate");

        // Report successful unsigned negative comparison
        $display("PASS: SLTIU negative immediate");

        // Verify six instructions advanced PC by 24 bytes
        if (dut.pc !== 32'd24)
            $fatal(1, "FAIL: Final PC");

        // Report successful completion
        $display("ALL NEGATIVE IMMEDIATE TESTS PASSED");

        // End simulation
        $finish;

    end

endmodule
