module SeqInput #(
    parameter PE_DIM = 3,
    parameter DATA_WIDTH = 16
) (
    input clk,
    input rstb,
    input [7:0] addr,
    input we,
    input [DATA_WIDTH-1:0] data_in,
    input init,                                 // init signal to drive output signals
    
    output [PE_DIM-1:0] valid,
    output [DATA_WIDTH-1:0] out_data [PE_DIM-1:0]
);

// memory width = DATA_WIDTH*PE_DIM bit
//  address      data
//     0         in0,  in1,  in2, 
//     1         in3,  in4,  in5, 
//     2         in6,  in7,  in8, 
//     3         in9, in10, in11, 
//    ...        ...

// PE_DIM = 3, I want to do matrix multiplication of two matrices with PE_DIM
//   t4    t3    t2    t1    t0
//               in7   in4   in0
//         in8   in5   in1
//   in9   in6   in2

// I need to hold data from addr 0 for three cycles( until in2 goes out at t2)
// for any other data from any address, we need to hold it for three cycles
// because we set our PE_DIM = 3.

// then we need 3 intermediate buffers to hold data
// as soon as buffer 0 can have new data at t2, we need to issue mem read to hold
// line from address 4.

// it will be like this;
//         t0     t1     t2     t3
// buf0   line0  line0  line0  line4
// buf1          line1  line1  line1   line5 
// buf2                 line2  line2   line2    line6

// what does this mean?
// this means that we issue memory read at every cycle and assign it to different buffer
// mem_read of addr 0 -> buf0
// mem_read of addr 1 -> buf1
// mem_read of addr 2 -> buf2
// mem_read of addr 4 -> buf0
// mem_read of addr 5 -> buf1
// mem_read of addr 6 -> buf2

// let's look how we will supply data from intermediate buffers.
// at t0, we set out_data[0] = buf0[0]
// at t1, we set out_data[0] = buf0[1]
//               out_data[1] = buf1[0]
// at t2, we set out_data[0] = buf0[PE_DIM-1]
//               out_data[1] = buf1[1]
//               out_data[2] = buf2[0]
// at t3, we set out_data[0] = buf0[0]
//               out_data[1] = buf1[PE_DIM-1]
//               out_data[2] = buf2[1]

// we have a counter cnt and it will start at t0 and it will iterate from 0 to PE_DIM-1
// then it will become;
// at t0, we set out_data[0] = buf0[cnt]                  // cnt = 0
// at t1, we set out_data[0] = buf0[cnt]                  // cnt = 1
//               out_data[1] = buf1[(cnt-1)%PE_DIM]
// at t2, we set out_data[0] = buf0[cnt]                  // cnt = 2
//               out_data[1] = buf1[(cnt-1)%PE_DIM]
//               out_data[2] = buf2[(cnt-2)%PE_DIM]
// at t3, we set out_data[0] = buf0[cnt]                  // cnt = 0
//               out_data[1] = buf1[(cnt-1)%PE_DIM]
//               out_data[2] = buf2[(cnt-2)%PE_DIM]

// we still need to index out_data to assign correct data.
// we can do this and indexing data from buf with one counter

// counter will start when init is asserted and will stop when 
// we hit the end of input sequence
// at t0, we set out_data[0] = buf0[cnt%PE_DIM]                  // cnt = 0
// at t1, we set out_data[0] = buf0[cnt%PE_DIM]                  // cnt = 1
//               out_data[1] = buf1[(cnt-1)%PE_DIM]
// at t2, we set out_data[0] = buf0[cnt%PE_DIM]                  // cnt = 2
//               out_data[1] = buf1[(cnt-1)%PE_DIM]
//               out_data[2] = buf2[(cnt-2)%PE_DIM]
// at t3, we set out_data[0] = buf0[cnt%PE_DIM]                  // cnt = 3
//               out_data[1] = buf1[(cnt-1)%PE_DIM]
//               out_data[2] = buf2[(cnt-2)%PE_DIM]


localparam MEM_WIDTH = DATA_WIDTH*PE_DIM;  
localparam MEM_DEPTH = 128;

// change this mem to real sram.  
logic [MEM_WIDTH-1:0] mem [MEM_DEPTH-1:0];
logic [MEM_WIDTH-1:0] int_buf [PE_DIM-1:0];

localparam END_SEQ = 4;
logic duration;
always_ff@(posedge clk) begin
  if(~rstb) begin duration <= 1'b0; end
  else begin
    if(init) begin duration <= 1'b1; end
    else if (cnt == END_SEQ) begin duration <= 1'b0; end
  end
end

// generate counter signal
logic [7:0] cnt;
  always_ff@(posedge clk) begin
    if (~rstb) begin cnt <= '0; end
    else begin
        if (cnt < END_SEQ && duration) begin 
            cnt <= cnt+1; 
        end
        else begin cnt <= '0; end
    end
  end

// read logic
logic [$clog2(MEM_DEPTH)-1:0] rd_addr;
logic [MEM_WIDTH-1:0] rd_data; 
always_ff@(posedge clk) begin
  if( ~rstb) begin 
    rd_addr <= '0;
    rd_data <= '0;
  end
  else begin
    rd_addr <= cnt;

end

// insert data into intermediate buffer
always_ff@(posedge clk)


endmodule