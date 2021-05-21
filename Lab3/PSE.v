module PSE ( clk,reset,Xin,Yin,point_num,valid,Xout,Yout);
input clk;
input reset;
input [9:0] Xin;
input [9:0] Yin;
input [2:0] point_num;
output 		valid;
output[9:0] Xout;
output[9:0] Yout;

/* Process step FSM */
parameter	[1:0] IDLE		= 2'b00,
				  INPUT 	= 2'b01,
				  PROCESS 	= 2'b10,
				  OUTPUT 	= 2'b11;

/* Register define */
reg 			  valid;
reg 		[1:0] current_state, next_state;
reg			[9:0] Xout;
reg 		[9:0] Yout;
reg 		[9:0] x_a[7:0];
reg 		[9:0] y_a[7:0];
reg 		[9:0] xout_a[6:0];
reg 		[9:0] yout_a[6:0];
reg 		[2:0] index;
reg			input_over;
reg 		output_over;
reg 		process_over;
reg			[10:0] Ax, Ay, Bx, By, neg_multiplicand;//1bits for signed, 10bits for value
reg 		[22:0] AxBy, BxAy;

/* Register for variable */
reg 		[2:0] position;//count point position
reg 		[2:0] i;//count point num
reg 		[3:0] k;//For multiply from 0 to 10

initial
begin
	index = 0;
end

	always@(posedge clk or posedge reset)begin
		if(reset)begin
			current_state <= INPUT;
		end
		else begin
			current_state <= next_state;
		end
	end

	always @(current_state or input_over or process_over or output_over) begin
		case(current_state)
			IDLE: next_state = current_state;
			INPUT:begin
				if(input_over)
					next_state = PROCESS;
				else 
					next_state = INPUT;
			end
			PROCESS:begin
				if(process_over)
					next_state = OUTPUT;
				else 
					next_state = PROCESS;
			end
			OUTPUT:begin
				if(output_over)
					next_state = INPUT;
				else 
					next_state = OUTPUT;
			end
			default: next_state = current_state;
		endcase // current_state
	end

	always@(posedge clk)begin
		/* Input logic */
		if(current_state == INPUT && ~input_over && ~reset)begin
			process_over = 0;
			output_over = 0;

			valid = 0;//put down it to get next input
			
			x_a[index] = Xin;
			y_a[index] = Yin;

			//$display("input x_a[%d]:%d, y_a[%d]:%d\n",index,x_a[index],index,y_a[index]);

			//First node should set 
			xout_a[0] = x_a[0];
			yout_a[0] = y_a[0];
			
			index = index + 1;
			if(index == point_num)begin
				input_over = 1;
				index = 1;
				position = 1;
				i=1;
			end
			else 
				input_over = 0;
		end

		/* Process logic */
		else if(current_state == PROCESS && ~process_over && ~reset)begin
			input_over = 0;
			output_over = 0;

			/* Choose Ax, Ay, Bx, By */
			Ax = x_a[index] - x_a[0];
			Ay = y_a[index] - y_a[0];

			case(i)
				3'b000:begin
					Bx = Bx;
					By = By;
				end
				3'b001:begin
					Bx = x_a[1] - x_a[0];
					By = y_a[1] - y_a[0];
				end
				3'b010:begin
					Bx = x_a[2] - x_a[0];
					By = y_a[2] - y_a[0];
				end
				3'b011:begin
					Bx = x_a[3] - x_a[0];
					By = y_a[3] - y_a[0];
				end
				3'b100:begin
					Bx = x_a[4] - x_a[0];
					By = y_a[4] - y_a[0];
				end
				3'b101:begin
					Bx = x_a[5] - x_a[0];
					By = y_a[5] - y_a[0];
				end
				3'b110:begin
					Bx = x_a[6] - x_a[0];
					By = y_a[6] - y_a[0];
				end
				3'b111:begin
					Bx = Bx;
					By = By;
				end
				default:begin
					Bx = Bx;
					By = By;
				end	
			endcase

			/* cross product */
			if(i!=index)begin
				/* check Ax*By */
				AxBy[22:0] = {11'b0,By[10:0],1'b0};
				neg_multiplicand = (~Ax)+1;
				for(k=0;k<11;k=k+1)begin
					case(AxBy[1:0])
						2'b01: AxBy[22:12] = AxBy[22:12] + Ax[10:0];
						2'b10: AxBy[22:12] = AxBy[22:12] + neg_multiplicand;
						default: AxBy = AxBy;
					endcase // tmp_sum[1:0]
					if(AxBy[22] == 1'b1) 
						AxBy = {1'b1, AxBy[22:1]};
					else 
						AxBy = AxBy >> 1;
				end

				/* check Bx*Ay */
				BxAy[22:0] = {11'b0,Ay[10:0],1'b0};
				neg_multiplicand = (~Bx)+1;
				for(k=0;k<11;k=k+1)begin
					case(BxAy[1:0])
						2'b01: BxAy[22:12] = BxAy[22:12] + Bx[10:0];
						2'b10: BxAy[22:12] = BxAy[22:12] + neg_multiplicand;
						default:BxAy = BxAy;
					endcase // tmp_sum[1:0]
					if(BxAy[22]==1'b1)
						BxAy = {1'b1, BxAy[22:1]};
					else
						BxAy = BxAy >> 1;
				end

				/* comparator */
				case({AxBy[22],BxAy[22]})
					2'b00:begin
						if(AxBy > BxAy) 
							position = position + 1;
						else
							position = position;
					end
					2'b01:position = position + 1;
					2'b10:position = position;
					2'b11:begin
						if(AxBy > BxAy) 
							position = position + 1;
						else
							position = position;
					end
					default:position = position;
				endcase
			end
	
			i = i + 1;
			if(i == point_num)begin//next turn

				xout_a[position] = x_a[index];
				yout_a[position] = y_a[index];
				//$display("set it i=%d, index:%d, xout_a[position] -> position %d = x_a[%d]:%d\n ", i, index, position, index, x_a[index]);
				
				i=1;	
				position = 1;

				index = index + 1;	
				if(index == point_num)begin
					process_over = 1;
					index = 0;
				end				
				else
					process_over = 0;			
			end
			else begin
				process_over = 0;
				index = index;
				position = position;
				i = i;
			end
		end

		/* Output logic */
		else if(current_state == OUTPUT && ~output_over && ~reset)begin
			input_over = 0;
			process_over = 0;

			valid = 1;

			Xout = xout_a[index];
			Yout = yout_a[index];
			
			//$display("xout_a[%d]:%d, yout_a[%d]:%d\n",index, xout_a[index], index, yout_a[index]);
			
			index = index + 1;
			if(index == point_num)begin
				output_over = 1;
				index = 0;
			end
			else	
				output_over = 0;
		end
		else begin
			input_over = 0;
			process_over = 0;
			output_over = 0;
		end
	end

endmodule