// ============================================================
// Arithmetic Logic Unit (ALU)
// Performs one of 8 operations on two 4-bit inputs, selected by ALU_Sel.
// ============================================================
module alu(
    input  [3:0] A,
    input  [3:0] B,
    input  [2:0] ALU_Sel,
    output reg [3:0] Result,
    output       Zero,
    output reg   Carry
);

always @(*) begin
    // Default Carry = 0 so every branch has a defined value
    // (logical ops like AND/OR/XOR don't produce a carry, so they
    // simply leave this default in place).
    Carry = 0;

    case(ALU_Sel)

        3'b000: begin // ADD
            // {Carry, Result} is 5 bits wide, so Verilog automatically
            // zero-extends A and B to 5 bits before adding -- this is
            // what correctly captures the carry-out bit instead of
            // silently truncating it.
            {Carry, Result} = A + B;
        end

        3'b001: begin // SUB
            // Same 5-bit widening trick applies to subtraction.
            // NOTE on convention: Carry=1 here means "a borrow occurred"
            // (i.e. A < B). This is the opposite of the x86/ARM carry-flag
            // convention (where C=1 usually means NO borrow) -- documented
            // here so it isn't misread later if reused in a control unit.
            {Carry, Result} = A - B;
        end

        3'b010: Result = A & B;   // AND
        3'b011: Result = A | B;   // OR
        3'b100: Result = A ^ B;   // XOR
        3'b101: Result = ~A;      // NOT

        3'b110: begin // INC
            // NOTE: this does not widen like ADD does, so incrementing
            // 4'b1111 silently wraps to 4'b0000 with no carry indication.
            // Fine for this design since no instruction currently depends
            // on INC's overflow -- flag this if that ever changes.
            Result = A + 1;
        end

        3'b111: Result = A;       // PASS (used as ALU default during LOAD/STORE)

    endcase
end

// Zero flag is purely combinational, derived from whatever Result currently holds
assign Zero = (Result == 4'b0000);

endmodule
