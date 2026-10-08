module decoder_tb;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_5;
    logic       reg_write;
    logic       alu_src;
    logic       mem_read;
    logic       mem_write;
    logic       mem_to_reg;
    logic       branch;
    logic       branch_ne;
    logic [3:0] alu_control;
    int errors = 0;

    decoder dut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .branch_ne(branch_ne),
        .alu_control(alu_control)
    );

    task automatic check(input string name,
                         input logic [6:0] op,
                         input logic [2:0] f3,
                         input logic f7,
                         input logic exp_rw,
                         input logic exp_src,
                         input logic [3:0] exp_alu,
                         input logic exp_mr,
                         input logic exp_mw,
                         input logic exp_m2r,
                         input logic exp_br,
                         input logic exp_bne);
        opcode   = op;
        funct3   = f3;
        funct7_5 = f7;
        #1;
        if (reg_write !== exp_rw || alu_src !== exp_src || alu_control !== exp_alu ||
            mem_read !== exp_mr || mem_write !== exp_mw || mem_to_reg !== exp_m2r ||
            branch !== exp_br || branch_ne !== exp_bne) begin
            $display("FAIL: %s  rw=%b src=%b alu=%b mr=%b mw=%b m2r=%b br=%b bne=%b",
                     name, reg_write, alu_src, alu_control, mem_read, mem_write,
                     mem_to_reg, branch, branch_ne);
            errors++;
        end else
            $display("PASS: %s", name);
    endtask

    initial begin
        check("ADD",  7'b0110011, 3'b000, 1'b0, 1'b1, 1'b0, 4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SUB",  7'b0110011, 3'b000, 1'b1, 1'b1, 1'b0, 4'b0001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SLL",  7'b0110011, 3'b001, 1'b0, 1'b1, 1'b0, 4'b0111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SLT",  7'b0110011, 3'b010, 1'b0, 1'b1, 1'b0, 4'b0101, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SLTU", 7'b0110011, 3'b011, 1'b0, 1'b1, 1'b0, 4'b0110, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("XOR",  7'b0110011, 3'b100, 1'b0, 1'b1, 1'b0, 4'b0100, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SRL",  7'b0110011, 3'b101, 1'b0, 1'b1, 1'b0, 4'b1000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SRA",  7'b0110011, 3'b101, 1'b1, 1'b1, 1'b0, 4'b1001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("OR",   7'b0110011, 3'b110, 1'b0, 1'b1, 1'b0, 4'b0011, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("AND",  7'b0110011, 3'b111, 1'b0, 1'b1, 1'b0, 4'b0010, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        check("ADDI",  7'b0010011, 3'b000, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("ADDI negative imm (bit 30 set)", 7'b0010011, 3'b000, 1'b1, 1'b1, 1'b1, 4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SLLI",  7'b0010011, 3'b001, 1'b0, 1'b1, 1'b1, 4'b0111, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SLTI",  7'b0010011, 3'b010, 1'b0, 1'b1, 1'b1, 4'b0101, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SLTIU", 7'b0010011, 3'b011, 1'b0, 1'b1, 1'b1, 4'b0110, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("XORI",  7'b0010011, 3'b100, 1'b0, 1'b1, 1'b1, 4'b0100, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SRLI",  7'b0010011, 3'b101, 1'b0, 1'b1, 1'b1, 4'b1000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("SRAI",  7'b0010011, 3'b101, 1'b1, 1'b1, 1'b1, 4'b1001, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("ORI",   7'b0010011, 3'b110, 1'b0, 1'b1, 1'b1, 4'b0011, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);
        check("ANDI",  7'b0010011, 3'b111, 1'b0, 1'b1, 1'b1, 4'b0010, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        check("LW",  7'b0000011, 3'b010, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
        check("LB",  7'b0000011, 3'b000, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
        check("LBU", 7'b0000011, 3'b100, 1'b0, 1'b1, 1'b1, 4'b0000, 1'b1, 1'b0, 1'b1, 1'b0, 1'b0);
        check("SW",  7'b0100011, 3'b010, 1'b0, 1'b0, 1'b1, 4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0);
        check("SB",  7'b0100011, 3'b000, 1'b0, 1'b0, 1'b1, 4'b0000, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0);

        check("BEQ",  7'b1100011, 3'b000, 1'b0, 1'b0, 1'b0, 4'b0001, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);
        check("BNE",  7'b1100011, 3'b001, 1'b0, 1'b0, 1'b0, 4'b0001, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1);
        check("BLT",  7'b1100011, 3'b100, 1'b0, 1'b0, 1'b0, 4'b0101, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1);
        check("BGE",  7'b1100011, 3'b101, 1'b0, 1'b0, 1'b0, 4'b0101, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);
        check("BLTU", 7'b1100011, 3'b110, 1'b0, 1'b0, 1'b0, 4'b0110, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1);
        check("BGEU", 7'b1100011, 3'b111, 1'b0, 1'b0, 1'b0, 4'b0110, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);
        check("BEQ (bit 30 set)", 7'b1100011, 3'b000, 1'b1, 1'b0, 1'b0, 4'b0001, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);
        check("BGE (bit 30 set)", 7'b1100011, 3'b101, 1'b1, 1'b0, 1'b0, 4'b0101, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0);
        check("Invalid branch funct3 does nothing", 7'b1100011, 3'b010, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        check("Unsupported opcode writes nothing", 7'b1101111, 3'b000, 1'b0, 1'b0, 1'b0, 4'b0000, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0);

        if (errors == 0)
            $display("ALL TESTS PASSED");
        else
            $fatal(1, "%0d FAILURES", errors);
        $finish;
    end

endmodule
