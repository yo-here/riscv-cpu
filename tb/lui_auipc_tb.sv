// Testbench for LUI and AUIPC instructions
module lui_auipc_tb;

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
    always #5 clk = ~clk;

    // Begin the simulation
    initial begin

        // Allow reset to initialize the program counter
        #2;

        // Verify that execution starts at address zero
        if (dut.pc !== 32'h00000000)
            $fatal(1, "FAIL: Initial PC");

        // Release reset
        reset = 0;

        // Execute LUI x5, 0x12345
        @(posedge clk);

        // Allow register and PC updates to complete
        #1;

        // Verify that LUI loaded the upper immediate
        if (dut.rf.registers[5] !== 32'h12345000)
            $fatal(1, "FAIL: LUI expected 0x12345000");

        // Display successful LUI result
        $display("PASS: LUI x5 = %h", dut.rf.registers[5]);

        // Execute AUIPC x6, 0x2
        @(posedge clk);

        // Allow updates to complete
        #1;

        // Verify AUIPC used the instruction's PC (address 4)
        if (dut.rf.registers[6] !== 32'h00002004)
            $fatal(1, "FAIL: AUIPC expected 0x00002004");

        // Display successful AUIPC result
        $display("PASS: AUIPC x6 = %h", dut.rf.registers[6]);

        // Verify PC advanced past both instructions
        if (dut.pc !== 32'h00000008)
            $fatal(1, "FAIL: PC expected 0x00000008");

        // Display successful PC result
        $display("PASS: PC = %h", dut.pc);

        // All checks succeeded
        $display("ALL LUI/AUIPC TESTS PASSED");

        // End simulation
        $finish;

    end

endmodule

