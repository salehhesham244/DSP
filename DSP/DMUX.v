module DMUX (clk,rst,E,D,S,Q,out);

parameter width=1;
parameter RSTTYPE="SYNC";

input  clk,rst,E,S;
input [width-1:0] D;
output reg [width-1:0] Q;
output [width-1:0]out;  

generate
    if (RSTTYPE=="SYNC") begin
        always @(posedge clk) begin
       if(rst)
        Q<=0;
        else begin
        if (E) begin
        Q<=D;       
        end
        end
        end
    end
    else begin
        always @(posedge clk or posedge rst) begin
       if(rst)
        Q<=0;
        else begin
        if (E) begin
        Q<=D;       
        end
        end
        end
    end
endgenerate
 
 assign out=(S==1)?Q:D;
 
endmodule //DMUX