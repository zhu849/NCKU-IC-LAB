
`timescale 1ns/10ps

module MFE(clk,reset,busy,ready,iaddr,idata,data_rd,data_wr,addr,wen);
	input						clk;
	input						reset;
	input						ready;
		
	output	reg		[13:0]		iaddr;
	input			[7:0]		idata;
	
	output	reg		[13:0]		addr;
	output	reg		[7:0]		data_wr;
	input			[7:0]		data_rd;
	output	reg					wen;

	output	reg					busy;


	reg 	[3:0]		current_state, next_state;
	reg 	[3:0]		counter;
	reg		[13:0]		counter_addr;
	reg 	[7:0]		buffer	[8:0];

	wire 	[13:0]		addr_	[8:0];
	
	
	assign addr_[0] = counter_addr - 13'd129;
	assign addr_[1] = counter_addr - 13'd128;
	assign addr_[2] = counter_addr - 13'd127;
	assign addr_[3] = counter_addr - 13'd1;
	assign addr_[4]	= counter_addr;
	assign addr_[5] = counter_addr + 13'd1;
	assign addr_[6] = counter_addr + 13'd127;
	assign addr_[7] = counter_addr + 13'd128;
	assign addr_[8] = counter_addr + 13'd129;

	parameter	[1:0]	START	= 2'd0,
						LOAD	= 2'd1,
						STORE	= 2'd2,
						END		= 2'd3
	;


	always @ (posedge clk or posedge reset) begin
		if(reset) begin
			current_state <= START;
			counter <= 4'd0;
			counter_addr <= 14'd0;

			buffer[0] <= 8'hff;
			buffer[1] <= 8'hff;
			buffer[2] <= 8'hff;
			buffer[3] <= 8'hff;
			buffer[4] <= 8'hff;
			buffer[5] <= 8'hff;
			buffer[6] <= 8'hff;
			buffer[7] <= 8'hff;
			buffer[8] <= 8'hff;

			iaddr <= 0;
			addr <= 14'd0;
			data_wr <= 8'd0;
			wen <= 1'b0;
			busy <= 1'b0;

		end
		else begin
			current_state <= next_state;

			case(current_state)
				START: begin
					busy <= (ready) ? 1'b1 : busy;
					iaddr <= addr_[counter];
					addr <= (ready) ? addr : addr + 13'd1;
					counter <= counter + 4'd1;

					buffer[0] <= 8'hff;
					buffer[1] <= 8'hff;
					buffer[2] <= 8'hff;
					buffer[3] <= 8'hff;
					buffer[4] <= 8'hff;
					buffer[5] <= 8'hff;
					buffer[6] <= 8'hff;
					buffer[7] <= 8'hff;
					buffer[8] <= 8'hff;

					wen <= 1'b0;
				end
				LOAD: begin
					iaddr <= (counter < 4'd9) ? addr_[counter] : addr_[8];
					counter <= (counter == 4'd9) ? 4'd0 : counter + 4'd1;

					if(	((counter == 4'd1 || counter == 4'd2 || counter == 4'd3) && (counter_addr[13:7] == 7'b0000000)) || 
						((counter == 4'd7 || counter == 4'd8 || counter == 4'd9) && (counter_addr[13:7] == 7'b1111111)) || 
						((counter == 4'd1 || counter == 4'd4 || counter == 4'd7) && (counter_addr[6:0] == 7'b0000000)) || 
						((counter == 4'd3 || counter == 4'd6 || counter == 4'd9) && (counter_addr[6:0] == 7'b1111111))) begin
						buffer[0] <= 14'd0;
						buffer[1] <= buffer[0];
						buffer[2] <= buffer[1];
						buffer[3] <= buffer[2];
						buffer[4] <= buffer[3];
						buffer[5] <= buffer[4];
						buffer[6] <= buffer[5];
						buffer[7] <= buffer[6];
						buffer[8] <= buffer[7];
					end
					else begin
						if(idata <= buffer[0]) begin
							buffer[0] <= idata;
							buffer[1] <= buffer[0];
							buffer[2] <= buffer[1];
							buffer[3] <= buffer[2];
							buffer[4] <= buffer[3];
							buffer[5] <= buffer[4];
							buffer[6] <= buffer[5];
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[0] && idata <= buffer[1]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= idata;
							buffer[2] <= buffer[1];
							buffer[3] <= buffer[2];
							buffer[4] <= buffer[3];
							buffer[5] <= buffer[4];
							buffer[6] <= buffer[5];
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[1] && idata <= buffer[2]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= idata;
							buffer[3] <= buffer[2];
							buffer[4] <= buffer[3];
							buffer[5] <= buffer[4];
							buffer[6] <= buffer[5];
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[2] && idata <= buffer[3]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= buffer[2];
							buffer[3] <= idata;
							buffer[4] <= buffer[3];
							buffer[5] <= buffer[4];
							buffer[6] <= buffer[5];
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[3] && idata <= buffer[4]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= buffer[2];
							buffer[3] <= buffer[3];
							buffer[4] <= idata;
							buffer[5] <= buffer[4];
							buffer[6] <= buffer[5];
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[4] && idata <= buffer[5]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= buffer[2];
							buffer[3] <= buffer[3];
							buffer[4] <= buffer[4];
							buffer[5] <= idata;
							buffer[6] <= buffer[5];
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[5] && idata <= buffer[6]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= buffer[2];
							buffer[3] <= buffer[3];
							buffer[4] <= buffer[4];
							buffer[5] <= buffer[5];
							buffer[6] <= idata;
							buffer[7] <= buffer[6];
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[6] && idata <= buffer[7]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= buffer[2];
							buffer[3] <= buffer[3];
							buffer[4] <= buffer[4];
							buffer[5] <= buffer[5];
							buffer[6] <= buffer[6];
							buffer[7] <= idata;
							buffer[8] <= buffer[7];
						end
						if(idata >= buffer[7] && idata <= buffer[8]) begin
							buffer[0] <= buffer[0];
							buffer[1] <= buffer[1];
							buffer[2] <= buffer[2];
							buffer[3] <= buffer[3];
							buffer[4] <= buffer[4];
							buffer[5] <= buffer[5];
							buffer[6] <= buffer[6];
							buffer[7] <= buffer[7];
							buffer[8] <= idata;
						end
					end
					
				end
				STORE: begin
					counter_addr <= counter_addr +14'd1;
					data_wr <= buffer[4];
					wen <= 1'b1;
				end
				END: begin
					busy <= 1'b0;
				end
				
			endcase
		end

	end

	always @ (*) begin
		case(current_state)
			START: begin
				next_state = LOAD;
			end
			LOAD: begin
				next_state = (counter == 4'd9) ? STORE : LOAD;
			end
			STORE: begin
				next_state = (addr == 14'd16383) ? END : START;
			end
			END: begin
				next_state = START;
			end
			default: begin
				next_state = START;
			end
		endcase
	end
	
endmodule




