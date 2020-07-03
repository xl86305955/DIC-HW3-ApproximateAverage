`timescale 1ns/10ps
module CS(Y, X, reset, clk);

input clk, reset; 
input 	[ 7:0] X;
output 	[ 9:0] Y;

reg 		[ 7:0] in	 [0:8];

reg     [11:0] sum;
reg     [11:0] avg;

wire     [ 7:0] appr;
wire    [ 9:0] Y; 

integer i;

/* Sum */
always @(posedge clk) begin
	if(reset) begin
		sum <= 0;
	end
	else begin
		sum <= sum - in[8] + X;	
	end
end

/* Shift */
always @(posedge clk) begin
	if(reset) begin
		for(i=0; i<9; i=i+1) begin
			in[i] <= 0;
		end
	end
	else begin
		in[0] <= X;
		for(i=0; i<8; i=i+1) begin
			in[i+1] <= in[i]; 
		end
	end
end

reg [11:0] q1;
reg [11:0] q2;
reg [11:0] q3;
reg [11:0] q4;
reg [11:0] r;

/* AVG */
always @(*) begin 
	q1 = sum - (sum>>3);
	q2 = q1 + (q1>>6);
	q3 = q2 + (q2>>12) + (q2>>24);
	q4 = q3 >> 3;
	r = sum - (((q4<<2)<<1) + q4);
	avg = q4 + ((r+7) >> 4);	
end

wire [ 7:0] g1; 
wire [ 7:0] g2; 
wire [ 7:0] g3; 
wire [ 7:0] g4; 
wire [ 7:0] w; 
wire [ 7:0] w1; 
wire [ 7:0] w2; 

/* Appr */
cmp cmp0(in[0], in[1], avg, g1);
cmp cmp2(in[2], in[3], avg, g2);
cmp cmp4(in[4], in[5], avg, g3);
cmp cmp6(in[6], in[7], avg, g4);
cmp G1(g1, g2, avg, w1);
cmp G2(g3, g4, avg, w2);
cmp W(w1, w2, avg, w);
cmp F(in[8], w, avg, appr);

assign Y = ((sum + appr) + (appr<<3)) >> 3;

endmodule




module cmp(src1, src2, avg, out);

input  [ 7:0] src1;
input  [ 7:0] src2;

input  [11:0] avg;

output [ 7:0] out; 

wire 					flag1;
wire 					flag2;

reg		 [ 7:0] out;

assign flag1 = src1 <= avg ? 1 : 0;
assign flag2 = src2 <= avg ? 1 : 0;

always @(*) begin
	case({flag1, flag2})
		2'b00: out = 8'b1;
		2'b01: out = src2;
		2'b10: out = src1;
		2'b11: out = src1 >= src2 ? src1 : src2;
	endcase
end

endmodule

