module FA(s, c_out, x, y, c_in);
input x, y, c_in;
output s, c_out;
wire s1, c1, c2;

	HA ha1(.s(s1),.c(c1),.x(x),.y(y));
  	HA ha2(.s(s),.c(c2),.x(s1),.y(c_in));
  	assign c_out = c1|c2;
  	
endmodule

