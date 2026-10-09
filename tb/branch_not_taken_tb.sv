module branch_not_taken_tb;

    logic clk = 0;
    logic reset = 1;
    logic [31:0] instruction;

    cpu dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction)
    );

    always #5 clk = ~clk;

    task automatic check_pc(input logic [31:0] expected);
        #1;
        if (dut.pc !== expected)
            $fatal(1, "FAIL: PC=%h expected=%h",
                   dut.pc, expected);

        $display("PASS: PC=%h", dut.pc);
    endtask

    initial begin
        #2;
        check_pc(32'h00000000);

        reset = 0;

        @(posedge clk);
        check_pc(32'h00000004);

        @(posedge clk);
        check_pc(32'h00000008);

        @(posedge clk);
        check_pc(32'h0000000C);

        @(posedge clk);
        check_pc(32'h00000010);

        @(posedge clk);
        check_pc(32'h00000014);

        @(posedge clk);
        check_pc(32'h00000018);

        if (dut.rf.registers[3] !== 32'd1)
            $fatal(1, "FAIL: x3 expected 1");

        if (dut.rf.registers[4] !== 32'd2)
            $fatal(1, "FAIL: x4 expected 2");

        $display("PASS: x3 = 1");
        $display("PASS: x4 = 2");
        $display("ALL NOT-TAKEN BRANCH TESTS PASSED");

        $finish;
    end

endmodule
