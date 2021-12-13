`include "cpu_if.sv"
import instr_package::*;
module top;
   bit clk;
   always #5 clk = ~clk;

   logic Din[15:0];
   logic Dout[15:0];
   logic [15:0]Address;
   logic RW;
   logic reset;

   cpu #(.N(16),.M(8)) dut 
	(.clk(clk),
           .reset(reset),
           .Din(Din),
           .Dout(Dout),
           .Address(Address),
           .RW(RW));


  memory mem (.clk(clk),
	.reset(reset),
	.Din(Dout),
	.Dout(Din),
	.Address(Address),
	.RW(RW));

   initial begin
      reset = 1'b0;
      @(posedge clk);
      reset=1'b1;
      @(posedge clk);
      reset=1'b0;
   end;      

   // Instruction properties
   assert property (
      @(posedge clk) ((dut.Instr[15:12]==ST) && (dut.uPC==1)) |-> ##2 $fell(RW)
   );

endmodule

