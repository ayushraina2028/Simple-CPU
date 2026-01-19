module register_file(
    input logic [4:0] rs1,
    input logic [4:0] rs2,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    // 32 registers of 32 bit each.
    logic [31:0] registers [0:31];

    // Initialize some of them for experiments
    initial begin

        registers[0] = 32'd0;
        registers[2] = 32'd10;
        registers[3] = 32'd20;

    end

    // read ports
    assign rs1_data = registers[rs1];
    assign rs2_data = registers[rs2];

endmodule