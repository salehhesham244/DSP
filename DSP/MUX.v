module MUX (A,B,C,S,out);

parameter widthA=1;
parameter widthB=1;
parameter widthC=1;
parameter widthout=1;

input [widthA-1:0] A;
input [widthB-1:0] B;
input [widthC-1:0] C;
input [1:0] S;
output reg [widthout-1:0] out;

always @(*) begin
    case (S)
        2'b00:out<=0;
        2'b01:out<=A;
        2'b10:out<=B;
        2'b11:out<=C;
    endcase
end

endmodule //MUX