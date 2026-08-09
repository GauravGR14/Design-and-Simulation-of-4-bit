// ============================================================
// Processor Top
// Wires together PC, instruction memory, control unit, register file,
// ALU, and data memory into a complete single-cycle 4-bit processor.
//
// Instruction format (8 bits): [opcode(4) | rd(2) | rs(2)]
//   - This is a 2-operand, DESTRUCTIVE format: ADD Rd, Rd, Rs means
//     Rd = Rd + Rs, overwriting Rd. There's no separate 3rd operand
//     field -- with only 8 instruction bits, a 2-bit opcode-adjacent
//     rd/rs pair is what's available after reserving 4 bits for opcode.
//   - For LOAD/STORE, the `rs` field is reinterpreted as a 2-bit
//     IMMEDIATE memory address (0-3), not a register selector. This
//     means only 4 of the 16 data memory locations are ever reachable
//     by the current instruction set.
// ============================================================
module processor_top(
    input clk,
    input reset
);

wire [3:0] pc;
wire [7:0] instruction;
wire [3:0] opcode;
wire [1:0] rd;
wire [1:0] rs;
wire reg_write;
wire mem_write;
wire [2:0] alu_sel;
wire pc_enable;
wire [3:0] read_data1;
wire [3:0] read_data2;
wire [3:0] write_data;
wire [3:0] alu_result;
wire zero;
wire carry;
wire [3:0] mem_data;

// --------------------------------------------------
// Instruction decode (bit-slicing, see format note above)
// --------------------------------------------------
assign opcode = instruction[7:4];
assign rd     = instruction[3:2];
assign rs     = instruction[1:0];

// --------------------------------------------------
// HALT control: freeze the PC once a HALT instruction is fetched.
// --------------------------------------------------
assign pc_enable = (opcode == 4'b1111) ? 1'b0 : 1'b1;

// --------------------------------------------------
// Reset-gated write enables.
//
// WHY THIS MATTERS: instruction_memory, control_unit, and the ALU are
// all purely combinational, driven off whatever `pc` currently holds.
// While `reset` is asserted, the PC correctly freezes at address 0 --
// but nothing else "knows" reset is active. If the instruction sitting
// at address 0 has reg_write=1 or mem_write=1 (e.g. a LOAD), it will
// fire on every clock edge for as long as reset is held, potentially
// executing multiple times before the program has "really" started.
// For an idempotent instruction (like LOAD) this is silently harmless;
// for an accumulating instruction (like ADD) it corrupts state.
// Gating both write-enables with ~reset closes this off entirely.
// --------------------------------------------------
wire reg_write_gated = reg_write & ~reset;
wire mem_write_gated = mem_write & ~reset;

program_counter PC(
    .clk(clk), .reset(reset), .enable(pc_enable), .pc(pc)
);

instruction_memory IM(
    .address(pc), .instruction(instruction)
);

control_unit CU(
    .opcode(opcode), .reg_write(reg_write), .mem_write(mem_write), .alu_sel(alu_sel)
);

register_file RF(
    .clk(clk), .we(reg_write_gated),
    .read_addr1(rd), .read_addr2(rs),
    .write_addr(rd), .write_data(write_data),
    .read_data1(read_data1), .read_data2(read_data2)
);

alu ALU(
    .A(read_data1), .B(read_data2), .ALU_Sel(alu_sel),
    .Result(alu_result), .Zero(zero), .Carry(carry)
);

data_memory DM(
    .clk(clk), .we(mem_write_gated),
    .address({2'b00, rs}),   // rs used as a 2-bit immediate address, zero-extended
    .write_data(read_data1), // for STORE: the value of Rd (read_data1, since read_addr1=rd)
    .read_data(mem_data)
);

// --------------------------------------------------
// Write-back mux: LOAD pulls its result from memory,
// every other reg_write instruction pulls from the ALU.
// --------------------------------------------------
assign write_data = (opcode == 4'b0101) ? mem_data : alu_result;

endmodule
