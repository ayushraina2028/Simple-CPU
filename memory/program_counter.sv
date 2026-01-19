module program_counter(
    input logic clock,
    input logic reset,
    input logic is_halt,
    output logic [31:0] program_counter_value

    // program_counter_value is the address to be used next
    // on reset program counter value sets to 0 again and on every clock it increments itself
    // it generates 0,1,2,3,4,... and so on.
);

    always_ff @(posedge clock) begin

        if (reset) 
            program_counter_value <= 32'd0;
        else if(!is_halt)
            program_counter_value <= program_counter_value + 32'd4;
        else    
            program_counter_value <= program_counter_value;
    end

endmodule