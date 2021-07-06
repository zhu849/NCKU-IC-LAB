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
                 FIR_CHECK          = 4'b0011,
                 OVER               = 4'b0100;

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

/* W real part and image part*/
parameter [31:0] W1_REAL  = 32'h00010000;
parameter [31:0] W2_REAL  = 32'h0000EC83;
parameter [31:0] W3_REAL  = 32'h0000B504;
parameter [31:0] W4_REAL  = 32'h000061F7;
parameter [31:0] W5_REAL  = 32'h00000000;
parameter [31:0] W6_REAL  = 32'hFFFF9E09;
parameter [31:0] W7_REAL  = 32'hFFFF4AFC;
parameter [31:0] W8_REAL  = 32'hFFFF137D;

parameter [31:0] W1_IMAGE = 32'h00000000;
parameter [31:0] W2_IMAGE = 32'hFFFF9E09;
parameter [31:0] W3_IMAGE = 32'hFFFF4AFC;
parameter [31:0] W4_IMAGE = 32'hFFFF137D;
parameter [31:0] W5_IMAGE = 32'hFFFF0000;
parameter [31:0] W6_IMAGE = 32'hFFFF137D;
parameter [31:0] W7_IMAGE = 32'hFFFF4AFC;
parameter [31:0] W8_IMAGE = 32'hFFFF9E09;


/* TB declared reg */
reg             fir_valid, fft_valid;
reg     [15:0]  fir_d;
reg     [31:0]  fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
reg     [31:0]  fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
reg             done;
reg     [3:0]   freq;

/* Self declared reg */
reg     [3:0]   current_state, next_state, state_counter;
reg     [10:0]  counter;//0-1023
reg     [10:0]  output_counter;//
reg     [15:0]  fir_data [32:0];
reg     [15:0]  neg_fir_data [32:0];
reg     [35:0]  fir_mul_result [32:0];
reg     [35:0]  fir_sum;
reg     [31:0]  fft_s0[4:0],fft_s1[4:0],fft_s2[4:0],fft_s3[4:0],fft_s4[4:0],fft_s5[4:0],fft_s6[4:0],fft_s7[4:0],fft_s8[4:0];
reg     [31:0]  fft_s9[4:0],fft_s10[4:0],fft_s11[4:0],fft_s12[4:0],fft_s13[4:0],fft_s14[4:0],fft_s15[4:0];
reg     [15:0]  real_part_A, real_part_B, image_part_A, image_part_B;
integer i;

/* FSM change logic*/
always@(*)
begin
    //$display("current_state:%d\n",current_state);
    case(current_state)
        IDLE: next_state = FIR_PROCESS;

        FIR_PROCESS:begin
            if(state_counter == 1)
                next_state = FIR_CHECK;
            else
                next_state = FIR_PROCESS;
        end
        FIR_CHECK:begin
            if(state_counter == 2)
                next_state = OVER;
            else
                next_state = FIR_CHECK;
        end // FIR_CHECK:

    endcase // current_state
end // always@(*)


