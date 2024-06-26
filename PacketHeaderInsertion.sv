module PacketHeaderInsertion # (
    parameter HEADER0 = 16'hdead,
    parameter HEADER1 = 16'hbeef,
    parameter HEADER2 = 16'haaaa    
    )(
    input clk,
    input rstb,
    input sof_in,
    input eof_in,
    input [63:0] data_in,
    input [1:0] valid_cnt_in,

    output sof_out,
    output eof_out,
    output [63:0] data_out,
    output [1:0] valid_cnt_out
);

/* 
 sof      0001 0 0 0
 eof      0000 0 0 0 1
 datain   000d0d1d2d3d4
 data_ff0 000  d0d1d2d3d40 0
 data_ff1 000    d0d1d2d3d40

 sof_ff   0000 1 0 0 0 0 0
 eof_out  0000 0 0 0 0 0 0 1  
 data_out 0000 h0d0d1d2d3d4
*/ 
logic sof_ff;
logic eof_ff0, eof_ff1, eof_ff2;
logic [63:0] data_ff0, data_ff1;
logic tracking;
// 2 stage data buffer
always_ff@(posedge clk) begin
    if(~rstb) begin
        sof_ff   <= '0; 
        eof_ff0  <= '0;
        eof_ff1  <= '0;
        eof_ff2  <= '0;
        data_ff0 <= '0;
        data_ff1 <= '0;
    end
    else begin
        sof_ff   <= sof_in;
        eof_ff0  <= eof_in,
        eof_ff1  <= eof_ff0;
        eof_ff2  <= eof_ff1;
        data_ff0 <= data_in;
        data_ff1 <= data_ff0; 
    end
end
always_ff@(posedge clk) begin
  if(~rstb) begin tracking <= 1'b0; end
  else begin
    if( sof ) begin tracking <= 1'b1; end
    else if (eof_ff2) begin tracking <= 1'b0; end
  end
end
assign sof_out = sof_ff;
assign eof_out = eof_ff2;
always_ff@(posedge clk) begin
    if(~rstb) begin
        data_out <= '0;
    end
    else begin
        if(sof_in & ~tracking ) begin
          data_out <= {HEADER0, HEADER1};
        end
        else if (tracking) begin
          if( sof_ff & ~sof_in) begin
            data_out <= {HEADER2, data_ff0[63:48]};
          end
          else begin
            data_out <= {data_ff1[47:0], data_ff0{63:48}};
          end
        end
        else begin
            data_out <= '0;
        end
    end
end


endmodule