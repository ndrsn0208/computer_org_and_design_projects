`timescale 1ns / 1ps
module tester(clrn, clk);
    output reg clrn;
    output reg clk;
    
    initial 
    begin
        clk = 0;
        clrn = 0;
    end
    
    always begin
        #5 clk = ~clk;
    end

endmodule
