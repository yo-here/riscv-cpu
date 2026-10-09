

module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instruction
);

    logic [31:0] memory [0:255];

    initial begin
        $readmemh("program.hex", memory);
    end

    always_comb begin
        instruction = 32'h00000000;

        if (addr < 32'd1024 && addr[1:0] == 2'b00)
            instruction = memory[addr[9:2]];
    end

endmodule
