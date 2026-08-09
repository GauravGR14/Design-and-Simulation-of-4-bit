// ============================================================
// Control Unit
// Pure decoder: reads the opcode and produces the control signals
// that drive the rest of the datapath. Performs no computation itself.
// ============================================================
module control_unit(
    input  [3:0] opcode,
    output reg   reg_write,
    output reg   mem_write,
    output reg [2:0] alu_sel
);

always @(*) begin
    // Defaults set first so every output is defined in every branch --
    // this is what prevents unintended latches during synthesis.
    reg_write = 0;
    mem_write = 0;
    alu_sel   = 3'b000;

    case(opcode)

        4'b0000: begin reg_write = 1; alu_sel = 3'b000; end // ADD
        4'b0001: begin reg_write = 1; alu_sel = 3'b001; end // SUB
        4'b0010: begin reg_write = 1; alu_sel = 3'b010; end // AND
        4'b0011: begin reg_write = 1; alu_sel = 3'b011; end // OR
        4'b0100: begin reg_write = 1; alu_sel = 3'b100; end // XOR

        4'b0101: begin
            // LOAD: reg_write=1 so the loaded value gets written back.
            // alu_sel is left at its default (ADD) -- some simple
            // processors use the ALU for address calculation even on
            // a LOAD; here it's unused since address comes directly
            // from the instruction's rs field, but left as-is for
            // consistency/future extension. Documented so it doesn't
            // look like an oversight.
            reg_write = 1;
        end

        4'b0110: begin
            // STORE: mem_write=1, reg_write stays 0 (default) since
            // a STORE writes a register's value OUT to memory, it
            // doesn't write anything back into a register.
            mem_write = 1;
        end

        4'b1111: begin
            // HALT: both writes explicitly disabled. Redundant with the
            // defaults above, but kept explicit for readability. Note:
            // this module does NOT stop instruction fetch by itself --
            // see processor_top's pc_enable logic for that.
            reg_write = 0;
            mem_write = 0;
        end

        default: begin
            reg_write = 0;
            mem_write = 0;
        end

    endcase
end

endmodule
