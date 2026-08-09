`timescale 1ns/1ps
// ============================================================
// Testbench for processor_top
// Runs the full program end-to-end, prints a live cycle-by-cycle
// trace, then dumps final register and memory state for verification.
// ============================================================
module processor_tb;
reg clk;
reg reset;

    // Device under test
    processor_top uut (clk,reset);

    // --------------------------------------------------
    // Clock generation: 10ns period (5ns high, 5ns low) --
    // frequency doesn't matter for functional simulation,
    // only the relative timing of edges does.
    // --------------------------------------------------
    initial begin
    clk = 0;
    forever #5 clk = ~clk;
    end

    // --------------------------------------------------
    // Reset pulse: held high for the first 20ns (2 clock
    // cycles) before the processor starts executing.
    // Note: reg_write/mem_write are gated by ~reset inside
    // processor_top specifically to keep this window safe --
    // see the comments in processor_top.v for why that matters.
    // --------------------------------------------------
    initial begin
     reset = 1;
     #20;
    reset = 0;
    end

    // --------------------------------------------------
    // Live trace: prints PC, raw instruction bits, decoded
    // opcode, and control signals every time any of them change.
    // --------------------------------------------------
    initial begin
        $display("--------------------------------------------------------------------------");
        $display(" Time | PC | Instruction | Opcode | RegWrite | MemWrite | ALU Result");
        $display("--------------------------------------------------------------------------");
        $monitor("%4t | %2d | %b | %b |    %b     |     %b     | %d",
$time,uut.pc,uut.instruction,uut.opcode,uut.reg_write,uut.mem_write,uut.alu_result);
end

    // --------------------------------------------------
    // Final state dump: runs once the program has had enough
    // time to reach HALT (9 instructions x ~10ns each, plus the
    // 20ns reset window, comfortably fits within 200ns).
    // Reads register_file and data_memory contents directly via
    // hierarchical references (uut.RF / uut.DM) for verification.
    // --------------------------------------------------
initial begin
#200;
        $display("\n================ FINAL REGISTER VALUES ================");
        $display("R0 = %d", uut.RF.regfile[0]);
        $display("R1 = %d", uut.RF.regfile[1]);
        $display("R2 = %d", uut.RF.regfile[2]);
        $display("R3 = %d", uut.RF.regfile[3]);
        $display("\n================ FINAL DATA MEMORY ====================");
        $display("MEM[0] = %d", uut.DM.memory[0]);
        $display("MEM[1] = %d", uut.DM.memory[1]);
        $display("MEM[2] = %d", uut.DM.memory[2]);
        $display("MEM[3] = %d", uut.DM.memory[3]);
        $display("\nSimulation Finished Successfully.");
        $finish;
 end
endmodule
