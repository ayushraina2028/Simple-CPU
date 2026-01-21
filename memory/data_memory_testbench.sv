module data_memory_tb;

    logic clock;
    logic memory_we;
    logic [31:0] address;
    logic [31:0] write_data;
    logic [31:0] read_data;

    data_memory dm1 (
        .clock(clock),
        .memory_we(memory_we),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    // clock
    initial clock = 0;
    always #5 clock = ~clock;

    initial begin
        memory_we = 0;

        // read initial values
        address = 0;
        #1 $display("mem[0] = %0d", read_data);

        address = 4;
        #1 $display("mem[1] = %0d", read_data);

        // write value 999 into mem[2]
        address = 8;
        write_data = 999;
        memory_we = 1;

        #10; // wait for clock edge
        memory_we = 0;

        // read back
        address = 8;
        #1 $display("mem[2] = %0d", read_data);

        $finish;
    end

endmodule
