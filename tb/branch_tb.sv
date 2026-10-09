
module branch_tb;

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
            $fatal(1, "FAIL: PC=%h expected=%h", dut.pc, expected);

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

// Display the registers used by BEQ
$display("DEBUG: x1=%h x2=%h", dut.rf.registers[1], dut.rf.registers[2]);

// Display the current instruction and branch decision
$display("DEBUG: instruction=%h branch=%b branch_taken=%b",
         instruction, dut.branch, dut.branch_taken);

        @(posedge clk);
        check_pc(32'h00000010);

        @(posedge clk);
        check_pc(32'h00000014);

        @(posedge clk);
        check_pc(32'h0000001C);

        @(posedge clk);
        check_pc(32'h00000020);

        if (dut.rf.registers[1] !== 32'd5)
            $fatal(1, "FAIL: x1");

        if (dut.rf.registers[2] !== 32'd5)
            $fatal(1, "FAIL: x2");

        if (dut.rf.registers[4] !== 32'd1)
            $fatal(1, "FAIL: x4");

        if (dut.rf.registers[6] !== 32'd7)
            $fatal(1, "FAIL: x6");

        $display("PASS: Register values");
        $display("ALL BRANCH TESTS PASSED");

        $finish;
    end

endmodule
