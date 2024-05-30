module RoundRobinArbiter (
    input        clk,
    input        rst,
    input  [3:0] req,
    output [3:0] grant
);

  logic [3:0] last_grant;
  logic [3:0] req_mod;
  always@(posedge clk or negedge rst) begin
    if (~rst)begin last_grant <= 4'b0; end
    else begin last_grant <= grant; end
  end

  always@(*) begin
    case(last_grant) begin
      4'b0001: req_mod = {req[0],req[3:1]};
      4'b0010: req_mod = {req[1:0],req[3:2]};
      4'b0100: req_mod = {req[2:0],req[3]};
      default: req_mod = req; 
    endcase

    if      (req_mod[0]) begin grant = 4'b0001; end
    else if (req_mod[1]) begin grant = 4'b0010; end
    else if (req_mod[2]) begin grant = 4'b0100; end
    else if (req_mod[3]) begin grant = 4'b1000; end
    else begin grant = 4'b0000; end
  end
  
endmodule

// a different way to implement RR arbiter

module RoundRobinArbiter (
    input        clk,
    input        rst,
    input  [3:0] req,
    output [3:0] grant
);

  logic [3:0] mask;
  logic [3:0] req_mod;
  always@(posedge clk or negedge rst) begin
    if (~rst)begin mask <= 4'b0; end
    else begin
        if ( grant == 4'b0001) begin mask <= 4'b1110; end
        else if (grant  == 4'b0010) begin mask <= 4'b1100; end
        else if (grant  == 4'b0100) begin mask <= 4'b1000; end
        else if (grant == 4'b1000) begin mask <= 4'b0000; end
     end
  end
  logic [3:0] masked_req;
  logic [3:0] grant_0, grant_1;

  assign masked_req = mask & req;
  
  always@(*) begin
    if      (masked_req[0]) begin grant_0 = 4'b0001; end
    else if (masked_req[1]) begin grant_0 = 4'b0010; end
    else if (masked_req[2]) begin grant_0 = 4'b0100; end
    else if (masked_req[3]) begin grant_0 = 4'b1000; end
    else begin grant_0 = 4'b0000; end
  end
  
  
  always@(*) begin
    if      (req[0]) begin grant_1 = 4'b0001; end
    else if (req[1]) begin grant_1 = 4'b0010; end
    else if (req[2]) begin grant_1 = 4'b0100; end
    else if (req[3]) begin grant_1 = 4'b1000; end
    else begin grant_1 = 4'b0000; end
  end
  
  assign grant = (masked_req == 4'b0000)? grant_1: grant_0;
endmodule