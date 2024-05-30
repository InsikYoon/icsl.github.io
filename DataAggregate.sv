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

always@(posedge clk or negedge rst) begin
  data_buf <= data_buf <<16,
end

assign rdy_src = 1'b1;
endmodule