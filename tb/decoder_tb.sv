module decoder_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_5;
    logic       reg_write;
    logic       alu_src;
    logic [3:0] alu_control;
    int errors = 0;

    decoder dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_control(alu_control)
    );

    task automatic check(input string name,
                         input logic [6:0] op,
                         input logic [2:0] f3,
                         input logic f7,
                         input logic exp_rw,
                         input logic exp_src,
                         input logic [3:0] exp_alu);
        opcode   = op;
        funct3   = f3;
        funct7_5 = f7;
        #1;
        if (reg_write !== exp_rw || alu_src !== exp_src || alu_control !== exp_alu) begin
            $display("FAIL: %s  rw=%b src=%b alu=%b", name, reg_write, alu_src, alu_control);
            errors++;
        end else
            $display("PASS: %s", name);
    endtask

    initial begin
        check("ADD",  7'b0110011, 3'b000, 1'b0, 1'b1, 1'b0, 4'b0000);
        check("SUB",  7'b0110011, 3'b000, 1'b1, 1'b1, 1'b0, 4'b0001);
        check("SLL",  7'b0110011, 3'b001, 1'b0, 1'b1, 1'b0, 4'b0111);
        check("SLT",  7'b0110011, 3'b010, 1'b0, 1'b1, 1'b0, 4'b0101);
        check("SLTU", 7'b0110011, 3'b011, 1'b0, 1'b1, 1'b0, 4'b0110);
        check("XOR",  7'b0110011, 3'b100, 1'b0, 1'b1, 1'b0, 4'b0100);
        check("SRL",  7'b0110011, 3'b101, 1'b0, 1'b1, 1'b0, 4'b1000);
        check("SRA",  7'b0110011, 3'b101, 1'b1, 1'b1, 1'b0, 4'b1001);
        check("OR",   7'b0110011, 3'b110, 1'b0, 1'b1, 1'b0, 4'b0011);
        check("AND",  7'b0110011, 3'b111, 1'b0, 1'b1, 1'b0, 4'b0010);

        check("ADDI",  7'b0010011, 3'b000, 1'b0, 1'b1, 1'b1, 4'b0000);
        check("ADDI negative imm (bit 30 set)", 7'b0010011, 3'b000, 1'b1, 1'b1, 1'b1, 4'b0000);
        check("SLLI",  7'b0010011, 3'b001, 1'b0, 1'b1, 1'b1, 4'b0111);
        check("SLTI",  7'b0010011, 3'b010, 1'b0, 1'b1, 1'b1, 4'b0101);
        check("SLTIU", 7'b0010011, 3'b011, 1'b0, 1'b1, 1'b1, 4'b0110);
        check("XORI",  7'b0010011, 3'b100, 1'b0, 1'b1, 1'b1, 4'b0100);
        check("SRLI",  7'b0010011, 3'b101, 1'b0, 1'b1, 1'b1, 4'b1000);
        check("SRAI",  7'b0010011, 3'b101, 1'b1, 1'b1, 1'b1, 4'b1001);
        check("ORI",   7'b0010011, 3'b110, 1'b0, 1'b1, 1'b1, 4'b0011);
        check("ANDI",  7'b0010011, 3'b111, 1'b0, 1'b1, 1'b1, 4'b0010);

        check("Unsupported opcode writes nothing", 7'b0100011, 3'b010, 1'b0, 1'b0, 1'b0, 4'b0000);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $fatal(1, "%0d FAILURES", errors);
        $finish;
    end

endmodule
