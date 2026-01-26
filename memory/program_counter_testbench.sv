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
    logic is_sw;

    logic is_beq;
    logic is_bne;
    logic is_blt;
    logic is_bge;
    logic is_bltu;
    logic is_bgeu;

    logic is_jal;
    logic is_jalr;

    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    
    logic [31:0] alu_result;
    
    logic reg_we;
    
    logic [31:0] x1_value;
    logic [31:0] x2_value;
    logic [31:0] x3_value;
    logic [31:0] x4_value;
    logic [31:0] x5_value;
    logic [31:0] x6_value;
    logic [31:0] x7_value;
    logic [31:0] x8_value;

    logic [31:0] mem6_value;

    logic [31:0] imm;
    logic [31:0] imm_s; // S type immediate
    logic [31:0] imm_b; // B type immediate
    logic [31:0] imm_j;

    logic memory_we;
    logic [31:0] memory_address;
    logic [31:0] memory_write_data;
    logic [31:0] memory_read_data;

    logic [31:0] wb_data;

    logic branch_taken;
    logic [31:0] branch_target;

    logic [31:0] jalr_target;


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

    // assign branch
    assign branch_taken = 
        (is_beq && (rs1_data == rs2_data)) ||
        (is_blt && ($signed(rs1_data) < $signed(rs2_data))) ||
        (is_bge && ($signed(rs1_data) >= $signed(rs2_data))) || 
        (is_bltu && (rs1_data < rs2_data)) ||
        (is_bgeu && (rs1_data >= rs2_data)) ||
        (is_bne && (rs1_data != rs2_data));

    assign branch_target = pc_value + imm_b;

    // Assign jalr_target
    assign jalr_target = rs1_data + imm;

    // Get memory values
    assign mem6_value = dm1.memory[6];

    // Wire Testing
    assign memory_address = alu_result;
    assign memory_write_data = rs2_data;
    assign memory_we = is_sw; // no writes for lw
    assign wb_data = 
        is_lw ? memory_read_data :
        is_jal ? (pc_value + 32'd4) : 
        is_jalr ? (pc_value + 32'd4) :
        alu_result;

    // Get register values
    assign x1_value = rf1.registers[1];
    assign x2_value = rf1.registers[2];
    assign x3_value = rf1.registers[3];
    assign x4_value = rf1.registers[4];
    assign x5_value = rf1.registers[5];
    assign x6_value = rf1.registers[6];
    assign x7_value = rf1.registers[7];
    assign x8_value = rf1.registers[8];

    // Write support for add and sub instruction.
    assign reg_we = (is_add | is_sub | is_addi | is_subi | is_lw | is_jal | is_jalr) & ~is_halt;

    // Computing Result, handle both add and sub
    assign alu_result = 
        is_add ? (rs1_data + rs2_data) : 
        is_sub ? (rs1_data - rs2_data) : 
        is_addi ? (rs1_data + imm) :
        is_subi ? (rs1_data - imm) :
        is_lw ? (rs1_data + imm) :
        is_sw ? (rs1_data + imm_s) :
        32'b0;

    // Checking for add,sub,addi,subi,halt,lw,sw
    assign is_add = (opcode == 7'b0110011) && (func3 == 3'b000) && (func7 == 7'b0000000);
    assign is_sub = (opcode == 7'b0110011) && (func3 == 3'b000) && (func7 == 7'b0100000);
    assign is_addi = (opcode == 7'b0010011) && (func3 == 3'b000);
    assign is_subi = (opcode == 7'b0010011) && (func3 == 3'b001);
    assign is_halt = (instruction == 32'hFFFFFFFF);
    assign is_lw = (opcode == 7'b0000011) && (func3 == 3'b010);
    assign is_sw = (opcode == 7'b0100011) && (func3 == 3'b010);
    
    assign is_beq = (opcode == 7'b1100011) && (func3 == 3'b000);
    assign is_bne = (opcode == 7'b1100011) && (func3 == 3'b001);
    assign is_blt = (opcode == 7'b1100011) && (func3 == 3'b100);
    assign is_bge = (opcode == 7'b1100011) && (func3 == 3'b101);
    assign is_bltu = (opcode == 7'b1100011) && (func3 == 3'b110);
    assign is_bgeu = (opcode == 7'b1100011) && (func3 == 3'b111);

    assign is_jal = (opcode == 7'b1101111);
    assign is_jalr = (opcode == 7'b1100111) && (func3 == 3'b000);

    // Getting imm (sign extended)
    assign imm = {{20{instruction[31]}}, instruction[31:20]};
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    assign imm_b = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    assign imm_j = {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
 

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
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .jalr_target(jalr_target),
        .imm_j(imm_j),
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
    // fetch_next, execute_next , write_prev - 1 cycle
    initial begin

        reset = 1;
        #10;
        reset = 0;

        #150;
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

        $monitor("time=%0t | PC=%0d | Instr=0x%h (Opc=%07b f3=%03b f7=%07b) | rd=%0d rs1=%0d rs2=%0d | rs1_data=%0d rs2_data=%0d | imm_b=%0d imm_j=%0d | ALU=%0d | is_beq=%0d is_jal=%0d branch_taken=%0d branch_target=%0d | reg_we=%0d wb_data=%0d | x1=%0d x2=%0d x3=%0d x4 = %0d x5 = %0d x6 = %0d x7 = %0d | mem_we=%0d mem_addr=%0d mem_data=%0d", 
        $time, pc_value, instruction, opcode, func3, func7, rd, rs1, rs2, rs1_data, rs2_data, imm_b, imm_j, alu_result, is_beq, is_jal, branch_taken, branch_target, reg_we, wb_data, x1_value, x2_value, x3_value, x4_value, x5_value, x6_value, x7_value, memory_we, memory_address, memory_read_data);

    end

endmodule