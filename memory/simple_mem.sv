module simple_memory(
    input logic [31:0] address,
    output logic [31:0] data

    // This means, input is 32 bit address, and output is also 32 bit address.
);

    // Memory Table -> sized for program_words.hex format
    logic [31:0] memory [0:255];

    // Initialize memory with some known values
    initial begin
        $readmemh("program_words.hex", memory);
    end


    // assign logic, address = program counter, which is increasing by 4, do divide by 4
    assign data = memory[address >> 2];

endmodule
