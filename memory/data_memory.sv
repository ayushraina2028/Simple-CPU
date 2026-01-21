module data_memory (
    input logic clock,
    input logic memory_we, // write enable
    input logic [31:0] address, // byte address
    input logic [31:0] write_data, // data to store
    output logic [31:0] read_data // data loaded
);


    // We will have 64 words of memory for now
    logic [31:0] memory [0:63];

    // Fill some values for simulation
    initial begin

        memory[0] = 32'd100;
        memory[1] = 32'd200;
        memory[2] = 32'd300;

    end

    // 31:2 means
    assign read_data = memory[address[31:2]]; 

    // Write on clock
    always_ff @(posedge clock) begin

        if(memory_we) begin
            memory[address[31:2]] <= write_data;
        end

    end


endmodule