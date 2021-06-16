`timescale 1ns/10ps

module MFE(clk,reset,busy,ready,iaddr,idata,data_rd,data_wr,addr,wen);
	input				clk;
	input				reset;
	output				busy;	
	input				ready;
	output	[13:0]		iaddr;
	input	[7:0]		idata;	
	input	[7:0]		data_rd;
	output	[7:0]		data_wr;
	output	[13:0]		addr;
	output				wen;

	/* COM_REG_LOAD step FSM */
	parameter [3:0] IDLE			=	4'b0000,
					COM_REG_LOAD 	= 	4'b0001,
					COMPARE_1 		=   4'b0010,
					COMPARE_2		= 	4'b0011,
					COMPARE_3 		=   4'b0100,
					COMPARE_4 		= 	4'b0101,
					COMPARE_5 		= 	4'b0110,
					COMPARE_6 		= 	4'b0111,
					COMPARE_7 		=   4'b1000,
					COMPARE_8 		= 	4'b1001,
					COMPARE_9 		= 	4'b1010,
					OUTPUT 			= 	4'b1011,
					OUTPUT_OVER 	=   4'b1100,
					VALID 			= 	4'b1101;

	/* TB declared reg */
	reg 				busy;
	reg 	[13:0] 		iaddr;
	reg 	[7:0] 		data_wr;
	reg 	[13:0] 		addr;
	reg 				wen;
	/* Self declared reg */
	reg		[3:0]		current_state, next_state, state_counter;// Use to FSM
	reg 	[13:0]		counter; // Use to counter # of operation 
	reg 	[3:0] 		position_counter; // Use to count direction want to read 
	reg 				next_set; //Use to notify next clk should set value
	reg 	[7:0]		com_reg [8:0]; // Use to compare logic

	always@(*)begin
		case(current_state)
			IDLE:begin
				if(ready)
					next_state = COM_REG_LOAD;
				else 
					next_state = IDLE;
			end

			COM_REG_LOAD:
			begin
				if(state_counter == 1)
					next_state = COMPARE_1;
				else 
					next_state = COM_REG_LOAD;
			end
			
			COMPARE_1:
			begin
				if(state_counter == 2)
					next_state = COMPARE_2;
				else 
					next_state = COMPARE_1;
			end
			
			COMPARE_2:
			begin
				if(state_counter == 3)
					next_state = COMPARE_3;
				else 
					next_state = COMPARE_2;				
			end
			
			COMPARE_3:
			begin
				if(state_counter == 4)
					next_state = COMPARE_4;
				else 
					next_state = COMPARE_3;
			end
			
			COMPARE_4:
			begin
				if(state_counter == 5)
					next_state = COMPARE_5;
				else 
					next_state = COMPARE_4;
			end

			COMPARE_5:
			begin
				if(state_counter == 6)
					next_state = COMPARE_6;
				else 
					next_state = COMPARE_5;
			end
			
			COMPARE_6:
			begin
				if(state_counter == 7)
					next_state = COMPARE_7;
				else 
					next_state = COMPARE_6;
			end
			
			COMPARE_7:
			begin
				if(state_counter == 8)
					next_state = COMPARE_8;
				else 
					next_state = COMPARE_7;				
			end
			
			COMPARE_8:
			begin
				if(state_counter == 9)
					next_state = COMPARE_9;
				else 
					next_state = COMPARE_8;
			end

			COMPARE_9:
			begin
				if(state_counter == 10)
					next_state = OUTPUT;
				else 
					next_state = COMPARE_9;
			end
			
			OUTPUT: next_state = OUTPUT_OVER;

			OUTPUT_OVER:
			begin
				if(counter == 16383)
					next_state = VALID;
				else 
					next_state = COM_REG_LOAD;
			end

			VALID: next_state = VALID;

		endcase
	end

	always @(posedge clk or posedge reset) begin : state_machine
		if(reset) 
		begin
			 current_state <= IDLE;
			 state_counter <= 0;
			 counter <= 0;
			 busy <= 0;
			 iaddr <= 0;
			 next_set <= 0;
			 position_counter <= 0;
		end 
		else 
		begin
			 current_state <= next_state;

			 case(current_state)
			 	IDLE: 
			 	begin
			 		busy <= 1'b1;
			 		state_counter <= 0;
			 	end

				COM_REG_LOAD:
				begin
					if(next_set)
						com_reg[position_counter-1] <= idata;
					else
						com_reg[position_counter-1] <= 1'b0;

					case(position_counter)
						0:
						begin
							// Check 0 position's border
							if((counter&14'b00000001111111)==0 || (counter<128))
								next_set <= 1'b0;
							else
							begin
								iaddr <= counter-14'b00000010000001;	
								next_set <= 1'b1;
							end		
						end
				
						1:
						begin
							// Check 1 position's border
							if(counter<128)
								next_set <= 1'b0;
							else
							begin
								iaddr <= counter-14'b00000010000000;
								next_set <= 1'b1;
							end				
						end

						2:
						begin
							// Check 2 position's border
							if((counter&14'b00000001111111)==127 || (counter<128))
								next_set <= 1'b0;
							else 
							begin
								iaddr <= counter-14'b00000001111111;
								next_set <= 1'b1;
							end					
						end

						3:
						begin
							// Check 3 position's border
							if((counter&14'b00000001111111)==0)
								next_set <= 1'b0;
							else 
							begin
								iaddr <= counter-14'b00000000000001;
								next_set <= 1'b1;
							end						
						end

						4:
						begin
							iaddr <= counter;
							next_set <= 1'b1;
						end

						5: 
						begin
							// Check 5 position's border
							if((counter&14'b00000001111111)==127)
								next_set <= 1'b0;
							else
							begin
								iaddr <= counter+14'b00000000000001;
								next_set <= 1'b1;
							end							
						end

						6:
						begin
							// Check 6 position's border
							if((counter&14'b00000001111111)==0 || (counter>16255))
								next_set <= 1'b0;
							else
							begin
								iaddr <= counter+14'b00000001111111;
								next_set <= 1'b1;
							end							
						end
					
						7:
						begin
							// Check 7 position's border
							if(counter>16255)
								next_set <= 1'b0;
							else
							begin
								iaddr <= counter+14'b00000010000000;
								next_set <= 1'b1;
							end								
						end

						8:
						begin
							// Check 8 position's border
							if((counter&14'b00000001111111)==127 || (counter>16255))
								next_set <= 1'b0;
							else
							begin
								iaddr <= counter+14'b00000010000001;
								next_set <= 1'b1;
							end							
						end
					endcase
					
					position_counter <= position_counter + 1'b1;
					if(position_counter == 8)
						state_counter <= state_counter + 1'b1;
				end
				
				COMPARE_1:
				begin					
					// a0 vs a1
					if(com_reg[0]<com_reg[1])
					begin
						com_reg[0] <= com_reg[1];
						com_reg[1] <= com_reg[0];
					end
					else
					begin
						com_reg[0] <= com_reg[0];
						com_reg[1] <= com_reg[1];
					end

					// a2 vs a3
					if(com_reg[2]<com_reg[3])
					begin
						com_reg[2] <= com_reg[3];
						com_reg[3] <= com_reg[2];	
					end
					else
					begin
						com_reg[2] <= com_reg[2];
						com_reg[3] <= com_reg[3];
					end

					// a4 vs a5
					if(com_reg[4]<com_reg[5])
					begin
						com_reg[4] <= com_reg[5];
						com_reg[5] <= com_reg[4];	
					end
					else
					begin
						com_reg[4] <= com_reg[4];
						com_reg[5] <= com_reg[5];
					end	

					// a6 vs a7
					if(com_reg[6]<com_reg[7])
					begin
						com_reg[6] <= com_reg[7];
						com_reg[7] <= com_reg[6];	
					end
					else
					begin
						com_reg[6] <= com_reg[6];
						com_reg[7] <= com_reg[7];
					end

					state_counter <= state_counter + 1'b1;
				end
				
				COMPARE_2:
				begin
					// a0 vs a2
					if(com_reg[0]<com_reg[2])
					begin
						com_reg[0] <= com_reg[2];
						com_reg[1] <= com_reg[0];	
					end
					else
					begin
						com_reg[0] <= com_reg[0];
						com_reg[1] <= com_reg[2];
					end					

					// a2 vs a3
					if(com_reg[1]<com_reg[3])
					begin
						com_reg[2] <= com_reg[3];
						com_reg[3] <= com_reg[1];	
					end
					else
					begin
						com_reg[2] <= com_reg[1];
						com_reg[3] <= com_reg[3];
					end	

					// a4 vs a6
					if(com_reg[4]<com_reg[6])
					begin
						com_reg[4] <= com_reg[6];
						com_reg[5] <= com_reg[4];	
					end
					else
					begin
						com_reg[4] <= com_reg[4];
						com_reg[5] <= com_reg[6];
					end

					// a5 vs a7
					if(com_reg[5]<com_reg[7])
					begin
						com_reg[6] <= com_reg[7];
						com_reg[7] <= com_reg[5];	
					end
					else
					begin
						com_reg[6] <= com_reg[5];
						com_reg[7] <= com_reg[7];
					end

					state_counter <= state_counter + 1'b1;
				end
				
				COMPARE_3:
				begin
					// a0 vs a4
					if(com_reg[0]<com_reg[4])
					begin
						com_reg[0] <= com_reg[4];
						com_reg[1] <= com_reg[0];	
					end
					else
					begin
						com_reg[0] <= com_reg[0];
						com_reg[1] <= com_reg[4];
					end					

					// a1 vs a5
					if(com_reg[1]<com_reg[5])
					begin
						com_reg[2] <= com_reg[5];
						com_reg[3] <= com_reg[1];	
					end
					else
					begin
						com_reg[2] <= com_reg[1];
						com_reg[3] <= com_reg[5];
					end	

					// a2 vs a6
					if(com_reg[2]<com_reg[6])
					begin
						com_reg[4] <= com_reg[6];
						com_reg[5] <= com_reg[2];	
					end
					else
					begin
						com_reg[4] <= com_reg[2];
						com_reg[5] <= com_reg[6];
					end

					// a3 vs a7
					if(com_reg[3]<com_reg[7])
					begin
						com_reg[6] <= com_reg[7];
						com_reg[7] <= com_reg[3];	
					end
					else
					begin
						com_reg[6] <= com_reg[3];
						com_reg[7] <= com_reg[7];
					end

					state_counter <= state_counter + 1'b1;
				end
				
				COMPARE_4:
				begin
					com_reg[0] <= com_reg[0];
					com_reg[7] <= com_reg[7];

					// a1 vs a2
					if(com_reg[1]<com_reg[2])
					begin
						com_reg[1] <= com_reg[2];
						com_reg[2] <= com_reg[1];	
					end
					else
					begin
						com_reg[1] <= com_reg[1];
						com_reg[2] <= com_reg[2];
					end					

					// a3 vs a4
					if(com_reg[3]<com_reg[4])
					begin
						com_reg[3] <= com_reg[4];
						com_reg[4] <= com_reg[3];	
					end
					else
					begin
						com_reg[3] <= com_reg[3];
						com_reg[4] <= com_reg[4];
					end	

					// a5 vs a6
					if(com_reg[5]<com_reg[6])
					begin
						com_reg[5] <= com_reg[6];
						com_reg[6] <= com_reg[5];	
					end
					else
					begin
						com_reg[5] <= com_reg[5];
						com_reg[6] <= com_reg[6];
					end

					state_counter <= state_counter + 1'b1;
				end

				COMPARE_5:
				begin
					com_reg[0] <= com_reg[0];
					com_reg[5] <= com_reg[5];
					com_reg[6] <= com_reg[6];
					com_reg[7] <= com_reg[7];

					// a1 vs a3
					if(com_reg[1]<com_reg[3])
					begin
						com_reg[1] <= com_reg[3];
						com_reg[2] <= com_reg[1];	
					end
					else
					begin
						com_reg[1] <= com_reg[1];
						com_reg[2] <= com_reg[3];
					end

					// a2 vs a4
					if(com_reg[2]<com_reg[4])
					begin
						com_reg[3] <= com_reg[4];
						com_reg[4] <= com_reg[2];	
					end
					else
					begin
						com_reg[3] <= com_reg[2];
						com_reg[4] <= com_reg[4];
					end

					state_counter <= state_counter + 1'b1;
				end
				
				COMPARE_6:
				begin
					com_reg[0] <= com_reg[0];
					com_reg[3] <= com_reg[2];
					com_reg[4] <= com_reg[3];
					com_reg[7] <= com_reg[7];

					// a1 vs a5
					if(com_reg[1]<com_reg[5])
					begin
						com_reg[1] <= com_reg[5];
						com_reg[2] <= com_reg[1];	
					end
					else
					begin
						com_reg[1] <= com_reg[1];
						com_reg[2] <= com_reg[5];
					end

					// a4 vs a6
					if(com_reg[4]<com_reg[6])
					begin
						com_reg[5] <= com_reg[6];
						com_reg[6] <= com_reg[4];	
					end
					else
					begin
						com_reg[5] <= com_reg[4];
						com_reg[6] <= com_reg[6];
					end
					state_counter <= state_counter + 1'b1;				
				end
				
				COMPARE_7:
				begin
					com_reg[0] <= com_reg[0];
					com_reg[1] <= com_reg[1];
					com_reg[6] <= com_reg[6];
					com_reg[7] <= com_reg[7];

					// a2 vs a3
					if(com_reg[2]<com_reg[3])
					begin
						com_reg[2] <= com_reg[3];
						com_reg[3] <= com_reg[2];	
					end
					else
					begin
						com_reg[2] <= com_reg[2];
						com_reg[3] <= com_reg[3];
					end

					// a4 vs a5
					if(com_reg[4]<com_reg[5])
					begin
						com_reg[4] <= com_reg[5];
						com_reg[5] <= com_reg[4];	
					end
					else
					begin
						com_reg[4] <= com_reg[4];
						com_reg[5] <= com_reg[5];
					end

					state_counter <= state_counter + 1'b1;		
				end

				COMPARE_8:
				begin
					com_reg[0] <= com_reg[0];
					com_reg[1] <= com_reg[1];
					com_reg[6] <= com_reg[6];
					com_reg[7] <= com_reg[7];

					// a2 vs a4
					if(com_reg[2]<com_reg[4])
					begin
						com_reg[2] <= com_reg[4];
						com_reg[3] <= com_reg[2];	
					end
					else
					begin
						com_reg[2] <= com_reg[2];
						com_reg[3] <= com_reg[4];
					end

					// a3 vs a5
					if(com_reg[3]<com_reg[5])
					begin
						com_reg[4] <= com_reg[5];
						com_reg[5] <= com_reg[3];	
					end
					else
					begin
						com_reg[4] <= com_reg[3];
						com_reg[5] <= com_reg[5];
					end

					state_counter <= state_counter + 1'b1;						
				end

				COMPARE_9:
				begin
					com_reg[0] <= com_reg[0];
					com_reg[1] <= com_reg[1];
					com_reg[2] <= com_reg[2];
					com_reg[5] <= com_reg[5];
					com_reg[6] <= com_reg[6];
					com_reg[7] <= com_reg[7];

					// a3 vs a4
					if(com_reg[3]<com_reg[4])
					begin
						com_reg[3] <= com_reg[4];
						com_reg[4] <= com_reg[3];	
					end
					else
					begin
						com_reg[3] <= com_reg[3];
						com_reg[4] <= com_reg[4];
					end

					state_counter <= state_counter + 1'b1;		
				end

				OUTPUT:
				begin	
					if((com_reg[4] < com_reg[8]) && (com_reg[8] < com_reg[3]))
						data_wr <= com_reg[8];
					else if(com_reg[8] >= com_reg[3])
						data_wr <= com_reg[3];
					else
						data_wr <= com_reg[4];
					wen <= 1'b1;
					addr <= counter;
				end

				OUTPUT_OVER:
				begin
					counter <= counter + 1'b1;
					position_counter <= 0;
					state_counter <= 1'b0;
					if(counter == 16383)
						busy <= 0;
				end
				
			 endcase // current_state
		end
	end

endmodule