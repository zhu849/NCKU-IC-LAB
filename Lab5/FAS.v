module  FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq,
 fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);

`include "dat/FIR_coefficient.dat"

input clk, rst;
input data_valid;
input [15:0] data; 

output fir_valid, fft_valid;
output [15:0] fir_d;
output [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output done;
output [3:0] freq;

/* State with FSM*/
parameter [3:0]  IDLE               = 4'b0000,
                 FIR_PRELOAD        = 4'b0001,
                 FIR_PROCESS        = 4'b0010,
                 FIR_CHECK          = 4'b0011;

/* Neg coefficient */
parameter signed [19:0] FIR_C00_NEG = ~FIR_C00+1;
parameter signed [19:0] FIR_C01_NEG = ~FIR_C01+1;
parameter signed [19:0] FIR_C02_NEG = ~FIR_C02+1;
parameter signed [19:0] FIR_C07_NEG = ~FIR_C07+1;
parameter signed [19:0] FIR_C08_NEG = ~FIR_C08+1;
parameter signed [19:0] FIR_C09_NEG = ~FIR_C09+1;
parameter signed [19:0] FIR_C10_NEG = ~FIR_C10+1;
parameter signed [19:0] FIR_C11_NEG = ~FIR_C11+1;
parameter signed [19:0] FIR_C20_NEG = ~FIR_C20+1;
parameter signed [19:0] FIR_C21_NEG = ~FIR_C21+1;
parameter signed [19:0] FIR_C22_NEG = ~FIR_C22+1;
parameter signed [19:0] FIR_C23_NEG = ~FIR_C23+1;
parameter signed [19:0] FIR_C24_NEG = ~FIR_C24+1;
parameter signed [19:0] FIR_C29_NEG = ~FIR_C29+1;
parameter signed [19:0] FIR_C30_NEG = ~FIR_C30+1;
parameter signed [19:0] FIR_C31_NEG = ~FIR_C31+1;

/* TB declared reg */
reg             fir_valid, fft_valid;
reg     [15:0]  fir_d;
reg     [31:0]  fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
reg     [31:0]  fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
reg             done;
reg     [3:0]   freq;
/* Self declared reg */
reg     [3:0]   current_state, next_state, state_counter;
reg     [9:0]   counter;//0-1023
reg     [15:0]  fir_data [31:0];
reg     [35:0]  fir_mul_result [31:0];
reg     [35:0]  fir_sum;
integer i;

/* FSM change logic*/
always@(*)
begin
    //$display("current_state:%d\n",current_state);
    case(current_state)
        IDLE: next_state = FIR_PROCESS;

        FIR_PROCESS:begin
            if(state_counter == 1)
                next_state = IDLE;
            else
                next_state = FIR_PROCESS;
        end

    endcase // current_state
end // always@(*)


always@(posedge clk or posedge rst)begin
    if(rst)
    begin
        current_state <= IDLE;
        state_counter <= 4'b0;
        counter <= 10'b0;
        fir_d <= 16'b0;
    end // if(reset)
    else
    begin
        current_state <= next_state;

        // Read fir_data from host file
        fir_data[0] <= data;
        for(i=0;i<31;i=i+1)
            fir_data[i+1] <= fir_data[i];


        case(current_state)
            IDLE: begin
                counter <= 10'b0000000000;
            end
            
            FIR_PROCESS:begin
                if(data_valid)
                begin
                    //$display("counter:%d\n",counter);

                    /*
                    $display("fir_data[0]:%b, FIR_COO_NEG:%b\n",fir_data[0],FIR_C00_NEG);
                    $display("result:%b\n",fir_data[0][14:0]*FIR_C00_NEG);
    
                    $display("fir_data[31]:%h\n",fir_data[31]);
                    $display("fir_data[30]:%h\n",fir_data[30]);
                    $display("fir_data[29]:%h\n",fir_data[29]);
                    $display("fir_data[28]:%h\n",fir_data[28]);
                    $display("fir_data[27]:%h\n\n",fir_data[27]);
                    */

                    
                    // Start count fir_d and output
                    $display("counter:%d\n",counter);
                    $display("fir_mul_result[0]:%h\n",fir_mul_result[0][35:20]);
                    $display("fir_mul_result[1]:%h\n",fir_mul_result[1][35:20]);
                    $display("fir_mul_result[2]:%h\n",fir_mul_result[2][35:20]);
                    $display("fir_mul_result[3]:%h\n",fir_mul_result[3][35:20]);
                    $display("fir_mul_result[4]:%h\n",fir_mul_result[4][35:20]);
                    $display("fir_mul_result[5]:%h\n",fir_mul_result[5][35:20]);
                    $display("fir_mul_result[6]:%h\n",fir_mul_result[6][35:20]);
                    $display("fir_mul_result[7]:%h\n",fir_mul_result[7][35:20]);
                    $display("fir_mul_result[8]:%h\n",fir_mul_result[8][35:20]);
                    $display("fir_mul_result[9]:%h\n",fir_mul_result[9][35:20]);
                    $display("fir_mul_result[10]:%h\n",fir_mul_result[10][35:20]);
                    $display("fir_mul_result[11]:%h\n",fir_mul_result[11][35:20]);
                    $display("fir_mul_result[12]:%h\n",fir_mul_result[12][35:20]);
                    $display("fir_mul_result[13]:%h\n",fir_mul_result[13][35:20]);
                    $display("fir_mul_result[14]:%h\n",fir_mul_result[14][35:20]);
                    $display("fir_mul_result[15]:%h\n",fir_mul_result[15][35:20]);
                    $display("fir_mul_result[16]:%h\n",fir_mul_result[16][35:20]);
                    $display("fir_mul_result[17]:%h\n",fir_mul_result[17][35:20]);
                    $display("fir_mul_result[18]:%h\n",fir_mul_result[18][35:20]);
                    $display("fir_mul_result[19]:%h\n",fir_mul_result[19][35:20]);
                    $display("fir_mul_result[20]:%h\n",fir_mul_result[20][35:20]);
                    $display("fir_mul_result[21]:%h\n",fir_mul_result[21][35:20]);
                    $display("fir_mul_result[22]:%h\n",fir_mul_result[22][35:20]);
                    $display("fir_mul_result[23]:%h\n",fir_mul_result[23][35:20]);
                    $display("fir_mul_result[24]:%h\n",fir_mul_result[24][35:20]);
                    $display("fir_mul_result[25]:%h\n",fir_mul_result[25][35:20]);
                    $display("fir_mul_result[26]:%h\n",fir_mul_result[26][35:20]);
                    $display("fir_mul_result[27]:%h\n",fir_mul_result[27][35:20]);
                    $display("fir_mul_result[28]:%h\n",fir_mul_result[28][35:20]);
                    $display("fir_mul_result[29]:%h\n",fir_mul_result[29][35:20]);
                    $display("fir_mul_result[30]:%h\n",fir_mul_result[30][35:20]);
                    $display("fir_mul_result[31]:%h\n",fir_mul_result[31][35:20]);

                    /* Decision result sign bit*/
                    fir_mul_result[0][35]  <= FIR_C00[0]^fir_data[0];// Last data
                    fir_mul_result[1][35]  <= FIR_C01[0]^fir_data[1];
                    fir_mul_result[2][35]  <= FIR_C02[0]^fir_data[2];
                    fir_mul_result[3][35]  <= FIR_C03[0]^fir_data[3];
                    fir_mul_result[4][35]  <= FIR_C04[0]^fir_data[4];
                    fir_mul_result[5][35]  <= FIR_C05[0]^fir_data[5];
                    fir_mul_result[6][35]  <= FIR_C06[0]^fir_data[6];
                    fir_mul_result[7][35]  <= FIR_C07[0]^fir_data[7];
                    fir_mul_result[8][35]  <= FIR_C08[0]^fir_data[8];
                    fir_mul_result[9][35]  <= FIR_C09[0]^fir_data[9];
                    fir_mul_result[10][35] <= FIR_C10[0]^fir_data[10];
                    fir_mul_result[11][35] <= FIR_C11[0]^fir_data[11];
                    fir_mul_result[12][35] <= FIR_C12[0]^fir_data[12];
                    fir_mul_result[13][35] <= FIR_C13[0]^fir_data[13];
                    fir_mul_result[14][35] <= FIR_C14[0]^fir_data[14];
                    fir_mul_result[15][35] <= FIR_C15[0]^fir_data[15];
                    fir_mul_result[16][35] <= FIR_C16[0]^fir_data[16];
                    fir_mul_result[17][35] <= FIR_C17[0]^fir_data[17];
                    fir_mul_result[18][35] <= FIR_C18[0]^fir_data[18];
                    fir_mul_result[19][35] <= FIR_C19[0]^fir_data[19];
                    fir_mul_result[20][35] <= FIR_C20[0]^fir_data[20];
                    fir_mul_result[21][35] <= FIR_C21[0]^fir_data[21];
                    fir_mul_result[22][35] <= FIR_C22[0]^fir_data[22];
                    fir_mul_result[23][35] <= FIR_C23[0]^fir_data[23];
                    fir_mul_result[24][35] <= FIR_C24[0]^fir_data[24];
                    fir_mul_result[25][35] <= FIR_C25[0]^fir_data[25];
                    fir_mul_result[26][35] <= FIR_C26[0]^fir_data[26];
                    fir_mul_result[27][35] <= FIR_C27[0]^fir_data[27];
                    fir_mul_result[28][35] <= FIR_C28[0]^fir_data[28];
                    fir_mul_result[29][35] <= FIR_C29[0]^fir_data[29];
                    fir_mul_result[30][35] <= FIR_C30[0]^fir_data[30];
                    fir_mul_result[31][35] <= FIR_C31[0]^fir_data[31];// First data

                    /* Decision result value */
                    fir_mul_result[0][34:0]   <= fir_data[0]*FIR_C00_NEG;
                    fir_mul_result[1][34:0]   <= fir_data[1]*FIR_C01_NEG;
                    fir_mul_result[2][34:0]   <= fir_data[2]*FIR_C02_NEG;
                    fir_mul_result[3][34:0]   <= fir_data[3]*FIR_C03;
                    fir_mul_result[4][34:0]   <= fir_data[4]*FIR_C04;
                    fir_mul_result[5][34:0]   <= fir_data[5]*FIR_C05;
                    fir_mul_result[6][34:0]   <= fir_data[6]*FIR_C06;
                    fir_mul_result[7][34:0]   <= fir_data[7]*FIR_C07_NEG;
                    fir_mul_result[8][34:0]   <= fir_data[8]*FIR_C08_NEG;
                    fir_mul_result[9][34:0]   <= fir_data[9]*FIR_C09_NEG;
                    fir_mul_result[10][34:0]  <= fir_data[10]*FIR_C10_NEG;
                    fir_mul_result[11][34:0]  <= fir_data[11]*FIR_C11_NEG;
                    fir_mul_result[12][34:0]  <= fir_data[12]*FIR_C12;
                    fir_mul_result[13][34:0]  <= fir_data[13]*FIR_C13;
                    fir_mul_result[14][34:0]  <= fir_data[14]*FIR_C14;
                    fir_mul_result[15][34:0]  <= fir_data[15]*FIR_C15;
                    fir_mul_result[16][34:0]  <= fir_data[16]*FIR_C16;
                    fir_mul_result[17][34:0]  <= fir_data[17]*FIR_C17;
                    fir_mul_result[18][34:0]  <= fir_data[18]*FIR_C18;
                    fir_mul_result[19][34:0]  <= fir_data[19]*FIR_C19;
                    fir_mul_result[20][34:0]  <= fir_data[20]*FIR_C20_NEG;
                    fir_mul_result[21][34:0]  <= fir_data[21]*FIR_C21_NEG;
                    fir_mul_result[22][34:0]  <= fir_data[22]*FIR_C22_NEG;
                    fir_mul_result[23][34:0]  <= fir_data[23]*FIR_C23_NEG;
                    fir_mul_result[24][34:0]  <= fir_data[24]*FIR_C24_NEG;
                    fir_mul_result[25][34:0]  <= fir_data[25]*FIR_C25;
                    fir_mul_result[26][34:0]  <= fir_data[26]*FIR_C26;
                    fir_mul_result[27][34:0]  <= fir_data[27]*FIR_C27;
                    fir_mul_result[28][34:0]  <= fir_data[28]*FIR_C28;
                    fir_mul_result[29][34:0]  <= fir_data[29]*FIR_C29_NEG;
                    fir_mul_result[30][34:0]  <= fir_data[30]*FIR_C30_NEG;
                    fir_mul_result[31][34:0]  <= fir_data[31]*FIR_C31_NEG;

                    counter <= counter + 1'b1;
                    if(counter == 10'b1111111111)
                        state_counter <= state_counter + 1'b1; 
                end
            end // READ_FROM_HOST:
        endcase // current_state
    end
end // always@(posedge clk or posedge rst)

endmodule