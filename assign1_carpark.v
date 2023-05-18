`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:56:03 04/12/2023 
// Design Name: 
// Module Name:    carpark 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////



module carpark(front,back,slot,clk,start,pswd,vn);
parameter n=4;
parameter PASSWORD= 4'b1010;
parameter CLOSE=1'b0 , OPEN= 1'b1;

output reg front,back;
output reg [3:0] slot;
input start,clk;
input [n-1:0] pswd,vn;

reg [n-1:0] park[0:15];
reg [n-1:0] c_pswd;
reg f,b,state,gate;
reg k=0;

always @(posedge clk)
begin
state<=gate;
end

always@ (*)
begin
case (state)
 CLOSE: begin
	 
	 if(start)
	  begin
	   front= 1'b1;
	   c_pswd= pswd;
	   gate= OPEN;
	  end
	 else if(!start)
	  begin
	   front= 1'b0;
           back=1'b0;
	   slot=0;
	   c_pswd=0;
	   gate= CLOSE;
	  end
	end

  OPEN: begin
	 c_pswd=pswd;
	 if(c_pswd== PASSWORD)
	  begin
	    park[k]= vn;
	    slot= vn;
	    k= k+1;
	    back=1'b1;
	    gate= CLOSE;
	   end
	  else if(c_pswd!= PASSWORD)
	    begin
	    back=1'b0;
	    slot=0;
	    gate= OPEN;
	   end
	end
  default : gate= CLOSE;
 endcase

end

endmodule


 



