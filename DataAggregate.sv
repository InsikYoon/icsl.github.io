module DataAggregate(
  input clk,
  input rst,
  input valid_src,
  input  [15:0] data_in,
  output rdy_src,

  output [22:0] data_out,
  output        valid_sink,
  input         rdy_sink
);

logic [36:0] data_buf;

logic [3:0] cnt;


always@(posedge clk or negedge rst) begin
  if (~rst) begin cnt <= 4'b0; end
  else begin
    if ( valid_src & rdy_src) begin
      if ( cnt == 4'b1001) begin cnt <= 4'b0; end
      else begin cnt <= cnt+1; end
    end
  end  
end

always@(*) begin
  if ( cnt == 4'h0 || cnt == 4'b3 || cnt == 4'h6) begin valid_sink = 1'b0; end
  else begin valid_sink = 1'b0; end
end

logic [4:0] data_remaining;
logic [5:0] data_max;
always@(posedge clk or negedge rst) begin
  if (~rst) begin 
    data_remaining <= 5'b0;
    data_max <= 6'b0; 
  end
  else begin
    if ( data_max > 22) begin
        
    end
    else begin
      data_max <= data_remaining+ 6'h10;
    end
  end 
end

assign rdy_src = 1'b1;
endmodule