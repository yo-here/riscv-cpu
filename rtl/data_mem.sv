// Data memory module for our RISC-V CPU
module data_mem (

    // CPU clock signal
    input logic clk,

    // Enables reading from memory
    input logic mem_read,

    // Enables writing to memory
    input logic mem_write,

// Selects the memory access size and signedness
input logic [2:0] funct3,

    // 32-bit byte address supplied by the ALU
    input logic [31:0] address,

    // Data coming from the CPU register file
    input logic [31:0] write_data,

    // Data being returned to the CPU
    output logic [31:0] read_data
);

    // Create 256 memory locations, each 32 bits wide
    logic [31:0] memory [0:255];

// Write data to memory on the rising clock edge
always_ff @(posedge clk) begin

    // Only write when enabled and address is within memory
    if (mem_write && address < 32'd1024) begin

        // Select the store instruction using funct3
        case (funct3)

            // SB: Store one byte
            3'b000: begin

                // Select one of the four bytes in the memory word
                case (address[1:0])

                    // Write bits 7 through 0
                    2'b00: memory[address[9:2]][7:0] <= write_data[7:0];

                    // Write bits 15 through 8
                    2'b01: memory[address[9:2]][15:8] <= write_data[7:0];

                    // Write bits 23 through 16
                    2'b10: memory[address[9:2]][23:16] <= write_data[7:0];

                    // Write bits 31 through 24
                    2'b11: memory[address[9:2]][31:24] <= write_data[7:0];

                endcase

            end

            // SH: Store two bytes
            3'b001: begin

                // Halfword addresses must be divisible by two
                if (address[0] == 1'b0) begin

                    // Select the lower or upper halfword
                    if (address[1] == 1'b0)
                        memory[address[9:2]][15:0] <= write_data[15:0];
                    else
                        memory[address[9:2]][31:16] <= write_data[15:0];

                end

            end

            // SW: Store an entire 32-bit word
            3'b010: begin

                // Word addresses must be divisible by four
                if (address[1:0] == 2'b00)
                    memory[address[9:2]] <= write_data;

            end

            // Unsupported store types perform no write
            default: ;

        endcase

    end

end

// Read data from memory using combinational logic
always_comb begin

    // Default output is zero
    read_data = 32'd0;

    // Only read when enabled and address is within memory
    if (mem_read && address < 32'd1024) begin

        // Select the load instruction using funct3
        case (funct3)

            // LB: Load one signed byte
            3'b000: begin

                // Select the byte using the lower address bits
                case (address[1:0])
                    2'b00: read_data = {{24{memory[address[9:2]][7]}}, memory[address[9:2]][7:0]};
                    2'b01: read_data = {{24{memory[address[9:2]][15]}}, memory[address[9:2]][15:8]};
                    2'b10: read_data = {{24{memory[address[9:2]][23]}}, memory[address[9:2]][23:16]};
                    2'b11: read_data = {{24{memory[address[9:2]][31]}}, memory[address[9:2]][31:24]};
                endcase

            end

            // LH: Load one signed halfword
            3'b001: begin

                // Halfword addresses must be aligned to two bytes
                if (address[0] == 1'b0) begin

                    // Select lower or upper halfword
                    if (address[1] == 1'b0)
                        read_data = {{16{memory[address[9:2]][15]}}, memory[address[9:2]][15:0]};
                    else
                        read_data = {{16{memory[address[9:2]][31]}}, memory[address[9:2]][31:16]};

                end

            end

            // LW: Load a complete 32-bit word
            3'b010: begin

                // Word addresses must be aligned to four bytes
                if (address[1:0] == 2'b00)
                    read_data = memory[address[9:2]];

            end

            // LBU: Load one unsigned byte
            3'b100: begin

                // Select the byte and fill upper bits with zeros
                case (address[1:0])
                    2'b00: read_data = {24'd0, memory[address[9:2]][7:0]};
                    2'b01: read_data = {24'd0, memory[address[9:2]][15:8]};
                    2'b10: read_data = {24'd0, memory[address[9:2]][23:16]};
                    2'b11: read_data = {24'd0, memory[address[9:2]][31:24]};
                endcase

            end

            // LHU: Load one unsigned halfword
            3'b101: begin

                // Halfword addresses must be aligned to two bytes
                if (address[0] == 1'b0) begin

                    // Select the halfword and fill upper bits with zeros
                    if (address[1] == 1'b0)
                        read_data = {16'd0, memory[address[9:2]][15:0]};
                    else
                        read_data = {16'd0, memory[address[9:2]][31:16]};

                end

            end

            // Unsupported load types return zero
            default: ;

        endcase

    end

end
// End the data memory module
endmodule
