module simple_memory(
    input logic [31:0] address,
    output logic [31:0] data

    // This means, input is 32 bit address, and output is also 32 bit address.
);

    // Memory Table -> 16 words, each of 32 bit 
    // We can also think this as array of 16 numbers each of 32 bits
    logic [31:0] memory [0:15];

    // Initialize memory with some known values
    initial begin
        
        // 32'dn -> store decimal number n in 32 bit register
        memory[0] = 32'h003100B3;

    end

    // assign logic, address = program counter, which is increasing by 4, do divide by 4
    assign data = memory[address >> 2];

endmodule
