module RCA(s, c_out, x, y, c_in);
input  [3:0] x, y;
output [3:0] s;
input  c_in;
output c_out;
wire [2:0] c;

	FA fa0(.s(s[0]), .c_out(c[0]), .x(x[0]), .y(y[0]), .c_in(c_in));
	FA fa1(.s(s[1]), .c_out(c[1]), .x(x[1]), .y(y[1]), .c_in(c[0]));
	FA fa2(.s(s[2]), .c_out(c[2]), .x(x[2]), .y(y[2]), .c_in(c[1]));
	FA fa3(.s(s[3]), .c_out(c_out), .x(x[3]), .y(y[3]), .c_in(c[2]));


endmodule
