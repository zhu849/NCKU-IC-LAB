module HA(s, c, x, y);
input x, y;
output s, c;

	assign s = x^y;
	assign c = x&y;

endmodule
