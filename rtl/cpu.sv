

module cpu (
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] instruction
);

    // Program counter
    logic [31:0] pc;

    // Decoder control signals
    logic reg_write;
    logic alu_src;
    logic mem_read;
    logic mem_write;
    logic mem_to_reg;
    logic branch;
    logic branch_ne;
    logic [3:0] alu_control;

    // Register file outputs
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;

    // Immediate generator output
    logic [31:0] immediate;

    // ALU signals
// Holds the selected first input to the ALU
logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;
    logic [31:0] alu_result;
    logic        alu_zero;
    
    // Holds the 32-bit value read from data memory
    logic [31:0] memory_read_data;

    // Holds the final value to write into a CPU register
    logic [31:0] writeback_data;
 
    // Instruction memory
    instr_mem imem (
        .addr(pc),
        .instruction(instruction)
    );

    // Instruction decoder
    decoder dec (
        .opcode(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7_5(instruction[30]),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .branch_ne(branch_ne),
        .alu_control(alu_control)
    );

    // Register file
       regfile rf (
    .clk(clk),
    .write_en(reg_write),
    .rs1(instruction[19:15]),
    .rs2(instruction[24:20]),
    .rd(instruction[11:7]),
    // Write the selected ALU or memory result
    .write_data(writeback_data),
    .read_data1(rs1_data),
    .read_data2(rs2_data)
);

    // Immediate generator
    imm_gen imm (
        .instruction(instruction),
        .immediate(immediate)
    );

// Select the first ALU operand
always_comb begin

    // Normally use the value from register rs1
    alu_operand_a = rs1_data;

    // LUI: use zero so the ALU returns the immediate
    if (instruction[6:0] == 7'b0110111)
        alu_operand_a = 32'd0;

    // AUIPC: use the current program counter
    else if (instruction[6:0] == 7'b0010111)
        alu_operand_a = pc;

end

    // Select ALU operand B
    assign alu_operand_b = alu_src ? immediate : rs2_data;

    // Arithmetic Logic Unit
    alu alu_inst (
        .a(alu_operand_a),
        .b(alu_operand_b),
    .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );

// Instantiate the data memory module
data_mem dmem (

    // Connect CPU clock to memory clock
    .clk(clk),

    // Decoder enables memory reads for LW
    .mem_read(mem_read),

    // Decoder enables memory writes for SW
    .mem_write(mem_write),

// Pass instruction bits 14 through 12 to data memory
.funct3(instruction[14:12]),

    // ALU calculates the memory address
    .address(alu_result),

    // Register rs2 supplies the value stored by SW
    .write_data(rs2_data),

    // Memory returns the value requested by LW
    .read_data(memory_read_data)

);

// Select which result goes back into the register file
// Select the value written into the destination register
always_comb begin

    // Default: write the ALU result
    writeback_data = alu_result;

    // LW: Write data retrieved from memory
    if (mem_to_reg)
        writeback_data = memory_read_data;

    // JAL or JALR: Write the return address (PC + 4)
    else if (instruction[6:0] == 7'b1101111 ||
             instruction[6:0] == 7'b1100111)
        writeback_data = pc + 32'd4;

end

// Branch decision
logic branch_taken;


// Determine whether the current branch condition is true
always_comb begin

    // Default: do not take the branch
    branch_taken = 1'b0;

    // Only evaluate branch conditions for branch instructions
    if (branch) begin

        // funct3 identifies which branch comparison to perform
        case (instruction[14:12])

            // BEQ: Branch if both registers are equal
            3'b000: branch_taken = (rs1_data == rs2_data);

            // BNE: Branch if the registers are not equal
            3'b001: branch_taken = (rs1_data != rs2_data);

            // BLT: Branch if rs1 is less than rs2 (signed)
            3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data));

            // BGE: Branch if rs1 is greater than or equal to rs2 (signed)
            3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data));

            // BLTU: Branch if rs1 is less than rs2 (unsigned)
            3'b110: branch_taken = (rs1_data < rs2_data);

            // BGEU: Branch if rs1 is greater than or equal to rs2 (unsigned)
            3'b111: branch_taken = (rs1_data >= rs2_data);

            // Unsupported branch condition
            default: branch_taken = 1'b0;

        endcase
    end
end

// Program counter update
always_ff @(posedge clk or posedge reset) begin

    // Reset execution to address zero
    if (reset)
        pc <= 32'h00000000;

    // JAL: Jump to the current PC plus the immediate
    else if (instruction[6:0] == 7'b1101111)
        pc <= pc + immediate;

    // JALR: Jump to rs1 plus immediate, clearing bit zero
    else if (instruction[6:0] == 7'b1100111)
        pc <= (rs1_data + immediate) & 32'hFFFFFFFE;

    // Conditional branch: Jump only when the condition is true
    else if (branch_taken)
        pc <= pc + immediate;

    // Normal instruction: Advance to the next instruction
    else
        pc <= pc + 32'd4;

end 
   
endmodule
