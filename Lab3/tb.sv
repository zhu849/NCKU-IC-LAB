`timescale 1ns/10ps
`define CYCLE      50.0  
`define End_CYCLE  1000000
`define PAT        "obj.data"
`define GOLDEN     "golden.data"

module testfixture();
integer fd;
integer fg;
integer objnum;
integer obj_isin;
integer charcount;
integer pass=0;
integer fail=0;
string line;
reg [9:0] X;
reg [9:0] Y;
reg [2:0] point_num;

reg clk = 0;
wire valid;
wire [9:0] Xout;
wire [9:0] Yout;
reg reset =0;

PSE u_PSE(
        .clk(clk),
        .reset(reset),
        .Xin(X),
        .Yin(Y),
        .point_num(point_num),
        .valid(valid),
        .Xout(Xout),
        .Yout(Yout)
        );

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
    $display("----------------------");
    $display("-- Simulation Start --");
    $display("----------------------");
    @(posedge clk);  #2 reset = 1'b1; 
    #(`CYCLE*2);  
    @(posedge clk);  #2  reset = 1'b0;
end

reg [22:0] cycle=0;

always @(posedge clk) begin
    cycle=cycle+1;
    if (cycle > `End_CYCLE) begin
        $display("--------------------------------------------------");
        $display("-- Failed waiting valid signal, Simulation STOP --");
        $display("--------------------------------------------------");
        $fclose(fd);
        $finish;
    end
end

initial begin
    fd = $fopen(`PAT,"r");
    if (fd == 0) begin
        $display ("pattern handle null");
        $finish;
    end
end

initial begin
    fg = $fopen(`GOLDEN,"r");
    if (fg == 0) begin
        $display ("golden handle null");
        $finish;
    end
end

reg  valid_reg;
always @(posedge clk) begin
    valid_reg = valid;
end
reg wait_valid;
reg [9:0] get_Xout;
reg [9:0] get_Yout;
reg [9:0] golden_Xout;
reg [9:0] golden_Yout;
integer ap_num;
integer pass_pt;

always @(posedge clk ) begin
    if (reset) begin
        wait_valid=0;
        pass_pt = 0;
    end
    else begin
        if(wait_valid == 0) begin
            pass_pt = 0;
            if(ap_num == point_num) wait_valid =1;
        end
        else begin
            if (valid ==1) begin
                get_Xout=Xout;
                get_Yout=Yout;
                if((get_Xout == golden_Xout) && (get_Yout == golden_Yout)) pass_pt = pass_pt + 1;

                if(ap_num == point_num)
                begin
                    wait_valid=0;
                    if(pass_pt == point_num) begin
                        pass = pass +1;
                        $display("Object%0d: PASS\n",objnum);
                    end
                    else begin
                        fail = fail +1;
                        $display("Object%0d: FAIL\n",objnum);
                    end
                end
            end
        end
    end
end

always @(negedge clk ) begin
    if (reset) begin
        X=0;
        Y=0;
        golden_Xout = 0;
        golden_Yout = 0;
        ap_num = 0;
        point_num = 0;
    end 
    else begin
        if (!$feof(fd)) begin
            if(wait_valid ==0) begin
                charcount = $fgets (line, fd);
                if(charcount != 0) begin
                    while( line.substr(1, 2) == "//") charcount = $fgets (line, fd);
                    if( line.substr(0, 5) == "object") begin
                        charcount = $sscanf(line, "object %d %d",objnum,point_num);
                        ap_num=1;
                        charcount = $fgets (line, fd);
                        charcount = $sscanf(line, "%d %d",X,Y);
                        //$display("%d: %d, %d",ap_num, X ,Y);
                    end 
                    else begin
                        ap_num = ap_num+1;
                        charcount = $sscanf(line, "%d %d",X,Y);
                        //$display("%d: %d, %d",ap_num, X ,Y);
                    end
                end
            end
            else if(valid == 1)
            begin
                charcount = $fgets (line, fg);
                if(charcount != 0) begin
                    while( line.substr(1, 2) == "//") charcount = $fgets (line, fd);

                    if( line.substr(0, 5) == "object") begin
                        charcount = $fgets (line, fg);
                        ap_num = 1;
                    end
                    else
                    begin
                        ap_num = ap_num+1;
                    end

                    charcount = $sscanf(line, "%d %d",golden_Xout,golden_Yout);
                    //$display("%d: %d, %d",ap_num, golden_Xout, golden_Yout);
                end
            end
        end //if (!$feof(fd)) begin
        else begin
             $fclose(fd);
             $fclose(fg);
             $display ("-------------------------------------------------");
             if(fail == 0)
                 $display("--    Simulation finish,  ALL PASS             --");
             else
                 $display("-- Simulation finish,  Pass = %2d , Fail = %2d   --",pass,fail);
             $display ("-------------------------------------------------");
             $finish;
        end
    end
end
endmodule
