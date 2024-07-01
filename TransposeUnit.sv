module TransposeUnit #(
    parameter DATA_WIDTH = 16,
    parameter MAT_DIM = 8
)(
  input clk,
  input rstb,

  input valid_in,
  input [DATA_WIDTH-1:0] data_in,
  output ready_out,

  output valid_out,
  input ready_in,
  output [DATA_WIDTH-1:0] data_out
);

logic [DATA_WIDTH-1:0] mat_buf0 [MAT_DIM-1:0];
logic [DATA_WIDTH-1:0] mat_buf1 [MAT_DIM-1:0];
integer i;
always_ff@(posedge clk) begin
  if( ~rstb ) begin
    for (i = 0; i< MAT_DIM; i++) begin
      mat_buf0[i] <= '0;
      mat_buf1[i] <= '0;
    end
  end
  else begin
    if( valid_in & ready_out) begin
        if( buf_idx ) begin mat_buf1[cnt] <= data_in; end
        else begin          mat_buf0[cnt] <= data_in; end
    end
  end
end
// buf_idx control
// buf_idx points to the write buffer
always_ff@(posedge clk) begin
  if( ~rstb) begin buf_idx <= 1'b0; end
  else begin
    if ( cnt == MAT_DIM-1 && valid_in & ready_out) begin
        buf_idx <= ~buf_idx;
    end
  end
end
// cnt control
localparam CNT_WIDTH = $clog2(MAT_DIM);
logic [CNT_WIDTH-1:0] wr_cnt, rd_cnt;

// rd_flag control
logic [1:0] rd_flag;

always_ff@(posedge clk) begin
    if( ~rstb) begin 
        wr_cnt <= '0;
    end
    else begin
      if(valid_in & ready_out) begin
        if( wr_cnt == MAT_DIM-1) begin  wr_cnt <= '0; end
        else begin wr_cnt <= wr_cnt+1; end
      end 
    end
end

always_ff@(posedge clk) begin
    if( ~rstb) begin
        rd_flag <= 2'b0;
    end
    else begin
        if( wr_cnt == MAT_DIM-1 && valid_in & ready_out) begin
            rd_flag[buf_idx] <= 1'b1;
        end
        else if (rd_cnt == MAT_DIM-1 && rd_flag[~buf_idx] ) begin
            rd_flag[~buf_idx] <= 1'b0;
        end 
    end
end

// rd_cnt control
always_comb begin
    if( ~rstb) begin rd_cnt <= '0;   end
    else begin
        if ( rd_flag[0] | rd_flag[1] ) begin
            if( valid_out & ready_in) begin 
              if( rd_cnt == MAT_DIM-1) begin rd_cnt <= '0; end
              else begin                     rd_cnt <= rd_cnt+1; end
            end
        end
    end
end

// valid_out control
always_comb begin
  valid_out = 1'b0;
  if ( rd_flag[0] | rd_flag[1]) begin valid_out = 1'b1; end
end

// ready_out control
always_comb begin
  ready_out = 1'b0;
  if ( ~rd_flag[0] | ~rd_flag[1]) begin ready_out = 1'b1; end
end

// data_out control
// we start reading the data only when data is full
// read_cnt is needed
always_comb begin
    data_out = '0;
    if( valid_out & ready_in) begin
        if( rd_flag[0]) begin
            for ( i = 0; i < MAT_DIM; i++) begin
                data_out[rd_cnt] = {mat_buf0[i][(DATA_WIDTH*(rd_cnt+1)-1): (DATA_WIDTH*rd_cnt)]};
            end
        end
        else if(rd_flag[1]) begin
            for ( i = 0; i < MAT_DIM; i++) begin
                data_out[rd_cnt] = {mat_buf1[i][(DATA_WIDTH*(rd_cnt+1)-1): (DATA_WIDTH*rd_cnt)]};
            end
        end
    end
end
endmodule