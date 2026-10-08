module regfile_tb;

    logic clk;
    logic write_en;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [4:0] rd;
    logic [31:0] write_data;
    logic [31:0] read_data1;
    logic [31:0] read_data2;

    regfile dut (
        .clk(clk),
        .write_en(write_en),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        write_en = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        write_data = 0;

        #10;

        rs1 = 5'd0;
        rs2 = 5'd0;
        #1;

        if ((read_data1 == 32'd0) && (read_data2 == 32'd0))
            $display("PASS: x0 reads as zero");
        else
            $display("FAIL: x0 reads as zero");

        rd = 5'd5;
        write_data = 32'h12345678;
        write_en = 1;

        #9;

        write_en = 0;
        rs1 = 5'd5;
        #1;

        if (read_data1 == 32'h12345678)
            $display("PASS: x5 write/read");
        else
            $display("FAIL: x5 write/read");

        rd = 5'd10;
        write_data = 32'hABCDEF01;
        write_en = 1;

        #10;

        write_en = 0;
        rs1 = 5'd5;
        rs2 = 5'd10;
        #1;

        if ((read_data1 == 32'h12345678) &&
            (read_data2 == 32'hABCDEF01))
            $display("PASS: simultaneous reads");
        else
            $display("FAIL: simultaneous reads");

        rd = 5'd0;
        write_data = 32'hFFFFFFFF;
        write_en = 1;

        #10;

        write_en = 0;
        rs1 = 5'd0;
        #1;

        if (read_data1 == 32'd0)
            $display("PASS: x0 cannot be written");
        else
            $display("FAIL: x0 cannot be written");

        $finish;

    end

endmodule
