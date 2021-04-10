module booth(out, in1, in2);

parameter width = 6;

input  	[width-1:0] in1;   //multiplicand
input  	[width-1:0] in2;   //multiplier
output  [2*width-1:0] out; //product

reg 	[width-1:0] neg_multiplicand;
reg		[2*width:0] product;
integer	i;

	always@(in1 or in2)begin
		product[2*width:0] = {6'b0,in2[width-1:0],1'b0};
		neg_multiplicand = ~in1+1;

		for(i=0;i<width;i=i+1)begin
			case(product[1:0])
				2'b01:begin
					product[2*width:width+1] = product[2*width:width+1] + in1[width-1:0];
				end
				2'b10:begin
					product[2*width:width+1] = product[2*width:width+1] + neg_multiplicand;
				end
				2'b00,2'b11:;
				default:;
			endcase
			if(product[2*width] == 1'b1)
				product = {1'b1, product[2*width:1]};
			else
				product = product >> 1;
		end

	end
	assign out = product[2*width:1];

endmodule
