module immediate_tb;

    // Initialize the clock
    logic clk = 0;

    // Begin with reset enabled
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

    // Begin testing
    initial begin

        // Allow the CPU to reset
        #2;

        // Verify the initial program counter
        if (dut.pc !== 32'd0)
            $fatal(1, "FAIL: Initial PC");

        // Release reset
        reset = 0;

        // Execute ADDI x1, x0, 5
        @(posedge clk);
        #1;
        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "FAIL: ADDI x1");
        $display("PASS: ADDI x1");

        // Execute ADDI x2, x1, 3
        @(posedge clk);
        #1;
        if (dut.rf.registers[2] !== 32'd8)
            $fatal(1, "FAIL: ADDI x2");
        $display("PASS: ADDI x2");

        // Execute SLTI x3, x1, 7
        @(posedge clk);
        #1;
        if (dut.rf.registers[3] !== 32'd1)
            $fatal(1, "FAIL: SLTI");
        $display("PASS: SLTI");

        // Execute SLTIU x4, x1, 7
        @(posedge clk);
        #1;
        if (dut.rf.registers[4] !== 32'd1)
            $fatal(1, "FAIL: SLTIU");
        $display("PASS: SLTIU");

        // Execute XORI x5, x1, 3
        @(posedge clk);
        #1;
        if (dut.rf.registers[5] !== 32'd6)
            $fatal(1, "FAIL: XORI");
        $display("PASS: XORI");

        // Execute ORI x6, x1, 3
        @(posedge clk);
        #1;
        if (dut.rf.registers[6] !== 32'd7)
            $fatal(1, "FAIL: ORI");
        $display("PASS: ORI");

        // Execute ANDI x7, x1, 3
        @(posedge clk);
        #1;
        if (dut.rf.registers[7] !== 32'd1)
            $fatal(1, "FAIL: ANDI");
        $display("PASS: ANDI");

        // Execute SLLI x8, x1, 2
        @(posedge clk);
        #1;
        if (dut.rf.registers[8] !== 32'd20)
            $fatal(1, "FAIL: SLLI");
        $display("PASS: SLLI");

        // Execute SRLI x9, x8, 1
        @(posedge clk);
        #1;
        if (dut.rf.registers[9] !== 32'd10)
            $fatal(1, "FAIL: SRLI");
        $display("PASS: SRLI");

        // Execute SRAI x10, x8, 1
        @(posedge clk);
        #1;
        if (dut.rf.registers[10] !== 32'd10)
            $fatal(1, "FAIL: SRAI");
        $display("PASS: SRAI");

        // Verify the CPU executed ten instructions
        if (dut.pc !== 32'd40)
            $fatal(1, "FAIL: Final PC");

        // Display successful completion
        $display("ALL IMMEDIATE TESTS PASSED");

        // End simulation
        $finish;

    end

endmodule

