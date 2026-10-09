
module imm_gen_tb;

    logic [31:0] instruction;
    logic [31:0] immediate;
    int errors = 0;

    imm_gen dut (
        .instruction(instruction),
        .immediate(immediate)
    );

    localparam logic [6:0] OPS [8] = '{
        7'b0010011, 7'b0000011, 7'b1100111,
        7'b0100011,
        7'b1100011,
        7'b1101111,
        7'b0110111, 7'b0010111
    };

    function automatic logic [31:0] ref_imm(input logic [31:0] i);
        case (i[6:0])
            7'b0010011, 7'b0000011, 7'b1100111:
                return {{20{i[31]}}, i[31:20]};
            7'b0100011:
                return {{20{i[31]}}, i[31:25], i[11:7]};
            7'b1100011:
                return {{19{i[31]}}, i[31], i[7], i[30:25], i[11:8], 1'b0};
            7'b1101111:
                return {{11{i[31]}}, i[31], i[19:12], i[20], i[30:21], 1'b0};
            7'b0110111, 7'b0010111:
                return {i[31:12], 12'b0};
            default:
                return 32'b0;
        endcase
    endfunction

    task automatic check(input string name, input logic [31:0] instr,
                         input logic [31:0] expected);
        instruction = instr;
        #1;
        if (immediate !== expected) begin
            $display("FAIL: %s  got %h  expected %h", name, immediate, expected);
            errors++;
        end else
            $display("PASS: %s", name);
    endtask

    initial begin
        check("I-type positive", 32'b00000000010100000000000010010011, 32'd5);
        check("I-type negative", 32'b11111111101100000000000010010011, 32'hFFFFFFFB);
        check("S-type positive", 32'b00000000010100010010010000100011, 32'd8);
        check("S-type negative", 32'b11111110010100010010111000100011, 32'hFFFFFFFC);
        check("B-type positive", 32'b00000000001000001000010001100011, 32'd8);
        check("B-type negative", 32'b11111110001000001000110011100011, 32'hFFFFFFF8);
        check("J-type positive", 32'b00000000100000000000000011101111, 32'd8);
        check("J-type negative", 32'b11111111100111111111000011101111, 32'hFFFFFFF8);
        check("LUI",             32'h123450B7, 32'h12345000);
        check("AUIPC",           32'h12345097, 32'h12345000);
        check("JALR",            32'h00C100E7, 32'h0000000C);

        check("I max",           32'h7FF00093, 32'h000007FF);
        check("I min",           32'h80000093, 32'hFFFFF800);
        check("S min",           32'h80000023, 32'hFFFFF800);
        check("B min",           32'h80000063, 32'hFFFFF000);
        check("J min",           32'h8000006F, 32'hFFF00000);

        check("B imm[11]",       32'h000000E3, 32'h00000800);
        check("J imm[11]",       32'h0010006F, 32'h00000800);
        check("J imm[12]",       32'h0000106F, 32'h00001000);

        for (int n = 0; n < 2000; n++) begin
            logic [31:0] r;
            int idx;

            r = $urandom;
            idx = $urandom_range(0, 7);
            r[6:0] = OPS[idx];
            instruction = r;
            #1;

            if (immediate !== ref_imm(r)) begin
                $display("FAIL: random %h  got %h  expected %h",
                         r, immediate, ref_imm(r));
                errors++;
            end
        end

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $fatal(1, "%0d FAILURES", errors);

        $finish;
    end

endmodule
