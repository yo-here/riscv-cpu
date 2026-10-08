module imm_gen_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;

    imm_gen dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin

        instruction = 32'b00000000010100000000000010010011;
        #1;
        if (immediate == 32'd5)
            $display("PASS: I-type positive");
        else
            $display("FAIL: I-type positive");

        instruction = 32'b11111111101100000000000010010011;
        #1;
        if (immediate == 32'hFFFFFFFB)
            $display("PASS: I-type negative");
        else
            $display("FAIL: I-type negative");

        instruction = 32'b00000000010100010010010000100011;
        #1;
        if (immediate == 32'd8)
            $display("PASS: S-type positive");
        else
            $display("FAIL: S-type positive");

        instruction = 32'b11111110010100010010111000100011;
        #1;
        if (immediate == 32'hFFFFFFFC)
            $display("PASS: S-type negative");
        else
            $display("FAIL: S-type negative");

        instruction = 32'b00000000001000001000010001100011;
        #1;
        if (immediate == 32'd8)
            $display("PASS: B-type positive");
        else
            $display("FAIL: B-type positive");

        instruction = 32'b11111110001000001000110011100011;
        #1;
        if (immediate == 32'hFFFFFFF8)
            $display("PASS: B-type negative");
        else
            $display("FAIL: B-type negative");

        instruction = 32'b00000000100000000000000011101111;
        #1;
        if (immediate == 32'd8)
            $display("PASS: J-type positive");
        else
            $display("FAIL: J-type positive");

        instruction = 32'b11111111100111111111000011101111;
        #1;
        if (immediate == 32'hFFFFFFF8)
            $display("PASS: J-type negative");
        else
            $display("FAIL: J-type negative");

        $finish;

    end

endmodule
