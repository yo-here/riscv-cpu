
module cpu_tb;

    logic clk = 0;
    logic reset = 1;
    logic [31:0] instruction;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    always #5 clk = ~clk;

    task automatic check_fetch(
        input logic [31:0] expected
    );
        #1;
        if (instruction !== expected)
            $fatal(1, "FAIL: PC=%h got=%h expected=%h",
                   dut.pc, instruction, expected);

        $display("PASS: PC=%h instruction=%h",
                 dut.pc, instruction);
    endtask

    initial begin
        #2;
        check_fetch(32'h00500093);

        reset = 0;

        @(posedge clk);
        check_fetch(32'h00A00113);

        @(posedge clk);
        check_fetch(32'h002081B3);

        @(posedge clk);
        check_fetch(32'h00000013);

        if (dut.reg_write !== 1'b1)
            $fatal(1, "FAIL: ADDI reg_write");

        if (dut.alu_src !== 1'b1)
            $fatal(1, "FAIL: ADDI alu_src");

        if (dut.alu_control !== 4'b0000)
            $fatal(1, "FAIL: ADDI alu_control");

        $display("PASS: ADDI decoder control signals");

        // Check register writeback
        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "FAIL: x1 expected 5");

        if (dut.rf.registers[2] !== 32'd10)
            $fatal(1, "FAIL: x2 expected 10");

        if (dut.rf.registers[3] !== 32'd15)
            $fatal(1, "FAIL: x3 expected 15");

        $display("PASS: x1 = 5");
        $display("PASS: x2 = 10");
        $display("PASS: x3 = 15");

        $display("ALL CPU TESTS PASSED");
        $finish;
    end

endmodule

