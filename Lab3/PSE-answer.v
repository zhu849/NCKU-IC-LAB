module PSE ( clk,reset,Xin,Yin,point_num,valid,Xout,Yout);
input clk;
input reset;
input [9:0] Xin;
input [9:0] Yin;
input [2:0] point_num;
output valid;
output [9:0] Xout;
output [9:0] Yout;

reg valid;
reg [9:0] Xout;
reg [9:0] Yout;

reg [1:0] round;
reg [2:0] index;
reg [3:0] state_cur,state_nxt;
reg [9:0] Rec_x[0:5];
reg [9:0] Rec_y[0:5];

integer i;

reg signed [10:0] buff1,buff2;
wire signed [21:0] mul = buff1*buff2;

// Cross product calculation
wire signed [10:0] Ax,Ay,Bx,By;
reg signed [21:0] tmp_cross;
wire signed [21:0] cross_product;

assign Ax = {1'b0,Rec_x[index]} - {1'b0,Rec_x[0]};
assign Ay = {1'b0,Rec_y[index]} - {1'b0,Rec_y[0]};
assign Bx = {1'b0,Rec_x[index + 3'd1]} - {1'b0,Rec_x[0]};
assign By = {1'b0,Rec_y[index + 3'd1]} - {1'b0,Rec_y[0]};
//assign cross_product = Ax*By - Bx*Ay;
assign cross_product = tmp_cross - mul;

always@(posedge clk or posedge reset)
begin

	if(reset)
	begin
		valid <= 1'b0;
		Xout <= 10'd0;
		Yout <= 10'd0;

		round <= 2'd0;
		index <= 3'd0;
		state_cur <= 4'd0;

		tmp_cross <= 22'd0;

		buff1 <= 11'd0;
		buff2 <= 11'd0;

		for(i = 0;i < 6;i = i + 1)
		begin
			Rec_x[i] <= 10'd0;
			Rec_y[i] <= 10'd0;
		end
	end
	else
	begin
		state_cur <= state_nxt;
		case(state_cur)

		4'd0: // Read Data
		begin
			valid <= 1'b0;
			round <= 2'd0;
			index <= (index == point_num - 3'd1)? 3'd1 : index + 3'd1;
			Rec_x[index] <= Xin;
			Rec_y[index] <= Yin;
		end

		4'd1: // Sort (Compute cross product)
		begin
			buff1 <= {1'b0,Rec_x[index]} - {1'b0,Rec_x[0]};
			buff2 <= {1'b0,Rec_y[index + 3'd1]} - {1'b0,Rec_y[0]};
		end

		4'd2: // Sort (Compute cross product)
		begin
			tmp_cross <= mul;
			buff1 <= {1'b0,Rec_y[index]} - {1'b0,Rec_y[0]};
			buff2 <= {1'b0,Rec_x[index + 3'd1]} - {1'b0,Rec_x[0]};
		end

		4'd3: // Sort (Compute cross product)
		begin
			round <= (round == point_num - 3'd3)? 2'd0 : ((index == (point_num - 3'd2 - {1'b0,round}))? round + 2'd1 : round);
			index <= (round == point_num - 3'd3)? 3'd0 : ((index == (point_num - 3'd2 - {1'b0,round}))? 3'd1 : index + 3'd1);
			if(cross_product[21] == 1'b0)
			begin
				Rec_x[index] <= Rec_x[index + 3'd1];
				Rec_y[index] <= Rec_y[index + 3'd1];
				Rec_x[index + 3'd1] <= Rec_x[index];
				Rec_y[index + 3'd1] <= Rec_y[index];
			end
			else
			begin
				Rec_x[index] <= Rec_x[index];
				Rec_y[index] <= Rec_y[index];
				Rec_x[index + 3'd1] <= Rec_x[index + 3'd1];
				Rec_y[index + 3'd1] <= Rec_y[index + 3'd1];
			end
		end

		4'd4: // Output
		begin
			valid <= 1'b1;
			Xout <= Rec_x[index];
			Yout <= Rec_y[index];
			index <= (index == point_num - 3'd1)? 3'd0 : index + 3'd1;
		end

		4'd5:
		begin
			valid <= 1'b0;
		end

		endcase
	end

end

always@(*)
begin
	case(state_cur)

	4'd0: // Read Data
	begin
		state_nxt = (index == point_num - 3'd1)? 4'd1 : 4'd0;
	end

	4'd1: // Sort (Compute cross product)
	begin
		state_nxt = 4'd2;
	end

	4'd2: // Sort (Compute cross product)
	begin
		state_nxt = 4'd3;
	end

	4'd3: // Sort (Compute cross product)
	begin
		state_nxt = (round == point_num - 3'd3)? 4'd4 : 4'd1;
	end

	4'd4: // Output
	begin
		state_nxt = (index == point_num - 3'd1)? 4'd5 : 4'd4;
	end

	4'd5:
	begin
		state_nxt = 4'd0;
	end

	default:
	begin
		state_nxt = 4'd0;
	end

	endcase
end

endmodule

