// Code your design here
module boothe(data_in,clr,ld_a,ld_q,ld_r,ld_cnt,clk,shift,ld_p,in,ld,dec,clr_f,out,add,sub,eqz);
  parameter N=9;//parameter value
  input [N-1:0] data_in;
input clr,ld_a,ld_q,ld_r,ld_cnt,clk,ld_p,in,ld,clr_f,dec,shift;
  output signed [(2*N)-1:0] out;
output add,sub,eqz;
  wire [N-1:0] aluout,p;
  wire [N-1:0] count;
wire o,in;
assign eqz = ~|count ;
shiftreg sr(out,aluout,data_in,clr,ld_a,ld_q,ld_r,clk,shift);
register r(p,data_in,clk,ld_p);
ff f(o,out[0],ld,clr_f,clk);
comp c(add,sub,out[0],o);
  ALU a(aluout,add,sub,out[(2*N)-1:N],p);
  counter cnt(count,clk,dec,ld_cnt);
endmodule
module shiftreg(out,aluout,data_in,clr,ld_a,ld_q,ld_r,clk,shift);
  parameter N=9;//parameter value
input clr,ld_a,ld_q,ld_r,clk,shift;
  input [N-1:0] data_in,aluout;
  output reg [(2*N)-1:0] out;
always@(posedge clk)
if (clr)
out <=0;
else if(ld_q)
  out[N-1:0] <= data_in;
else if(ld_r)
begin  
  out[(2*N)-1:N] <= aluout;
  #1 out <= out >>1 ;
  #1 out[(2*N)-1] <= out[(2*N)-2];  
end  
else if(shift)
begin
 #1 out <= out >>1 ;
  #1 out[(2*N)-1] <= out[(2*N)-2];
end
endmodule
module register(p,data_in,clk,ld_p);
  parameter N=9;//parameter value
input clk,ld_p;
  input [N-1:0] data_in;
  output reg [N-1:0] p;
always@(posedge clk)
if(ld_p)
p <= data_in;
endmodule
module ff(o,in,ld,clr_f,clk);
input ld,clr_f,clk,in;
output reg o;
always@(posedge clk)
if (clr_f)
o <= 0 ;
else if (ld)
o <= in;
endmodule
module comp(add,sub,in1,in2);
input  in1,in2;
output add,sub,shift;
assign add = ({in1,in2} == 2'b01 );
assign sub = ({in1,in2} == 2'b10 );
endmodule
module ALU(out,add,sub,in1,in2);
  parameter N=9;//parameter value
  input [N-1:0] in1,in2;
input add,sub;
  output reg [N-1:0] out;
always@(*)
if (add)
out = in1 + in2;
else if (sub)
out = in1 - in2;
endmodule
module counter(count,clk,dec,ld_cnt);
  parameter N=9;//parameter value
input clk,dec,ld_cnt;
  output reg [N-1:0] count;
always@(posedge clk)
  if (ld_cnt)
    count <= N;
else if(dec)
count <= count - 1;
endmodule
module controlpath(clr,ld_a,ld_q,clk,ld_p,ld_r,in,ld,ld_cnt,clr_f,start,add,sub,eqz,done,shift,dec);
input clk,add,sub,start;
input  eqz;
output reg clr,ld_a,ld_q,ld_p,ld_r,ld_cnt,in,ld,clr_f,done,shift,dec;
reg [2:0] state;
parameter s0 =3'b000 ,s1=3'b001,s2=3'b010,s3=3'b011,s4=3'b100,s5=3'b101,s6=3'b110;
always@(posedge clk)
    case(state)
      s0 : #2 if(start)
			state <= s1;
	  s1 : state <= s2;	   
      s2 : state <= s3;
	  s3  : #2 if (!eqz && (add | sub) )
	         state <= s4;
			  else if (!eqz && !(add | sub) )
			  state <= s5;
			  else if (eqz)
			  state <= s6;
	  s4  : #2 if (!eqz && (add | sub) )
	          state <= s4;
			  else if (!eqz && !(add | sub) )
			  state <= s5;
			  else if (eqz)
			  state <= s6; 
	  s5  : #2 if (!eqz && (add | sub) )
	          state <= s4;
			  else if (!eqz && !(add | sub) )
			  state <= s5;
			  else if (eqz)
			  state <= s6;
	  s6 :  state <= s6;
	  default :state <= s0;
endcase
  always@(state)
	case(state)
	s0 : begin clr=1;clr_f=1;done=0;ld_cnt=1; end
	s1 : begin clr=0;clr_f=0;ld_q=1;ld_cnt=0; end
	s2 : begin ld_q=0;ld_p=1;        end
	s3 : begin ld_p=0;
			  if (!eqz && (add | sub) )
	   begin ld_r=1; shift=0; ld=1 ; dec=1 ; end
			  else if (!eqz && !(add | sub) )
		begin ld_r=0; shift=1; ld=1 ; dec=1 ; end	  
			   else if (eqz)
		begin ld_r=0; shift=0; ld=0 ; dec=0 ; done=1 ; end
		end
	s4 :	  if (!eqz && (add | sub) )
	   begin ld_r=1; shift=0; ld=1 ; dec=1 ; end
			  else if (!eqz && !(add | sub) )
		begin ld_r=0; shift=1; ld=1 ; dec=1 ; end	  
			   else if (eqz)
		begin ld_r=0; shift=0; ld=0 ; dec=0 ; done=1 ; end	 
	s5 :
			  if (!eqz && (add | sub) )
	   begin ld_r=1; shift=0; ld=1 ; dec=1 ; end
			  else if (!eqz && !(add | sub) )
		begin ld_r=0; shift=1; ld=1 ; dec=1 ; end	  
			   else if (eqz)
		begin ld_r=0; shift=0; ld=0 ; dec=0 ; done=1 ; end	
		
	s6  :begin done=1;ld_r=0; shift=0; ld=0 ; dec=0 ;  end
	default : begin clr=1;clr_f=1;done=0; end  
endcase
endmodule
