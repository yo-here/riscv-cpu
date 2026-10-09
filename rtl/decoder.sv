module decoder (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    output logic       reg_write,
    output logic       alu_src,
    output logic       mem_read,
    output logic       mem_write,
    output logic       mem_to_reg,
    output logic       branch,
    output logic       branch_ne,
    output logic [3:0] alu_control
);

    always_comb begin
        reg_write   = 1'b0;
        alu_src     = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        mem_to_reg  = 1'b0;
        branch      = 1'b0;
        branch_ne   = 1'b0;
        alu_control = 4'b0000;

        case (opcode)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                case (funct3)
                    3'b000: alu_control = funct7_5 ? 4'b0001 : 4'b0000;
                    3'b001: alu_control = 4'b0111;
                    3'b010: alu_control = 4'b0101;
                    3'b011: alu_control = 4'b0110;
                    3'b100: alu_control = 4'b0100;
                    3'b101: alu_control = funct7_5 ? 4'b1001 : 4'b1000;
                    3'b110: alu_control = 4'b0011;
                    3'b111: alu_control = 4'b0010;
                endcase
            end
            7'b0010011: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    3'b000: alu_control = 4'b0000;
                    3'b001: alu_control = 4'b0111;
                    3'b010: alu_control = 4'b0101;
                    3'b011: alu_control = 4'b0110;
                    3'b100: alu_control = 4'b0100;
                    3'b101: alu_control = funct7_5 ? 4'b1001 : 4'b1000;
                    3'b110: alu_control = 4'b0011;
                    3'b111: alu_control = 4'b0010;
                endcase
            end
            7'b0000011: begin
                reg_write   = 1'b1;
                alu_src     = 1'b1;
                mem_read    = 1'b1;
                mem_to_reg  = 1'b1;
                alu_control = 4'b0000;
            end
            7'b0100011: begin
                alu_src     = 1'b1;
                mem_write   = 1'b1;
                alu_control = 4'b0000;
            end
            7'b1100011: begin
                alu_src = 1'b0;
                case (funct3)
                    3'b000: begin branch = 1'b1; branch_ne = 1'b0; alu_control = 4'b0001; end
                    3'b001: begin branch = 1'b1; branch_ne = 1'b1; alu_control = 4'b0001; end
                    3'b100: begin branch = 1'b1; branch_ne = 1'b1; alu_control = 4'b0101; end
                    3'b101: begin branch = 1'b1; branch_ne = 1'b0; alu_control = 4'b0101; end
                    3'b110: begin branch = 1'b1; branch_ne = 1'b1; alu_control = 4'b0110; end
                    3'b111: begin branch = 1'b1; branch_ne = 1'b0; alu_control = 4'b0110; end
                    default: ;
                endcase
            end

// JAL: Jump and Link
7'b1101111: begin

    // Enable writing the return address to rd
    reg_write = 1'b1;

end

// JALR: Jump and Link Register
7'b1100111: begin

    // Enable writing the return address to rd
    reg_write = 1'b1;

    // Select the immediate as the second ALU operand
    alu_src = 1'b1;

    // Select addition to calculate rs1 + immediate
    alu_control = 4'b0000;

end

            default: ;
            
		// LUI: Load Upper Immediate
            7'b0110111: begin

                // Enable writing to the destination register
                reg_write = 1'b1;

                // Use the immediate as ALU operand B
                alu_src = 1'b1;

                // Select addition in the ALU
                alu_control = 4'b0000;

            end

            // AUIPC: Add Upper Immediate to PC
            7'b0010111: begin

                // Enable writing to the destination register
                reg_write = 1'b1;

                // Use the immediate as ALU operand B
                alu_src = 1'b1;

                // Select addition in the ALU
                alu_control = 4'b0000;

            end
        endcase
    end

endmodule
