// Define the CPU arithmetic testbench
module alu_cpu_tb;

    // CPU clock starts at 0
    logic clk = 0;

    // Reset starts enabled
    logic reset = 1;

    // Holds the current instruction
    logic [31:0] instruction;

    // Create the CPU being tested
    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    // Toggle the clock every 5 time units
    always #5 clk = ~clk;

    // Check a register against its expected value
    task automatic check_register(
        input int reg_number,
        input logic [31:0] expected
    );
        // Compare actual and expected register values
        if (dut.rf.registers[reg_number] !== expected)
            $fatal(1,
                "FAIL: x%0d expected %0d, got %0d",
                reg_number,
                expected,
                dut.rf.registers[reg_number]
            );

        // Display a successful comparison
        $display("PASS: x%0d = %0d", reg_number, expected);
    endtask

    // Begin simulation
    initial begin

        // Allow the reset signal to initialize the PC
        #2;

        // Release reset
        reset = 0;

        // Execute the first 11 instructions
        repeat (11) begin
            @(posedge clk);
            #1;
        end

        // Verify every destination register
        check_register(1, 32'd10);
        check_register(2, 32'd3);
        check_register(3, 32'd7);
        check_register(4, 32'd2);
        check_register(5, 32'd11);
        check_register(6, 32'd9);
        check_register(7, 32'd80);
        check_register(8, 32'd1);
        check_register(9, 32'd1);
        check_register(10, 32'd0);
        check_register(11, 32'd0);

        // All comparisons succeeded
        $display("ALL CPU ARITHMETIC TESTS PASSED");

        // End simulation
        $finish;

    end

endmodule
