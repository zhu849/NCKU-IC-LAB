module  FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq,
 fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
input clk, rst;
input data_valid;
input [15:0] data; 

output fir_valid, fft_valid;
output [15:0] fir_d;
output [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output done;
output [3:0] freq;

wire x_valid;
wire signed [15:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15;

FIR fir(.clk(clk),.rst(rst),.data_valid(data_valid),.data(data),.fir_valid(fir_valid),.fir_d(fir_d));

// Serial to Parallel circuit
S2P s2p( 
	.clk(clk),
	.rst(rst),
	.fir_valid(fir_valid),
	.fir_d(fir_d),
	.x_valid(x_valid),
	.x0(x0),
	.x1(x1),
	.x2(x2),
	.x3(x3),
	.x4(x4),
	.x5(x5),
	.x6(x6),
	.x7(x7),
	.x8(x8),
	.x9(x9),
	.x10(x10),
	.x11(x11),
	.x12(x12),
	.x13(x13),
	.x14(x14),
	.x15(x15)
	); 

FFT fft(
	.clk(clk),
	.rst(rst),
	.x_valid(x_valid),
	.x0(x0),
	.x1(x1),
	.x2(x2),
	.x3(x3),
	.x4(x4),
	.x5(x5),
	.x6(x6),
	.x7(x7),
	.x8(x8),
	.x9(x9),
	.x10(x10),
	.x11(x11),
	.x12(x12),
	.x13(x13),
	.x14(x14),
	.x15(x15),
	.fft_valid(fft_valid),
	.fft_d0(fft_d0),
	.fft_d1(fft_d1),
	.fft_d2(fft_d2),
	.fft_d3(fft_d3),
	.fft_d4(fft_d4),
	.fft_d5(fft_d5),
	.fft_d6(fft_d6),
	.fft_d7(fft_d7),
	.fft_d8(fft_d8),
	.fft_d9(fft_d9),
	.fft_d10(fft_d10),
	.fft_d11(fft_d11),
	.fft_d12(fft_d12),
	.fft_d13(fft_d13),
	.fft_d14(fft_d14),
	.fft_d15(fft_d15)
	);

FA fa(
	.clk(clk),
	.rst(rst),
	.fft_valid(fft_valid),
	.fft_d0(fft_d0),
	.fft_d1(fft_d1),
	.fft_d2(fft_d2),
	.fft_d3(fft_d3),
	.fft_d4(fft_d4),
	.fft_d5(fft_d5),
	.fft_d6(fft_d6),
	.fft_d7(fft_d7),
	.fft_d8(fft_d8),
	.fft_d9(fft_d9),
	.fft_d10(fft_d10),
	.fft_d11(fft_d11),
	.fft_d12(fft_d12),
	.fft_d13(fft_d13),
	.fft_d14(fft_d14),
	.fft_d15(fft_d15),
	.done(done),
	.freq(freq)
	);



endmodule


module FIR (clk,rst,data_valid,data,fir_valid,fir_d);

`include "./dat/FIR_coefficient.dat"

input clk;
input rst;
input data_valid;
input signed [15:0] data;
output reg fir_valid;
output reg [15:0] fir_d;

reg [5:0] cnt;
reg signed [15:0] fir_buff[0:30];

wire signed [35:0] mul31 = (fir_buff[30] + data)*FIR_C31;
wire signed [35:0] mul30 = (fir_buff[29] + fir_buff[0])*FIR_C30;
wire signed [35:0] mul29 = (fir_buff[28] + fir_buff[1])*FIR_C29;
wire signed [35:0] mul28 = (fir_buff[27] + fir_buff[2])*FIR_C28;
wire signed [35:0] mul27 = (fir_buff[26] + fir_buff[3])*FIR_C27;
wire signed [35:0] mul26 = (fir_buff[25] + fir_buff[4])*FIR_C26;
wire signed [35:0] mul25 = (fir_buff[24] + fir_buff[5])*FIR_C25;
wire signed [35:0] mul24 = (fir_buff[23] + fir_buff[6])*FIR_C24;
wire signed [35:0] mul23 = (fir_buff[22] + fir_buff[7])*FIR_C23;
wire signed [35:0] mul22 = (fir_buff[21] + fir_buff[8])*FIR_C22;
wire signed [35:0] mul21 = (fir_buff[20] + fir_buff[9])*FIR_C21;
wire signed [35:0] mul20 = (fir_buff[19] + fir_buff[10])*FIR_C20;
wire signed [35:0] mul19 = (fir_buff[18] + fir_buff[11])*FIR_C19;
wire signed [35:0] mul18 = (fir_buff[17] + fir_buff[12])*FIR_C18;
wire signed [35:0] mul17 = (fir_buff[16] + fir_buff[13])*FIR_C17;
wire signed [35:0] mul16 = (fir_buff[15] + fir_buff[14])*FIR_C16;
wire signed [35:0] sum = mul16 + mul17 + mul18 + mul19 + mul20 + mul21 + mul22 + mul23 + mul24 + mul25 + mul26 + mul27 + mul28 + mul29 + mul30 + mul31;

integer i;

always@(posedge clk or posedge rst)
begin
	
	if (rst)
	begin
		fir_valid <= 0;
		fir_d <= 16'd0;
		cnt <= 6'd0;

		for(i = 0;i < 31;i = i + 1)
			fir_buff[i] <= 16'd0;

	end
	else if (data_valid)
	begin
		
		if(cnt == 6'd31)
		begin
			fir_valid <= 1;
			cnt <= cnt;
		end
		else
		begin
			fir_valid <= 0;
			cnt <= cnt + 6'd1;
		end

		for(i = 1;i < 31;i = i + 1)
			fir_buff[i] <= fir_buff[i - 1];

		fir_buff[0] <= data;
		fir_d <= (&sum[31:16])? 16'd0:sum[31:16];

	end

end

endmodule


module S2P (clk,rst,fir_valid,fir_d,x_valid,x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15);

input clk;
input rst;
input fir_valid;
input [15:0] fir_d;
output reg x_valid;
output reg signed [15:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15;

reg [3:0] cnt;

always@(posedge clk or posedge rst)
begin
	
	if (rst)
	begin
		x_valid <= 0;
		cnt <= 4'd0;

		x0 <= 16'd0;
		x1 <= 16'd0;
		x2 <= 16'd0;
		x3 <= 16'd0;
		x4 <= 16'd0;
		x5 <= 16'd0;
		x6 <= 16'd0;
		x7 <= 16'd0;
		x8 <= 16'd0;
		x9 <= 16'd0;
		x10 <= 16'd0;
		x11 <= 16'd0;
		x12 <= 16'd0;
		x13 <= 16'd0;
		x14 <= 16'd0;
		x15 <= 16'd0;
	end
	else if (fir_valid)
	begin
		if (cnt == 4'd15)
		begin
			x_valid <= 1;
		end
		else
		begin
			x_valid <= 0;
		end

		x0 <= x1;
		x1 <= x2;
		x2 <= x3;
		x3 <= x4;
		x4 <= x5;
		x5 <= x6;
		x6 <= x7;
		x7 <= x8;
		x8 <= x9;
		x9 <= x10;
		x10 <= x11;
		x11 <= x12;
		x12 <= x13;
		x13 <= x14;
		x14 <= x15;
		x15 <= fir_d + {15'd0,fir_d[15]};

		cnt <= cnt + 4'd1;
	end

end

endmodule


module FFT (clk,rst,x_valid,x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,fft_valid,
	 fft_d0,fft_d1,fft_d2,fft_d3,fft_d4,fft_d5,fft_d6,fft_d7,
	 fft_d8,fft_d9,fft_d10,fft_d11,fft_d12,fft_d13,fft_d14,fft_d15);

input clk, rst;
input x_valid;
input signed [15:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15;
output reg fft_valid;
output reg [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output reg [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;

parameter signed [31:0] FFT_R0 = 32'h00010000;
parameter signed [31:0] FFT_R1 = 32'h0000EC83;
parameter signed [31:0] FFT_R2 = 32'h0000B504;
parameter signed [31:0] FFT_R3 = 32'h000061F7;
parameter signed [31:0] FFT_R4 = 32'h00000000;
parameter signed [31:0] FFT_R5 = 32'hFFFF9E09;
parameter signed [31:0] FFT_R6 = 32'hFFFF4AFC;
parameter signed [31:0] FFT_R7 = 32'hFFFF137D;

parameter signed [31:0] FFT_I0 = 32'h00000000;
parameter signed [31:0] FFT_I1 = 32'hFFFF9E09;
parameter signed [31:0] FFT_I2 = 32'hFFFF4AFC;
parameter signed [31:0] FFT_I3 = 32'hFFFF137D;
parameter signed [31:0] FFT_I4 = 32'hFFFF0000;
parameter signed [31:0] FFT_I5 = 32'hFFFF137D;
parameter signed [31:0] FFT_I6 = 32'hFFFF4AFC;
parameter signed [31:0] FFT_I7 = 32'hFFFF9E09;

//==================================================================================================
// Stage 1
//==================================================================================================
wire signed [15:0] mul_S1_R0,mul_S1_R1,mul_S1_R2,mul_S1_R3,mul_S1_R4,mul_S1_R5,mul_S1_R6,mul_S1_R7;
assign mul_S1_R0 = x0 + x8;
assign mul_S1_R1 = x1 + x9;
assign mul_S1_R2 = x2 + x10;
assign mul_S1_R3 = x3 + x11;
assign mul_S1_R4 = x4 + x12;
assign mul_S1_R5 = x5 + x13;
assign mul_S1_R6 = x6 + x14;
assign mul_S1_R7 = x7 + x15;

wire signed [47:0] mul_S1_R8,mul_S1_R9,mul_S1_R10,mul_S1_R11,mul_S1_R12,mul_S1_R13,mul_S1_R14,mul_S1_R15;
assign mul_S1_R8 = ((x0 - x8)*FFT_R0);
assign mul_S1_R9 = ((x1 - x9)*FFT_R1);
assign mul_S1_R10 = ((x2 - x10)*FFT_R2);
assign mul_S1_R11 = ((x3 - x11)*FFT_R3);
assign mul_S1_R12 = ((x4 - x12)*FFT_R4);
assign mul_S1_R13 = ((x5 - x13)*FFT_R5);
assign mul_S1_R14 = ((x6 - x14)*FFT_R6);
assign mul_S1_R15 = ((x7 - x15)*FFT_R7);

wire signed [47:0] mul_S1_I8,mul_S1_I9,mul_S1_I10,mul_S1_I11,mul_S1_I12,mul_S1_I13,mul_S1_I14,mul_S1_I15;
assign mul_S1_I8 = ((x0 - x8)*FFT_I0);
assign mul_S1_I9 = ((x1 - x9)*FFT_I1);
assign mul_S1_I10 = ((x2 - x10)*FFT_I2);
assign mul_S1_I11 = ((x3 - x11)*FFT_I3);
assign mul_S1_I12 = ((x4 - x12)*FFT_I4);
assign mul_S1_I13 = ((x5 - x13)*FFT_I5);
assign mul_S1_I14 = ((x6 - x14)*FFT_I6);
assign mul_S1_I15 = ((x7 - x15)*FFT_I7);

//==================================================================================================
// Stage 2
//==================================================================================================
wire signed [15:0] mul_S2_R0,mul_S2_R1,mul_S2_R2,mul_S2_R3;
wire signed [31:0] mul_S2_R8,mul_S2_R9,mul_S2_R10,mul_S2_R11;
assign mul_S2_R0 = mul_S1_R0 + mul_S1_R4;
assign mul_S2_R1 = mul_S1_R1 + mul_S1_R5;
assign mul_S2_R2 = mul_S1_R2 + mul_S1_R6;
assign mul_S2_R3 = mul_S1_R3 + mul_S1_R7;
assign mul_S2_R8 = mul_S1_R8[39:8] + mul_S1_R12[39:8];
assign mul_S2_R9 = mul_S1_R9[39:8] + mul_S1_R13[39:8];
assign mul_S2_R10 = mul_S1_R10[39:8] + mul_S1_R14[39:8];
assign mul_S2_R11 = mul_S1_R11[39:8] + mul_S1_R15[39:8];

wire signed [31:0] mul_S2_I8,mul_S2_I9,mul_S2_I10,mul_S2_I11;
assign mul_S2_I8 = mul_S1_I8[39:8] + mul_S1_I12[39:8];
assign mul_S2_I9 = mul_S1_I9[39:8] + mul_S1_I13[39:8];
assign mul_S2_I10 = mul_S1_I10[39:8] + mul_S1_I14[39:8];
assign mul_S2_I11 = mul_S1_I11[39:8] + mul_S1_I15[39:8];

wire signed [47:0] mul_S2_R4,mul_S2_R5,mul_S2_R6,mul_S2_R7;
wire signed [47:0] mul_S2_I4,mul_S2_I5,mul_S2_I6,mul_S2_I7;
assign mul_S2_R4 = (mul_S1_R0 - mul_S1_R4)*FFT_R0;
assign mul_S2_R5 = (mul_S1_R1 - mul_S1_R5)*FFT_R2;
assign mul_S2_R6 = (mul_S1_R2 - mul_S1_R6)*FFT_R4;
assign mul_S2_R7 = (mul_S1_R3 - mul_S1_R7)*FFT_R6;
assign mul_S2_I4 = (mul_S1_R0 - mul_S1_R4)*FFT_I0;
assign mul_S2_I5 = (mul_S1_R1 - mul_S1_R5)*FFT_I2;
assign mul_S2_I6 = (mul_S1_R2 - mul_S1_R6)*FFT_I4;
assign mul_S2_I7 = (mul_S1_R3 - mul_S1_R7)*FFT_I6;

wire signed [63:0] mul_S2_R12,mul_S2_R13,mul_S2_R14,mul_S2_R15;
wire signed [63:0] mul_S2_I12,mul_S2_I13,mul_S2_I14,mul_S2_I15;
assign mul_S2_R12 = ($signed(mul_S1_R8[39:8]) - $signed(mul_S1_R12[39:8]))*FFT_R0 + ($signed(mul_S1_I12[39:8]) - $signed(mul_S1_I8[39:8]))*FFT_I0;
assign mul_S2_R13 = ($signed(mul_S1_R9[39:8]) - $signed(mul_S1_R13[39:8]))*FFT_R2 + ($signed(mul_S1_I13[39:8]) - $signed(mul_S1_I9[39:8]))*FFT_I2;
assign mul_S2_R14 = ($signed(mul_S1_R10[39:8]) - $signed(mul_S1_R14[39:8]))*FFT_R4 + ($signed(mul_S1_I14[39:8]) - $signed(mul_S1_I10[39:8]))*FFT_I4;
assign mul_S2_R15 = ($signed(mul_S1_R11[39:8]) - $signed(mul_S1_R15[39:8]))*FFT_R6 + ($signed(mul_S1_I15[39:8]) - $signed(mul_S1_I11[39:8]))*FFT_I6;
assign mul_S2_I12 = ($signed(mul_S1_R8[39:8]) - $signed(mul_S1_R12[39:8]))*FFT_I0 + ($signed(mul_S1_I8[39:8]) - $signed(mul_S1_I12[39:8]))*FFT_R0;
assign mul_S2_I13 = ($signed(mul_S1_R9[39:8]) - $signed(mul_S1_R13[39:8]))*FFT_I2 + ($signed(mul_S1_I9[39:8]) - $signed(mul_S1_I13[39:8]))*FFT_R2;
assign mul_S2_I14 = ($signed(mul_S1_R10[39:8]) - $signed(mul_S1_R14[39:8]))*FFT_I4 + ($signed(mul_S1_I10[39:8]) - $signed(mul_S1_I14[39:8]))*FFT_R4;
assign mul_S2_I15 = ($signed(mul_S1_R11[39:8]) - $signed(mul_S1_R15[39:8]))*FFT_I6 + ($signed(mul_S1_I11[39:8]) - $signed(mul_S1_I15[39:8]))*FFT_R6;

//==================================================================================================
// Stage 3
//==================================================================================================
wire signed [15:0] mul_S3_R0,mul_S3_R1;
wire signed [31:0] mul_S3_R4,mul_S3_R5,mul_S3_R8,mul_S3_R9,mul_S3_R12,mul_S3_R13;
assign mul_S3_R0 = mul_S2_R0 + mul_S2_R2;
assign mul_S3_R1 = mul_S2_R1 + mul_S2_R3;
assign mul_S3_R4 = mul_S2_R4[39:8] + mul_S2_R6[39:8];
assign mul_S3_R5 = mul_S2_R5[39:8] + mul_S2_R7[39:8];
assign mul_S3_R8 = mul_S2_R8 + mul_S2_R10;
assign mul_S3_R9 = mul_S2_R9 + mul_S2_R11;
assign mul_S3_R12 = mul_S2_R12[47:16] + mul_S2_R14[47:16];
assign mul_S3_R13 = mul_S2_R13[47:16] + mul_S2_R15[47:16];

wire signed [31:0] mul_S3_I4,mul_S3_I5,mul_S3_I8,mul_S3_I9,mul_S3_I12,mul_S3_I13;
assign mul_S3_I4 = mul_S2_I4[39:8] + mul_S2_I6[39:8];
assign mul_S3_I5 = mul_S2_I5[39:8] + mul_S2_I7[39:8];
assign mul_S3_I8 = mul_S2_I8 + mul_S2_I10;
assign mul_S3_I9 = mul_S2_I9 + mul_S2_I11;
assign mul_S3_I12 = mul_S2_I12[47:16] + mul_S2_I14[47:16];
assign mul_S3_I13 = mul_S2_I13[47:16] + mul_S2_I15[47:16];

wire signed [47:0] mul_S3_R2,mul_S3_R3;
wire signed [47:0] mul_S3_I2,mul_S3_I3;
assign mul_S3_R2 = (mul_S2_R0 - mul_S2_R2)*FFT_R0;
assign mul_S3_R3 = (mul_S2_R1 - mul_S2_R3)*FFT_R4;
assign mul_S3_I2 = (mul_S2_R0 - mul_S2_R2)*FFT_I0;
assign mul_S3_I3 = (mul_S2_R1 - mul_S2_R3)*FFT_I4;

wire signed [63:0] mul_S3_R6,mul_S3_R7,mul_S3_R10,mul_S3_R11,mul_S3_R14,mul_S3_R15;
wire signed [63:0] mul_S3_I6,mul_S3_I7,mul_S3_I10,mul_S3_I11,mul_S3_I14,mul_S3_I15;
assign mul_S3_R6 = ($signed(mul_S2_R4[39:8]) - $signed(mul_S2_R6[39:8]))*FFT_R0 + ($signed(mul_S2_I6[39:8]) - $signed(mul_S2_I4[39:8]))*FFT_I0;
assign mul_S3_R7 = ($signed(mul_S2_R5[39:8]) - $signed(mul_S2_R7[39:8]))*FFT_R4 + ($signed(mul_S2_I7[39:8]) - $signed(mul_S2_I5[39:8]))*FFT_I4;
assign mul_S3_R10 = (mul_S2_R8 - mul_S2_R10)*FFT_R0 + (mul_S2_I10 - mul_S2_I8)*FFT_I0;
assign mul_S3_R11 = (mul_S2_R9 - mul_S2_R11)*FFT_R4 + (mul_S2_I11 - mul_S2_I9)*FFT_I4;
assign mul_S3_R14 = ($signed(mul_S2_R12[47:16]) - $signed(mul_S2_R14[47:16]))*FFT_R0 + ($signed(mul_S2_I14[47:16]) - $signed(mul_S2_I12[47:16]))*FFT_I0;
assign mul_S3_R15 = ($signed(mul_S2_R13[47:16]) - $signed(mul_S2_R15[47:16]))*FFT_R4 + ($signed(mul_S2_I15[47:16]) - $signed(mul_S2_I13[47:16]))*FFT_I4;
assign mul_S3_I6 = ($signed(mul_S2_R4[39:8]) - $signed(mul_S2_R6[39:8]))*FFT_I0 + ($signed(mul_S2_I4[39:8]) - $signed(mul_S2_I6[39:8]))*FFT_R0;
assign mul_S3_I7 = ($signed(mul_S2_R5[39:8]) - $signed(mul_S2_R7[39:8]))*FFT_I4 + ($signed(mul_S2_I5[39:8]) - $signed(mul_S2_I7[39:8]))*FFT_R4;
assign mul_S3_I10 = (mul_S2_R8 - mul_S2_R10)*FFT_I0 + (mul_S2_I8 - mul_S2_I10)*FFT_R0;
assign mul_S3_I11 = (mul_S2_R9 - mul_S2_R11)*FFT_I4 + (mul_S2_I9 - mul_S2_I11)*FFT_R4;
assign mul_S3_I14 = ($signed(mul_S2_R12[47:16]) - $signed(mul_S2_R14[47:16]))*FFT_I0 + ($signed(mul_S2_I12[47:16]) - $signed(mul_S2_I14[47:16]))*FFT_R0;
assign mul_S3_I15 = ($signed(mul_S2_R13[47:16]) - $signed(mul_S2_R15[47:16]))*FFT_I4 + ($signed(mul_S2_I13[47:16]) - $signed(mul_S2_I15[47:16]))*FFT_R4;

//==================================================================================================
// Stage 4
//==================================================================================================
wire signed [15:0] mul_S4_R0;
wire signed [31:0] mul_S4_R2,mul_S4_R4,mul_S4_R6,mul_S4_R8,mul_S4_R10,mul_S4_R12,mul_S4_R14;
assign mul_S4_R0 = mul_S3_R0 + mul_S3_R1;
assign mul_S4_R2 = mul_S3_R2[39:8] + mul_S3_R3[39:8];
assign mul_S4_R4 = mul_S3_R4 + mul_S3_R5;
assign mul_S4_R6 = mul_S3_R6[47:16] + mul_S3_R7[47:16];
assign mul_S4_R8 = mul_S3_R8 + mul_S3_R9;
assign mul_S4_R10 = mul_S3_R10[47:16] + mul_S3_R11[47:16];
assign mul_S4_R12 = mul_S3_R12 + mul_S3_R13;
assign mul_S4_R14 = mul_S3_R14[47:16] + mul_S3_R15[47:16];

wire signed [31:0] mul_S4_I2,mul_S4_I4,mul_S4_I6,mul_S4_I8,mul_S4_I10,mul_S4_I12,mul_S4_I14;
assign mul_S4_I2 = mul_S3_I2[39:8] + mul_S3_I3[39:8];
assign mul_S4_I4 = mul_S3_I4 + mul_S3_I5;
assign mul_S4_I6 = mul_S3_I6[47:16] + mul_S3_I7[47:16];
assign mul_S4_I8 = mul_S3_I8 + mul_S3_I9;
assign mul_S4_I10 = mul_S3_I10[47:16] + mul_S3_I11[47:16];
assign mul_S4_I12 = mul_S3_I12 + mul_S3_I13;
assign mul_S4_I14 = mul_S3_I14[47:16] + mul_S3_I15[47:16];

wire signed [47:0] mul_S4_R1;
wire signed [47:0] mul_S4_I1;
assign mul_S4_R1 = (mul_S3_R0 - mul_S3_R1)*FFT_R0;
assign mul_S4_I1 = (mul_S3_R0 - mul_S3_R1)*FFT_I0;

wire signed [63:0] mul_S4_R3,mul_S4_R5,mul_S4_R7,mul_S4_R9,mul_S4_R11,mul_S4_R13,mul_S4_R15;
wire signed [63:0] mul_S4_I3,mul_S4_I5,mul_S4_I7,mul_S4_I9,mul_S4_I11,mul_S4_I13,mul_S4_I15;
assign mul_S4_R3 = ($signed(mul_S3_R2[39:8]) - $signed(mul_S3_R3[39:8]))*FFT_R0 + ($signed(mul_S3_I3[39:8]) - $signed(mul_S3_I2[39:8]))*FFT_I0;
assign mul_S4_R5 = (mul_S3_R4 - mul_S3_R5)*FFT_R0 + (mul_S3_I5 - mul_S3_I4)*FFT_I0;
assign mul_S4_R7 = ($signed(mul_S3_R6[47:16]) - $signed(mul_S3_R7[47:16]))*FFT_R0 + ($signed(mul_S3_I7[47:16]) - $signed(mul_S3_I6[47:16]))*FFT_I0;
assign mul_S4_R9 = (mul_S3_R8 - mul_S3_R9)*FFT_R0 + (mul_S3_I9 - mul_S3_I8)*FFT_I0;
assign mul_S4_R11 = ($signed(mul_S3_R10[47:16]) - $signed(mul_S3_R11[47:16]))*FFT_R0 + ($signed(mul_S3_I11[47:16]) - $signed(mul_S3_I10[47:16]))*FFT_I0;
assign mul_S4_R13 = (mul_S3_R12 - mul_S3_R13)*FFT_R0 + (mul_S3_I13 - mul_S3_I12)*FFT_I0;
assign mul_S4_R15 = ($signed(mul_S3_R14[47:16]) - $signed(mul_S3_R15[47:16]))*FFT_R0 + ($signed(mul_S3_I15[47:16]) - $signed(mul_S3_I14[47:16]))*FFT_I0;
assign mul_S4_I3 = ($signed(mul_S3_R2[39:8]) - $signed(mul_S3_R3[39:8]))*FFT_I0 + ($signed(mul_S3_I2[39:8]) - $signed(mul_S3_I3[39:8]))*FFT_R0;
assign mul_S4_I5 = (mul_S3_R4 - mul_S3_R5)*FFT_I0 + (mul_S3_I4 - mul_S3_I5)*FFT_R0;
assign mul_S4_I7 = ($signed(mul_S3_R6[47:16]) - $signed(mul_S3_R7[47:16]))*FFT_I0 + ($signed(mul_S3_I6[47:16]) - $signed(mul_S3_I7[47:16]))*FFT_R0;
assign mul_S4_I9 = (mul_S3_R8 - mul_S3_R9)*FFT_I0 + (mul_S3_I8 - mul_S3_I9)*FFT_R0;
assign mul_S4_I11 = ($signed(mul_S3_R10[47:16]) - $signed(mul_S3_R11[47:16]))*FFT_I0 + ($signed(mul_S3_I10[47:16]) - $signed(mul_S3_I11[47:16]))*FFT_R0;
assign mul_S4_I13 = (mul_S3_R12 - mul_S3_R13)*FFT_I0 + (mul_S3_I12 - mul_S3_I13)*FFT_R0;
assign mul_S4_I15 = ($signed(mul_S3_R14[47:16]) - $signed(mul_S3_R15[47:16]))*FFT_I0 + ($signed(mul_S3_I14[47:16]) - $signed(mul_S3_I15[47:16]))*FFT_R0;


always@(posedge clk or posedge rst)
begin
	
	if(rst)
	begin
		fft_valid <= 0;
		fft_d0 <= 32'd0;
		fft_d1 <= 32'd0;
		fft_d2 <= 32'd0;
		fft_d3 <= 32'd0;
		fft_d4 <= 32'd0;
		fft_d5 <= 32'd0;
		fft_d6 <= 32'd0;
		fft_d7 <= 32'd0;
		fft_d8 <= 32'd0;
		fft_d9 <= 32'd0;
		fft_d10 <= 32'd0;
		fft_d11 <= 32'd0;
		fft_d12 <= 32'd0;
		fft_d13 <= 32'd0;
		fft_d14 <= 32'd0;
		fft_d15 <= 32'd0;
	end
	else if (x_valid)
	begin
		fft_valid <= 1;
		fft_d0 <= {mul_S4_R0,16'd0};
		fft_d1 <= {mul_S4_R8[23:8],mul_S4_I8[23:8]};
		fft_d2 <= {mul_S4_R4[23:8],mul_S4_I4[23:8]};
		fft_d3 <= {mul_S4_R12[23:8],mul_S4_I12[23:8]};
		fft_d4 <= {mul_S4_R2[23:8],mul_S4_I2[23:8]};
		fft_d5 <= {mul_S4_R10[23:8],mul_S4_I10[23:8]};
		fft_d6 <= {mul_S4_R6[23:8],mul_S4_I6[23:8]};
		fft_d7 <= {mul_S4_R14[23:8],mul_S4_I14[23:8]};
		fft_d8 <= {mul_S4_R1[31:16],mul_S4_I1[31:16]};
		fft_d9 <= {mul_S4_R9[39:24],mul_S4_I9[39:24]};
		fft_d10 <= {mul_S4_R5[39:24],mul_S4_I5[39:24]};
		fft_d11 <= {mul_S4_R13[39:24],mul_S4_I13[39:24]};
		fft_d12 <= {mul_S4_R3[39:24],mul_S4_I3[39:24]};
		fft_d13 <= {mul_S4_R11[39:24],mul_S4_I11[39:24]};
		fft_d14 <= {mul_S4_R7[39:24],mul_S4_I7[39:24]};
		fft_d15 <= {mul_S4_R15[39:24],mul_S4_I15[39:24]};
	end
	else
	begin
		fft_valid <= 0;
		fft_d0 <= fft_d0;
		fft_d1 <= fft_d1;
		fft_d2 <= fft_d2;
		fft_d3 <= fft_d3;
		fft_d4 <= fft_d4;
		fft_d5 <= fft_d5;
		fft_d6 <= fft_d6;
		fft_d7 <= fft_d7;
		fft_d8 <= fft_d8;
		fft_d9 <= fft_d9;
		fft_d10 <= fft_d10;
		fft_d11 <= fft_d11;
		fft_d12 <= fft_d12;
		fft_d13 <= fft_d13;
		fft_d14 <= fft_d14;
		fft_d15 <= fft_d15;
	end

end


endmodule


module FA (clk,rst,fft_valid,done,freq,
	 fft_d0,fft_d1,fft_d2,fft_d3,fft_d4,fft_d5,fft_d6,fft_d7,
	 fft_d8,fft_d9,fft_d10,fft_d11,fft_d12,fft_d13,fft_d14,fft_d15);

input clk, rst;
input fft_valid;
input [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
input [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output reg done;
output reg [3:0] freq;

reg [4:0] state_cur,state_nxt;
reg [31:0] buff_fft;
reg [64:0] buff_res;

wire [64:0] res = ($signed(buff_fft[31:16])*$signed(buff_fft[31:16])) + ($signed(buff_fft[15:0])*$signed(buff_fft[15:0]));

always@(posedge clk or posedge rst)
begin
	
	if(rst)
	begin
		done <= 0;
		freq <= 4'd0;
		state_cur <= 5'd0;
		buff_fft <= 32'd0;
		buff_res <= 65'd0;
	end
	else
	begin

		state_cur <= state_nxt;

		case(state_cur)

		5'd0:
		begin
			buff_fft <= fft_d0;
			done <= 0;
		end

		5'd1:
		begin
			buff_fft <= fft_d1;
			buff_res <= res;
			freq <= 4'd0;
		end

		5'd2:
		begin
			buff_fft <= fft_d2;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd1:freq;
		end

		5'd3:
		begin
			buff_fft <= fft_d3;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd2:freq;
		end

		5'd4:
		begin
			buff_fft <= fft_d4;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd3:freq;
		end

		5'd5:
		begin
			buff_fft <= fft_d5;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd4:freq;
		end

		5'd6:
		begin
			buff_fft <= fft_d6;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd5:freq;
		end

		5'd7:
		begin
			buff_fft <= fft_d7;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd6:freq;
		end

		5'd8:
		begin
			buff_fft <= fft_d8;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd7:freq;
		end

		5'd9:
		begin
			buff_fft <= fft_d9;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd8:freq;
		end

		5'd10:
		begin
			buff_fft <= fft_d10;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd9:freq;
		end

		5'd11:
		begin
			buff_fft <= fft_d11;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd10:freq;
		end

		5'd12:
		begin
			buff_fft <= fft_d12;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd11:freq;
		end

		5'd13:
		begin
			buff_fft <= fft_d13;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd12:freq;
		end

		5'd14:
		begin
			buff_fft <= fft_d14;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd13:freq;
		end

		5'd15:
		begin
			buff_fft <= fft_d15;
			buff_res <= (res > buff_res)? res:buff_res;
			freq <= (res > buff_res)? 4'd14:freq;
		end

		5'd16:
		begin
			freq <= (res > buff_res)? 4'd15:freq;
			done <= 1;
		end

		endcase

	end

end

always@(*)
begin
		
	case(state_cur)

	5'd0:
		state_nxt = (fft_valid)? 5'd1:5'd0;

	5'd1:
		state_nxt = 5'd2;

	5'd2:
		state_nxt = 5'd3;

	5'd3:
		state_nxt = 5'd4;

	5'd4:
		state_nxt = 5'd5;

	5'd5:
		state_nxt = 5'd6;

	5'd6:
		state_nxt = 5'd7;

	5'd7:
		state_nxt = 5'd8;

	5'd8:
		state_nxt = 5'd9;

	5'd9:
		state_nxt = 5'd10;

	5'd10:
		state_nxt = 5'd11;

	5'd11:
		state_nxt = 5'd12;

	5'd12:
		state_nxt = 5'd13;

	5'd13:
		state_nxt = 5'd14;

	5'd14:
		state_nxt = 5'd15;

	5'd15:
		state_nxt = 5'd16;

	5'd16:
		state_nxt = 5'd0;

	default:
		state_nxt = 5'd0;

	endcase

end

endmodule

