// This module computes add and multiplication of two fixed point numbers 
// which format is Q4.4, 4 bits for exponenents, 4 bits for fractions

// by running following matlab code, you can get test cases

// a = fi(-5 + (5+5)*rand(1000,1), 1,4,4); 1000 random input a from -5 to 5
// b = fi(-5 + (5+5)*rand(1000,1), 1,4,4); 1000 random input b from -5 to 5
// res_add = a+b;                          a+b
// res_mult = a.*b;                        a*b since it is mult, exponent bit  = 8, fraction bit  = 8

module fixed_point_arith #( 
    parameter  EX_WIDTH = 4,
    parameter  FRAC_WIDTH = 4
)
(
    input                                  clk,
    input                                  resetn,
    input                                  op,     // if 0: mult, 1: add
    input [EX_WIDTH+FRAC_WIDTH-1:0]        op_a,
    input [EX_WIDTH+FRAC_WIDTH-1:0]        op_b,
    output logic [EX_WIDTH+FRAC_WIDTH-1:0] res
);


always_ff(posedge clk or negedge resetn) begin
  if ( resetn == 1'b0 ) begin
    res <= '0;
  end    
  else begin
      if ( op == 1'b0 ) begin // add case
        // fill this logic
        //
        // res <= 
      end
      else begin  // mult case
        // fill this logic
        //
        // res <= 
      end
  end
end
    
endmodule