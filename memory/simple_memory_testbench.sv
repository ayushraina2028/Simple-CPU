module memory_testbench;

    logic [31:0] address;
    logic [31:0] data;

    simple_memory dut (
        .address(address),
        .data(data)
    );

    initial begin 
        
        address = 0;
        #1 $display(
            "address = 0 data = %0d", data
        );

        address = 1;
        #1 $display(
            "address = 1, data = %0d", data
        );
        
        // When address changes, data automatically changes because of Line 24 in simple_mem.sv
        address = 2;
        #1 $display(
            "address = 2, data = %0d", data
        );

        address = 3;
        #1 $display(
            "address = 3, data = %0d", data
        );

        $finish;
    end

endmodule