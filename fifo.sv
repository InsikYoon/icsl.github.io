module fifo (
    input clk,
    input rst,
    input w_valid,
    input [7:0] data_in,
    input r_valid,
    output reg [7:0] data_out,
    output full,
    output empty,
    output [3:0] fill_level
)

  logic [15:0][7:0] mem;
  // w_ptr points to the next entry that data will be written
  // r_ptr points to the current entry that data is read
  logic [4:0] w_ptr, r_ptr;
  logic full, empty;

  always@(posedge clk or negedge rst) begin
    if (~rst) begin // initialize mem to 0 when reset
        for ( int i = 0; i<16; i++) begin mem[i] <= 8'b0; end
        w_ptr <= 5'b0;
        r_ptr <= 5'b0;
    end
    else begin
        if ( w_valid & ~full ) begin 
            mem[w_ptr] <= data_in;
            w_ptr <= w_ptr+1; 
        end
        if ( r_valid & ~empty) begin
            r_ptr <= r_ptr+1;
        end
    end
  end

assign data_out = mem[r_ptr];
  //determine empty and full condition
  // empty when w_ptr == r_ptr
  // full when {~w_ptr[4], w_ptr[3:0]} == r_ptr
  always@(*) begin
    full = 1'b0;
    empty = 1'b0;
    if ( {~w_ptr[4], w_ptr[3:0]} == r_ptr) begin full = 1'b1; end
    if ( w_ptr == r_ptr ) begin empty = 1'b1; end
  end

assign fill_level = ( w_ptr[4] == r_ptr[4])? w_ptr - r_ptr+1: (16-r_ptr)+w_ptr[3:0];
// put SVA assertion
// full & empty cannot be asserted at the same time
// w_valid cannot be high when full
// r_valid cannot be high when empty
// fill value cannot be negative or more than fifo depth
assert_property ((@posedge clk) w_valid == 1'b1 |-> full == 1'b0);
assert_property ((@posedge clk) r_valid == 1'b1 |-> empty == 1'b0);
assert_property ((@posedge clk) full & empty == 1'b0);
assert_property ((@posedge clk) fill_level != -1 && fill_level < 17);
endmodule