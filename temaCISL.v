`timescale 1ns / 1ns

//pulse generator
module generator(
    input clk,clr,en,
    output reg o
);

reg [12:0] st_reg,st_nxt;

always @(posedge clk) begin
    if(clr) st_reg <= 13'd0;
    else st_reg <= st_nxt;
end

always @ * begin
    if(en) begin
        if(st_reg == 13'd4999) begin
            st_nxt = 13'd0;
            o = 1'b1;
        end
        else begin
            st_nxt = st_reg + 1;
            o = 1'b0;
        end
    end
    else begin
        if(st_reg == 13'd4999) begin
            st_nxt = 13'd0;
            o = 1'b0;
        end
        else begin
            st_nxt = st_reg;
            o = 1'b0;
        end
    end
end

endmodule
//tb for generator
module generator_tb(
    output reg clk,clr,en,
    output o
);

generator cut(.clk(clk),.clr(clr),.en(en),.o(o));

initial $dumpvars(0,generator_tb);

initial begin
    clk = 1'd1;
    repeat (200000)
    #100 clk = ~clk;
end

initial begin
    clr = 1'd1;
    #50 clr = 1'd0;
end

initial begin
    en = 1'd1;
    #4999750 en = 1'd0;
    #100 en = 1'd1;
end

endmodule

//counter
module counter(
    input clk,clr,en,
    output reg [12:0] o
);

reg [12:0] st_nxt;

always @ (posedge clk) begin
    if(clr) o <= 13'd0;
    else o <= st_nxt;
end

always @ *
    if(en) st_nxt = o + 1;
    else st_nxt = o;

endmodule
//tb counter
module counter_tb(
    output reg clk,clr,en,
    output [12:0] o
);

counter cut(.clk(clk),.clr(clr),.en(en),.o(o));

initial $dumpvars(0,counter_tb);

initial begin
    clk = 1'd1;
    repeat (20)
    #100 clk = ~clk;
end

initial begin
    clr = 1'd1;
    #50 clr = 1'd0;
end

initial begin
    en = 1'd1;
    #550 en = 1'd0;
    #200 en = 1'd1;
end

endmodule

//circuit
module circuit(
    input clk,clr,en,
    output [12:0] o
);

wire f;

generator i0(.clk(clk),.clr(clr),.en(en),.o(f));
counter i1(.clk(clk),.clr(clr),.en(f),.o(o));

endmodule
//tb circuit
module circuit_tb(
    output reg clk,clr,en,
    output [12:0] o
);

circuit cut(.clk(clk),.clr(clr),.en(en),.o(o));

initial $dumpvars(0,circuit_tb);

initial begin
    clk = 1'd1;
    repeat (200000)
    #100 clk = ~clk;
end

initial begin
    clr = 1'd1;
    #50 clr = 1'd0;
end

initial begin
    en = 1'd1;
    #4999900 en = 1'd0;
    #200 en = 1'd1;
end

endmodule

//atuomaton
module automaton(
    input clk,rst,
    input [2:0]in,
    output reg clr,en
);

localparam S0_ST = 2'b00;
localparam S1_ST = 2'b01;
localparam S2_ST = 2'b10;

reg [1:0] st_reg,st_nxt;

always @ * begin
    case(st_reg)
        S0_ST: if(!in[1]) st_nxt = S0_ST;
               else if(in[0]) st_nxt = S2_ST;
               else st_nxt = S1_ST;
        S1_ST: if(!in[0]) st_nxt = S1_ST;
               else if(in[1]) st_nxt = S2_ST;
               else st_nxt = S0_ST;
        S2_ST: if(in == 2'd1) st_nxt = S0_ST;
               else st_nxt = S2_ST; 
    endcase
end

always @ * begin
    case(st_reg)
        S0_ST: {clr,en} = 2'd1; 
        S1_ST: {clr,en} = 2'd0;
        S2_ST: clr = 1'd1;
    endcase
end

always @(posedge clk) begin
    if(rst) st_reg <= S2_ST;
    else st_reg <= st_nxt;
end

endmodule
//tb automaton
module automaton_tb(
    output reg clk,rst,
    output reg [2:0]in,
    output clr,en
);

automaton cut(.clk(clk),.rst(rst),.in(in),.clr(clr),.en(en));

initial $dumpvars(0,automaton_tb);

initial begin
    clk = 1'd1;
    repeat (200)
    #100 clk = ~clk;
end

initial begin
    rst = 1'd1;
    #50 rst = 1'd0;
end

initial begin
    in = 3'd1;
    #600 in = 3'd2;
    #200 in = 3'd1;
    #400 in = 3'd0;
    #200 in = 3'd3;
    #600 in = 3'd1;
end

endmodule

//control unit
module control_unit(
    input clk,rst,
    input [2:0]in,
    output [12:0]o
);

wire f,g;

automaton i0(.clk(clk),.rst(rst),.in(in),.clr(f),.en(g));
circuit i1(.clk(clk),.clr(f),.en(g),.o(o));

endmodule
//tb control unit
module control_unit_tb(
    output reg clk,rst,
    output reg [2:0]in,
    output [12:0]o
);

control_unit cut(.clk(clk),.rst(rst),.in(in),.o(o));

initial $dumpvars(0,control_unit_tb);

initial begin
    clk = 1'd1;
    repeat (130000)
    #100 clk = ~clk;
end

initial begin
    rst = 1'd1;
    #50 rst = 1'd0;
end

initial begin
    in = 3'd1;
    #3000000 in = 3'd2;
    #1000000 in = 3'd1;
    #3000000 in = 3'd0;
    #2000000 in = 3'd3;
    #1000000 in = 3'd1;
end

endmodule