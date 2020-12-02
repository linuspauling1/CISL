`include "temaCISL.v"

//sram used for instructions
module sram_1port_instructions(
    input clk,
    input [15:0] address,
    input wr,rd,
    input [2:0] wr_data,
    output reg [2:0] rd_data
);

reg [2:0] mem_reg [65535:0];//16 addressable lines 

always @ (posedge clk) begin
    if(wr) mem_reg[address] <= wr_data;
    else if(rd) rd_data <= mem_reg[address];
end

endmodule

//sram used for data
module sram_1port_data(
    input clk,
    input [15:0] address,
    input wr, rd,
    input [12:0] wr_data,
    output reg [12:0] rd_data
);

reg [12:0] mem_reg [65535:0];

always @ (posedge clk) begin
    if(wr) mem_reg[address] <= wr_data;
    else if(rd) rd_data <= mem_reg[address];
end

endmodule

//automaton
module control_sram(
    input clk, wr, rd, rst,
    input [2:0] wr_data,//read 1 instruction/clk
    output [12:0] out
);

reg [15:0] address,address_rd,address_wr,adr;
reg wr_en,rd_en;
wire [2:0] rd_data;

initial address = 16'd0;
initial address_wr = 16'd0;
initial address_rd = 16'd0;
initial adr = 16'd0;

sram_1port_instructions i0(.clk(clk),.address(address),.wr(wr),
.rd(rd),.wr_data(wr_data),.rd_data(rd_data));
sram_1port_data i1(.clk(clk),.address(adr),.wr(wr_en),.rd(rd_en),
.wr_data(out));//missing rd_data
control_unit i2(.clk(clk),.rst(rst),.in(rd_data),.o(out));

always @(posedge clk) begin
    if(wr) begin
        address_wr = address_wr + 1;
        address = address_wr;
        address_rd = 16'd0;
    end
    else if(rd) begin
        address_rd = address_rd + 1;
        address = address_rd;
        address_wr = 16'd0;
        if(wr_data == 3'b010) begin
            adr = adr + 1;
            wr_en = 1'b1;
            rd_en = 1'b0;
        end 
    end
end

endmodule
//tb for control_sram
module control_sram_tb(
    output reg clk,wr,rd,rst,
    output reg [2:0] wr_data,
    output [12:0] out
);

control_sram cut(.clk(clk),.wr(wr),.rd(rd),.rst(rst),
.wr_data(wr_data),.out(out));

initial $dumpvars(0,control_sram_tb);

initial begin
    clk = 1'd1;
    repeat (260000)
    #100 clk = ~clk;
end

initial begin
    rst = 1'd1;
    #50 rst = 1'd0;
end

initial begin
    wr_data = 3'd1;
    #3000000 wr_data = 3'd2;
    #1000000 wr_data = 3'd1;
    #3000000 wr_data = 3'd0;
    #2000000 wr_data = 3'd3;
    #1000000 wr_data = 3'd1;
end

initial begin
    rd = 1'b0;
    #13000000 rd = 1'b1;
end

initial begin
    wr = 1'b1;
    #13000000 wr = 1'b0;
end

endmodule
 