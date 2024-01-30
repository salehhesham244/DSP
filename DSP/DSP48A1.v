module DSP48A1 #(
    parameter A0REG=0,//control signal of level one of input A.
    parameter A1REG=1,//control signal of level two of input A.
    parameter B0REG=0,//control signal of level one of input B.
    parameter B1REG=1,//control signal of level two of input B.
    parameter CREG=1,//control signal of level one of input C.
    parameter DREG=1,//control signal of level one of input D.
    parameter MREG=1,//control signal of level three of signal M.
    parameter PREG=1,//control signal of level five of output P.
    parameter CARRYINREG=1,//control signal of level three of carry_in (CYI).
    parameter CARRYOUTREG=1,//control signal of level four of carry_out (CYO).
    parameter OPMODEREG=1,//control signal of all reg of opmode bits.
    parameter CARRYINSEL="OPMODE5",//control signal of CYI to select if choose opmode5 or carryin.
    parameter B_INPUT="DIRECT",//control signal to select which to pass Bor BCIN.
    parameter RSTTYPE="SYNC"//control signal to select the type of the resets to be synchrouns or asynchronous.
)(
    input  clk,
    input  cin,//input carry_in.
    input  rsta,//reset of input A
    input  rstb,//reset of input B
    input  rstm,//reset of signal M.
    input  rstp,//reset of output P.
    input  rstc,//reset of input C.
    input  rstd,//reset of input D.
    input  rstcin,//reset of the carry in .
    input  rstopmode,//reset of the opmode signals.
    input  cea,//clock enable of input A.
    input  ceb,//clock enable of input B.
    input  cem,//clock enable of signal M.
    input  cep,//clock enable of output P.
    input  cec,//clock enable of input C.
    input  ced,//clock enable of input D.
    input  cecin,//clock enable of the carry in.
    input  ceopmode,//clock enable of the opmode signals.
    input  [17:0]A,//input A.
    input  [17:0]B,//input B.
    input  [17:0]D,//input D.
    input  [47:0]C,//input C.
    input  [7:0]opmode,//control signals.
    input  [17:0]BCIN,//cascade input for port B.
    input  [47:0]PCIN,//cascade input for port p.
    output  CARRYOUT,//carry out of the post add/sub. 
    output  CARRYOUTF,//the copy of the carry out signal.
    output  [17:0]BCOUT,//cascade output for port B.
    output  [47:0]PCOUT,//cascade output for port p. 
    output  [47:0]P,//output P.
    output  [35:0]M // output signal. 
);
//numbers after any mux describe the number of the level.
wire [17:0] Dreg_out,B0reg_out,B1reg_out,A0reg_out,A1reg_out,Dout_mux1,B0out_mux1,B1out_mux2,A0out_mux1,A1out_mux2;//output of each register with it's name and the mux of it.
wire [47:0] Creg_out,Cout_mux1;
wire opm4_out,opm4_out_mux,opm5_out,opm5_out_mux,opm6_out,opm6_out_mux,opm7_out,opm7_out_mux;//output of the mux of the opmode bits with it's name.
wire [1:0] opm01_out,opm01_mux_out,opm23_out,opm23_out_mux;
//output of the first add/sub.
wire [17:0] Pre_addsub_out;
//outputs of the multiplier and the reg with mux.
wire [35:0] mult_out,Mreg_out,Mout_mux3;
//outputs of the reg and mux of the carry in.
wire CYIreg_out,CYIout_mux3;
//output of the post add/sub with it's reg and mux and carry out of it.
wire [47:0] post_addsub_out,preg_out,pout_mux5;
wire post_addsub_carry,CYOreg_out,CYOout_mux4;
//outputs of X&Z muxs.
wire [47:0]out_X,out_Z;

DMUX #(18,"SYNC") dutD (clk,rstd,ced,D,DREG,Dreg_out,Dout_mux1);
DMUX #(18,"SYNC") dutB0 (clk,rstb,ceb,(B_INPUT=="DIRECT")?B:(B_INPUT=="CASCADE")?BCIN:0,B0REG,B0reg_out,B0out_mux1);
DMUX #(18,"SYNC") dutA0 (clk,rsta,cea,A,A0REG,A0reg_out,A0out_mux1);
DMUX #(48,"SYNC") dutC (clk,rstc,cec,C,CREG,Creg_out,Cout_mux1);
DMUX #(18,"SYNC") dutB1 (clk,rstb,ceb,(opm4_out_mux==0)?B0out_mux1:Pre_addsub_out,B1REG,B1reg_out,B1out_mux2);
DMUX #(18,"SYNC") dutA1 (clk,rstc,cea,A0out_mux1,A1REG,A1reg_out,A1out_mux2);
DMUX #(36,"SYNC") dutM (clk,rstm,cem,mult_out,MREG,Mreg_out,Mout_mux3);
DMUX #(1,"SYNC") dutCYI (clk,rstcin,cecin,(CARRYINSEL=="OPMODE5")?opm5_out:(CARRYINSEL=="CARRYIN")?cin:0,CARRYINREG,CYIreg_out,CYIout_mux3);
DMUX #(1,"SYNC") dutCYO (clk,rstcin,cecin,post_addsub_carry,CARRYOUTREG,CYOreg_out,CYOout_mux4);
DMUX #(48,"SYNC") dutP (clk,rstp,cep,post_addsub_out,PREG,preg_out,pout_mux5);
DMUX #(2,"SYNC") opm01 (clk,rstopmode,ceopmode,opmode[1:0],OPMODEREG,opm01_out,opm01_out_mux);
DMUX #(2,"SYNC") opm23 (clk,rstopmode,ceopmode,opmode[3:2],OPMODEREG,opm23_out,opm23_out_mux);
DMUX #(1,"SYNC") opm4 (clk,rstopmode,ceopmode,opmode[4],OPMODEREG,opm4_out,opm4_out_mux);
DMUX #(1,"SYNC") opm5 (clk,rstopmode,ceopmode,opmode[5],OPMODEREG,opm5_out,opm5_out_mux);
DMUX #(1,"SYNC") opm6 (clk,rstopmode,ceopmode,opmode[6],OPMODEREG,opm6_out,opm6_out_mux);
DMUX #(1,"SYNC") opm7 (clk,rstopmode,ceopmode,opmode[7],OPMODEREG,opm7_out,opm7_out_mux);

MUX #(36,48,48,48) X (Mout_mux3,P,{D[11:0],A1out_mux2[17:0],B1out_mux2[17:0]},opm01_out_mux,out_X);
MUX #(48,48,48,48) Z (PCIN,P,Cout_mux1,opm23_out_mux,out_Z);

assign Pre_addsub_out=(!opm6_out_mux)?(Dout_mux1+B0out_mux1):(Dout_mux1-B0out_mux1);
assign {post_addsub_carry,post_addsub_out}=(!opm7_out_mux)?(out_X+out_Z+CYIout_mux3):(out_Z-(out_X+CYIout_mux3));
assign mult_out=B1out_mux2*A1out_mux2;

assign BCOUT=B1out_mux2;
assign M=Mout_mux3;
assign CARRYOUT=CYOout_mux4;
assign CARRYOUTF=CARRYOUT;
assign p=pout_mux5;
assign Pcout=P;

endmodule //DSP48A1
