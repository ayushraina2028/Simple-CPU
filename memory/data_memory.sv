module data_memory (
    input logic clock,
    input logic memory_we, // write enable
    input logic [31:0] address, // byte address
    input logic [31:0] write_data, // data to store
    output logic [31:0] read_data // data loaded
);


    // We need 65536 words to support full 32-bit address space (after >> 2)
    logic [31:0] memory [0:65535];

    // Fill some values for simulation
    initial begin

        memory[0] = 32'd100;
        memory[1] = 32'd200;
        memory[2] = 32'd300;
        memory[5] = 32'd888;
        
    end

    // 31:2 means divide by 4, but mask to valid memory range
    assign read_data = memory[address[15:2]];  // Mask to 14 bits for 16K words 

    // Write on clock
    always_ff @(posedge clock) begin

        if(memory_we) begin
            memory[address[15:2]] <= write_data;  // Mask address to valid range
        end

    end


endmodule