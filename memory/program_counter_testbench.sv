module pc_testbench;

    logic clock;
    logic reset;
    logic [31:0] pc_value;
    logic [31:0] data;

    // Program counter
    program_counter pc (
        .clock(clock),
        .reset(reset),
        .program_counter_value(pc_value)
    );

    // Memory
    simple_memory memory (
        .address(pc_value),
        .data(data)
    );

    // Clock
    initial clock = 0;
    always #5 clock = ~clock;

    // t = 5, clock is 1, t = 10 (c = 0, no record), t = 15 (clock = 1, record again) and so on.

    initial begin

        reset = 1;
        #10;
        reset = 0;

        #50;
        $finish;

    end

    initial begin

        $monitor("time=%0t PC= %0d Data = %0d", $time, pc_value, data);

    end

endmodule