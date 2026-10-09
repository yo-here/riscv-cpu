module jumps_tb;

    // Initialize the CPU clock to zero
    logic clk = 0;

    // Start with reset enabled
    logic reset = 1;

    // Holds the instruction fetched by the CPU
    logic [31:0] instruction;

    // Create the CPU being tested
    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    // Generate a clock that toggles every 5 time units
    always #5 clk <= ~clk;

    // Begin the simulation
    initial begin

        // Allow reset to initialize the program counter
        #2;

        // Verify execution starts at address zero
        if (dut.pc !== 32'h00000000)
            $fatal(1, "FAIL: Initial PC");

        // Release reset
        reset = 0;

        // Execute ADDI x2, x0, 24
        @(posedge clk);
        #1;

        // Verify x2 contains the JALR target address
        if (dut.rf.registers[2] !== 32'd24)
            $fatal(1, "FAIL: x2 expected 24");

        // Execute JAL x1, 12
        @(posedge clk);
        #1;

        // Verify JAL jumped from address 4 to address 16
        if (dut.pc !== 32'h00000010)
            $fatal(1, "FAIL: JAL target");

        // Verify JAL saved the return address 8
        if (dut.rf.registers[1] !== 32'h00000008)
            $fatal(1, "FAIL: JAL return address");

        // Display successful JAL result
        $display("PASS: JAL target and return address");

        // Verify skipped instruction did not modify x3
        if (dut.rf.registers[3] !== 32'd0)
            $fatal(1, "FAIL: JAL skipped instruction");

        // Execute JALR x4, 0(x2)
        @(posedge clk);
        #1;

        // Verify JALR jumped to address 24
        if (dut.pc !== 32'h00000018)
            $fatal(1, "FAIL: JALR target");

        // Verify JALR saved return address 20
        if (dut.rf.registers[4] !== 32'h00000014)
            $fatal(1, "FAIL: JALR return address");

        // Display successful JALR result
        $display("PASS: JALR target and return address");

        // Verify skipped instruction did not modify x5
        if (dut.rf.registers[5] !== 32'd0)
            $fatal(1, "FAIL: JALR skipped instruction");

        // Display successful completion
        $display("ALL JUMP TESTS PASSED");

        // End simulation
        $finish;

    end

endmodule
