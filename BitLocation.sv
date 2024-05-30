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
  
  // don't initiate accepting the data 
  // if there's one outstanding data that needs to be sent
  // In this case, rdy_src should not be asserted to 1 until vld_sink & rdy_sink == 1'b1
  
  // so first job is to detect if there's outstanding data
  // if there is one, hold rdy_src to 0
  // else set rdy_src to 1

  // second job is to determine the bit position where 1 is set.
  // this could be finding 1 from MSB or LSB. In here, I will implement finding one from MSB
  // for better timing, I will dedicate one clock cycle for finding index

  // step 1. controlling rdy_src and set outstanding bit to 1

  logic outstanding;
  logic [7:0] data_ff;
  // controlling outstanding and capturing data
  always@(posedge clk or negedge rst) begin
    if(~rst) begin 
        outstanding <= 1'b0; 
    end
    else begin 
        if (vld_src & rdy_src) begin outstanding <= 1'b1; end
        else if (outstanding & vld_sink & rdy_sink) begin outstanding <= 1'b0; end
    end
  end

  // we don't need rst for data_ff. we know when data_ff is valid
  always@(psoedge clk or negedge rst) begin
    if ( ~rst) begin data_ff <= data_in; end
    else begin
      if ( vld_src & rdy_src) begin data_ff <= data_in; end
    end
  end

  // controlling rdy_src
  always@(*) begin 
    rdy_src = 1'b0;
    if ( ~outstanding ) begin rdy_src = 1'b1; end
  end

  // finding one from data
  always@(*) begin // synopsys parallel full case
    index = 3'b0;
    case(data_ff)
      8'b1xxx_xxxx: index = 3'h7;
      8'b01xx_xxxx: index = 3'h6;
      8'b001x_xxxx: index = 3'h5;
      8'b0001_xxxx: index = 3'h4;
      8'b0000_1xxx: index = 3'h3;
      8'b0000_01xx: index = 3'h2;
      8'b0000_001x: index = 3'h1;
      8'b0000_0001: index = 3'h0;
      default: index = 3'h0;
      endcase 
  end
  
  // controlling vld_sink
  always@(*) begin
    vld_src = 1'b0;
    if (outstanding) begin vld_src = 1'b1; end
    else begin vld_src = 1'b0; end
  end

endmodule