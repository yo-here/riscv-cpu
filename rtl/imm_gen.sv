module imm_gen (
    input  logic [31:0] instruction,
    output logic [31:0] immediate
);

    always_comb begin
        case (instruction[6:0])

            7'b0010011: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            7'b0000011: begin
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end

            7'b0100011: begin
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            end

            7'b1100011: begin
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};
            end

            7'b1101111: begin
                immediate = {{11{instruction[31]}},
                             instruction[31],
                             instruction[19:12],
                             instruction[20],
                             instruction[30:21],
                             1'b0};
            end

            default: begin
                immediate = 32'd0;
            end

        endcase
    end

endmodule
