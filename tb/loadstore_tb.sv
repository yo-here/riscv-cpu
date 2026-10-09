module loadstore_tb;

    // Initialize the clock
    logic clk = 0;

    // Start with reset enabled
    logic reset = 1;

    // Hold the fetched instruction
    logic [31:0] instruction;

    // Instantiate the CPU
    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    // Generate the clock
    always #5 clk <= ~clk;

    // Begin simulation
    initial begin

        // Allow reset to initialize the PC
        #2;

        // Verify the initial PC
        if (dut.pc !== 32'd0)
            $fatal(1, "FAIL: Initial PC");

        // Release reset
        reset = 0;

        // Execute ADDI x1, x0, 0
        @(posedge clk);
        #1;

        // Execute ADDI x2, x0, -1
        @(posedge clk);
        #1;

        // Execute SB x2, 0(x1)
        @(posedge clk);
        #1;

        // Verify the stored byte
        if (dut.dmem.memory[0][7:0] !== 8'hFF)
            $fatal(1, "FAIL: SB");

        // Report successful byte store
        $display("PASS: SB");

        // Execute LB x3, 0(x1)
        @(posedge clk);
        #1;

        // Verify signed byte loading
        if (dut.rf.registers[3] !== 32'hFFFFFFFF)
            $fatal(1, "FAIL: LB");

        // Report successful signed byte load
        $display("PASS: LB");

        // Execute LBU x4, 0(x1)
        @(posedge clk);
        #1;

        // Verify unsigned byte loading
        if (dut.rf.registers[4] !== 32'h000000FF)
            $fatal(1, "FAIL: LBU");

        // Report successful unsigned byte load
        $display("PASS: LBU");

        // Execute SH x2, 2(x1)
        @(posedge clk);
        #1;

        // Verify the upper halfword was stored
        if (dut.dmem.memory[0][31:16] !== 16'hFFFF)
            $fatal(1, "FAIL: SH");

        // Report successful halfword store
        $display("PASS: SH");

        // Execute LHU x5, 2(x1)
        @(posedge clk);
        #1;

        // Verify unsigned halfword loading
        if (dut.rf.registers[5] !== 32'h0000FFFF)
            $fatal(1, "FAIL: LHU");

        // Report successful unsigned halfword load
        $display("PASS: LHU");

        // Execute LH x6, 2(x1)
        @(posedge clk);
        #1;

        // Verify signed halfword loading
        if (dut.rf.registers[6] !== 32'hFFFFFFFF)
            $fatal(1, "FAIL: LH");

        // Report successful signed halfword load
        $display("PASS: LH");

        // Execute SW x2, 4(x1)
        @(posedge clk);
        #1;

        // Verify the complete word was stored
        if (dut.dmem.memory[1] !== 32'hFFFFFFFF)
            $fatal(1, "FAIL: SW");

        // Report successful word store
        $display("PASS: SW");

        // Execute LW x7, 4(x1)
        @(posedge clk);
        #1;

        // Verify the complete word was loaded
        if (dut.rf.registers[7] !== 32'hFFFFFFFF)
            $fatal(1, "FAIL: LW");

        // Report successful word load
        $display("PASS: LW");

        // Verify byte and halfword stores preserved other bytes
        if (dut.dmem.memory[0][15:8] !== 8'h00)
            $fatal(1, "FAIL: Partial store preservation");

        // Report successful partial store check
        $display("PASS: Partial store preservation");

        // Verify the final program counter
        if (dut.pc !== 32'd40)
            $fatal(1, "FAIL: Final PC");

        // Report successful completion
        $display("ALL LOAD/STORE TESTS PASSED");

        // Finish simulation
        $finish;

    end

endmodule
