`timescale 1ns / 1ps
module testbench();
    wire clrn, clk;
    
    top c
    (
        .clrn   (clrn      ),
        .clk    (clk       )     
    );
    
    tester t
    (
        .clrn   (clrn      ),
        .clk    (clk       )
    );
    
    initial
    begin
        $monitor ($time,"clrn=%b, clk=%b", clrn, clk);
    end
        
endmodule
