module program_counter(
    input logic clock,
    input logic reset,
    input logic is_halt,
    input logic is_jal,
    input logic is_jalr,
    input logic branch_taken,
    input logic [31:0] branch_target,
    input logic [31:0] jalr_target,
    input logic [31:0] imm_j,
    output logic [31:0] program_counter_value
);

    logic [31:0] next_pc;
    assign next_pc = 
                    branch_taken ? branch_target : 
                    is_jal ? (program_counter_value + imm_j) :
                    is_jalr ? jalr_target :
                    program_counter_value + 32'd4;

    always_ff @(posedge clock) begin
        if (reset) 
            program_counter_value <= 32'd0;
        else if (!is_halt)
            program_counter_value <= next_pc;
        else    
            program_counter_value <= program_counter_value;
    end

endmodule
