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
    logic is_sub;
    logic is_addi;
    logic is_subi;
    logic is_halt;
    logic is_lw;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    
    logic [31:0] alu_result;
    
    logic reg_we;
    
    logic [31:0] x1_value;
    logic [31:0] x4_value;
    logic [31:0] x5_value;
    logic [31:0] x6_value;
    logic [31:0] x7_value;
    logic [31:0] x8_value;

    logic [31:0] imm;

    logic memory_we;
    logic [31:0] memory_address;
    logic [31:0] memory_write_data;
    logic [31:0] memory_read_data;

    logic [31:0] wb_data;

    data_memory dm1 (
        .clock(clock),
        .memory_we(memory_we),
        .address(memory_address),
        .write_data(memory_write_data),
        .read_data(memory_read_data)
    );

    // Register
    register_file rf1 (
        .clock(clock),
        .we(reg_we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(wb_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // Wire Testing
    assign memory_address = alu_result;
    assign memory_write_data = rs2_data;
    assign memory_we = 1'b0; // no writes for lw
    assign wb_data = is_lw ? memory_read_data : alu_result;

    // Get register values
    assign x1_value = rf1.registers[1];
    assign x4_value = rf1.registers[4];
    assign x5_value = rf1.registers[5];
    assign x6_value = rf1.registers[6];
    assign x7_value = rf1.registers[7];
    assign x8_value = rf1.registers[8];

    // Write support for add and sub instruction.
    assign reg_we = (is_add | is_sub | is_addi | is_subi | is_lw) & ~is_halt;

    // Computing Result, handle both add and sub
    assign alu_result = 
        is_add ? (rs1_data + rs2_data) : 
        is_sub ? (rs1_data - rs2_data) : 
        is_addi ? (rs1_data + imm) :
        is_subi ? (rs1_data - imm) :
        is_lw ? (rs1_data + imm) :
        32'b0;

    // Checking if its an add instruction;
    assign is_add = (opcode == 7'b0110011) && (func3 == 3'b000) && (func7 == 7'b0000000);

    // Checkingif its an subtract operation
    assign is_sub = (opcode == 7'b0110011) && (func3 == 3'b000) && (func7 == 7'b0100000);

    // Checking if its an addi operation
    assign is_addi = (opcode == 7'b0010011) && (func3 == 3'b000);

    // Checking if its an subi (our own)
    assign is_subi = (opcode == 7'b0010011) && (func3 == 3'b001);

    // Checking if its an halt operation
    assign is_halt = (instruction == 32'hFFFFFFFF);

    // Checking if this is a lw instruction
    assign is_lw = (opcode == 7'b0000011) && (func3 == 3'b010);

    // Getting imm (sign extended)
    assign imm = {{20{instruction[31]}}, instruction[31:20]};

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
        .is_halt(is_halt),
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

        #100;
        $finish;

    end

    // Halt early if halt instruction is executed
    always @(posedge clock) begin
        if(is_halt) begin

            $display("CPU Halted at time %0t", $time);
            $finish;

        end
    end

    initial begin

        $monitor("time=%0t PC= %0d Instruction = %0d Opcode = %07b rd = %0d rs1 = %0d rs2 = %0d func3 = %03b func7 = %07b is_add=%0d rs1_value = %0d, rs2_value = %0d, alu_result = %0d, x1=%0d x4 = %0d x5 = %0d x6 = %0d x7=%0d memory_address = %0d memory_we = %0d memory_read = %0d x5_value = %0d x8_value = %0d", $time, pc_value, instruction, opcode, rd, rs1, rs2, func3, func7, is_add, rs1_data, rs2_data, alu_result, x1_value, x4_value, x5_value, x6_value, x7_value, memory_address, memory_we, memory_read_data, x5_value, x8_value);

    end

endmodule