module pc_testbench;

    logic clock;
    logic reset;
    logic [31:0] pc_value;
    logic [31:0] data;
    logic [31:0] instruction;
    logic [6:0] opcode;
    logic [4:0] rd;
    logic [4:0] rs1;
    logic [4:0] rs2;
    logic [2:0] func3;
    logic [6:0] func7;
    logic is_add;

    // Checking if its an add instruction;
    assign is_add = (opcode == 7'b0110011) && (func3 == 3'b000) && (func7 == 7'b0000000);

    // In Riscv, instructions are of 32 bits and lower 7 bits are for opcodes
    assign opcode = instruction[6:0];

    // Extracting Operands from instruction
    assign rd = instruction[11:7];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];

    // Extract f -> which will be applied on rd, rs1, rs2
    assign func3 = instruction[14:12];
    assign func7 = instruction[31:25];

    // Instruction Register
    instruction_register ir (
        .clock(clock),
        .instruction_in(data),
        .instruction_out(instruction)
    );

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

        $monitor("time=%0t PC= %0d Instruction = %0d Opcode = %07b rd = %0d rs1 = %0d rs2 = %0d func3 = %03b func7 = %07b is_add=%0d", $time, pc_value, instruction, opcode, rd, rs1, rs2, func3, func7, is_add);

    end

endmodule