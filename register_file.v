module register_file(
    input        clk,
    input        we,
    input  [1:0] read_addr1,
    input  [1:0] read_addr2,
    input  [1:0] write_addr,
    input  [3:0] write_data,
    output [3:0] read_data1,
    output [3:0] read_data2
);
    reg [3:0] regfile [0:3];
    initial begin
        regfile[0] = 4'd3;   // R0 = 3
        regfile[1] = 4'd5;   // R1 = 5
        regfile[2] = 4'd1;   // R2 = 1
        regfile[3] = 4'd0;   // R3 = 0
    end
    assign read_data1 = regfile[read_addr1];
    assign read_data2 = regfile[read_addr2];
    always @(posedge clk) begin
        if (we) regfile[write_addr] <= write_data;
    end
endmodule
