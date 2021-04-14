// Code your testbench here
// or browse Examples
module boothe_test;
 parameter N=9;//parameter value
  reg [N-1:0] data_in;
reg clk,start;
boothe
  dp(data_in,clr,ld_a,ld_q,ld_r,ld_cnt,clk,shift,ld_p,in,ld,dec,clr_f,out,add,sub,eqz);  
  controlpath cp(clr,ld_a,ld_q,clk,ld_p,ld_r,in,ld,ld_cnt,clr_f,start,add,sub,eqz,done,shift,dec);
initial
begin
clk = 1'b0;
#3 start = 1'b1;  
#300 $finish;
end
always #5 clk = ~clk;
initial
begin
#20 data_in =  -185;
#10 data_in = 255;
end
initial
begin
  $monitor($time," %d %b %b %d %b  %b ",dp.out,dp.out,dp.o,cp.state,dp.aluout,dp.p);
  $dumpfile ("boothe.vcd"); 
  $dumpvars (0, boothe_test);
end
endmodule