module instruction_register (
    input logic clock,
    input logic [31:0] instruction_in,
    output logic [31:0] instruction_out
);

    always_ff @(posedge clock) begin
        instruction_out <= instruction_in;
    end

endmodule