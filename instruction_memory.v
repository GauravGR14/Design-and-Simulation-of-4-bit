// ============================================================
// Instruction Memory
// 16 x 8-bit ROM holding the program. Combinational read --
// no clock involved, address in, instruction out.
// Preloaded here with the verified test program.
//
// Encoding reminder: [opcode(4 bits) | rd(2 bits) | rs(2 bits)]
// ============================================================
module instruction_memory(
    input  [3:0] address,
    output [7:0] instruction
);
    reg [7:0] memory [0:15];

    initial begin
        // PC=0: opcode=0101(LOAD), rd=01(R1), rs=11(addr 3) -> LOAD R1 <- MEM[3]
        //       R1 = 6 (MEM[3]'s initial value)
        memory[0] = 8'b01010111;

        // PC=1: opcode=0101(LOAD), rd=11(R3), rs=10(addr 2) -> LOAD R3 <- MEM[2]
        //       R3 = 12 (MEM[2]'s initial value)
        memory[1] = 8'b01011110;

        // PC=2: opcode=0001(SUB), rd=01(R1), rs=11(R3) -> R1 = R1 - R3
        //       6 - 12 wraps (via 5-bit width extension) to Result=10, Carry=1 (borrow)
        memory[2] = 8'b00010111;

        // PC=3: opcode=0010(AND), rd=01(R1), rs=11(R3) -> R1 = R1 & R3
        //       10 & 12 = 8
        memory[3] = 8'b00100111;

        // PC=4: opcode=0011(OR), rd=01(R1), rs=11(R3) -> R1 = R1 | R3
        //       8 | 12 = 12
        memory[4] = 8'b00110111;

        // PC=5: opcode=0100(XOR), rd=01(R1), rs=11(R3) -> R1 = R1 ^ R3
        //       12 ^ 12 = 0
        memory[5] = 8'b01000111;

        // PC=6: opcode=0000(ADD), rd=01(R1), rs=11(R3) -> R1 = R1 + R3
        //       0 + 12 = 12
        memory[6] = 8'b00000111;

        // PC=7: opcode=0110(STORE), rd=01(R1, source value), rs=01(addr 1) -> MEM[1] <- R1
        //       MEM[1] = 12 (overwrites its initial value of 2)
        memory[7] = 8'b01100101;

        // PC=8: opcode=1111(HALT), rd/rs unused -> freezes pc_enable, processor stops here
        memory[8] = 8'b11110000;

        // PC=9-15: unused, never reached since HALT freezes the PC at address 8
        memory[9]  = 8'b00000000;
        memory[10] = 8'b00000000;
        memory[11] = 8'b00000000;
        memory[12] = 8'b00000000;
        memory[13] = 8'b00000000;
        memory[14] = 8'b00000000;
        memory[15] = 8'b00000000;
    end

    assign instruction = memory[address];
endmodule
