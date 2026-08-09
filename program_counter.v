// ============================================================
// Program Counter (PC)
// Tracks the address of the instruction to fetch next.
// Asynchronous reset takes priority; otherwise increments by 1
// each clock edge when enabled (enable is pulled low by
// processor_top during HALT to freeze execution).
// ============================================================
module program_counter(
    input        clk,
    input        reset,
    input        enable,
    output reg [3:0] pc
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc <= 4'b0000;
    else if (enable)
        pc <= pc + 1;
    // else: enable=0 (HALT) -- pc holds its current value
end

endmodule
