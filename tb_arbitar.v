
`timescale 1ns/1ps
`include "arbitar.v"
module tb_arbitar;
  reg clock,reset,req_0,req_1;
  wire gnt_0, gnt_1;
  
  always #10 clock = ~clock;
  
  arbitar u1(clock,reset,req_0, req_1, gnt_0, gnt_1);
  
  initial
    begin
      $dumpfile("arbitar.vcd"); 
      $dumpvars;
      //initializing all the inputs
      clock <= 0;
      reset <= 0;
      req_0 <= 0;
      req_1 <= 0;

      //giving actual test vectors
      #15 reset <= 1;
      #10 reset <= 0;
      
      #10 req_0 <= 1;
      #25 req_0 <= 0;
      
      #15 req_1 <= 1;
      #10 req_1 <= 0;
      
      #10 req_0 <=1;
      req_1 <= 1;

      #10 req_0 <= 0;
      req_1 <= 1;
      
      #10 req_0 <= 0;
      req_1 <= 0;

      
      #100 $finish;
    end
endmodule