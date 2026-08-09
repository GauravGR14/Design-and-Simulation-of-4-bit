module data_memory(
    input        clk,
    input        we,
    input  [3:0] address,
    input  [3:0] write_data,
    output [3:0] read_data
);
    reg [3:0] memory [0:15];
    initial begin
        memory[0]  = 4'd7;
        memory[1]  = 4'd2;
        memory[2]  = 4'd12;
        memory[3]  = 4'd6;
        memory[4]  = 4'd0;
        memory[5]  = 4'd0;
        memory[6]  = 4'd0;
        memory[7]  = 4'd0;
        memory[8]  = 4'd0;
        memory[9]  = 4'd0;
        memory[10] = 4'd0;
        memory[11] = 4'd0;
        memory[12] = 4'd0;
        memory[13] = 4'd0;
        memory[14] = 4'd0;
        memory[15] = 4'd0;
    end
    always @(posedge clk) begin
        if (we) memory[address] <= write_data;
    end
    assign read_data = memory[address];
endmodule
