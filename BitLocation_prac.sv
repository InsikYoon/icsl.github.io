module dut   (
    input wire 					clk,
    input wire 					rst,
   	
    input  wire 		    	vld_src,   // valid signal from source
    input  wire	[7:0] 			data_in,   // data bus from source
    output logic  		       	rdy_src,   // ready signal to source
   
    output logic [2:0]  		index,     // bit position where 1 is set
    output logic				vld_sink,  // valid signal to sink
    input  wire				   	rdy_sink   // ready signal from sink
    
  );
  
  /*
  1. rdy_sink = 0, rdy_src & vld_src = 1 -> rdy_src should be 0 on the next cycle, hold data in a buffer
  2. when rdy_sink = 0->1, rdy_src should be 1 on the next cycle and data in a buffer must be processed.
  3. if rdy_sink = 1, rdy_src = 1
  */

  // rdy_src control
  always_ff@(posedge clk) begin
    if(rst) begin rdy_src <= 1'b0; end
    else begin  rdy_src <= rdy_sink; end
  end

assign index = (data_valid[0] & data_valid[1] & ~buf_idx) ? idx_data[0] :
               (data_valid[0] & ~data_valid[1] & buf_idx) ? idx_data[0] :
               (~data_valid[0] & data_valid[1] & ~buf_idx) ? idx_data[1] : idx_data[0];
               
/*
  if there's data to output, then set it to 1. 
*/
  // vld_sink control
  always_comb begin
    vld_sink = |data_valid;
  end

// two buffers
logic buf_idx;
always_ff@(posedge clk) begin
  if(rst) begin buf_idx <= 1'b0; end
  else begin
    if( vld_src & rdy_src) begin buf_idx <= ~buf_idx; end
  end
end

logic [1:0] data_valid;
logic [$clog2(DATA_WIDTH)-1:0] idx_data [1:0];
//data insertion
always_ff@(posedge clk) begin
    if( rst) begin
        data_valid <= 1'b0;
        idx_data[0] <= '0;
        idx_data[1] <= '0;
    end
    else begin
        if( vld_src & rdy_src) begin
            idx_data[buf_idx]   <= index_in;
            data_valid[buf_idx] <= 1'b1;
        end

        if( vld_sink & rdy_sink) begin
            if ( data_valid == 2'b11 ) begin data_valid[buf_idx] <= 1'b0; end
            else begin data_valid[~buf_idx] <= 1'b0; end
        end
    end
end

// figuring out the index
logic [$clog2(DATA_WIDTH)-1:0] index_in;
always_comb begin
  found = 1'b0;
  if( vld_src & rdy_src) begin
    for (i = 0; i< DATA_WIDTH; i++) begin
      if( data_in[i] & ~found) begin
        index_in = i;
        found = 1'b0;
      end
    end
  end
end
// assign  
endmodule
