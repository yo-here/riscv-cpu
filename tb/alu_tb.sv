module alu_tb;

    logic [31:0] a;
    logic [31:0] b;
    logic [3:0] alu_control;
    logic [31:0] result;
    logic zero;

    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin

        a = 32'd10;
        b = 32'd5;

        alu_control = 4'b0000;
        #1;
        if (result == 32'd15)
            $display("PASS: ADD");
        else
            $display("FAIL: ADD");

        alu_control = 4'b0001;
        #1;
        if (result == 32'd5)
            $display("PASS: SUB");
        else
            $display("FAIL: SUB");

        alu_control = 4'b0010;
        #1;
        if (result == 32'd0)
            $display("PASS: AND");
        else
            $display("FAIL: AND");

        alu_control = 4'b0011;
        #1;
        if (result == 32'h0000000F)
            $display("PASS: OR");
        else
            $display("FAIL: OR");

        alu_control = 4'b0100;
        #1;
        if (result == 32'h0000000F)
            $display("PASS: XOR");
        else
            $display("FAIL: XOR");

        a = -32'sd10;
        b = 32'sd5;

        alu_control = 4'b0101;
        #1;
        if (result == 32'd1)
            $display("PASS: SLT");
        else
            $display("FAIL: SLT");

        a = 32'hFFFFFFFF;
        b = 32'd1;

        alu_control = 4'b0110;
        #1;
        if (result == 32'd0)
            $display("PASS: SLTU");
        else
            $display("FAIL: SLTU");

        a = 32'd3;
        b = 32'd2;

        alu_control = 4'b0111;
        #1;
        if (result == 32'd12)
            $display("PASS: SLL");
        else
            $display("FAIL: SLL");

        a = 32'd16;
        b = 32'd2;

        alu_control = 4'b1000;
        #1;
        if (result == 32'd4)
            $display("PASS: SRL");
        else
            $display("FAIL: SRL");

        a = -32'sd16;
        b = 32'd2;

        alu_control = 4'b1001;
        #1;
        if (result == -32'sd4)
            $display("PASS: SRA");
        else
            $display("FAIL: SRA");

        $finish;

    end

endmodule