always@(posedge clk or posedge rst)begin
    if(rst)
    begin
        current_state <= IDLE;
        state_counter <= 4'b0;
        counter <= 10'b0;
        fir_d <= 16'b0;
        output_counter <= 10'b0;
    end // if(reset)
    else
    begin
        current_state <= next_state;

        // Read fir_data from host file
        fir_data[0] <= data;
        for(i=0;i<32;i=i+1)begin
            fir_data[i+1] <= fir_data[i];
            neg_fir_data[i+1] <= (~fir_data[i])+1;
        end

        case(current_state)
            IDLE: begin
                counter <= 10'b0;
            end
            
            FIR_PROCESS:begin
                if(data_valid)
                begin
                    if(fir_data[1][15])
                        fir_mul_result[1] = neg_fir_data[1]*FIR_C00_NEG;
                    else
                        fir_mul_result[1] = fir_data[1]*FIR_C00_NEG;
                    if(fir_data[2][15])
                        fir_mul_result[2] = neg_fir_data[2]*FIR_C00_NEG;
                    else
                        fir_mul_result[2] = fir_data[2]*FIR_C01_NEG;
                    if(fir_data[3][15])
                        fir_mul_result[3] = neg_fir_data[3]*FIR_C02_NEG;
                    else
                        fir_mul_result[3] = fir_data[3]*FIR_C02_NEG;
                    if(fir_data[4][15])
                        fir_mul_result[4] = neg_fir_data[4]*FIR_C03;
                    else
                        fir_mul_result[4] = fir_data[4]*FIR_C03;
                    if(fir_data[5][15])
                        fir_mul_result[5] = neg_fir_data[5]*FIR_C04;
                    else
                        fir_mul_result[5] = fir_data[5]*FIR_C04;
                    if(fir_data[6][15])
                        fir_mul_result[6] = neg_fir_data[6]*FIR_C05;
                    else
                        fir_mul_result[6] = fir_data[6]*FIR_C05;
                    if(fir_data[7][15])
                        fir_mul_result[7] = neg_fir_data[7]*FIR_C06;
                    else
                        fir_mul_result[7] = fir_data[7]*FIR_C06;
                    if(fir_data[8][15])
                        fir_mul_result[8] = neg_fir_data[8]*FIR_C07_NEG;
                    else
                        fir_mul_result[8] = fir_data[8]*FIR_C07_NEG;
                    if(fir_data[9][15])
                        fir_mul_result[9] = neg_fir_data[9]*FIR_C08_NEG;
                    else
                        fir_mul_result[9] = fir_data[9]*FIR_C08_NEG;
                    if(fir_data[10][15])
                        fir_mul_result[10] = neg_fir_data[10]*FIR_C09_NEG;
                    else
                        fir_mul_result[10] = fir_data[10]*FIR_C09_NEG;
                    if(fir_data[11][15])
                        fir_mul_result[11] = neg_fir_data[11]*FIR_C10_NEG;
                    else
                        fir_mul_result[11] = fir_data[11]*FIR_C10_NEG;
                    if(fir_data[12][15])
                        fir_mul_result[12] = neg_fir_data[12]*FIR_C11_NEG;
                    else
                        fir_mul_result[12] = fir_data[12]*FIR_C11_NEG;
                    if(fir_data[13][15])
                        fir_mul_result[13] = neg_fir_data[13]*FIR_C12;
                    else
                        fir_mul_result[13] = fir_data[13]*FIR_C12;
                    if(fir_data[14][15])
                        fir_mul_result[14] = neg_fir_data[14]*FIR_C13;
                    else
                        fir_mul_result[14] = fir_data[14]*FIR_C13;
                    if(fir_data[15][15])
                        fir_mul_result[15] = neg_fir_data[15]*FIR_C14;
                    else
                        fir_mul_result[15] = fir_data[15]*FIR_C14;
                    if(fir_data[16][15])
                        fir_mul_result[16] = neg_fir_data[16]*FIR_C15;
                    else
                        fir_mul_result[16] = fir_data[16]*FIR_C15;
                    if(fir_data[17][15])
                        fir_mul_result[17] = neg_fir_data[17]*FIR_C16;
                    else
                        fir_mul_result[17] = fir_data[17]*FIR_C16;
                    if(fir_data[18][15])
                        fir_mul_result[18] = neg_fir_data[18]*FIR_C17;
                    else
                        fir_mul_result[18] = fir_data[18]*FIR_C17;
                    if(fir_data[19][15])
                        fir_mul_result[19] = neg_fir_data[19]*FIR_C18;
                    else
                        fir_mul_result[19] = fir_data[19]*FIR_C18;
                    if(fir_data[20][15])
                        fir_mul_result[20] = neg_fir_data[20]*FIR_C19;
                    else
                        fir_mul_result[20] = fir_data[20]*FIR_C19;
                    if(fir_data[21][15])
                        fir_mul_result[21] = neg_fir_data[21]*FIR_C20_NEG;
                    else
                        fir_mul_result[21] = fir_data[21]*FIR_C20_NEG;
                    if(fir_data[22][15])
                        fir_mul_result[22] = neg_fir_data[22]*FIR_C21_NEG;
                    else
                        fir_mul_result[22] = fir_data[22]*FIR_C21_NEG;
                    if(fir_data[23][15])
                        fir_mul_result[23] = neg_fir_data[23]*FIR_C22_NEG;
                    else
                        fir_mul_result[23] = fir_data[23]*FIR_C22_NEG;
                    if(fir_data[24][15])
                        fir_mul_result[24] = neg_fir_data[24]*FIR_C23_NEG;
                    else
                        fir_mul_result[24] = fir_data[24]*FIR_C23_NEG;
                    if(fir_data[25][15])
                        fir_mul_result[25] = neg_fir_data[25]*FIR_C24_NEG;
                    else
                        fir_mul_result[25] = fir_data[25]*FIR_C24_NEG;
                    if(fir_data[26][15])
                        fir_mul_result[26] = neg_fir_data[26]*FIR_C25;
                    else
                        fir_mul_result[26] = fir_data[26]*FIR_C25;
                    if(fir_data[27][15])
                        fir_mul_result[27] = neg_fir_data[27]*FIR_C26;
                    else
                        fir_mul_result[27] = fir_data[27]*FIR_C26;
                    if(fir_data[28][15])
                        fir_mul_result[28] = neg_fir_data[28]*FIR_C27;
                    else
                        fir_mul_result[28] = fir_data[28]*FIR_C27;
                    if(fir_data[29][15])
                        fir_mul_result[29] = neg_fir_data[29]*FIR_C28;
                    else
                        fir_mul_result[29] = fir_data[29]*FIR_C28;
                    if(fir_data[30][15])
                        fir_mul_result[30] = neg_fir_data[30]*FIR_C29_NEG;
                    else
                        fir_mul_result[30] = fir_data[30]*FIR_C29_NEG;
                    if(fir_data[31][15])
                        fir_mul_result[31] = neg_fir_data[31]*FIR_C30_NEG;
                    else
                        fir_mul_result[31] = fir_data[31]*FIR_C30_NEG;
                    if(fir_data[32][15])
                        fir_mul_result[32] = neg_fir_data[32]*FIR_C31_NEG;
                    else
                        fir_mul_result[32] = fir_data[32]*FIR_C31_NEG;


                    
                    if(FIR_C00[19]^fir_data[1][15])
                        fir_mul_result[1] = ~(fir_mul_result[1]-1);
                    if(FIR_C01[19]^fir_data[2][15])
                        fir_mul_result[2] = ~(fir_mul_result[2]-1);
                    if(FIR_C02[19]^fir_data[3][15])
                        fir_mul_result[3] = ~(fir_mul_result[3]-1);
                    if(FIR_C03[19]^fir_data[4][15])
                        fir_mul_result[4] = ~(fir_mul_result[4]-1);
                    if(FIR_C04[19]^fir_data[5][15])
                        fir_mul_result[5] = ~(fir_mul_result[5]-1);
                    if(FIR_C05[19]^fir_data[6][15])
                        fir_mul_result[6] = ~(fir_mul_result[6]-1);
                    if(FIR_C06[19]^fir_data[7][15])
                        fir_mul_result[7] = ~(fir_mul_result[7]-1);
                    if(FIR_C07[19]^fir_data[8][15])
                        fir_mul_result[8] = ~(fir_mul_result[8]-1);
                    if(FIR_C08[19]^fir_data[9][15])
                        fir_mul_result[9] = ~(fir_mul_result[9]-1);
                    if(FIR_C09[19]^fir_data[10][15])
                        fir_mul_result[10] = ~(fir_mul_result[10]-1);
                    if(FIR_C10[19]^fir_data[11][15])
                        fir_mul_result[11] = ~(fir_mul_result[11]-1);
                    if(FIR_C11[19]^fir_data[12][15])
                        fir_mul_result[12] = ~(fir_mul_result[12]-1);
                    if(FIR_C12[19]^fir_data[13][15])
                        fir_mul_result[13] = ~(fir_mul_result[13]-1);
                    if(FIR_C13[19]^fir_data[14][15])
                        fir_mul_result[14] = ~(fir_mul_result[14]-1);
                    if(FIR_C14[19]^fir_data[15][15])
                        fir_mul_result[15] = ~(fir_mul_result[15]-1);
                    if(FIR_C15[19]^fir_data[16][15])
                        fir_mul_result[16] = ~(fir_mul_result[16]-1);
                    if(FIR_C16[19]^fir_data[17][15])
                        fir_mul_result[17] = ~(fir_mul_result[17]-1);
                    if(FIR_C17[19]^fir_data[18][15])
                        fir_mul_result[18] = ~(fir_mul_result[18]-1);
                    if(FIR_C18[19]^fir_data[19][15])
                        fir_mul_result[19] = ~(fir_mul_result[19]-1);
                    if(FIR_C19[19]^fir_data[20][15])
                        fir_mul_result[20] = ~(fir_mul_result[20]-1);
                    if(FIR_C20[19]^fir_data[21][15])
                        fir_mul_result[21] = ~(fir_mul_result[21]-1);
                    if(FIR_C21[19]^fir_data[22][15])
                        fir_mul_result[22] = ~(fir_mul_result[22]-1);
                    if(FIR_C22[19]^fir_data[23][15])
                        fir_mul_result[23] = ~(fir_mul_result[23]-1);
                    if(FIR_C23[19]^fir_data[24][15])
                        fir_mul_result[24] = ~(fir_mul_result[24]-1);
                    if(FIR_C24[19]^fir_data[25][15])
                        fir_mul_result[25] = ~(fir_mul_result[25]-1);
                    if(FIR_C25[19]^fir_data[26][15])
                        fir_mul_result[26] = ~(fir_mul_result[26]-1);
                    if(FIR_C26[19]^fir_data[27][15])
                        fir_mul_result[27] = ~(fir_mul_result[27]-1);
                    if(FIR_C27[19]^fir_data[28][15])
                        fir_mul_result[28] = ~(fir_mul_result[28]-1);
                    if(FIR_C28[19]^fir_data[29][15])
                        fir_mul_result[29] = ~(fir_mul_result[29]-1);
                    if(FIR_C29[19]^fir_data[30][15])
                        fir_mul_result[30] = ~(fir_mul_result[30]-1);
                    if(FIR_C30[19]^fir_data[31][15])
                        fir_mul_result[31] = ~(fir_mul_result[31]-1);
                    if(FIR_C31[19]^fir_data[32][15])
                        fir_mul_result[32] = ~(fir_mul_result[32]-1);


                    fir_sum = 0;
                    if(counter >= 32)begin
                        for(i=32;i>0;i=i-1)begin
                            if(fir_mul_result[i][15])
                                fir_sum = fir_sum - ((~fir_mul_result[i])+1);
                            else 
                                fir_sum = fir_sum + fir_mul_result[i];
                        end
                        
                        if(fir_sum[15:12] > 7)
                            fir_sum[31:16] = fir_sum[31:16] + 1'b1;
    
                        //$display("counter:%d, fir_sum:%h\n",counter, fir_sum);
                        fir_valid = 1;
                        fir_d = fir_sum[31:16];
                    end

                    /*
                    //FFT start
                    case (counter%16)
                        0:fft_s0[0] = fir_d;
                        1:fft_s1[0] = fir_d;
                        2:fft_s2[0] = fir_d;
                        3:fft_s3[0] = fir_d;
                        4:fft_s4[0] = fir_d;
                        5:fft_s5[0] = fir_d;
                        6:fft_s6[0] = fir_d;
                        7:fft_s7[0] = fir_d;
                        8:fft_s8[0] = fir_d;
                        9:fft_s9[0] = fir_d;
                        10:fft_s10[0] = fir_d;
                        11:fft_s11[0] = fir_d;
                        12:fft_s12[0] = fir_d;
                        13:fft_s13[0] = fir_d;
                        14:fft_s14[0] = fir_d;
                        15:fft_s15[0] = fir_d;
                    endcase
                    
                    if((counter%16==0) && (counter!=0))begin
                       //first stage
                        fft_s0[1] = fft_s8[0];
                        fft_s1[1] = fft_s9[0];
                        fft_s2[1] = fft_s10[0];
                        fft_s3[1] = fft_s11[0];
                        fft_s4[1] = fft_s12[0];
                        fft_s5[1] = fft_s13[0];
                        fft_s6[1] = fft_s14[0];
                        fft_s7[1] = fft_s15[0];

                        real_part_A = fft_s0[0][31:16];
                        real_part_B = W1_REAL;

                        fft_s8[1] = fft_s0[0]*W1;
                        fft_s9[1] = fft_s1[0]*W2;
                        fft_s10[1] = fft_s2[0]*W3;
                        fft_s11[1] = fft_s3[0]*W4;
                        fft_s12[1] = fft_s4[0]*W5;
                        fft_s13[1] = fft_s5[0]*W6;
                        fft_s14[1] = fft_s6[0]*W7;
                        fft_s15[1] = fft_s7[0]*W8;

                        // second stage
                        fft_s0[2] = fft_s4[1];
                        fft_s1[2] = fft_s5[1];
                        fft_s2[2] = fft_s6[1];
                        fft_s3[2] = fft_s7[1];
                        fft_s4[2] = fft_s0[1]*W0;
                        fft_s5[2] = fft_s1[1]*W2;
                        fft_s6[2] = fft_s2[1]*W4;
                        fft_s7[2] = fft_s3[1]*W6;
                        fft_s8[2] = fft_s12[1];
                        fft_s9[2] = fft_s13[1];
                        fft_s10[2] = fft_s14[1];
                        fft_s11[2] = fft_s15[1];
                        fft_s12[2] = fft_s8[1]*W0;
                        fft_s13[2] = fft_s9[1]*W2;
                        fft_s14[2] = fft_s10[1]*W4;
                        fft_s15[2] = fft_s11[1]*W6;
                       
                        // third stage
                        fft_s0 [0] = fft_s2[0];
                        fft_s1 [0] = fft_s3[0];
                        fft_s2 [0] = fft_s0*W0[0];
                        fft_s3 [0] = fft_s1*W4[0];
                        fft_s4 [0] = fft_s6[0];
                        fft_s5 [0] = fft_s7[0];
                        fft_s6 [0] = fft_s4*W0[0];
                        fft_s7 [0] = fft_s5*W4[0];
                        fft_s8 [0] = fft_s10[0];
                        fft_s9 [0] = fft_s11[0];
                        fft_s10[0] = fft_s8*W0[0];
                        fft_s11[0] = fft_s9*W4[0];
                        fft_s12[0] = fft_s14[0];
                        fft_s13[0] = fft_s15[0];
                        fft_s14[0] = fft_s12*W0[0];
                        fft_s15[0] = fft_s13*W4[0];

                        //fourth stage
                        fft_s0 [0] = fft_s1[0];
                        fft_s8 [0] = fft_s0*W0[0];
                        fft_s4 [0] = fft_s3[0];
                        fft_s12[0] = fft_s2*W0[0];
                        fft_s2 [0] = fft_s5[0];
                        fft_s10[0] = fft_s4*W0[0];
                        fft_s6 [0] = fft_s7[0];
                        fft_s14[0] = fft_s6*W0[0];
                        fft_s1 [0] = fft_s9[0];
                        fft_s9 [0] = fft_s8*W0[0];
                        fft_s5 [0] = fft_s11*W[0];
                        fft_s13[0] = fft_s10*W0[0];
                        fft_s3 [0] = fft_s13[0];
                        fft_s11[0] = fft_s12[0];
                        fft_s7 [0] = fft_s15*W4[0];
                        fft_s15[0] = fft_s14[0];
                    end
                    */
                    counter <= counter + 1'b1;
                    if(counter == 1023)begin
                        state_counter <= state_counter + 1'b1;
                        output_counter <= 0;
                    end 
                end
            end // FIR_PROCESS:
        endcase // current_state
    end
end // always@(posedge clk or posedge rst)
endmodule